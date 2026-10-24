import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/nexus_plan.dart';
import '../utils/version_utils.dart';
import 'endorse_info_store.dart';

/// Motivo por el que no se pudo cambiar el endorse de un mod.
enum EndorseFailure {
  /// El usuario no ha introducido su API key.
  noApiKey,

  /// Nexus rechazó la API key (401).
  invalidKey,

  /// Nexus solo deja endorsar mods descargados con la cuenta.
  notDownloaded,

  /// Hay que esperar 15 min desde la descarga (TOO_SOON_AFTER_DOWNLOAD).
  tooSoon,

  /// El usuario es el autor del mod.
  ownMod,

  /// Límite de solicitudes alcanzado (429).
  rateLimited,

  /// El mod ya no existe en Nexus (404).
  notFound,

  /// Sin conexión / tiempo de espera agotado.
  network,

  /// Cualquier otro error.
  unknown,
}

/// Resultado de endorsar (o quitar el endorse de) un mod.
class EndorseResult {
  final bool ok;

  /// 'Endorsed' o 'Abstained' cuando [ok] es true.
  final String? status;
  final EndorseFailure? failure;

  const EndorseResult.success(this.status) : ok = true, failure = null;
  const EndorseResult.failure(this.failure) : ok = false, status = null;
}

class _FilesCacheEntry {
  final Map<String, dynamic> data;
  final DateTime time;
  _FilesCacheEntry(this.data, this.time);
}

/// Resultado interno de la construcción de la galería de un mod.
class _GalleryResult {
  final List<Map<String, dynamic>> items;

  /// true solo si la lista completa de imágenes se obtuvo de Nexus. Si es
  /// false (sin red, API caída...) `items` puede traer solo la portada y el
  /// llamador NO debe dar la galería por "terminada".
  final bool complete;
  _GalleryResult(this.items, this.complete);
}

class _CachedModData {
  final Map<String, dynamic> data;
  final DateTime time;
  _CachedModData(this.data, this.time);
}

/// Motivo por el que no se pudo resolver el enlace de descarga de un nxm://.
enum NxmLinkFailureKind {
  noApiKey,
  invalidLink,
  unauthorized, // 401: API key rechazada
  forbidden, // 403: enlace caducado / key o expires inválidos
  notFound, // 404
  rateLimited, // 429
  server, // 5xx
  network, // sin conexión / timeout
  noLinks, // Nexus no devolvió ningún mirror
}

class NxmLinkException implements Exception {
  final NxmLinkFailureKind kind;
  final int? statusCode;
  final String detail;
  const NxmLinkException(this.kind, {this.statusCode, this.detail = ''});

  @override
  String toString() =>
      'NxmLinkException(${kind.name}${statusCode != null ? ' $statusCode' : ''}) $detail';
}

/// Resultado de resolver un nxm://: TODOS los mirrors del CDN (el primero es
/// el preferido) más los datos del archivo.
class NxmDownloadInfo {
  final List<String> urls;
  final String fileName;
  final String modId;
  final String version;

  /// Tamaño exacto según la API (para el progreso y las comprobaciones).
  final int? sizeBytes;

  const NxmDownloadInfo({
    required this.urls,
    required this.fileName,
    required this.modId,
    required this.version,
    this.sizeBytes,
  });

  String get url => urls.first;
}

class _NxmRef {
  final String game;
  final String modId;
  final String fileId;
  final String? key;
  final String? expires;
  const _NxmRef(this.game, this.modId, this.fileId, this.key, this.expires);
}

class NexusApiService {
  // --- VARIABLES ESTÁTICAS PARA LÍMITES GLOBALES ---
  static String dailyRemaining = 'N/A';
  static String hourlyRemaining = 'N/A';

  // Límites REALES de la cuenta, tal como los informa Nexus en cada respuesta
  // (x-rl-daily-limit / x-rl-hourly-limit). No cambian al consumir solicitudes.
  static String dailyLimit = 'N/A';
  static String hourlyLimit = 'N/A';

  // --- FUNCIÓN INTERNA PARA ACTUALIZAR LOS LÍMITES ---
  static void _updateLimitsFromHeaders(http.Response response) {
    if (response.headers.containsKey('x-rl-daily-remaining')) {
      dailyRemaining = response.headers['x-rl-daily-remaining']!;
    }
    if (response.headers.containsKey('x-rl-hourly-remaining')) {
      hourlyRemaining = response.headers['x-rl-hourly-remaining']!;
    }
    // Solo se guardan si son números válidos y mayores que 0.
    final dLimit = int.tryParse(response.headers['x-rl-daily-limit'] ?? '');
    if (dLimit != null && dLimit > 0) dailyLimit = dLimit.toString();
    final hLimit = int.tryParse(response.headers['x-rl-hourly-limit'] ?? '');
    if (hLimit != null && hLimit > 0) hourlyLimit = hLimit.toString();
  }

  static Future<bool> validateApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('https://api.nexusmods.com/v1/users/validate.json'),
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response); // <-- Actualizamos aquí
      return response.statusCode == 200;
    } catch (e) {
      print('Error validating API key: $e');
      return false;
    }
  }

  // Caché corta de los datos del mod: instalar un mod, cachear su portada y
  // cachear su galería consultan el mismo mod seguidos; así se hace una sola
  // vez (REST v1 + GraphQL) en lugar de tres.
  static final Map<String, _CachedModData> _modDataCache = {};
  static const Duration _modDataCacheTtl = Duration(minutes: 10);

  /// Datos del mod. Devuelve (entre otros):
  ///  * `gallery`: lista COMPLETA de imágenes `[{image, thumbnail}, ...]` en el
  ///    orden de la página del mod (o solo la portada si GraphQL falla).
  ///  * `galleryComplete`: true si la lista completa se obtuvo de Nexus.
  ///  * `gameId`: id numérico del juego (lo pide GraphQL).
  static Future<Map<String, dynamic>?> fetchNexusModData(String nexusId, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) return null;

    final cached = _modDataCache[nexusId];
    if (cached != null && DateTime.now().difference(cached.time) < _modDataCacheTtl) {
      return cached.data;
    }

    final headers = {'apikey': apiKey, 'accept': 'application/json'};

    try {
      final modDetailsUrl = Uri.parse(
        'https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId.json',
      );
      var response = await http.get(modDetailsUrl, headers: headers);
      _updateLimitsFromHeaders(response);

      if (response.statusCode == 200) {
        final modDetails = json.decode(response.body);
        final pictureUrl = modDetails['picture_url'] as String?;
        String? summary = modDetails['summary'] as String?;
        if (summary != null) summary = summary.replaceAll('<br />', '\n');
        String? description = modDetails['description'] as String?;
        if (description != null) description = description.replaceAll('<br />', '\n');
        final author = modDetails['author'] as String?;
        // Título de la página del mod (sirve para identificar ediciones).
        final modName = (modDetails['name'] as String?)?.trim();
        final gameId = int.tryParse((modDetails['game_id'] ?? '').toString());

        final galleryResult = await _buildFullGallery(
          nexusId: nexusId,
          gameId: gameId,
          pictureUrl: pictureUrl,
          apiKey: apiKey,
        );

        final result = <String, dynamic>{
          'gallery': galleryResult.items.isEmpty ? null : galleryResult.items,
          'galleryComplete': galleryResult.complete,
          'gameId': gameId,
          'summary': summary,
          'author': author,
          'description': description,
          'modName': modName,
        };

        // Se cachea siempre (10 min): instalar, cachear portada y cachear
        // galería consultan el mismo mod seguidos y así no se repite la
        // petición. El reintento de una galería incompleta lo controla
        // `galleryAttemptAt` en el nexus_info.json del mod.
        _modDataCache[nexusId] = _CachedModData(result, DateTime.now());
        return result;
      }
      return null;
    } catch (e) {
      print("Error fetchNexusModData: $e");
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  //  GALERÍA COMPLETA (GraphQL v2)
  //
  //  La API REST (v1) solo da `picture_url` y el OpenAPI v3.0.0 no tiene
  //  endpoint de galería: la lista completa de imágenes de la página del mod
  //  solo se puede pedir por GraphQL v2, con la misma API key.
  // ---------------------------------------------------------------------------

  static const String _graphqlUrl = 'https://api.nexusmods.com/v2/graphql';

  /// Fallos seguidos al pedir galerías. Si el esquema de GraphQL no coincide
  /// (o no hay red) no se sigue insistiendo con cada mod: se reintenta en el
  /// próximo arranque.
  static int _galleryFailStreak = 0;
  static const int _galleryMaxFailStreak = 3;

  static Future<_GalleryResult> _buildFullGallery({
    required String nexusId,
    required int? gameId,
    required String? pictureUrl,
    required String apiKey,
  }) async {
    final items = <Map<String, dynamic>>[];
    var complete = false;

    if (gameId != null) {
      final urls = await fetchModGalleryImages(
        nexusId: nexusId,
        gameId: gameId,
        apiKey: apiKey,
      );
      if (urls != null) {
        complete = true;
        for (final url in urls) {
          if (!items.any((e) => e['image'] == url)) {
            items.add({'image': url, 'thumbnail': url});
          }
        }
      }
    }

    // Respaldo: sin lista de GraphQL, al menos la portada (comportamiento
    // anterior). Si la lista existe, la portada ya es su primera imagen.
    if (items.isEmpty && pictureUrl != null && pictureUrl.isNotEmpty) {
      items.add({'image': pictureUrl, 'thumbnail': pictureUrl});
    }
    return _GalleryResult(items, complete);
  }

  /// URLs de TODAS las imágenes de la galería del mod, en el orden de la
  /// página. Lista vacía = el mod no tiene imágenes (o ya no es accesible).
  /// null = no se pudo obtener (error de red/API/esquema): el llamador debe
  /// reintentar más tarde.
  ///
  /// La galería NO es un campo de `Mod`: está en la consulta de nivel superior
  /// `media`, que se filtra por juego y mod. Como el esquema no está
  /// documentado con detalle, la consulta se CONSTRUYE por introspección.
  static Future<List<String>?> fetchModGalleryImages({
    required String nexusId,
    required int gameId,
    required String apiKey,
  }) async {
    if (_galleryFailStreak >= _galleryMaxFailStreak) return null;

    _mediaPlan ??= await _buildMediaPlan(apiKey);
    final plan = _mediaPlan;
    if (plan == null) {
      _galleryFailStreak++;
      return null;
    }

    final urls = await _runMediaPlan(plan, nexusId, gameId, apiKey);
    if (urls == null) {
      _galleryFailStreak++;
      return null;
    }
    _galleryFailStreak = 0;
    print('[NexusGallery] mod $nexusId: ${urls.length} imágenes (media)');
    return urls;
  }

  // --- Introspección -------------------------------------------------------

  static _MediaPlan? _mediaPlan;

  static const String _typeRefFragment =
      r'fragment TR on __Type { name kind ofType { name kind ofType { name kind '
      r'ofType { name kind ofType { name kind } } } } }';

  static String? _namedType(dynamic t) {
    String? name;
    while (t is Map) {
      if (t['name'] != null) name = t['name'].toString();
      t = t['ofType'];
    }
    return name;
  }

  /// `[Foo!]!` -> texto GraphQL para declarar una variable de ese tipo.
  static String _typeRefToString(dynamic t) {
    if (t is! Map) return 'String';
    final kind = t['kind']?.toString();
    if (kind == 'NON_NULL') return '${_typeRefToString(t['ofType'])}!';
    if (kind == 'LIST') return '[${_typeRefToString(t['ofType'])}]';
    return t['name']?.toString() ?? 'String';
  }

  static Future<Map<String, dynamic>?> _introspectType(String name, String apiKey) async {
    final body = await _graphql(
      'query(\$n: String!) { __type(name: \$n) { name kind '
      'fields { name args { name type { ...TR } } type { ...TR } } '
      'inputFields { name type { ...TR } } '
      'possibleTypes { name } enumValues { name } } } $_typeRefFragment',
      {'n': name},
      apiKey,
    );
    final data = body?['data'];
    final t = data is Map ? data['__type'] : null;
    return t is Map ? Map<String, dynamic>.from(t) : null;
  }

  static List<Map<String, dynamic>> _mapList(dynamic v) =>
      v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];

  static Map<String, dynamic>? _byName(List<Map<String, dynamic>> list, String name,
      {bool ignoreCase = false}) {
    for (final e in list) {
      final n = e['name']?.toString() ?? '';
      if (ignoreCase ? n.toLowerCase() == name.toLowerCase() : n == name) return e;
    }
    return null;
  }

  static void _logSchemaHint(String why, {List<String>? modFields, List<String>? mediaArgs}) {
    print('[NexusGallery] Esquema GraphQL no reconocido: $why');
    if (modFields != null) print('[NexusGallery]   campos de Mod: ${modFields.join(', ')}');
    if (mediaArgs != null) print('[NexusGallery]   argumentos de media: ${mediaArgs.join(', ')}');
  }

  /// Averigua cómo se llama el filtro de `media`, qué campos tiene y qué
  /// forma tienen los resultados. Devuelve null si no encaja.
  static Future<_MediaPlan?> _buildMediaPlan(String apiKey) async {
    final qBody = await _graphql(
      '{ __schema { queryType { name } } }',
      const {},
      apiKey,
    );
    final qData = qBody?['data'];
    final schema = qData is Map ? qData['__schema'] : null;
    final queryTypeName =
        (schema is Map && schema['queryType'] is Map) ? schema['queryType']['name']?.toString() : null;
    if (queryTypeName == null) {
      _logSchemaHint('no se pudo leer el esquema (¿introspección desactivada o sin red?)');
      return null;
    }

    final root = await _introspectType(queryTypeName, apiKey);
    final media = _byName(_mapList(root?['fields']), 'media');
    if (media == null) {
      _logSchemaHint('no existe la consulta "media"');
      return null;
    }

    final args = _mapList(media['args']);
    final argNames = args.map((a) => a['name'].toString()).toList();
    final filterArg = _byName(args, 'filter');
    final filterTypeName = filterArg == null ? null : _namedType(filterArg['type']);
    if (filterArg == null || filterTypeName == null) {
      _logSchemaHint('"media" no tiene argumento filter', mediaArgs: argNames);
      return null;
    }

    final filterType = await _introspectType(filterTypeName, apiKey);
    final filterFields = _mapList(filterType?['inputFields']);
    final modFilter = _byName(filterFields, 'modId', ignoreCase: true);
    final gameFilter = _byName(filterFields, 'gameId', ignoreCase: true);
    if (modFilter == null) {
      _logSchemaHint(
        'el filtro $filterTypeName no permite filtrar por modId '
        '(campos: ${filterFields.map((f) => f['name']).join(', ')})',
        mediaArgs: argNames,
      );
      return null;
    }

    // Forma de cada valor de filtro (esperado: { value, op }).
    final valueTypeName = _namedType(modFilter['type']);
    String opField = 'op';
    String valueField = 'value';
    String opValue = 'EQUALS';
    if (valueTypeName != null) {
      final vt = await _introspectType(valueTypeName, apiKey);
      final vf = _mapList(vt?['inputFields']);
      if (_byName(vf, 'value') == null || vf.isEmpty) {
        _logSchemaHint('forma inesperada de $valueTypeName (${vf.map((f) => f['name']).join(', ')})');
        return null;
      }
      final opF = _byName(vf, 'op') ?? _byName(vf, 'operator');
      if (opF != null) {
        opField = opF['name'].toString();
        final opType = _namedType(opF['type']);
        if (opType != null) {
          final et = await _introspectType(opType, apiKey);
          final values = _mapList(et?['enumValues']).map((e) => e['name'].toString()).toList();
          if (values.isNotEmpty && !values.contains(opValue)) opValue = values.first;
        }
      }
    }

    // Forma de los resultados.
    final retName = _namedType(media['type']);
    final ret = retName == null ? null : await _introspectType(retName, apiKey);
    if (ret == null) {
      _logSchemaHint('no se pudo leer el tipo de retorno de media', mediaArgs: argNames);
      return null;
    }
    final retFields = _mapList(ret['fields']);
    final nodesField = _byName(retFields, 'nodes');
    final itemTypeName = nodesField != null ? _namedType(nodesField['type']) : retName;
    final itemType =
        itemTypeName == null ? null : (itemTypeName == retName ? ret : await _introspectType(itemTypeName, apiKey));
    if (itemType == null) {
      _logSchemaHint('no se pudo leer el tipo de cada elemento de media', mediaArgs: argNames);
      return null;
    }

    // Selección: solo imágenes (se excluyen vídeos e imágenes de supporter).
    final possible = _mapList(itemType['possibleTypes']).map((e) => e['name'].toString()).toList();
    final candidateTypes = possible.isNotEmpty ? possible : [itemTypeName!];
    final selections = <String>[];
    var selectionHasModId = false;
    for (final tn in candidateTypes) {
      final lower = tn.toLowerCase();
      if (!lower.contains('image') || lower.contains('supporter')) continue;
      final t = tn == itemTypeName ? itemType : await _introspectType(tn, apiKey);
      final fields = _mapList(t?['fields']);
      if (_byName(fields, 'url') == null) continue;
      final pick = <String>['url'];
      if (_byName(fields, 'order') != null) pick.add('order');
      if (_byName(fields, 'modId') != null) {
        pick.add('modId');
        selectionHasModId = true;
      }
      selections.add(possible.isNotEmpty ? '... on $tn { ${pick.join(' ')} }' : pick.join(' '));
    }
    if (selections.isEmpty) {
      _logSchemaHint('no se encontró un tipo de imagen con campo url en media '
          '(tipos: ${candidateTypes.join(', ')})', mediaArgs: argNames);
      return null;
    }

    final countArg = _byName(args, 'count');
    final offsetArg = _byName(args, 'offset');
    final paged = countArg != null && offsetArg != null;

    final selection = selections.join(' ');
    final varDecls = <String>['\$f: ${_typeRefToString(filterArg['type'])}'];
    final callArgs = <String>['filter: \$f'];
    if (paged) {
      varDecls..add('\$c: ${_typeRefToString(countArg['type'])}')..add('\$o: ${_typeRefToString(offsetArg['type'])}');
      callArgs..add('count: \$c')..add('offset: \$o');
    }
    final body = nodesField != null ? 'nodes { $selection }' : selection;
    final query = 'query ModGalleryMedia(${varDecls.join(', ')}) { media(${callArgs.join(', ')}) { $body } }';

    print('[NexusGallery] Plan media: $query');
    return _MediaPlan(
      query: query,
      modField: modFilter['name'].toString(),
      gameField: gameFilter?['name']?.toString(),
      valueField: valueField,
      opField: opField,
      opValue: opValue,
      paged: paged,
      hasNodes: nodesField != null,
      selectionHasModId: selectionHasModId,
    );
  }

  static Future<List<String>?> _runMediaPlan(
    _MediaPlan plan,
    String nexusId,
    int gameId,
    String apiKey,
  ) async {
    Map<String, dynamic> cond(String v) => {plan.valueField: v, plan.opField: plan.opValue};
    final filter = <String, dynamic>{
      plan.modField: [cond(nexusId)],
      if (plan.gameField != null) plan.gameField!: [cond(gameId.toString())],
    };

    const pageSize = 50;
    final raw = <Map>[];
    for (var page = 0; page < 10; page++) {
      final vars = <String, dynamic>{'f': filter};
      if (plan.paged) {
        vars['c'] = pageSize;
        vars['o'] = page * pageSize;
      }
      final body = await _graphql(plan.query, vars, apiKey);
      if (body == null) return null;
      if (body['errors'] != null) {
        final errs = body['errors'];
        final msg = errs is List && errs.isNotEmpty && errs.first is Map
            ? (errs.first as Map)['message']
            : errs;
        print('[NexusGallery] media devolvió error: $msg');
        return null;
      }
      final data = body['data'];
      final media = data is Map ? data['media'] : null;
      final list = plan.hasNodes ? (media is Map ? media['nodes'] : null) : media;
      if (list is! List) return null;
      final maps = list.whereType<Map>().toList();
      raw.addAll(maps);
      if (!plan.paged || maps.length < pageSize) break;
    }

    // Seguridad: si la API devuelve el id del mod, se descarta lo que sea de
    // otro mod (un filtro ignorado traería imágenes ajenas).
    final own = raw.where((e) {
      if (!plan.selectionHasModId || e['modId'] == null) return true;
      return e['modId'].toString() == nexusId;
    }).toList();
    if (!plan.selectionHasModId && raw.length > 60) {
      print('[NexusGallery] media sin modId y con ${raw.length} resultados: se descarta por seguridad');
      return null;
    }
    return _parseImageUrls(own);
  }

  /// Ordena por `order` (numérico si todos lo son, texto si no) y devuelve
  /// solo URLs únicas y válidas.
  static List<String> _parseImageUrls(List raw) {
    final entries = <_RawImage>[];
    for (var i = 0; i < raw.length; i++) {
      final e = raw[i];
      if (e is! Map) continue;
      final url = e['url']?.toString().trim() ?? '';
      if (!url.startsWith('http')) continue;
      entries.add(_RawImage(url, e['order']?.toString(), i));
    }
    final allNumeric = entries.isNotEmpty &&
        entries.every((e) => e.order != null && num.tryParse(e.order!) != null);
    entries.sort((a, b) {
      int c = 0;
      if (a.order != null && b.order != null) {
        c = allNumeric
            ? num.parse(a.order!).compareTo(num.parse(b.order!))
            : a.order!.compareTo(b.order!);
      }
      return c != 0 ? c : a.index.compareTo(b.index);
    });
    final seen = <String>{};
    return [for (final e in entries) if (seen.add(e.url)) e.url];
  }

  /// POST a la API GraphQL v2. Devuelve el cuerpo completo (`data` y/o
  /// `errors`) o null si falló la petición.
  static Future<Map<String, dynamic>?> _graphql(
    String query,
    Map<String, dynamic> variables,
    String apiKey,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_graphqlUrl),
            headers: {
              'apikey': apiKey,
              'content-type': 'application/json',
              'accept': 'application/json',
            },
            body: json.encode({'query': query, 'variables': variables}),
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) {
        print('[NexusGallery] GraphQL HTTP ${response.statusCode}');
        return null;
      }
      final body = json.decode(response.body);
      return body is Map<String, dynamic> ? body : null;
    } catch (e) {
      print('[NexusGallery] Error GraphQL: $e');
      return null;
    }
  }

  // Caché de nombres de mod: varias ediciones del mismo mod (o varios mods
  // soltados a la vez) no repiten la misma petición.
  static final Map<String, String> _modNameCache = {};

  /// Nombre del mod en Nexus (el título de la página del mod, NO el nombre del
  /// archivo). Sirve para distinguir ediciones con el mismo nombre de archivo,
  /// p. ej. "Alt Goth Mini Set" y "Obsidian Set" con una edición "CNS compatible".
  static Future<String?> fetchModName(String nexusId, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) return null;
    final cached = _modNameCache[nexusId];
    if (cached != null) return cached;
    try {
      final response = await http.get(
        Uri.parse('https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId.json'),
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      final name = (data is Map ? data['name'] : null)?.toString().trim();
      if (name == null || name.isEmpty) return null;
      _modNameCache[nexusId] = name;
      return name;
    } catch (e) {
      print('Error fetchModName($nexusId): $e');
      return null;
    }
  }

  static Future<String?> fetchLatestModVersion(String nexusId, String? apiKey) async {
    try {
      if (apiKey == null || apiKey.isEmpty) return null;
      final headers = {'apikey': apiKey, 'accept': 'application/json'};
      final url = Uri.parse(
        'https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId/files.json',
      );
      final response = await http.get(url, headers: headers);
      _updateLimitsFromHeaders(response); // <-- Actualizamos aquí

      if (response.statusCode != 200) return null;

      final jsonResponse = json.decode(response.body);
      final allFiles = jsonResponse['files'] as List;

      dynamic highestVersionFile;
      String highestVersion = "0";
      
      for (final file in allFiles) {
        final currentVersion = file['version'] as String?;
        if (currentVersion != null && VersionUtils.compareVersions(currentVersion, highestVersion) > 0) {
          highestVersion = currentVersion;
          highestVersionFile = file;
        }
      }
      return highestVersionFile?['version'];
    } catch (e) {
      return null;
    }
  }

  // Caché corta de files.json: al soltar varios archivos del mismo mod
  // (p. ej. las variantes "CNS" y "Replacer") solo se consulta una vez.
  static final Map<String, _FilesCacheEntry> _filesCache = {};
  static const Duration _filesCacheTtl = Duration(minutes: 10);

  /// Devuelve el JSON completo de files.json (`files` + `file_updates`) o null
  /// si falla / el mod no existe. Con [includeOldVersions] también pide los
  /// archivos antiguos, que la API no devuelve por defecto.
  static Future<Map<String, dynamic>?> fetchModFiles(
    String modId,
    String? apiKey, {
    bool includeOldVersions = false,
  }) async {
    if (apiKey == null || apiKey.isEmpty) return null;

    final cacheKey = '$modId|${includeOldVersions ? 'all' : 'default'}';
    final cached = _filesCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.time) < _filesCacheTtl) {
      return cached.data;
    }

    try {
      var uri = Uri.parse(
        'https://api.nexusmods.com/v1/games/stellarblade/mods/$modId/files.json',
      );
      if (includeOldVersions) {
        uri = uri.replace(queryParameters: {
          'category': 'main,update,optional,old_version,miscellaneous',
        });
      }
      final response = await http.get(
        uri,
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) return null;
      _filesCache[cacheKey] = _FilesCacheEntry(data, DateTime.now());
      return data;
    } catch (e) {
      print('Error fetchModFiles($modId): $e');
      return null;
    }
  }

  /// Busca un archivo por su hash MD5 (identifica el mod y el archivo exactos
  /// aunque el usuario haya renombrado el zip). Cada elemento trae `mod` y
  /// `file_details`. Lista vacía si no hay coincidencias o falla la petición.
  static Future<List<Map<String, dynamic>>> findFilesByMd5(
    String md5Hash,
    String? apiKey,
  ) async {
    if (apiKey == null || apiKey.isEmpty) return [];
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.nexusmods.com/v1/games/stellarblade/mods/md5_search/$md5Hash.json',
        ),
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      print('Error findFilesByMd5: $e');
      return [];
    }
  }

  static Future<bool> isValidNexusId(String modId, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) return false;
    try {
      final uri = Uri.parse(
        'https://api.nexusmods.com/v1/games/stellarblade/mods/$modId.json',
      );
      final response = await http.get(
        uri,
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response); // <-- Actualizamos aquí
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static bool _hasArchiveExtension(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.zip') || n.endsWith('.rar') || n.endsWith('.7z');
  }

  static _NxmRef? _parseNxm(String nxmUrl) {
    try {
      final uri = Uri.parse(nxmUrl);
      final seg = uri.pathSegments;
      final mi = seg.indexOf('mods');
      final fi = seg.indexOf('files');
      if (uri.host.isEmpty ||
          mi < 0 ||
          fi < 0 ||
          mi + 1 >= seg.length ||
          fi + 1 >= seg.length) {
        return null;
      }
      return _NxmRef(
        uri.host,
        seg[mi + 1],
        seg[fi + 1],
        uri.queryParameters['key'],
        uri.queryParameters['expires'],
      );
    } catch (_) {
      return null;
    }
  }

  static NxmLinkException _linkExceptionForStatus(int status) {
    if (status == 401) {
      return NxmLinkException(NxmLinkFailureKind.unauthorized, statusCode: status);
    }
    if (status == 403) {
      return NxmLinkException(NxmLinkFailureKind.forbidden, statusCode: status);
    }
    if (status == 404) {
      return NxmLinkException(NxmLinkFailureKind.notFound, statusCode: status);
    }
    if (status == 429) {
      return NxmLinkException(NxmLinkFailureKind.rateLimited, statusCode: status);
    }
    if (status >= 500) {
      return NxmLinkException(NxmLinkFailureKind.server, statusCode: status);
    }
    return NxmLinkException(NxmLinkFailureKind.invalidLink,
        statusCode: status, detail: 'HTTP $status');
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  /// Resuelve un nxm:// a TODOS los mirrors del CDN. Reintenta ante fallos
  /// transitorios (red, 429, 5xx) y lanza [NxmLinkException] con el motivo
  /// real en vez de devolver un `null` mudo.
  static Future<NxmDownloadInfo> resolveNxmDownload(
      String nxmUrl, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) {
      throw const NxmLinkException(NxmLinkFailureKind.noApiKey);
    }
    final ref = _parseNxm(nxmUrl);
    if (ref == null) {
      throw NxmLinkException(NxmLinkFailureKind.invalidLink,
          detail: 'Unrecognized nxm link');
    }

    // Los usuarios Premium pueden no traer key/expires: no se envían como "null".
    final query = <String, String>{
      if (ref.key != null && ref.key!.isNotEmpty) 'key': ref.key!,
      if (ref.expires != null && ref.expires!.isNotEmpty) 'expires': ref.expires!,
    };
    final apiUri = Uri.https(
      'api.nexusmods.com',
      '/v1/games/${ref.game}/mods/${ref.modId}/files/${ref.fileId}/download_link.json',
      query.isEmpty ? null : query,
    );
    final headers = {'apikey': apiKey, 'accept': 'application/json'};

    http.Response? response;
    NxmLinkException? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final r = await http
            .get(apiUri, headers: headers)
            .timeout(const Duration(seconds: 20));
        _updateLimitsFromHeaders(r);
        if (r.statusCode == 200) {
          response = r;
          break;
        }
        lastError = _linkExceptionForStatus(r.statusCode);
        final retryable = r.statusCode == 429 || r.statusCode >= 500;
        if (!retryable) throw lastError;
      } on NxmLinkException {
        rethrow;
      } catch (e) {
        lastError = NxmLinkException(NxmLinkFailureKind.network, detail: e.toString());
      }
      await Future.delayed(Duration(seconds: 1 + attempt * 2));
    }
    if (response == null) {
      throw lastError ?? const NxmLinkException(NxmLinkFailureKind.network);
    }

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      throw NxmLinkException(NxmLinkFailureKind.invalidLink,
          detail: 'Unexpected API response: $e');
    }
    final links = decoded is List ? decoded.whereType<Map>().toList() : <Map>[];

    // Premium primero; después el resto de mirrors en el orden de Nexus.
    final urls = <String>[];
    void addUrl(Map link) {
      final u = link['URI']?.toString();
      if (u != null && u.isNotEmpty && !urls.contains(u)) urls.add(u);
    }

    for (final l in links) {
      if (l['short_name'] == 'Premium') addUrl(l);
    }
    for (final l in links) {
      addUrl(l);
    }
    if (urls.isEmpty) {
      throw const NxmLinkException(NxmLinkFailureKind.noLinks);
    }

    final firstSegments = Uri.tryParse(urls.first)?.pathSegments ?? const <String>[];
    var fileName = firstSegments.isNotEmpty ? firstSegments.last : '';
    var exactVersion = '1';
    int? sizeBytes;

    // Detalles del archivo (mejor esfuerzo): nombre real, versión y tamaño.
    try {
      final detailsUri = Uri.parse(
          'https://api.nexusmods.com/v1/games/${ref.game}/mods/${ref.modId}/files/${ref.fileId}.json');
      final dr = await http
          .get(detailsUri, headers: headers)
          .timeout(const Duration(seconds: 15));
      _updateLimitsFromHeaders(dr);
      if (dr.statusCode == 200) {
        final details = json.decode(dr.body);
        if (details is Map) {
          sizeBytes = _asInt(details['size_in_bytes']);
          if (sizeBytes == null) {
            final kb = _asInt(details['size_kb']);
            if (kb != null) sizeBytes = kb * 1024;
          }
          if (!_hasArchiveExtension(fileName)) {
            final realFileName = details['file_name'] as String?;
            if (realFileName != null && realFileName.isNotEmpty) fileName = realFileName;
            if (details['version'] != null) exactVersion = details['version'].toString();
          }
        }
      }
    } catch (e) {
      print('Error al consultar detalles: $e');
    }

    if (fileName.isEmpty) fileName = 'mod-${ref.modId}-${ref.fileId}';
    if (!_hasArchiveExtension(fileName)) fileName = '$fileName.zip';

    return NxmDownloadInfo(
      urls: urls,
      fileName: fileName,
      modId: ref.modId,
      version: exactVersion,
      sizeBytes: sizeBytes,
    );
  }

  /// Compatibilidad con el código antiguo: devuelve solo el primer mirror o
  /// null si falla. Para descargas nuevas usar [resolveNxmDownload].
  static Future<Map<String, String>?> getDownloadLinkFromNxm(
      String nxmUrl, String? apiKey) async {
    try {
      final info = await resolveNxmDownload(nxmUrl, apiKey);
      return {
        'url': info.url,
        'fileName': info.fileName,
        'modId': info.modId,
        'version': info.version,
      };
    } catch (e) {
      print('Error nxm:// : $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> validateAndGetProfile(String apiKey) async {
    if (apiKey.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('https://api.nexusmods.com/v1/users/validate.json'),
        headers: {'apikey': apiKey, 'accept': 'application/json'},
      );
      _updateLimitsFromHeaders(response); // <-- Actualizamos aquí

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Nexus manda las banderas como "is_premium" o "is_premium?" según el caso.
        final isPremium = (data['is_premium'] ?? data['is_premium?']) == true;
        final isSupporter = (data['is_supporter'] ?? data['is_supporter?']) == true;
        return {
          'isValid': true,
          'isPremium': isPremium,
          'isSupporter': isSupporter,
          'plan': NexusPlan.fromFlags(isPremium: isPremium, isSupporter: isSupporter),
          'name': data['name'], // el texto de respaldo se resuelve en la UI (l10n.nexusUserFallback)
          'profileUrl': data['profile_url'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  //  ENDORSE
  //
  //  Aquí no se guarda nada en memoria ni en disco: cada llamada pregunta a
  //  Nexus. Quien llama decide cuándo (el panel lo hace cada 10 min por mod) y
  //  guarda el resultado en el nexus_info.json del mod (EndorseInfoStore).
  // ---------------------------------------------------------------------------

  /// Lista de endorsements de TODA la cuenta (una sola petición). null si no
  /// se pudo obtener.
  static Future<Map<String, String>?> _fetchUserEndorsements(String apiKey) async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.nexusmods.com/v1/user/endorsements.json'),
            headers: {'apikey': apiKey, 'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is! List) return null;
      final map = <String, String>{};
      for (final e in data) {
        if (e is! Map) continue;
        if (e['domain_name']?.toString() != 'stellarblade') continue;
        final status = EndorseRecord.normalize(e['status']);
        final id = e['mod_id']?.toString();
        if (status != null && id != null) map[id] = status;
      }
      return map;
    } catch (e) {
      print('Error _fetchUserEndorsements: $e');
      return null;
    }
  }

  /// Estado de endorse del usuario para este mod, preguntado a Nexus ahora
  /// mismo: 'Endorsed', 'Abstained' o 'Undecided'. null = NO SE SABE (sin API
  /// key, sin red, Nexus no informó el dato...): quien llame debe conservar el
  /// último estado guardado.
  ///
  /// Fuentes: el campo `endorsement` de la ficha del mod y la lista de
  /// endorsements de la cuenta. Si la ficha no dice nada o dice "no endorsado"
  /// se contrasta con la lista, porque equivocarse en ese sentido es lo que
  /// hacía que un mod endorsado pareciera sin endorsar.
  static Future<String?> fetchEndorseStatus(String nexusId, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) return null;

    String? status;
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId.json',
            ),
            headers: {'apikey': apiKey, 'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final endorsement = data is Map ? data['endorsement'] : null;
        if (endorsement is Map) {
          status = EndorseRecord.normalize(endorsement['endorse_status']);
        }
      }
    } catch (e) {
      print('Error fetchEndorseStatus($nexusId): $e');
    }

    if (status == null || status == 'Undecided') {
      final all = await _fetchUserEndorsements(apiKey);
      final fromList = all?[nexusId];
      if (fromList != null) status = fromList;
    }
    return status;
  }

  /// Igual que [fetchEndorseStatus], pero una cuenta que nunca ha endorsado
  /// nada devuelve 'Undecided' (Nexus a veces no manda el campo `endorsement`
  /// ni la lista de endorsements lo incluye). null solo si NO se pudo consultar.
  static Future<String?> fetchEndorseStatusOrUndecided(
    String nexusId,
    String? apiKey,
  ) async {
    if (apiKey == null || apiKey.isEmpty) return null;

    String? status;
    bool modOk = false;
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId.json',
            ),
            headers: {'apikey': apiKey, 'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);
      if (response.statusCode == 200) {
        modOk = true;
        final data = json.decode(response.body);
        final endorsement = data is Map ? data['endorsement'] : null;
        if (endorsement is Map) {
          status = EndorseRecord.normalize(endorsement['endorse_status']);
        }
      } else {
        print('[Endorse] ficha del mod $nexusId: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchEndorseStatusOrUndecided($nexusId): $e');
    }

    if (status == null || status == 'Undecided') {
      final all = await _fetchUserEndorsements(apiKey);
      if (all != null) {
        status = all[nexusId] ?? status ?? 'Undecided';
      } else if (status == null && modOk) {
        status = 'Undecided';
      }
    }
    return status;
  }

  // ---- Última descarga de este mod por la cuenta ------------------------------
  // Nexus no expone "el botón endorse está habilitado", pero sí `viewerDownloaded`
  // (GraphQL v2): la FECHA de la última vez que la cuenta descargó el mod. Los
  // 15 min de espera se cuentan desde esa fecha.
  static int? _gameIdCache;

  static Future<int?> _stellarBladeGameId(String apiKey) async {
    if (_gameIdCache != null) return _gameIdCache;
    try {
      final response = await http
          .get(
            Uri.parse('https://api.nexusmods.com/v1/games/stellarblade.json'),
            headers: {'apikey': apiKey, 'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      return _gameIdCache = int.tryParse('${data is Map ? data['id'] : ''}');
    } catch (e) {
      print('Error _stellarBladeGameId: $e');
      return null;
    }
  }

  /// Fecha en que la cuenta descargó este mod por última vez. null = no se sabe
  /// (sin API key, sin red, nunca descargado, campo no disponible...).
  static Future<DateTime?> fetchViewerDownloadedAt(
    String nexusId,
    String? apiKey,
  ) async {
    if (apiKey == null || apiKey.isEmpty) return null;
    final modId = int.tryParse(nexusId);
    final gameId = await _stellarBladeGameId(apiKey);
    if (modId == null || gameId == null) return null;

    // Ids como literales: valen tanto si el esquema los declara Int como ID.
    final queries = <String, Object? Function(Map)>{
      'query { mod(modId: $modId, gameId: $gameId) { viewerDownloaded } }':
          (data) => data['mod'],
      'query { legacyMods(ids: [{gameId: $gameId, modId: $modId}]) '
          '{ nodes { viewerDownloaded } } }': (data) {
        final nodes = data['legacyMods'] is Map ? data['legacyMods']['nodes'] : null;
        return nodes is List && nodes.isNotEmpty ? nodes.first : null;
      },
    };

    for (final entry in queries.entries) {
      final body = await _graphql(entry.key, const {}, apiKey);
      final data = body?['data'];
      if (body == null || body['errors'] != null || data is! Map) {
        print('[Endorse] consulta viewerDownloaded falló: ${body?['errors']}');
        continue;
      }
      final node = entry.value(data);
      final raw = node is Map ? node['viewerDownloaded'] : null;
      print('[Endorse] viewerDownloaded($nexusId) = $raw');
      final at = raw == null ? null : DateTime.tryParse(raw.toString());
      if (at != null) return at.toLocal();
      return null; // consulta válida pero sin fecha (nunca descargado)
    }
    return null;
  }

  static EndorseFailure? _endorseFailureFromMessage(String upperMessage) {
    if (upperMessage.contains('TOO_SOON')) return EndorseFailure.tooSoon;
    if (upperMessage.contains('NOT_DOWNLOADED')) {
      return EndorseFailure.notDownloaded;
    }
    if (upperMessage.contains('OWN_MOD')) return EndorseFailure.ownMod;
    return null;
  }

  /// Endorsa ([endorse] = true) o quita el endorse ([endorse] = false) de un
  /// mod. [version] es la versión instalada, que Nexus guarda junto al voto.
  ///
  /// Nexus responde con errores propios que se traducen a [EndorseFailure]:
  /// `NOT_DOWNLOADED_MOD`, `TOO_SOON_AFTER_DOWNLOAD` (15 min desde la
  /// descarga) e `IS_OWN_MOD`.
  static Future<EndorseResult> setEndorsement({
    required String nexusId,
    required String? apiKey,
    required bool endorse,
    String? version,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return const EndorseResult.failure(EndorseFailure.noApiKey);
    }

    try {
      final cleanVersion = version?.trim() ?? '';
      final response = await http
          .post(
            Uri.parse(
              'https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId/'
              '${endorse ? 'endorse' : 'abstain'}.json',
            ),
            headers: {
              'apikey': apiKey,
              'accept': 'application/json',
              'content-type': 'application/json',
            },
            body: json.encode({
              if (cleanVersion.isNotEmpty) 'Version': cleanVersion,
            }),
          )
          .timeout(const Duration(seconds: 20));
      _updateLimitsFromHeaders(response);

      // El motivo del rechazo viaja en `message`.
      var message = '';
      try {
        final body = json.decode(response.body);
        if (body is Map) {
          message = (body['message'] ?? body['error'] ?? '').toString();
        }
      } catch (_) {
        message = response.body;
      }
      final upper = message.toUpperCase();

      // Ya estaba endorsado: el resultado deseado ya se cumple.
      if (endorse && upper.contains('ALREADY_ENDORSED')) {
        return const EndorseResult.success('Endorsed');
      }

      final byMessage = _endorseFailureFromMessage(upper);
      if (byMessage != null) {
        print('[Endorse] Nexus rechazó el endorse: "$message"');
        return EndorseResult.failure(byMessage);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = endorse ? 'Endorsed' : 'Abstained';
        return EndorseResult.success(status);
      }

      print('Endorse HTTP ${response.statusCode}: $message');
      switch (response.statusCode) {
        case 401:
          return const EndorseResult.failure(EndorseFailure.invalidKey);
        case 404:
          return const EndorseResult.failure(EndorseFailure.notFound);
        case 429:
          return const EndorseResult.failure(EndorseFailure.rateLimited);
        default:
          return const EndorseResult.failure(EndorseFailure.unknown);
      }
    } on TimeoutException {
      return const EndorseResult.failure(EndorseFailure.network);
    } on SocketException {
      return const EndorseResult.failure(EndorseFailure.network);
    } on http.ClientException {
      return const EndorseResult.failure(EndorseFailure.network);
    } catch (e) {
      print('Error setEndorsement($nexusId): $e');
      return const EndorseResult.failure(EndorseFailure.unknown);
    }
  }
}

class _RawImage {
  final String url;
  final String? order;
  final int index;
  _RawImage(this.url, this.order, this.index);
}

/// Consulta `media` ya resuelta por introspección (se reutiliza para todos
/// los mods de la sesión).
class _MediaPlan {
  final String query;
  final String modField;
  final String? gameField;
  final String valueField;
  final String opField;
  final String opValue;
  final bool paged;
  final bool hasNodes;
  final bool selectionHasModId;
  _MediaPlan({
    required this.query,
    required this.modField,
    required this.gameField,
    required this.valueField,
    required this.opField,
    required this.opValue,
    required this.paged,
    required this.hasNodes,
    required this.selectionHasModId,
  });
}