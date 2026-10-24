// lib/services/mod_metadata_migrator.dart
//
// Adapta el nexus_info.json de los mods instalados con versiones antiguas de
// la app al formato actual, para que la app reconozca la EDICIÓN de cada mod
// (modName, editionName, nexusFileId...) y pueda:
//
//   * seguir la cadena de actualizaciones exacta (file_updates) de su archivo,
//   * distinguir "Foo - CNS" de "Foo - Replacer" al instalar o actualizar,
//   * guardar "omitir versión" por edición.
//
// Reglas de seguridad:
//   * NUNCA se renombra la carpeta ni se tocan displayName / customName: son
//     lo que ve el usuario y las rutas ya registradas en el juego.
//   * Solo se RELLENAN campos que faltan (??=). Lo que ya existe se respeta.
//   * El archivo exacto (nexusFileId) solo se asigna cuando Nexus lo confirma
//     sin ambigüedad (id conocido, nombre + versión, o cadena file_updates).
//   * Si no hay archivo exacto pero la heurística de la comprobación de
//     actualizaciones (UpdateService.pickBestFileByName) sí sabe a qué edición
//     pertenece el mod, se guarda solo el nombre de la edición. Así el
//     migrador identifica los mismos mods que ya reconoce el buscador de
//     actualizaciones.
//   * Sin ninguna certeza, el campo queda vacío y la app sigue usando su
//     respaldo (editionName ?? displayName).
//
// TRAJES (mods genéricos y de reemplazo):
//   * Los mods genéricos ('genericPak') y los de reemplazo ('replacement') que
//     aún no tienen ningún traje asignado se analizan con OutfitDetector (lee
//     solo el índice de nombres de sus .pak/.utoc, igual que al instalar).
//   * Es un paso LOCAL: no necesita API key, red ni nexusId, así que también
//     cubre mods instalados desde un archivo suelto.
//   * Si se detectan trajes se guardan en replacesOutfits y el mod pasa a
//     'replacement' (lo mismo que hace la instalación).
//   * Nunca se pisa una selección existente: solo se completan mods SIN trajes.
//   * El análisis se hace UNA sola vez por mod (outfitScanSchema). Así, si el
//     usuario quita los trajes a mano más adelante, no se le vuelven a poner.
//   * Respeta el ajuste "Asignar trajes automáticamente" (assignOutfits).
//   * Los mods a los que se les asignan trajes en esta sesión se anotan en
//     [takeNewlyAssignedOutfitMods] para que la app pueda desactivar los que
//     acaben compartiendo traje con otro mod activo.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import '../utils/version_utils.dart';
import 'archive_service.dart';
import 'nexus_api_service.dart';
import 'nexus_file_identifier.dart';
import 'outfit_detector.dart';
import 'update_service.dart';

class ModMetadataMigrator {
  /// Súbelo cuando vuelvas a cambiar el formato del nexus_info.json. Permite
  /// migrar aunque se te olvide subir la versión del pubspec.
  ///
  ///   2 -> campos de edición (modName, editionName, nexusFileId...)
  ///   3 -> la edición también se identifica con la heurística de las
  ///        actualizaciones (reintenta los mods que el esquema 2 no pudo
  ///        identificar).
  static const int currentSchema = 4;

  /// Versión del análisis de trajes (independiente de [currentSchema], porque
  /// no depende de la red). Súbelo si mejora OutfitDetector y quieres que se
  /// reanalicen los mods que se quedaron sin traje.
  ///
  ///   1 -> primera versión.
  ///   2 -> el detector distingue núcleo (malla/física) de dependencias
  ///        (materiales/texturas). Se reanalizan los mods sin traje y los que
  ///        la app asignó automáticamente ([outfitsAutoDetectedKey]), para
  ///        corregir falsos positivos como "Planet Diving Suit (7th)".
  static const int outfitScanSchema = 2;

  /// Marca en nexus_info.json: los trajes los asignó la detección automática
  /// (no el usuario). Solo esos mods se reanalizan al subir [outfitScanSchema];
  /// una selección manual nunca se toca.
  static const String outfitsAutoDetectedKey = 'outfitsAutoDetected';

  /// Con menos solicitudes restantes en la hora se pausa la migración.
  static const int _minHourlyRemaining = 5;

  /// false = un mod cuya actualización de metadatos de Nexus se intentó y no
  /// llegó a completarse (error, mod retirado, límite de la API...) NO se
  /// vuelve a intentar en los siguientes arranques: se anota
  /// [migrationGivenUpKey] en su nexus_info.json. Ponlo en true para volver al
  /// comportamiento anterior (reintentar los pendientes en cada arranque).
  static const bool retryPendingMetadata = false;
  static const String migrationGivenUpKey = 'metadataMigrationGivenUp';

  /// true solo durante el botón "Actualizar metadatos" de Ajustes: además de
  /// rellenar lo que falta, se refrescan resumen, autor y descripción de Nexus
  /// (los textos personalizados por el usuario viven en otros campos y no se
  /// tocan).
  static bool forceRefresh = false;

  /// Quita de [data] las marcas que impiden reintentar la actualización
  /// ("no reintentar", versión de la app ya migrada, galería ya intentada y, solo
  /// en mods con trajes asignados automáticamente, el análisis de trajes).
  /// Un traje elegido por el usuario nunca se reanaliza. Devuelve true si
  /// cambió algo.
  static bool resetForRefresh(Map<String, dynamic> data) {
    var changed = false;
    for (final key in const [
      'managerVersion',
      migrationGivenUpKey,
      'metadataMigrationGivenUpAt',
      'galleryAttemptAt',
    ]) {
      if (data.remove(key) != null) changed = true;
    }
    if (data[outfitsAutoDetectedKey] == true &&
        data.remove('outfitScanSchema') != null) {
      changed = true;
    }
    return changed;
  }

  /// Olvida los mods que fallaron en esta sesión (para poder reintentarlos).
  static void clearSessionFailures() => _failedThisSession.clear();

  /// ¿Este nexus_info.json necesita migrarse?
  static bool needsMigration(Map<String, dynamic> data, String appVersion) {
    final nexusId = data['nexusId']?.toString();
    if (nexusId == null || nexusId.isEmpty) return false;
    if (!retryPendingMetadata && data[migrationGivenUpKey] == true) {
      return false;
    }

    final managerVersion = data['managerVersion'] as String?;
    if (managerVersion == null) return true;
    if (VersionUtils.compareVersions(appVersion, managerVersion) > 0) {
      return true;
    }
    final rawSchema = data['metadataSchema'];
    final schema = rawSchema is int ? rawSchema : 0;
    if (schema >= currentSchema) return false;
    // Del esquema 2 al 3 solo mejoró la identificación de la edición: los mods
    // que ya la tienen completa no necesitan gastar solicitudes de la API.
    if (schema >= 2) return _identityIncomplete(data);
    return true;
  }

  static bool _identityIncomplete(Map<String, dynamic> data) =>
      data['nexusFileId'] == null || data['editionName'] == null;

  /// ¿Este mod genérico / de reemplazo necesita que se le detecten los trajes?
  ///
  /// Es true solo si todavía no se analizó, no tiene ningún traje asignado y es
  /// un mod genérico o de reemplazo. No exige nexusId: es un análisis local.
  static bool needsOutfitScan(Map<String, dynamic> data) {
    final scanned = data['outfitScanSchema'];
    if (scanned is int && scanned >= outfitScanSchema) return false;

    // Trajes asignados por la propia detección con una versión anterior del
    // análisis: se reevalúan (el detector ha mejorado).
    final current0 = data['replacesOutfits'];
    if (data[outfitsAutoDetectedKey] == true &&
        current0 is List &&
        current0.isNotEmpty) {
      return true;
    }

    // Ya tiene trajes (formato actual o el antiguo de un solo traje): se respeta.
    final current = data['replacesOutfits'];
    if (current is List && current.isNotEmpty) return false;
    final legacy = data['replacesOutfit'];
    if (legacy is String && legacy.isNotEmpty) return false;

    final modType = data['modType'] as String?;
    if (modType == 'genericPak' || modType == 'replacement') return true;
    // Mods muy antiguos: sin modType, pero marcados como "Generic".
    return modType == null && data['fitMeshType'] == 'Generic';
  }

  /// Migra [data] (el contenido de nexus_info.json de [modDirectory]) y lo
  /// guarda en disco.
  ///
  /// Hace dos cosas independientes:
  ///   1) asigna los trajes de los mods genéricos / de reemplazo (local, sin
  ///      red; si [assignOutfits] es true y [needsOutfitScan]);
  ///   2) adapta los metadatos de Nexus (edición, archivo, nombre del mod...).
  ///
  /// Devuelve true si la parte de Nexus se completó. Devuelve false si no hacía
  /// falta, falta la API key, no hay red, el mod ya no existe en Nexus o se
  /// agotó el límite horario. Con [retryPendingMetadata] en false, un intento
  /// que falló no se repite en arranques posteriores.
  /// Los trajes detectados en el paso 1 se guardan (y se reflejan en [data])
  /// aunque devuelva false.
  static Future<bool> migrate({
    required Directory modDirectory,
    required Map<String, dynamic> data,
    required String appVersion,
    required String? apiKey,
    bool assignOutfits = true,
  }) async {
    // 1) Trajes: no depende de la API key, del nexusId ni de la red.
    if (assignOutfits && needsOutfitScan(data)) {
      await _assignOutfits(modDirectory, data);
    }

    // 2) Nexus.
    if (!needsMigration(data, appVersion)) return false;
    if (apiKey == null || apiKey.isEmpty) return false;
    final nexusId = data['nexusId']?.toString();
    if (nexusId == null || nexusId.isEmpty) return false;
    // Un mod que ya falló en esta sesión no se reintenta hasta reiniciar la
    // app (loadMods se ejecuta en cada recarga de la lista).
    if (_failedThisSession.contains(modDirectory.path)) return false;
    if (_apiBudgetLow()) {
      if (!retryPendingMetadata) await _giveUp(modDirectory, data);
      return false;
    }

    final ok = await _migrate(modDirectory, data, appVersion, apiKey, nexusId);
    if (!ok) {
      _failedThisSession.add(modDirectory.path);
      if (!retryPendingMetadata) await _giveUp(modDirectory, data);
    }
    return ok;
  }

  /// Anota en el nexus_info.json que este mod no se reintentará más. Se relee
  /// el archivo antes de escribir para no pisar otros cambios.
  static Future<void> _giveUp(
    Directory modDirectory,
    Map<String, dynamic> data,
  ) async {
    data[migrationGivenUpKey] = true;
    try {
      final file = File(p.join(modDirectory.path, 'nexus_info.json'));
      final latest =
          Map<String, dynamic>.from(json.decode(await file.readAsString()));
      latest[migrationGivenUpKey] = true;
      latest['metadataMigrationGivenUpAt'] = DateTime.now().toIso8601String();
      await file.writeAsString(JsonEncoder.withIndent('  ').convert(latest));
      debugPrint('[ModMetadataMigrator] ${p.basename(modDirectory.path)}: '
          'metadatos pendientes, no se reintentará.');
    } catch (e) {
      debugPrint('[ModMetadataMigrator] No se pudo anotar el abandono en '
          '${modDirectory.path}: $e');
    }
  }

  static final Set<String> _failedThisSession = {};

  /// Carpetas (normalizadas) de los mods a los que la migración acaba de
  /// asignar trajes y que la app aún no ha revisado en busca de conflictos.
  static final Set<String> _newlyAssignedOutfits = {};

  /// Devuelve (y vacía) los mods que recibieron trajes automáticamente desde la
  /// última llamada. Las rutas están normalizadas con `p.normalize`.
  static Set<String> takeNewlyAssignedOutfitMods() {
    final out = Set<String>.of(_newlyAssignedOutfits);
    _newlyAssignedOutfits.clear();
    return out;
  }

  /// ¿Vale la pena intentar migrar este mod ahora? Es false si ya falló en
  /// esta sesión o si queda poco límite horario de la API. Sirve para no
  /// contar (ni mostrar progreso de) mods que [migrate] rechazaría al instante.
  static bool canAttempt(String modPath) =>
      !_failedThisSession.contains(modPath) && !_apiBudgetLow();

  /// Detecta los trajes que reemplaza el mod leyendo sus archivos y los guarda.
  /// Si no encuentra ninguno (mod cifrado, sin índice, de otra cosa...) no toca
  /// el traje, pero anota que ya se analizó para no repetirlo en cada arranque.
  static Future<void> _assignOutfits(
    Directory modDirectory,
    Map<String, dynamic> data,
  ) async {
    try {
      final found = await OutfitDetector.detect(modDirectory);
      final prevRaw = data['replacesOutfits'];
      final prev = prevRaw is List
          ? prevRaw.map((e) => e.toString()).toSet()
          : <String>{};
      // Solo hay algo nuevo que revisar (conflictos) si aparece un traje que
      // antes no estaba; un resultado más estrecho no puede crear choques.
      final gainedOutfit = found.any((o) => !prev.contains(o));
      if (found.isNotEmpty) {
        data['replacesOutfits'] = found;
        data[outfitsAutoDetectedKey] = true;
        // Igual que al instalar: con trajes asignados es un mod de reemplazo.
        data['modType'] = 'replacement';
      }
      data['outfitScanSchema'] = outfitScanSchema;
      await File(p.join(modDirectory.path, 'nexus_info.json'))
          .writeAsString(JsonEncoder.withIndent('  ').convert(data));
      if (found.isNotEmpty && gainedOutfit) {
        _newlyAssignedOutfits.add(p.normalize(modDirectory.path));
      }
      debugPrint('[ModMetadataMigrator] ${p.basename(modDirectory.path)}: '
          '${found.isEmpty ? 'sin trajes detectados' : found}');
    } catch (e) {
      // Sin escribir el marcador: se reintentará en el próximo arranque.
      debugPrint('[ModMetadataMigrator] No se pudieron detectar trajes en '
          '${modDirectory.path}: $e');
    }
  }

  static Future<bool> _migrate(
    Directory modDirectory,
    Map<String, dynamic> data,
    String appVersion,
    String apiKey,
    String nexusId,
  ) async {

    // 1) Metadatos del mod (resumen, autor, galería, nombre del mod...).
    final modData = await NexusApiService.fetchNexusModData(nexusId, apiKey);
    if (modData == null) return false;

    void fill(String key) {
      final value = modData[key];
      if (forceRefresh && value != null) {
        data[key] = value;
      } else {
        data[key] ??= value;
      }
    }

    fill('summary');
    fill('author');
    data['gallery'] ??= modData['gallery'];
    fill('description');
    data['sourceUrl'] ??= 'https://www.nexusmods.com/stellarblade/mods/$nexusId';

    final rawModName = (modData['modName'] as String?)?.trim();
    if (rawModName != null && rawModName.isNotEmpty) {
      data['modName'] ??= NexusFileNameParser.sanitizeDisplayName(rawModName);
    }

    // 2) Edición y archivo exacto de Nexus.
    final needsEdition = data['nexusFileId'] == null || data['editionName'] == null;
    if (needsEdition) {
      if (_apiBudgetLow()) return false;
      final filesData = await NexusApiService.fetchModFiles(
        nexusId,
        apiKey,
        includeOldVersions: true,
      );
      if (filesData == null) return false;
      _applyEdition(
        data,
        filesData,
        fallbackName: ArchiveService.stripVersionFromFolderName(
          p.basename(modDirectory.path),
        ),
      );
    }

    data['managerVersion'] = appVersion;
    data['metadataSchema'] = currentSchema;

    await File(p.join(modDirectory.path, 'nexus_info.json'))
        .writeAsString(JsonEncoder.withIndent('  ').convert(data));
    return true;
  }

  // ---------------------------------------------------------------------------

  static bool _apiBudgetLow() {
    final remaining = int.tryParse(NexusApiService.hourlyRemaining);
    return remaining != null && remaining < _minHourlyRemaining;
  }

  static String _compact(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Nombre de edición de un archivo de Nexus, igual que lo calcula
  /// NexusFileIdentifier al instalar (para que ambos coincidan).
  static String _editionOf(Map<String, dynamic> file) {
    final version = _versionOf(file);
    return NexusFileNameParser.sanitizeDisplayName(
      (file['name'] ?? '').toString(),
      version: version,
    );
  }

  static String? _versionOf(Map<String, dynamic> file) {
    final raw = (file['version'] ?? '').toString().trim().isNotEmpty
        ? file['version'].toString()
        : (file['mod_version'] ?? '').toString();
    return raw.trim().isEmpty ? null : NexusFileNameParser.normalizeVersion(raw);
  }

  static void _applyEdition(
    Map<String, dynamic> data,
    Map<String, dynamic> filesData, {
    required String fallbackName,
  }) {
    final files = ((filesData['files'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (files.isEmpty) return;

    final installedRaw = (data['installedVersion'] ?? '').toString().trim();
    final installed = installedRaw.isEmpty
        ? null
        : NexusFileNameParser.normalizeVersion(installedRaw);

    bool sameVersion(Map<String, dynamic> f) {
      final v = _versionOf(f);
      return installed != null &&
          v != null &&
          VersionUtils.compareVersions(v, installed) == 0;
    }

    // a) El mod ya tenía nexusFileId: es la fuente más fiable.
    final knownId = data['nexusFileId']?.toString();
    Map<String, dynamic>? exact;
    if (knownId != null) {
      for (final f in files) {
        if (f['file_id']?.toString() == knownId) {
          exact = f;
          break;
        }
      }
    }

    // b) Buscar por nombre (displayName antiguo = nombre del archivo de Nexus,
    //    o "Mod - Edición" si ya era el nombre compuesto).
    String? editionByName;
    if (exact == null) {
      final display = _compact(
        NexusFileNameParser.sanitizeDisplayName(
          (data['displayName'] ?? '').toString(),
          version: installed,
        ),
      );
      final modName = data['modName']?.toString();

      final sameName = display.isEmpty
          ? <Map<String, dynamic>>[]
          : files.where((f) {
              final edition = _editionOf(f);
              if (edition.isEmpty) return false;
              return _compact(edition) == display ||
                  _compact(NexusFileNameParser.composeModEditionName(
                          modName, edition)) ==
                      display;
            }).toList();

      if (sameName.isNotEmpty) {
        editionByName = _editionOf(sameName.first);
        final byVersion = sameName.where(sameVersion).toList();
        if (byVersion.length == 1) exact = byVersion.first;
      } else {
        // c) Mod de una sola edición: si TODOS sus archivos (también los
        //    antiguos) comparten el mismo nombre, no hay ambigüedad posible.
        final names = files.map((f) => _compact(_editionOf(f))).toSet();
        if (names.length == 1 && names.first.isNotEmpty) {
          editionByName = _editionOf(files.first);
          final byVersion = files.where(sameVersion).toList();
          if (byVersion.length == 1) exact = byVersion.first;
        }
      }
    }

    // d) Lo que no resolvieron las reglas estrictas se intenta con la MISMA
    //    heurística que usa la comprobación de actualizaciones para saber a qué
    //    edición pertenece un mod (preferencia CNS, coincidencia de nombre...).
    var identifiedBy = 'apiMigration';
    String? editionOverride;
    if (exact == null) {
      final knownEdition = (data['editionName'] ?? '').toString().trim();
      final display = (data['displayName'] ?? '').toString().trim();
      final nameForMatch = knownEdition.isNotEmpty
          ? knownEdition
          : (display.isNotEmpty ? display : fallbackName);

      final match = _matchByUpdateHeuristic(
        files: files,
        fileUpdates: (filesData['file_updates'] as List?) ?? const [],
        displayName: nameForMatch,
        installed: installed,
      );
      if (match != null) {
        identifiedBy = 'apiMigrationUpdateMatch';
        if (match.exact != null) exact = match.exact;
        if (match.edition.isNotEmpty) {
          editionOverride = match.edition;
          if (editionByName == null || editionByName.isEmpty) {
            editionByName = match.edition;
          }
        }
      }
    }

    if (exact != null) {
      data['nexusFileId'] ??= exact['file_id']?.toString();
      data['nexusFileName'] ??= exact['file_name']?.toString();
      final edition = (editionOverride != null && editionOverride.isNotEmpty)
          ? editionOverride
          : _editionOf(exact);
      if (edition.isNotEmpty) data['editionName'] ??= edition;
      data['identifiedBy'] ??= identifiedBy;
    } else if (editionByName != null && editionByName.isNotEmpty) {
      // Se sabe la edición pero no el archivo exacto (versión no reconocida).
      data['editionName'] ??= editionByName;
      data['identifiedBy'] ??= identifiedBy;
    }
    // Sin certeza: no se inventa nada.
  }

  static bool _sameVersion(Map<String, dynamic> file, String? installed) {
    final v = _versionOf(file);
    return installed != null &&
        v != null &&
        VersionUtils.compareVersions(v, installed) == 0;
  }

  /// Aplica la heurística de nombre de las actualizaciones y, con el archivo
  /// vigente de la edición que elija, localiza el archivo INSTALADO:
  ///   1) recorriendo hacia atrás la cadena file_updates hasta la versión
  ///      instalada, o
  ///   2) buscando un único archivo con el mismo nombre de edición y versión.
  /// Si no se puede fijar el archivo exacto, devuelve solo el nombre de la
  /// edición (nunca se asigna un nexusFileId que no coincida con la versión).
  static _EditionMatch? _matchByUpdateHeuristic({
    required List<Map<String, dynamic>> files,
    required List<dynamic> fileUpdates,
    required String displayName,
    required String? installed,
  }) {
    if (displayName.trim().isEmpty) return null;

    final dynamic picked = UpdateService.pickBestFileByName(
      allFiles: files,
      displayName: displayName,
    );
    if (picked is! Map) return null;
    final best = Map<String, dynamic>.from(picked);

    final edition = _editionOf(best);
    if (edition.isEmpty) return null;

    Map<String, dynamic>? exact;
    if (installed != null) {
      // 1) Cadena de actualizaciones: del archivo vigente hacia los antiguos.
      final previousOf = <String, String>{}; // nuevo -> anterior
      for (final u in fileUpdates) {
        if (u is! Map) continue;
        final oldId = u['old_file_id']?.toString();
        final newId = u['new_file_id']?.toString();
        if (oldId != null && newId != null) previousOf[newId] = oldId;
      }
      final byId = <String, Map<String, dynamic>>{
        for (final f in files)
          if (f['file_id'] != null) f['file_id'].toString(): f,
      };

      var currentId = best['file_id']?.toString();
      final visited = <String>{};
      while (currentId != null && visited.add(currentId)) {
        final f = byId[currentId];
        if (f != null && _sameVersion(f, installed)) {
          exact = f;
          break;
        }
        currentId = previousOf[currentId];
      }

      // 2) Mismo nombre de edición y misma versión (autor sin enlazar la
      //    cadena de actualizaciones).
      if (exact == null) {
        final target = _compact(edition);
        final same = files
            .where((f) =>
                _compact(_editionOf(f)) == target && _sameVersion(f, installed))
            .toList();
        if (same.length == 1) exact = same.first;
      }
    }

    return _EditionMatch(edition: edition, exact: exact);
  }
}

/// Resultado de [ModMetadataMigrator._matchByUpdateHeuristic].
class _EditionMatch {
  final String edition;
  final Map<String, dynamic>? exact;
  const _EditionMatch({required this.edition, this.exact});
}