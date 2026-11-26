import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/mod_info.dart';
import '../utils/version_utils.dart';
import 'nexus_auth.dart';

class UpdateCheckResult {
  final Map<String, dynamic>? cnsUpdateInfo;
  final Map<String, Map<String, dynamic>> modUpdates;
  final int updatesFound;
  final String? error;

  UpdateCheckResult({
    this.cnsUpdateInfo,
    required this.modUpdates,
    required this.updatesFound,
    this.error,
  });
}

class UpdateService {
  static String _normalizeName(String name) {
    final withoutExtension = p.basenameWithoutExtension(name);
    return withoutExtension.toLowerCase().replaceAll(RegExp(r'[_ -]'), '');
  }

  static String _compact(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Clave con la que se guarda "Omitir esta versión" para un mod instalado.
  /// Es POR EDICIÓN (`<nexusId>#<edición>`): omitir la actualización de
  /// "Alt Goth Mini Set - CNS" no oculta la de "Alt Goth Mini Set - Replacer".
  static String editionSkipKey(ModInfo mod) =>
      '${mod.nexusId}#${_compact(mod.editionName ?? mod.displayName)}';

  /// Versión omitida para [mod]. Primero la de su edición; si no hay, y solo
  /// cuando es la única edición instalada, se respeta la clave antigua
  /// (solo `<nexusId>`) guardada antes de que existieran las ediciones.
  static String? skippedVersionFor(
    Map<String, String> skipped,
    ModInfo mod, {
    required bool soleEdition,
  }) {
    final byEdition = skipped[editionSkipKey(mod)];
    if (byEdition != null) return byEdition;
    return soleEdition ? skipped[mod.nexusId] : null;
  }

  /// Sigue `file_updates` desde [fileId] hasta el archivo más reciente de esa
  /// línea de versiones y devuelve su id (el mismo [fileId] si no hay nuevos).
  static String _followUpdateChain(String fileId, List<dynamic> fileUpdates) {
    final Map<String, String> nextOf = {};
    for (final u in fileUpdates) {
      if (u is! Map) continue;
      final oldId = u['old_file_id']?.toString();
      final newId = u['new_file_id']?.toString();
      if (oldId != null && newId != null) nextOf[oldId] = newId;
    }

    var current = fileId;
    final visited = <String>{current};
    while (nextOf.containsKey(current)) {
      final next = nextOf[current]!;
      if (!visited.add(next)) break;
      current = next;
    }
    return current;
  }

  /// Elige, entre los archivos VIGENTES de un mod (MAIN / OPTIONAL), el que
  /// corresponde a [displayName]: descarta las variantes "sin CNS", prefiere las
  /// que llevan "cns" en el nombre y puntúa por coincidencia de nombre/palabras.
  ///
  /// Es la heurística que usa la comprobación de actualizaciones para saber a
  /// qué edición pertenece un mod; el migrador de metadatos la reutiliza para
  /// identificar la edición de los mods antiguos. Devuelve null si no hay un
  /// candidato razonable.
  static dynamic pickBestFileByName({
    required List allFiles,
    required String displayName,
  }) {
    final potentialFiles = allFiles.where((file) =>
        file['category_name'] == 'MAIN' || file['category_name'] == 'OPTIONAL').toList();

    final compatibleFiles = potentialFiles.where((file) {
      final fileName = (file['file_name'] as String).toLowerCase();
      return !fileName.contains('not cns') &&
             !fileName.contains('without cns') &&
             !fileName.contains('non cns');
    }).toList();

    if (compatibleFiles.isEmpty) return null;

    final cnsFiles = compatibleFiles.where((file) =>
        (file['file_name'] as String).toLowerCase().contains('cns')).toList();

    final filesToConsider = cnsFiles.isNotEmpty ? cnsFiles : compatibleFiles;
    dynamic bestMatchFile;

    if (filesToConsider.length == 1) {
      bestMatchFile = filesToConsider.first;
    } else {
      final normalizedDisplayName = _normalizeName(displayName);
      final keywords = displayName.toLowerCase().split(RegExp(r'[_ -]')).where((s) => s.isNotEmpty).toList();

      final fileScores = filesToConsider.map((file) {
        final rawFileName = file['file_name'] as String;
        final normalizedFileName = _normalizeName(rawFileName);
        int score = 0;

        if (normalizedFileName.contains(normalizedDisplayName)) {
          score = 100;
        } else {
          for (final keyword in keywords) {
            if (normalizedFileName.contains(keyword)) score++;
          }
        }
        return {'file': file, 'score': score};
      }).toList();

      fileScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      if (fileScores.isNotEmpty && (fileScores.first['score'] as int) > 0) {
        bestMatchFile = fileScores.first['file'];
      }
    }
    return bestMatchFile;
  }

  static Future<Map<String, dynamic>?> checkSingleModUpdate({
    required String apiKey,
    required String nexusId,
    required String localVersion,
    required bool hasLocalVersion,
    required String displayName,
    required Directory modDirectory,
    required Map<String, String> skippedVersions,
    // Edición concreta que se comprueba (null = el CNS u otro sin ediciones).
    // Con ella, la versión omitida se busca por edición y no por mod.
    ModInfo? editionMod,
    bool soleEdition = true,
  }) async {
    final String? skippedVersion = editionMod != null
        ? skippedVersionFor(skippedVersions, editionMod, soleEdition: soleEdition)
        : skippedVersions[nexusId];
    final headers = await NexusAuth.headers(apiKey);
    final url = Uri.parse('https://api.nexusmods.com/v1/games/stellarblade/mods/$nexusId/files.json');

    // file_id del archivo de Nexus instalado (si se reconoció al instalarlo)
    String? localFileId;
    try {
      final localInfo = File(p.join(modDirectory.path, 'nexus_info.json'));
      if (await localInfo.exists()) {
        final localData = json.decode(await localInfo.readAsString());
        localFileId = localData['nexusFileId']?.toString();
      }
    } catch (_) {}

    final response = await http.get(url, headers: headers);

    try {
      final infoFile = File(p.join(modDirectory.path, 'nexus_info.json'));
      if (await infoFile.exists()) {
        final modData = json.decode(await infoFile.readAsString());
        modData['lastUpdateCheck'] = {
          'timestamp': DateTime.now().toIso8601String(),
          'statusCode': response.statusCode,
        };
        await infoFile.writeAsString(JsonEncoder.withIndent('  ').convert(modData));
      }
    } catch (e) {
      print('Could not update lastUpdateCheck for $displayName: $e');
    }

    if (response.statusCode != 200) return null;

    final jsonResponse = json.decode(response.body);
    final allFiles = jsonResponse['files'] as List;

    // Camino exacto: seguir la cadena de actualizaciones de ESE archivo.
    if (localFileId != null) {
      final newestId = _followUpdateChain(
        localFileId,
        (jsonResponse['file_updates'] as List?) ?? const [],
      );
      dynamic exactFile;
      for (final f in allFiles) {
        if (f['file_id']?.toString() == newestId) {
          exactFile = f;
          break;
        }
      }
      if (exactFile != null) {
        final latestVersion = exactFile['version'] as String;
        final isSkipped = skippedVersion != null &&
            VersionUtils.compareVersions(latestVersion, skippedVersion) <= 0;
        if (hasLocalVersion &&
            !isSkipped &&
            VersionUtils.compareVersions(latestVersion, localVersion) > 0) {
          return {
            'version': latestVersion,
            'fileId': exactFile['file_id'] as int,
          };
        }
        return null;
      }
      // Si el archivo ya no existe en Nexus se usa la búsqueda por nombre.
    }

    final dynamic bestMatchFile =
        pickBestFileByName(allFiles: allFiles, displayName: displayName);

    if (bestMatchFile != null) {
      final latestVersion = bestMatchFile['version'] as String;
      final isSkipped = skippedVersion != null && VersionUtils.compareVersions(latestVersion, skippedVersion) <= 0;

      if (hasLocalVersion && !isSkipped && VersionUtils.compareVersions(latestVersion, localVersion) > 0) {
        return {
          'version': latestVersion,
          'fileId': bestMatchFile['file_id'] as int,
        };
      }
    }
    return null;
  }

  static Future<UpdateCheckResult> checkForAllUpdates({
    required String apiKey,
    required String? cnsNexusId,
    required String? cnsVersion,
    required String? gameRootPath,
    required List<ModInfo> allMods,
    required Map<String, String> skippedVersions,
  }) async {
    final List<Future<Map<String, dynamic>?>> futures = [];
    final List<String> paths = [];
    final List<bool> isCnsList = [];

    if (cnsNexusId != null && cnsNexusId.isNotEmpty && gameRootPath != null) {
      futures.add(checkSingleModUpdate(
        apiKey: apiKey,
        nexusId: cnsNexusId,
        localVersion: cnsVersion ?? '0',
        hasLocalVersion: cnsVersion != null,
        displayName: "Custom Nanosuit System",
        modDirectory: Directory(p.join(gameRootPath, 'SB', 'Binaries', 'Win64', 'ue4ss')),
        skippedVersions: skippedVersions,
      ));
      paths.add('');
      isCnsList.add(true);
    }

    final allModsWithNexusId = allMods.where((mod) => mod.nexusId != null && mod.nexusId!.isNotEmpty).toList();
    final Map<String, int> editionsPerMod = {};
    for (final m in allModsWithNexusId) {
      editionsPerMod[m.nexusId!] = (editionsPerMod[m.nexusId!] ?? 0) + 1;
    }
    
    for (final mod in allModsWithNexusId) {
      final String versionForCheck = mod.customVersion?.isNotEmpty == true
          ? mod.customVersion!
          : mod.localVersion ?? '0';

      final bool hasVersionForCheck = (mod.customVersion?.isNotEmpty == true) || 
                                      (mod.localVersion?.isNotEmpty == true);

      futures.add(checkSingleModUpdate(
        apiKey: apiKey,
        nexusId: mod.nexusId!,
        localVersion: versionForCheck,
        hasLocalVersion: hasVersionForCheck,
        // Con ediciones, el nombre de la edición es lo que distingue los archivos
        // del mod en Nexus (solo se usa si no hay file_id guardado).
        displayName: mod.editionName ?? mod.displayName,
        modDirectory: mod.directory,
        skippedVersions: skippedVersions,
        editionMod: mod,
        soleEdition: editionsPerMod[mod.nexusId!] == 1,
      ));
      paths.add(mod.directory.path);
      isCnsList.add(false);
    }

    if (futures.isEmpty) {
      return UpdateCheckResult(modUpdates: {}, updatesFound: 0);
    }

    try {
      final results = await Future.wait(futures);
      int updatesFound = 0;
      Map<String, dynamic>? cnsUpdateInfo;
      final Map<String, Map<String, dynamic>> modUpdates = {};

      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        if (result != null) {
          updatesFound++;
          if (isCnsList[i]) {
            cnsUpdateInfo = result;
          } else {
            modUpdates[paths[i]] = result;
          }
        }
      }

      return UpdateCheckResult(
        cnsUpdateInfo: cnsUpdateInfo,
        modUpdates: modUpdates,
        updatesFound: updatesFound,
      );
    } catch (e) {
      return UpdateCheckResult(
        modUpdates: {},
        updatesFound: 0,
        error: e.toString(),
      );
    }
  }
}