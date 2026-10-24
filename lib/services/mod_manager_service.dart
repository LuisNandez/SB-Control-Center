import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/mod_info.dart';
import 'mod_metadata_migrator.dart';
import 'archive_service.dart';
import 'nexus_api_service.dart';
import 'package:flutter/material.dart';

class ModManagerService {
  /// Carpetas que el CNS principal trae por defecto dentro de
  /// `~mods/CustomNanosuitSystem` (Animations y Cosmetics). No son mods del
  /// usuario, así que la app las ignora por completo: no se listan, no se
  /// migran, no se consultan en Nexus ni se pueden activar/desactivar.
  static const Set<String> coreCnsFolders = {'animations', 'cosmetics'};

  /// ID de Nexus con el que versiones anteriores de la app marcaban esas
  /// carpetas (CNS). Sirve para reconocerlas en __MOD_BACKUPS__.
  static const String _legacyCoreCnsNexusId = '1496';

  static bool isCoreCnsFolderName(String name) =>
      coreCnsFolders.contains(name.toLowerCase());

  /// ¿[dir] es una de las carpetas por defecto del CNS (Animations/Cosmetics)?
  ///  - En la carpeta del CNS ([inCnsFolder]) basta con el nombre.
  ///  - En cualquier otra (copias de seguridad de mods desactivados) exige
  ///    además el nexusId del CNS que la app guardó antes, para no ocultar un
  ///    mod del usuario que casualmente se llame igual.
  static Future<bool> isCoreCnsAddon(Directory dir,
      {required bool inCnsFolder}) async {
    if (!isCoreCnsFolderName(p.basename(dir.path))) return false;
    if (inCnsFolder) return true;
    try {
      final info = File(p.join(dir.path, 'nexus_info.json'));
      if (!await info.exists()) return false;
      final data = json.decode(await info.readAsString());
      return data is Map && data['nexusId']?.toString() == _legacyCoreCnsNexusId;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getFitMeshTypeForMod(Directory modDir) async {
    try {
      await for (final entity in modDir.list()) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.json') {
          var jsonString = await entity.readAsString();
          jsonString = jsonString.replaceAll(RegExp(r',\s*(?=[\}\]])'), '');
          final jsonDecoded = json.decode(jsonString);
          if (jsonDecoded is List && jsonDecoded.isNotEmpty) {
            final modInfo = jsonDecoded[0] as Map<String, dynamic>;
            final fitMeshType = modInfo['FitMeshType'] as String?;
            if (fitMeshType != null && fitMeshType.trim().isNotEmpty) {
              return fitMeshType.trim();
            }
          }
        }
      }
    } catch (e) {
      print("Could not read FitMeshType from ${modDir.path}: $e");
    }
    return null;
  }

  static Future<String?> getDisplayNameForMod(Directory modDir) async {
    try {
      await for (final entity in modDir.list()) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.json') {
          var jsonString = await entity.readAsString();
          jsonString = jsonString.replaceAll(RegExp(r',\s*(?=[\}\]])'), '');
          final jsonDecoded = json.decode(jsonString);
          if (jsonDecoded is List && jsonDecoded.isNotEmpty) {
            final modInfo = jsonDecoded[0] as Map<String, dynamic>;
            final displayName = modInfo['DisplayName'] as String?;
            if (displayName != null && displayName.trim().isNotEmpty) {
              return displayName.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
            }
          }
          break;
        }
      }
    } catch (e) {
      print("Could not read DisplayName from ${modDir.path}: $e");
    }
    return null;
  }

  static Future<String?> getCompositeDisplayName(Directory modDir) async {
    final List<File> jsonFiles = [];
    await for (final entity in modDir.list()) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.json') {
        jsonFiles.add(entity);
      }
    }

    if (jsonFiles.isEmpty) return null;

    List<String> displayNames = [];
    for (final jsonFile in jsonFiles) {
      try {
        var jsonString = await jsonFile.readAsString();
        jsonString = jsonString.replaceAll(RegExp(r',\s*(?=[\}\]])'), '');
        final jsonDecoded = json.decode(jsonString);
        if (jsonDecoded is List && jsonDecoded.isNotEmpty) {
          final modInfo = jsonDecoded[0] as Map<String, dynamic>;
          final displayName = modInfo['DisplayName'] as String?;
          if (displayName != null && displayName.trim().isNotEmpty) {
            displayNames.add(displayName.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '-'));
          }
        }
      } catch (e) {
        print('Could not parse display name from ${jsonFile.path}: $e');
      }
    }
    return displayNames.isEmpty ? null : displayNames.join(' ~ ');
  }

  static Future<String?> getVersionFromModJsonDescription(Directory modDir) async {
    try {
      await for (final file in modDir.list()) {
        if (file is File && p.extension(file.path).toLowerCase() == '.json') {
          final jsonString = await file.readAsString();
          final jsonDecoded = json.decode(jsonString.replaceAll(RegExp(r',\s*(?=[\}\]])'), ''));
          if (jsonDecoded is List && jsonDecoded.isNotEmpty) {
            final modInfo = jsonDecoded[0] as Map<String, dynamic>;
            final description = modInfo['Description'] as String?;
            if (description != null) {
              return ModInfo.extractVersionFromName(description);
            }
          }
          break;
        }
      }
    } catch (e) {
      print('Error reading version from JSON description for ${modDir.path}: $e');
    }
    return null;
  }

  static Future<void> cacheNexusThumbnail({
    required Directory modDirectory,
    required String nexusId,
    required String? apiKey,
  }) async {
    final infoFile = File(p.join(modDirectory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) return;

    // La galería completa se guarda ANTES de leer el JSON de la portada: ambas
    // escriben nexus_info.json y así no se pisan. Es independiente de si el
    // usuario tiene una portada personalizada.
    await cacheNexusGallery(
      modDirectory: modDirectory,
      nexusId: nexusId,
      apiKey: apiKey,
    );

    try {
      Map<String, dynamic> data = json.decode(await infoFile.readAsString());

      if (data['customCoverPath'] != null && (data['customCoverPath'] as String).isNotEmpty) {
        return;
      }

      final nexusData = await NexusApiService.fetchNexusModData(nexusId, apiKey);
      final gallery = nexusData?['gallery'] as List<dynamic>?;
      if (gallery == null || gallery.isEmpty) return;

      final imageUrl = gallery.first['image'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) return;

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final fileExtension = p.extension(imageUrl).isNotEmpty ? p.extension(imageUrl) : '.jpg';
        const coverFileName = '_nexus_cover';
        final finalFileName = '$coverFileName$fileExtension';

        final coverFile = File(p.join(modDirectory.path, finalFileName));
        await coverFile.writeAsBytes(response.bodyBytes);

        data['customCoverPath'] = finalFileName;
        data['customCoverAlignmentX'] ??= 0.0;
        data['customCoverAlignmentY'] ??= 0.0;

        final encoder = JsonEncoder.withIndent('  ');
        await infoFile.writeAsString(encoder.convert(data));
        print('Portada de Nexus cacheada para ${p.basename(modDirectory.path)}');
      }
    } catch (e) {
      print('No se pudo cachear la portada de Nexus para ${p.basename(modDirectory.path)}: $e');
    }
  }

  // ---------------------------------------------------------------------------
  //  GALERÍA DE NEXUS: todas las imágenes del mod, guardadas en local
  //
  //  Estructura dentro de la carpeta del mod:
  //    <mod>/_nexus_gallery/01_<nombre>.jpg, 02_<nombre>.png, ...
  //  (el prefijo numérico conserva el orden de la página del mod).
  //  En nexus_info.json cada entrada de `gallery` conserva `image`/`thumbnail`
  //  (URLs) y gana `localImage` (ruta RELATIVA a la carpeta del mod, así sigue
  //  valiendo al activar/desactivar el mod, que mueve la carpeta).
  // ---------------------------------------------------------------------------

  /// Súbelo si cambia el formato de la galería local para volver a bajarla.
  static const int _gallerySchema = 1;
  static const String galleryDirName = '_nexus_gallery';
  static const int _galleryParallelDownloads = 3;
  static const int _galleryMinHourlyRemaining = 5;

  /// Mods cuya galería falló en esta sesión: no se reintentan hasta reiniciar
  /// (loadMods se ejecuta en cada recarga de la lista).
  static final Set<String> _galleryFailedThisSession = {};

  /// ¿Este nexus_info.json aún no tiene la galería completa en local?
  static bool needsGalleryCache(Map<String, dynamic> data) {
    final nexusId = data['nexusId']?.toString();
    if (nexusId == null || nexusId.isEmpty) return false;
    final v = data['galleryCacheSchema'];
    if (v is int && v >= _gallerySchema) return false;
    // Ya se intentó y quedó incompleta: con [retryPendingGallery] en false no
    // se vuelve a intentar; con true, solo pasados [_galleryRetryAfter].
    final last = DateTime.tryParse(data['galleryAttemptAt']?.toString() ?? '');
    if (last != null &&
        (!retryPendingGallery ||
            DateTime.now().difference(last) < _galleryRetryAfter)) {
      return false;
    }
    return true;
  }

  /// false = una galería cuyo intento de descarga no se completó no se
  /// reintenta en arranques posteriores. true = se reintenta tras 7 días.
  static const bool retryPendingGallery = false;
  static const Duration _galleryRetryAfter = Duration(days: 7);

  /// Olvida las galerías que fallaron en esta sesión (para poder reintentarlas).
  static void clearGalleryFailuresThisSession() =>
      _galleryFailedThisSession.clear();

  /// Anota que se intentó bajar la galería de este mod (releyendo el archivo
  /// para no pisar otros cambios).
  static Future<void> _markGalleryAttempt(File infoFile) async {
    try {
      final latest =
          Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
      latest['galleryAttemptAt'] = DateTime.now().toIso8601String();
      await infoFile.writeAsString(JsonEncoder.withIndent('  ').convert(latest));
    } catch (e) {
      print('[NexusGallery] No se pudo anotar el intento: $e');
    }
  }

  /// Borra la carpeta `_nexus_gallery` y las rutas locales de `gallery`.
  /// Se usa cuando la galería solo tiene la portada: esa imagen ya está
  /// guardada como `_nexus_cover.*` y copiarla otra vez la duplicaría.
  static Future<void> _removeGalleryCopy(Directory modDirectory, Map<String, dynamic> data) async {
    final dir = Directory(p.join(modDirectory.path, galleryDirName));
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      print('[NexusGallery] No se pudo borrar $galleryDirName: $e');
    }
    final g = data['gallery'];
    if (g is List) {
      for (final e in g) {
        if (e is Map) e.remove('localImage');
      }
    }
  }

  /// ¿Vale la pena intentar bajar la galería de este mod ahora?
  static bool canCacheGallery(String modPath) {
    if (_galleryFailedThisSession.contains(modPath)) return false;
    final remaining = int.tryParse(NexusApiService.hourlyRemaining);
    return remaining == null || remaining >= _galleryMinHourlyRemaining;
  }

  static List<Map<String, dynamic>> _galleryEntriesFrom(dynamic raw) {
    final out = <Map<String, dynamic>>[];
    if (raw is! List) return out;
    for (final e in raw) {
      if (e is! Map) continue;
      final image = e['image']?.toString() ?? '';
      if (image.isEmpty) continue;
      out.add(Map<String, dynamic>.from(e));
    }
    return out;
  }

  static String _galleryFileName(int index, String url) {
    const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'};
    final uri = Uri.tryParse(url);
    final last = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : 'image';
    var ext = p.extension(last).toLowerCase();
    if (!allowed.contains(ext)) ext = '.jpg';
    var base = p.basenameWithoutExtension(last).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (base.length > 60) base = base.substring(0, 60);
    if (base.isEmpty) base = 'image';
    return '${(index + 1).toString().padLeft(2, '0')}_$base$ext';
  }

  /// Descarga TODAS las imágenes de la galería de Nexus del mod a
  /// `<mod>/_nexus_gallery/` y guarda en nexus_info.json la ruta local de cada
  /// una (`localImage`). Es idempotente: lo ya descargado no se vuelve a bajar
  /// y, una vez completa, no gasta solicitudes de la API.
  ///
  /// Devuelve true si la galería quedó completa.
  static Future<bool> cacheNexusGallery({
    required Directory modDirectory,
    required String nexusId,
    required String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) return false;
    if (_galleryFailedThisSession.contains(modDirectory.path)) return false;

    final infoFile = File(p.join(modDirectory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) return false;
    final encoder = JsonEncoder.withIndent('  ');

    try {
      final Map<String, dynamic> data = json.decode(await infoFile.readAsString());
      final bool flagged = data['galleryCacheSchema'] is int &&
          (data['galleryCacheSchema'] as int) >= _gallerySchema;

      // Copia duplicada de la portada de una versión anterior: se limpia ya.
      final oldGalleryDir = Directory(p.join(modDirectory.path, galleryDirName));
      if (!flagged && await oldGalleryDir.exists()) {
        final files = await oldGalleryDir.list().where((e) => e is File).length;
        if (files <= 1) {
          await _removeGalleryCopy(modDirectory, data);
          await infoFile.writeAsString(encoder.convert(data));
        }
      }

      var entries = _galleryEntriesFrom(data['gallery']);
      var complete = flagged;

      if (flagged && entries.isEmpty) return true; // mod sin imágenes, ya comprobado

      // Solo se consulta la API si la galería local aún no está marcada como
      // completa; si lo está, únicamente se rellenan archivos que falten.
      if (!flagged || entries.isEmpty) {
        // Aquí sí hace falta la API: se respeta el límite horario.
        if (!canCacheGallery(modDirectory.path)) {
          if (!retryPendingGallery) await _markGalleryAttempt(infoFile);
          return false;
        }
        final nexusData = await NexusApiService.fetchNexusModData(nexusId, apiKey);
        if (nexusData == null) {
          _galleryFailedThisSession.add(modDirectory.path);
          if (!retryPendingGallery) await _markGalleryAttempt(infoFile);
          return false;
        }
        entries = _galleryEntriesFrom(nexusData['gallery']);
        complete = nexusData['galleryComplete'] == true;
      }

      // Sin galería real (no se obtuvo la lista completa, o el mod solo tiene
      // una imagen): esa única imagen es la portada, que ya está guardada como
      // `_nexus_cover.*`. No se copia a `_nexus_gallery` para no duplicarla, y
      // se limpia la copia que hubiera de versiones anteriores.
      if (!complete || entries.length <= 1) {
        final latest = Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
        await _removeGalleryCopy(modDirectory, latest);
        if (complete) {
          latest['galleryCacheSchema'] = _gallerySchema;
        } else {
          latest['galleryAttemptAt'] = DateTime.now().toIso8601String();
          _galleryFailedThisSession.add(modDirectory.path);
        }
        await infoFile.writeAsString(encoder.convert(latest));
        return complete;
      }

      final galleryDir = Directory(p.join(modDirectory.path, galleryDirName));
      await galleryDir.create(recursive: true);

      final keep = <String>{};
      var failures = 0;

      for (var start = 0; start < entries.length; start += _galleryParallelDownloads) {
        final batch = <Future<void>>[];
        for (var i = start; i < entries.length && i < start + _galleryParallelDownloads; i++) {
          final entry = entries[i];
          final url = entry['image'] as String;
          final fileName = _galleryFileName(i, url);
          keep.add(fileName);
          batch.add(() async {
            final file = File(p.join(galleryDir.path, fileName));
            if (await file.exists() && await file.length() > 0) {
              entry['localImage'] = '$galleryDirName/$fileName';
              return;
            }
            try {
              final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
              if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
                await file.writeAsBytes(response.bodyBytes);
                entry['localImage'] = '$galleryDirName/$fileName';
              } else {
                failures++;
                print('[NexusGallery] HTTP ${response.statusCode} al bajar $url');
              }
            } catch (e) {
              failures++;
              print('[NexusGallery] No se pudo bajar $url: $e');
            }
          }());
        }
        await Future.wait(batch);
      }

      // Borra archivos huérfanos (imágenes quitadas o reordenadas en Nexus).
      await for (final e in galleryDir.list()) {
        if (e is File && !keep.contains(p.basename(e.path))) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }

      // Se relee el JSON justo antes de escribir para no pisar otros cambios.
      final latest = Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
      latest['gallery'] = entries;
      final done = complete && failures == 0;
      if (done) latest['galleryCacheSchema'] = _gallerySchema;
      latest['galleryCachedAt'] = DateTime.now().toIso8601String();
      if (!done) latest['galleryAttemptAt'] = DateTime.now().toIso8601String();
      await infoFile.writeAsString(encoder.convert(latest));

      if (!done) _galleryFailedThisSession.add(modDirectory.path);
      print('[NexusGallery] ${p.basename(modDirectory.path)}: '
          '${entries.length - failures}/${entries.length} imágenes en local'
          '${done ? '' : (retryPendingGallery ? ' (incompleta, se reintentará)' : ' (incompleta)')}');
      return done;
    } catch (e) {
      _galleryFailedThisSession.add(modDirectory.path);
      if (!retryPendingGallery) await _markGalleryAttempt(infoFile);
      print('[NexusGallery] Error en ${p.basename(modDirectory.path)}: $e');
      return false;
    }
  }

  static Future<List<ModInfo>> loadMods({
    required String? gameRootPath,
    required String finalModsPath,
    required String genericModsPath,
    required String logicModsPath,
    required String appVersion,
    required String? apiKey,
    bool autoAssignOutfits = true,
  }) async {
    Future<List<ModInfo>> getModsFromDirectory(
      String path,
      bool isEnabled, {
      Set<String> logicModNamesToIgnore = const {},
    }) async {
      final dir = Directory(path);
      if (!await dir.exists()) return [];

      final List<ModInfo> mods = [];
      await for (var entity in dir.list()) {
        if (entity is Directory) {
          final basename = p.basename(entity.path);

          if (path == genericModsPath && logicModNamesToIgnore.contains(basename)) continue;
          final basenameLower = basename.toLowerCase();
          if (path == genericModsPath && (basenameLower == 'customnanosuitsystem' || basenameLower == 'logicmods')) continue;
          if (basename == '__mod_backups__') continue;
          // Animations / Cosmetics del CNS principal: se ignoran (también si
          // quedaron en la carpeta de copias de seguridad).
          if (await isCoreCnsAddon(entity,
              inCnsFolder: p.equals(path, finalModsPath))) {
            continue;
          }

          try {
            String? nexusId;
            String? installedVersion;
            String? origin;
            List<dynamic>? gallery;
            String? fitMeshType;
            String? modType;
            String? customCoverPath;
            Alignment? customCoverAlignment;
            DateTime? customCoverLastModified;
            String folderName = p.basename(entity.path);
            String displayName = ArchiveService.stripVersionFromFolderName(folderName);
            String customName = folderName;
            DateTime modLastModified = DateTime.now();
            String? customVersion;
            String? customFitMeshType;
            String? summary;
            String? customSummary;
            String? description;
            String? customDescription;
            String? author;
            String? customAuthor;
            String? userNotes;
            String? sourceUrl;
            String? customSourceUrl;
            List<String>? replacesOutfits;
            String? modName;
            String? editionName;

            bool isEnabledForMod = isEnabled;
            DateTime? installDate;

            final infoFile = File(p.join(entity.path, 'nexus_info.json'));
            final fileStat = await entity.stat();

            if (await infoFile.exists()) {
              final content = await infoFile.readAsString();
              Map<String, dynamic> data = json.decode(content);

              // Adapta mods antiguos al formato actual (edición, archivo de
              // Nexus, nombre del mod...). Se hace aquí también para los mods
              // de rutas que el arranque no recorre.
              // También asigna los trajes de los mods genéricos / de reemplazo
              // que aún no tienen ninguno (paso local, sin red).
              final bool wantsOutfits = autoAssignOutfits &&
                  ModMetadataMigrator.needsOutfitScan(data);
              if (ModMetadataMigrator.needsMigration(data, appVersion) ||
                  wantsOutfits) {
                print('Auto-updating metadata for mod: ${data['displayName']}');
                final migrated = await ModMetadataMigrator.migrate(
                  modDirectory: entity,
                  data: data,
                  appVersion: appVersion,
                  apiKey: apiKey,
                  assignOutfits: autoAssignOutfits,
                );
                // Los trajes ya quedaron reflejados en `data` (se modifica en
                // el sitio); solo la parte de Nexus necesita recargar el JSON.
                if (migrated) {
                  await cacheNexusThumbnail(
                    modDirectory: entity,
                    nexusId: data['nexusId'].toString(),
                    apiKey: apiKey,
                  );
                  // cacheNexusThumbnail reescribe el JSON (portada): recargar.
                  data = json.decode(await infoFile.readAsString());
                }
              }

              if (data['installDate'] != null) installDate = DateTime.tryParse(data['installDate']);
              modLastModified = installDate ?? fileStat.modified;
              nexusId = data['nexusId'];
              installedVersion = data['installedVersion'];
              origin = data['origin'];
              gallery = data['gallery'];
              fitMeshType = data['fitMeshType'];
              modType = data['modType'] as String?;
              summary = data['summary'];
              customSummary = data['customSummary'];
              description = data['description'];
              customDescription = data['customDescription'];
              author = data['author'];
              customAuthor = data['customAuthor'];
              userNotes = data['userNotes'];
              sourceUrl = data['sourceUrl'];
              customSourceUrl = data['customSourceUrl'];
              modName = data['modName'] as String?;
              editionName = data['editionName'] as String?;
              if (data['replacesOutfits'] != null) {
                replacesOutfits = List<String>.from(data['replacesOutfits']);
              } else if (data['replacesOutfit'] != null) {
                // Compatibilidad con JSONs antiguos
                replacesOutfits = [data['replacesOutfit'] as String];
  }

              if (installedVersion != null && installedVersion.toLowerCase().startsWith('v')) {
                installedVersion = installedVersion.substring(1);
              }

              customCoverPath = data['customCoverPath'];
              if (customCoverPath != null) {
                final coverFile = File(p.join(entity.path, customCoverPath));
                if (await coverFile.exists()) {
                  customCoverLastModified = await coverFile.lastModified();
                }
              }
              if (data['customCoverAlignmentX'] != null && data['customCoverAlignmentY'] != null) {
                customCoverAlignment = Alignment(
                  data['customCoverAlignmentX'].toDouble(),
                  data['customCoverAlignmentY'].toDouble(),
                );
              }
              customVersion = data['customVersion'] as String?;
              customFitMeshType = data['customFitMeshType'] as String?;

              if (data['displayName'] != null) displayName = data['displayName'];
              if (data['customName'] != null) customName = data['customName'];
              else customName = displayName;
            }

            if (modType == null && isEnabled) {
              if (path == genericModsPath) modType = 'genericPak';
              else if (path == finalModsPath) modType = 'cns';
            }

            if (['movies', 'save', 'config', 'splash'].contains(modType) && await infoFile.exists()) {
              final content = await infoFile.readAsString();
              final data = json.decode(content);
              isEnabledForMod = data['isEnabled'] as bool? ?? false;
            }

            if (fitMeshType == null && modType != 'movies') {
              fitMeshType = await getFitMeshTypeForMod(entity);
              if (fitMeshType != null && await infoFile.exists()) {
                try {
                  final content = await infoFile.readAsString();
                  Map<String, dynamic> data = json.decode(content);
                  data['fitMeshType'] = fitMeshType;
                  final encoder = JsonEncoder.withIndent('  ');
                  await infoFile.writeAsString(encoder.convert(data));
                } catch (e) {}
              }
            }

            installedVersion ??= ModInfo.extractVersionFromName(folderName);

            mods.add(ModInfo(
              directory: entity,
              nexusId: nexusId,
              localVersion: installedVersion,
              lastModified: modLastModified,
              installDate: installDate,
              isEnabled: isEnabledForMod,
              origin: origin,
              displayName: displayName,
              customName: customName,
              gallery: gallery,
              fitMeshType: fitMeshType,
              modType: modType,
              customCoverPath: customCoverPath,
              customCoverAlignment: customCoverAlignment,
              customCoverLastModified: customCoverLastModified,
              customVersion: customVersion,
              customFitMeshType: customFitMeshType,
              summary: summary,
              customSummary: customSummary,
              description: description,
              customDescription: customDescription,
              author: author,
              customAuthor: customAuthor,
              userNotes: userNotes,
              sourceUrl: sourceUrl,
              customSourceUrl: customSourceUrl,
              replacesOutfits: replacesOutfits,
              modName: modName,
              editionName: editionName,
            ));
          } catch (e) {
            print("Error processing directory ${entity.path}: $e");
          }
        }
      }
      return mods;
    }

    final enabledLogicMods = await getModsFromDirectory(logicModsPath, true);
    final Set<String> logicModFolderNames = enabledLogicMods.map((mod) => p.basename(mod.directory.path)).toSet();
    final enabledCnsMods = await getModsFromDirectory(finalModsPath, true);
    final enabledGenericMods = await getModsFromDirectory(genericModsPath, true, logicModNamesToIgnore: logicModFolderNames);

    if (gameRootPath == null) {
      return [...enabledCnsMods, ...enabledGenericMods, ...enabledLogicMods];
    }
    
    final backupDirPath = p.join(gameRootPath, 'SB', 'Content', '__MOD_BACKUPS__');
    final disabledMods = await getModsFromDirectory(backupDirPath, false);

    return [...enabledCnsMods, ...enabledGenericMods, ...enabledLogicMods, ...disabledMods];
  }

  static Future<int> runSelfHealing({
    required List<ModInfo> allMods,
    required Map<String, dynamic> modDatabase,
    required String? apiKey,
  }) async {
    int repairedCount = 0;
    for (final mod in List.from(allMods)) {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      bool needsRepair = false;
      if (await infoFile.exists()) {
        try {
          final content = await infoFile.readAsString();
          if (content.trim().isEmpty) {
            needsRepair = true;
          } else {
            final data = json.decode(content) as Map<String, dynamic>;
            final nexusId = data['nexusId'] as String?;
            if (nexusId == null || nexusId.isEmpty) needsRepair = true;
          }
        } catch (e) {
          print('Found malformed nexus_info.json for ${mod.customName}. Error: $e');
          needsRepair = true;
        }
      } else {
        needsRepair = true;
      }

      if (!needsRepair) continue;

      final primaryDisplayName = await getDisplayNameForMod(mod.directory);
      if (primaryDisplayName != null && modDatabase.containsKey(primaryDisplayName)) {
        final dbEntry = modDatabase[primaryDisplayName] as Map<String, dynamic>;
        final nexusId = dbEntry['nexusId'] as String?;
        if (nexusId == null) continue;

        String? version = ModInfo.extractVersionFromName(p.basename(mod.directory.path));
        version ??= await getVersionFromModJsonDescription(mod.directory);

        if (version == null) {
          if (apiKey == null || apiKey.isEmpty) break;
          version = await NexusApiService.fetchLatestModVersion(nexusId, apiKey);
        }

        final compositeDisplayName = await getCompositeDisplayName(mod.directory) ?? primaryDisplayName;
        final currentFolderName = p.basename(mod.directory.path);

        try {
          Map<String, dynamic> modData = {};
          if (await infoFile.exists()) {
            try {
              final content = await infoFile.readAsString();
              if (content.trim().isNotEmpty) modData = json.decode(content);
            } catch (e) {
              print('Could not parse existing nexus_info.json for ${mod.customName}. Creating new.');
            }
          }

          modData['nexusId'] = nexusId;
          modData['displayName'] = compositeDisplayName;
          modData['customName'] ??= currentFolderName;
          modData['installedVersion'] = version;
          modData['installDate'] ??= DateTime.now().toIso8601String();
          modData['origin'] = 'repaired';

          final nexusData = await NexusApiService.fetchNexusModData(nexusId, apiKey);
          if (nexusData != null) {
            modData['gallery'] = nexusData['gallery'];
            modData['summary'] = nexusData['summary'];
            modData['author'] = nexusData['author'];
            modData['description'] = nexusData['description'];
          }

          final encoder = JsonEncoder.withIndent('  ');
          await infoFile.writeAsString(encoder.convert(modData));
          await cacheNexusThumbnail(modDirectory: mod.directory, nexusId: nexusId, apiKey: apiKey);
          repairedCount++;
        } catch (e) {
          print('Could not self-repair mod "$primaryDisplayName": $e');
        }
      }
    }
    return repairedCount;
  }
}