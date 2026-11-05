import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'file_manager_service.dart';

/// No existe el manifiesto de instalación. El texto visible se genera en la UI
/// con l10n.errorManifestNotFound.
class InstallManifestNotFoundException implements Exception {
  const InstallManifestNotFoundException();

  @override
  String toString() => 'Installation manifest not found. Cannot uninstall.';
}

class CoreInstallerService {
  static const String defaultUe4ssManifestContent = r'''
  ["dwmapi.dll","ue4ss","ue4ss/Default_UVTD_Configs","ue4ss/Default_UVTD_Configs/Config","ue4ss/Default_UVTD_Configs/Config/case_preserving_variants.json","ue4ss/Default_UVTD_Configs/Config/member_rename_map.json","ue4ss/Default_UVTD_Configs/Config/object_items.json","ue4ss/Default_UVTD_Configs/Config/pdbs_to_dump.json","ue4ss/Default_UVTD_Configs/Config/private_variables.json","ue4ss/Default_UVTD_Configs/Config/types_not_to_dump.json","ue4ss/Default_UVTD_Configs/Config/uprefix_to_fprefix.json","ue4ss/Default_UVTD_Configs/Config/valid_udt_names.json","ue4ss/Default_UVTD_Configs/Config/virtual_generator_includes.json","ue4ss/LICENSE","ue4ss/Mods","ue4ss/Mods/ActorDumperMod","ue4ss/Mods/ActorDumperMod/Scripts","ue4ss/Mods/ActorDumperMod/Scripts/main.lua","ue4ss/Mods/BPML_GenericFunctions","ue4ss/Mods/BPML_GenericFunctions/Scripts","ue4ss/Mods/BPML_GenericFunctions/Scripts/main.lua","ue4ss/Mods/BPModLoaderMod","ue4ss/Mods/BPModLoaderMod/load_order.txt","ue4ss/Mods/BPModLoaderMod/Scripts","ue4ss/Mods/BPModLoaderMod/Scripts/main.lua","ue4ss/Mods/CheatManagerEnablerMod","ue4ss/Mods/CheatManagerEnablerMod/Scripts","ue4ss/Mods/CheatManagerEnablerMod/Scripts/main.lua","ue4ss/Mods/ConsoleCommandsMod","ue4ss/Mods/ConsoleCommandsMod/Scripts","ue4ss/Mods/ConsoleCommandsMod/Scripts/dump_object.lua","ue4ss/Mods/ConsoleCommandsMod/Scripts/main.lua","ue4ss/Mods/ConsoleCommandsMod/Scripts/set.lua","ue4ss/Mods/ConsoleCommandsMod/Scripts/summon_unloaded_assets.lua","ue4ss/Mods/ConsoleEnablerMod","ue4ss/Mods/ConsoleEnablerMod/Scripts","ue4ss/Mods/ConsoleEnablerMod/Scripts/main.lua","ue4ss/Mods/jsbLuaProfilerMod","ue4ss/Mods/jsbLuaProfilerMod/Scripts","ue4ss/Mods/jsbLuaProfilerMod/Scripts/main.lua","ue4ss/Mods/Keybinds","ue4ss/Mods/Keybinds/Scripts","ue4ss/Mods/Keybinds/Scripts/main.lua","ue4ss/Mods/LineTraceMod","ue4ss/Mods/LineTraceMod/Scripts","ue4ss/Mods/LineTraceMod/Scripts/main.lua","ue4ss/Mods/mods.json","ue4ss/Mods/mods.txt","ue4ss/Mods/shared","ue4ss/Mods/shared/jsbProfiler","ue4ss/Mods/shared/jsbProfiler/jsbProfi.lua","ue4ss/Mods/shared/Types.lua","ue4ss/Mods/shared/UEHelpers","ue4ss/Mods/shared/UEHelpers/UEHelpers.lua","ue4ss/Mods/SplitScreenMod","ue4ss/Mods/SplitScreenMod/Scripts","ue4ss/Mods/SplitScreenMod/Scripts/main.lua","ue4ss/UE4SS-settings.ini","ue4ss/UE4SS.dll","ue4ss/UE4SS_Signatures","ue4ss/UE4SS_Signatures/FName_ToString.lua.example","ue4ss/UE4SS_Signatures/FText_Constructor.lua","ue4ss/UE4SS_Signatures/GNatives.lua","ue4ss/UE4SS_Signatures/GUObjectArray.lua","ue4ss/UE4SS_Signatures/GUObjectArray.lua.example","ue4ss/VTableLayout.ini"]
  ''';

  static const String defaultCnsManifestContent = r'''
  ["Binaries","Binaries/Win64","Binaries/Win64/ue4ss","Binaries/Win64/ue4ss/Mods","Binaries/Win64/ue4ss/Mods/DekCNS","Binaries/Win64/ue4ss/Mods/DekCNS/enabled.txt","Binaries/Win64/ue4ss/Mods/DekCNS/Scripts","Binaries/Win64/ue4ss/Mods/DekCNS/Scripts/config.lua","Binaries/Win64/ue4ss/Mods/DekCNS/Scripts/json.lua","Binaries/Win64/ue4ss/Mods/DekCNS/Scripts/main.lua","Binaries/Win64/ue4ss/nexus_info.json","Content","Content/Paks","Content/Paks/LogicMods","Content/Paks/LogicMods/DekCNS_P.pak","Content/Paks/LogicMods/DekCNS_P.ucas","Content/Paks/LogicMods/DekCNS_P.utoc","Content/Paks/~mods","Content/Paks/~mods/CustomNanosuitSystem","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultAccessories.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultEarrings.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultFaces.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultHairs.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultOutfits.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultOutfitsAdam.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultOutfitsDrone.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultOutfitsLily.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-DefaultWeaponsTest.dekcns.json","Content/Paks/~mods/CustomNanosuitSystem/DekCNS-Defaults.dekcns.json"]
  ''';

  static Future<List<String>> generateInstallManifest(Directory sourceDir, String basePath) async {
    final List<String> paths = [];
    await for (final entity in sourceDir.list(recursive: true, followLinks: false)) {
      final relativePath = p.relative(entity.path, from: basePath);
      paths.add(relativePath.replaceAll(r'\', '/'));
    }
    return paths;
  }

  static Future<String?> getVersionFromCnsPackage(Directory sourceSBDir) async {
    try {
      final luaFile = File(
        p.join(sourceSBDir.path, 'Binaries', 'Win64', 'ue4ss', 'Mods', 'DekCNS', 'Scripts', 'main.lua'),
      );
      if (await luaFile.exists()) {
        final content = await luaFile.readAsString();
        final regex = RegExp(r'local CNS_Version = "(.+)"');
        final match = regex.firstMatch(content);
        if (match != null && match.group(1) != null) {
          return match.group(1);
        }
      }
    } catch (e) {
      print("No se pudo leer la versión del paquete CNS: $e");
    }
    return null;
  }

  static Future<void> uninstallCoreComponent({
    required bool isUe4ss,
    required String gameRootPath,
  }) async {
    final manifestName = isUe4ss ? 'ue4ss_manifest.json' : 'cns_manifest.json';
    final manifestFile = File(
      p.join(gameRootPath, 'SB', 'Binaries', 'Win64', '_manager_metadata', manifestName),
    );

    if (!await manifestFile.exists()) {
      throw InstallManifestNotFoundException();
    }

    final content = await manifestFile.readAsString();
    final List<String> relativePaths = List<String>.from(json.decode(content));

    final String baseDeletePath = isUe4ss
        ? p.join(gameRootPath, 'SB', 'Binaries', 'Win64')
        : p.join(gameRootPath, 'SB');

    for (final relativePath in relativePaths.reversed) {
      final fullPath = p.join(baseDeletePath, relativePath);
      try {
        final entityType = await FileSystemEntity.type(fullPath, followLinks: false);
        if (entityType == FileSystemEntityType.file) {
          await File(fullPath).delete();
        } else if (entityType == FileSystemEntityType.directory) {
          await Directory(fullPath).delete();
        }
      } catch (e) {
        print("Could not delete entity $fullPath: $e");
      }
    }

    await manifestFile.delete();
  }

  static Future<void> installUE4SS({
    required Directory sourceDir,
    required String gameRootPath,
  }) async {
    final manifestDir = Directory(p.join(gameRootPath, 'SB', 'Binaries', 'Win64', '_manager_metadata'));
    if (!await manifestDir.exists()) await manifestDir.create(recursive: true);
    final manifestFile = File(p.join(manifestDir.path, 'ue4ss_manifest.json'));

    final newPaths = await generateInstallManifest(sourceDir, sourceDir.path);
    Set<String> finalPaths = newPaths.toSet();
    
    if (await manifestFile.exists()) {
      try {
        final oldContent = await manifestFile.readAsString();
        finalPaths.addAll(List<String>.from(json.decode(oldContent)));
      } catch (e) {
        print("No se pudo leer el manifiesto antiguo de UE4SS, será reemplazado. Error: $e");
      }
    }

    await manifestFile.writeAsString(json.encode(finalPaths.toList()));

    final destinationDir = Directory(p.join(gameRootPath, 'SB', 'Binaries', 'Win64'));
    await FileManagerService.copyDirectory(sourceDir, destinationDir);
  }

  static Future<void> installCNS({
    required Directory sourceSBDir,
    required String gameRootPath,
  }) async {
    final manifestDir = Directory(p.join(gameRootPath, 'SB', 'Binaries', 'Win64', '_manager_metadata'));
    if (!await manifestDir.exists()) await manifestDir.create(recursive: true);
    final manifestFile = File(p.join(manifestDir.path, 'cns_manifest.json'));

    final newPaths = await generateInstallManifest(sourceSBDir, sourceSBDir.path);
    Set<String> finalPaths = newPaths.toSet();
    
    if (await manifestFile.exists()) {
      try {
        final oldContent = await manifestFile.readAsString();
        finalPaths.addAll(List<String>.from(json.decode(oldContent)));
      } catch (e) {
        print("No se pudo leer el manifiesto antiguo de CNS, será reemplazado. Error: $e");
      }
    }

    await manifestFile.writeAsString(json.encode(finalPaths.toList()));

    final destinationSBDir = Directory(p.join(gameRootPath, 'SB'));
    await FileManagerService.copyDirectory(sourceSBDir, destinationSBDir);
  }

  // ---------------------------------------------------------------------------
  //  Apartar / restaurar componentes (usado por "Reparar inicio del juego")
  //  Los archivos NO se borran: se MUEVEN a una carpeta de respaldo y luego se
  //  devuelven a su sitio, junto con su manifiesto de instalación.
  // ---------------------------------------------------------------------------

  static String repairBackupPath(String gameRootPath) => p.join(
        gameRootPath, 'SB', 'Binaries', 'Win64', '_manager_metadata', '_repair_backup');

  static File _repairJournalFile(String gameRootPath) =>
      File(p.join(repairBackupPath(gameRootPath), 'journal.json'));

  static String _coreBaseDir(bool isUe4ss, String gameRootPath) => isUe4ss
      ? p.join(gameRootPath, 'SB', 'Binaries', 'Win64')
      : p.join(gameRootPath, 'SB');

  static File _coreManifestFile(bool isUe4ss, String gameRootPath) => File(
        p.join(
          gameRootPath, 'SB', 'Binaries', 'Win64', '_manager_metadata',
          isUe4ss ? 'ue4ss_manifest.json' : 'cns_manifest.json',
        ),
      );

  static String _stashName(bool isUe4ss) => isUe4ss ? 'ue4ss' : 'cns';

  /// Mueve un archivo (rename; si falla, copia + borra). Sobrescribe el destino.
  static Future<void> _moveFile(File src, String destPath) async {
    await Directory(p.dirname(destPath)).create(recursive: true);
    final dest = File(destPath);
    if (await dest.exists()) await dest.delete();
    try {
      await src.rename(destPath);
    } on FileSystemException {
      await src.copy(destPath);
      await src.delete();
    }
  }

  /// Crea la marca que indica "hay una reparación en curso". Si la app se
  /// cierra a mitad, en el siguiente inicio se recuperan los archivos.
  static Future<void> beginRepairJournal(String gameRootPath) async {
    final journal = _repairJournalFile(gameRootPath);
    await journal.parent.create(recursive: true);
    await journal.writeAsString(
      json.encode({'startedAt': DateTime.now().toIso8601String()}),
    );
  }

  static Future<bool> hasPendingRepair(String gameRootPath) =>
      _repairJournalFile(gameRootPath).exists();

  /// Desinstala un componente guardando sus archivos para reinstalarlo luego.
  /// Devuelve false si el componente no estaba instalado (no hay nada que hacer).
  static Future<bool> stashCoreComponent({
    required bool isUe4ss,
    required String gameRootPath,
  }) async {
    final manifestFile = _coreManifestFile(isUe4ss, gameRootPath);
    if (!await manifestFile.exists()) return false;

    final relativePaths = List<String>.from(
      json.decode(await manifestFile.readAsString()),
    );

    final stashDir = p.join(repairBackupPath(gameRootPath), _stashName(isUe4ss));
    final filesDir = p.join(stashDir, 'files');
    await Directory(filesDir).create(recursive: true);
    // El manifiesto se guarda ANTES de mover nada.
    await manifestFile.copy(p.join(stashDir, 'manifest.json'));

    final baseDir = _coreBaseDir(isUe4ss, gameRootPath);

    // 1) Mover los archivos al respaldo.
    for (final rel in relativePaths) {
      final fullPath = p.join(baseDir, rel);
      final type = await FileSystemEntity.type(fullPath, followLinks: false);
      if (type == FileSystemEntityType.file) {
        await _moveFile(File(fullPath), p.join(filesDir, rel));
      }
    }

    // 2) Quitar las carpetas que hayan quedado vacías (de la más profunda a la
    //    más superficial). Si una carpeta aún tiene archivos de otros mods,
    //    simplemente no se borra.
    for (final rel in relativePaths.reversed) {
      final fullPath = p.join(baseDir, rel);
      try {
        final type = await FileSystemEntity.type(fullPath, followLinks: false);
        if (type == FileSystemEntityType.directory) {
          await Directory(fullPath).delete();
        }
      } catch (_) {}
    }

    await manifestFile.delete();
    return true;
  }

  /// Devuelve a su sitio los archivos apartados con [stashCoreComponent] y
  /// restaura el manifiesto. Devuelve false si no había nada apartado.
  static Future<bool> restoreStashedComponent({
    required bool isUe4ss,
    required String gameRootPath,
  }) async {
    final stashDir = Directory(
      p.join(repairBackupPath(gameRootPath), _stashName(isUe4ss)),
    );
    if (!await stashDir.exists()) return false;

    final baseDir = _coreBaseDir(isUe4ss, gameRootPath);
    final filesDir = Directory(p.join(stashDir.path, 'files'));

    if (await filesDir.exists()) {
      final files = await filesDir
          .list(recursive: true, followLinks: false)
          .where((e) => e is File)
          .toList();
      for (final entity in files) {
        final rel = p.relative(entity.path, from: filesDir.path);
        await _moveFile(entity as File, p.join(baseDir, rel));
      }
    }

    final stashedManifest = File(p.join(stashDir.path, 'manifest.json'));
    if (await stashedManifest.exists()) {
      final dest = _coreManifestFile(isUe4ss, gameRootPath);
      await dest.parent.create(recursive: true);
      await stashedManifest.copy(dest.path);
    }

    await stashDir.delete(recursive: true);
    return true;
  }

  /// Borra la carpeta de respaldo y la marca de reparación en curso.
  static Future<void> cleanupRepairBackup(String gameRootPath) async {
    final dir = Directory(repairBackupPath(gameRootPath));
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Recupera una reparación interrumpida: devuelve UE4SS y CNS a su sitio.
  static Future<void> recoverPendingRepair(String gameRootPath) async {
    await restoreStashedComponent(isUe4ss: true, gameRootPath: gameRootPath);
    await restoreStashedComponent(isUe4ss: false, gameRootPath: gameRootPath);
    await cleanupRepairBackup(gameRootPath);
  }
}