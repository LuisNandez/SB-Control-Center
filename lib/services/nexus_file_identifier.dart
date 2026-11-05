// lib/services/nexus_file_identifier.dart
//
// Identifica con exactitud qué mod / archivo de Nexus Mods es un archivo
// descargado manualmente ("Manual download") o con el gestor (nxm://).
//
// Nexus nombra los archivos descargados así:
//
//     <Nombre del archivo>-<modId>-<versión con '.' cambiado por '-'>-<timestamp>.zip
//
// Ejemplo (captura de la pestaña Files):
//     Neurolink Suit Titties Out CNS-1234-1-0-1759300260.zip
//        nombre  -> "Neurolink Suit Titties Out CNS"   (el que se ve en la página)
//        modId   -> 1234
//        versión -> 1.0
//        fecha   -> 1759300260 (uploaded_timestamp del archivo)
//
// El nombre del archivo por sí solo es ambiguo (el nombre puede contener
// números separados por guiones y la versión también), así que la
// identificación se hace por capas:
//
//   1. Se analiza el nombre y se generan los posibles (modId, versión).
//   2. Se confirma contra files.json de la API comparando el file_name exacto
//      o el uploaded_timestamp. De ahí salen el nombre oficial, la versión
//      oficial y el file_id.
//   3. Si el archivo fue renombrado / no coincide, se busca por MD5.
//   4. Sin API key (o sin red) se usa solo lo que dice el nombre del archivo.

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'nexus_api_service.dart';

enum NexusIdentitySource {
  /// Confirmado con la API comparando file_name / fecha de subida.
  apiFileName,

  /// Confirmado con la API mediante el hash MD5 del archivo.
  apiMd5,

  /// Solo se interpretó el nombre del archivo (sin confirmación de la API).
  fileNameOnly,
}

/// Resultado de identificar un archivo descargado de Nexus Mods.
class NexusFileIdentity {
  /// ID del mod en Nexus (null si no se pudo determinar con seguridad).
  final String? modId;

  /// ID del archivo concreto dentro del mod (solo si lo confirmó la API).
  final String? fileId;

  /// Nombre tal como aparece en la pestaña "Files" de Nexus, ya saneado
  /// para poder usarse como nombre de carpeta. Es el nombre de la EDICIÓN
  /// (p. ej. "CNS compatible"): varios mods distintos pueden tener archivos
  /// con el mismo nombre.
  final String name;

  /// Nombre del MOD en Nexus (título de la página, ya saneado), p. ej.
  /// "Alt Goth Mini Set". Null si no se pudo consultar (sin API key / sin red).
  final String? modName;

  /// Versión del archivo (la columna "Version" de la pestaña Files).
  final String? version;

  /// Nombre real del archivo en Nexus (con id, versión y timestamp).
  final String? remoteFileName;

  final NexusIdentitySource source;

  /// Categoría del archivo en Nexus según files.json ("MAIN", "OPTIONAL",
  /// "UPDATE", "MISCELLANEOUS", "OLD_VERSION"...). Null si la API no la dio
  /// (sin API key / sin red / identificado solo por el nombre).
  final String? categoryName;

  /// IDs de archivo de este archivo y de todas las versiones anteriores
  /// que reemplaza (cadena `file_updates` de Nexus). Sirve para saber que
  /// "Foo CNS v2" es la actualización de "Foo CNS v1" aunque cambie el nombre.
  final List<String> lineageFileIds;

  const NexusFileIdentity({
    required this.name,
    required this.source,
    this.modName,
    this.modId,
    this.fileId,
    this.version,
    this.remoteFileName,
    this.categoryName,
    this.lineageFileIds = const [],
  });

  /// ¿Es un "Main file" de Nexus (o una versión antigua que lo fue)? Solo si
  /// la API lo confirmó. Nexus pasa a OLD_VERSION los main files reemplazados.
  bool get isMainFile {
    final c = categoryName?.trim().toUpperCase();
    return c == 'MAIN' || c == 'OLD_VERSION';
  }

  bool get isVerified => source != NexusIdentitySource.fileNameOnly;

  /// Nombre de la edición (el archivo dentro del mod).
  String get editionName => name;

  /// Nombre completo para mostrar y para la carpeta: mod + edición.
  /// Ej.: "Alt Goth Mini Set - CNS compatible".
  String get fullName =>
      NexusFileNameParser.composeModEditionName(modName, name);

  NexusFileIdentity withModName(String? newModName) => NexusFileIdentity(
        name: name,
        source: source,
        modName: newModName,
        modId: modId,
        fileId: fileId,
        version: version,
        remoteFileName: remoteFileName,
        categoryName: categoryName,
        lineageFileIds: lineageFileIds,
      );

  /// Formato antiguo {'id': ..., 'version': ...} que usa ArchiveService.
  Map<String, String> toLegacyInfo() {
    final map = <String, String>{};
    if (modId != null) map['id'] = modId!;
    if (version != null && version!.isNotEmpty) map['version'] = version!;
    return map;
  }
}

/// Un posible reparto del nombre de archivo en nombre / modId / versión / fecha.
class ParsedNexusFileName {
  final String name;
  final String modId;

  /// Versión tal como aparece en el nombre de archivo, p. ej. "1-0-2".
  final String rawVersion;

  /// Timestamp de subida ("0" cuando el nombre fue generado por el gestor
  /// sin conocer la fecha real).
  final String timestamp;

  /// true si la versión "parece" una versión real (números, sufijos tipo
  /// beta/rc...). Se usa para ordenar las hipótesis.
  final bool hasSimpleVersion;

  const ParsedNexusFileName({
    required this.name,
    required this.modId,
    required this.rawVersion,
    required this.timestamp,
    required this.hasSimpleVersion,
  });

  String get version => NexusFileNameParser.dashedToVersion(rawVersion);
}

class NexusFileNameParser {
  static final RegExp _archiveExt =
      RegExp(r'\.(zip|rar|7z)$', caseSensitive: false);

  // Los navegadores añaden " (1)", " (2)"... al repetir una descarga.
  static final RegExp _browserDuplicate = RegExp(r'\s*\(\d+\)\s*$');

  // Posibles inicios del modId: un '-' seguido de dígitos y otro '-'.
  static final RegExp _idStart = RegExp(r'-(?=\d+-)');

  // Desde el '-' previo al modId hasta el final:
  //   -<modId>-<versión>-<timestamp>
  static final RegExp _tail = RegExp(
    r'^-(\d+)-((?:cns-)?[vV]?\d+(?:-[0-9A-Za-z]+)*)-(0|\d{9,11})$',
    caseSensitive: false,
  );

  static final RegExp _simpleSegment = RegExp(
    r'^(?:[vV]?\d+[a-z]?|(?:alpha|beta|rc|pre|preview|hotfix|hf|fix|final|test|dev|wip|patch|update)\d*)$',
    caseSensitive: false,
  );

  /// Nombre sin ruta, sin extensión de archivo comprimido y sin el sufijo
  /// " (1)" que añaden los navegadores.
  static String baseName(String fileName) {
    final withoutExt = p.basename(fileName).replaceFirst(_archiveExt, '');
    return withoutExt.replaceFirst(_browserDuplicate, '').trim();
  }

  static String stripArchiveExtension(String fileName) =>
      fileName.replaceFirst(_archiveExt, '');

  static bool _isSimpleVersion(String rawVersion) {
    final segments = rawVersion.split('-');
    if (segments.isNotEmpty && segments.first.toLowerCase() == 'cns') {
      segments.removeAt(0);
    }
    if (segments.isEmpty) return false;
    return segments.every(_simpleSegment.hasMatch);
  }

  /// Todas las formas posibles de interpretar el nombre. Primero las que
  /// tienen una versión "simple", y dentro de cada grupo de izquierda a derecha.
  static List<ParsedNexusFileName> parse(String fileName) {
    final base = baseName(fileName);
    final found = <ParsedNexusFileName>[];

    for (final m in _idStart.allMatches(base)) {
      final tail = _tail.firstMatch(base.substring(m.start));
      if (tail == null) continue;
      final name = base.substring(0, m.start).trim();
      if (name.isEmpty) continue;
      final rawVersion = tail.group(2)!;
      found.add(ParsedNexusFileName(
        name: name,
        modId: tail.group(1)!,
        rawVersion: rawVersion,
        timestamp: tail.group(3)!,
        hasSimpleVersion: _isSimpleVersion(rawVersion),
      ));
    }

    return [
      ...found.where((c) => c.hasSimpleVersion),
      ...found.where((c) => !c.hasSimpleVersion),
    ];
  }

  /// Mejor interpretación posible SIN consultar la API (o null si es dudosa).
  static ParsedNexusFileName? bestGuess(String fileName) {
    final candidates = parse(fileName);
    if (candidates.isEmpty) return null;
    return candidates.first.hasSimpleVersion ? candidates.first : null;
  }

  /// "1-0-2" -> "1.0.2" · "v1-5" -> "1.5" · "1-0-beta" -> "1.0-beta"
  static String dashedToVersion(String raw) {
    var segments = raw.split('-');
    if (segments.isNotEmpty && segments.first.toLowerCase() == 'cns') {
      segments = segments.sublist(1);
    }
    if (segments.isEmpty) return raw;

    final buffer =
        StringBuffer(segments.first.replaceFirst(RegExp(r'^[vV](?=\d)'), ''));
    for (final s in segments.skip(1)) {
      final isWord = RegExp(r'^[A-Za-z]').hasMatch(s);
      buffer.write(isWord ? '-$s' : '.$s');
    }
    return buffer.toString();
  }

  /// Convierte un nombre de la página de Nexus en un nombre válido de carpeta
  /// de Windows. Si el nombre termina con la propia versión ("Foo v1.0") se
  /// quita, porque la versión ya se añade aparte al nombre de la carpeta.
  static String sanitizeDisplayName(String raw, {String? version}) {
    var name = raw
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (version != null && version.isNotEmpty) {
      // Una versión de un solo número ("2") solo se quita si lleva prefijo "v",
      // para no recortar nombres como "Outfit Pack 2".
      final prefix = version.contains('.') ? r'\s+[vV]?' : r'\s+[vV]';
      final stripped = name
          .replaceFirst(RegExp(prefix + RegExp.escape(version) + r'\s*$'), '')
          .trim();
      if (stripped.isNotEmpty) name = stripped;
    }

    name = name.replaceAll(RegExp(r'[. ]+$'), '');
    return name;
  }

  static String normalizeVersion(String version) =>
      version.trim().replaceFirst(RegExp(r'^[vV](?=\d)'), '');

  static String _compact(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Une el nombre del mod y el de la edición (archivo) sin repetir texto:
  ///
  ///   mod "Alt Goth Mini Set" + edición "CNS compatible"
  ///       -> "Alt Goth Mini Set - CNS compatible"
  ///   mod "Obsidian Set" + edición "Obsidian Set CNS"
  ///       -> "Obsidian Set CNS"   (la edición ya incluye el nombre del mod)
  ///   mod "Obsidian Set" + edición "Obsidian Set"
  ///       -> "Obsidian Set"
  ///   sin nombre de mod -> solo la edición.
  static String composeModEditionName(String? modName, String editionName) {
    final edition = editionName.trim();
    final mod = sanitizeDisplayName(modName ?? '');
    if (mod.isEmpty) return edition;
    if (edition.isEmpty) return mod;

    final compactMod = _compact(mod);
    final compactEdition = _compact(edition);
    if (compactMod.isEmpty) return edition;
    if (compactEdition.contains(compactMod)) return edition;
    return '$mod - $edition';
  }
}

class _FileLookup {
  final bool modExists;
  final Map<String, dynamic>? file;
  final List<dynamic> fileUpdates;
  const _FileLookup(this.modExists, this.file, this.fileUpdates);
}

class NexusFileIdentifier {
  /// Máximo de hipótesis (modId) a comprobar contra la API por archivo.
  static const int _maxCandidatesToVerify = 4;

  /// Identifica el archivo y le añade el nombre del MOD (no solo el del
  /// archivo) para poder distinguir ediciones de mods distintos que se llaman
  /// igual, p. ej. dos mods con una edición "CNS compatible".
  static Future<NexusFileIdentity?> identify({
    required File archive,
    required String? apiKey,
  }) async {
    final identity = await _identifyFile(archive: archive, apiKey: apiKey);
    if (identity == null || identity.modId == null) return identity;
    if (apiKey == null || apiKey.isEmpty) return identity;

    final modName = await NexusApiService.fetchModName(identity.modId!, apiKey);
    if (modName == null) return identity;
    return identity.withModName(NexusFileNameParser.sanitizeDisplayName(modName));
  }

  static Future<NexusFileIdentity?> _identifyFile({
    required File archive,
    required String? apiKey,
  }) async {
    final fileName = p.basename(archive.path);
    final candidates = NexusFileNameParser.parse(fileName);
    final String key = apiKey ?? '';
    final bool hasKey = key.isNotEmpty;
    final Set<String> verifiedMods = {};

    if (hasKey) {
      // 1) Confirmación por nombre exacto / fecha de subida.
      for (final c in candidates.take(_maxCandidatesToVerify)) {
        final lookup = await _lookupInMod(c, fileName, key);
        if (lookup.modExists) verifiedMods.add(c.modId);
        if (lookup.file != null) {
          return _fromApiFile(
            modId: c.modId,
            file: lookup.file!,
            fileUpdates: lookup.fileUpdates,
            source: NexusIdentitySource.apiFileName,
          );
        }
      }

      // 2) El archivo no coincide con ninguna hipótesis (renombrado, copiado,
      //    versión antigua retirada...): se identifica por su MD5.
      final byHash = await _identifyByMd5(archive, candidates, key);
      if (byHash != null) return byHash;
    }

    // 3) Sin confirmación de la API: solo lo que dice el nombre del archivo.
    final guess = NexusFileNameParser.bestGuess(fileName);
    if (guess == null) return null;

    final version = NexusFileNameParser.normalizeVersion(guess.version);
    // Con API key, solo se acepta el modId si la API confirmó que el mod existe.
    final trustModId = !hasKey || verifiedMods.contains(guess.modId);

    return NexusFileIdentity(
      modId: trustModId ? guess.modId : null,
      name: NexusFileNameParser.sanitizeDisplayName(guess.name, version: version),
      version: version,
      source: NexusIdentitySource.fileNameOnly,
    );
  }

  static Future<_FileLookup> _lookupInMod(
    ParsedNexusFileName candidate,
    String localFileName,
    String apiKey,
  ) async {
    final localBase = NexusFileNameParser.baseName(localFileName);
    bool modExists = false;
    List<dynamic> updates = const [];

    // Primero los archivos vigentes; si no está, también los antiguos.
    for (final includeOld in const [false, true]) {
      final data = await NexusApiService.fetchModFiles(
        candidate.modId,
        apiKey,
        includeOldVersions: includeOld,
      );
      if (data == null) break;

      modExists = true;
      updates = (data['file_updates'] as List<dynamic>?) ?? const [];
      final files = (data['files'] as List<dynamic>?) ?? const [];
      final match = _matchFile(files, candidate, localBase);
      if (match != null) return _FileLookup(true, match, updates);
    }
    return _FileLookup(modExists, null, updates);
  }

  static Map<String, dynamic>? _matchFile(
    List<dynamic> files,
    ParsedNexusFileName candidate,
    String localBase,
  ) {
    final target = localBase.toLowerCase();
    Map<String, dynamic>? byTimestamp;
    Map<String, dynamic>? byNameAndVersion;

    for (final f in files) {
      if (f is! Map) continue;
      final file = Map<String, dynamic>.from(f);

      final remoteName = NexusFileNameParser.stripArchiveExtension(
          (file['file_name'] ?? '').toString());
      if (remoteName.toLowerCase() == target) return file;

      if (candidate.timestamp != '0' &&
          file['uploaded_timestamp']?.toString() == candidate.timestamp) {
        byTimestamp ??= file;
      }

      if (candidate.timestamp == '0') {
        final sameName = NexusFileNameParser.sanitizeDisplayName(
                    (file['name'] ?? '').toString())
                .toLowerCase() ==
            NexusFileNameParser.sanitizeDisplayName(candidate.name).toLowerCase();
        final sameVersion = (file['version'] ?? '')
                .toString()
                .replaceAll('.', '-')
                .toLowerCase() ==
            candidate.rawVersion.toLowerCase();
        if (sameName && sameVersion) byNameAndVersion ??= file;
      }
    }
    return byTimestamp ?? byNameAndVersion;
  }

  static Future<NexusFileIdentity?> _identifyByMd5(
    File archive,
    List<ParsedNexusFileName> candidates,
    String apiKey,
  ) async {
    try {
      final digest = await md5.bind(archive.openRead()).first;
      final results =
          await NexusApiService.findFilesByMd5(digest.toString(), apiKey);
      if (results.isEmpty) return null;

      final preferredModIds = candidates.map((c) => c.modId).toSet();
      Map<String, dynamic>? chosen;
      for (final r in results) {
        final modId = (r['mod'] as Map?)?['mod_id']?.toString();
        if (modId != null && preferredModIds.contains(modId)) {
          chosen = r;
          break;
        }
      }
      chosen ??= results.first;

      final modId = (chosen['mod'] as Map?)?['mod_id']?.toString();
      final fileDetails = chosen['file_details'];
      if (modId == null || fileDetails is! Map) return null;

      // La cadena de actualizaciones solo viene en files.json.
      final filesData = await NexusApiService.fetchModFiles(
        modId,
        apiKey,
        includeOldVersions: true,
      );

      return _fromApiFile(
        modId: modId,
        file: Map<String, dynamic>.from(fileDetails),
        fileUpdates: (filesData?['file_updates'] as List<dynamic>?) ?? const [],
        source: NexusIdentitySource.apiMd5,
      );
    } catch (e) {
      print('MD5 identification failed for ${archive.path}: $e');
      return null;
    }
  }

  static NexusFileIdentity _fromApiFile({
    required String modId,
    required Map<String, dynamic> file,
    required List<dynamic> fileUpdates,
    required NexusIdentitySource source,
  }) {
    final fileId = file['file_id']?.toString();
    final rawVersion = (file['version'] ?? '').toString().trim().isNotEmpty
        ? file['version'].toString()
        : (file['mod_version'] ?? '').toString();
    final version =
        rawVersion.trim().isEmpty ? null : NexusFileNameParser.normalizeVersion(rawVersion);

    var name = NexusFileNameParser.sanitizeDisplayName(
        (file['name'] ?? '').toString(),
        version: version);

    // Respaldo: sacar el nombre del file_name si la API no trae "name".
    if (name.isEmpty) {
      final remoteBase = NexusFileNameParser.stripArchiveExtension(
          (file['file_name'] ?? '').toString());
      final parsed = NexusFileNameParser.bestGuess(remoteBase);
      name = NexusFileNameParser.sanitizeDisplayName(
          parsed?.name ?? remoteBase,
          version: version);
    }

    return NexusFileIdentity(
      modId: modId,
      fileId: fileId,
      name: name,
      version: version,
      remoteFileName: file['file_name']?.toString(),
      categoryName: file['category_name']?.toString(),
      source: source,
      lineageFileIds: _buildLineage(fileId, fileUpdates),
    );
  }

  /// [fileId] y los ids de todas las versiones anteriores que reemplaza.
  static List<String> _buildLineage(String? fileId, List<dynamic> fileUpdates) {
    if (fileId == null) return const [];

    final Map<String, String> previousOf = {}; // nuevo -> anterior
    for (final u in fileUpdates) {
      if (u is! Map) continue;
      final oldId = u['old_file_id']?.toString();
      final newId = u['new_file_id']?.toString();
      if (oldId != null && newId != null) previousOf[newId] = oldId;
    }

    final lineage = <String>[fileId];
    var current = fileId;
    while (previousOf.containsKey(current) && lineage.length < 64) {
      final older = previousOf[current]!;
      if (lineage.contains(older)) break;
      lineage.add(older);
      current = older;
    }
    return lineage;
  }
}