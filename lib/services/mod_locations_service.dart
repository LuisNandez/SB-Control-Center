// lib/services/mod_locations_service.dart
//
// Dónde están REALMENTE los archivos de un mod instalado.
//
// Un mod "simple" (CNS, genérico, reemplazo...) vive en una sola carpeta:
// [ModInfo.directory]. Un mod con partes (logicMod: blueprint en LogicMods,
// paks de contenido en ~mods, scripts en ue4ss/Mods, archivos sueltos en la
// raíz de ue4ss) deja en [ModInfo.directory] solo su nexus_info.json y
// miniatura, y el resto repartido por el juego. Este servicio reconstruye
// esas ubicaciones leyendo lo que el instalador anotó en nexus_info.json
// (tildeModsComponentFolder, ue4ssComponents, ue4ssLooseFiles).
//
// Los mods de archivos del juego (config, save, splash, movies) guardan su
// copia de trabajo en SB/Content/__MOD_BACKUPS__/<mod> y, al activarse,
// COPIAN sus archivos a la carpeta real del juego (Config, Saved, Splash,
// Movies). Para esos se abre la carpeta donde quedaron instalados.
//
// Con el mod DESACTIVADO todas las partes están dentro de su carpeta de
// respaldo (_tilde_mods, _ue4ss_mods, _ue4ss_loose_files), así que basta con
// abrir esa carpeta.
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/mod_info.dart';

enum ModLocationKind {
  /// Carpeta propia del mod (la única, o el respaldo si está desactivado).
  mod,

  /// Carpeta (o archivo) del juego donde un mod de config/save/splash/movies
  /// dejó sus archivos al activarse.
  installed,

  /// Blueprint con ModActor en Paks/LogicMods/<mod>.
  logic,

  /// Paks de contenido en Paks/~mods/<mod>.
  paks,

  /// Carpeta de scripts en ue4ss/Mods/<componente>.
  ue4ssScript,

  /// Archivo suelto en la raíz de ue4ss (UE4SS-settings.ini...).
  ue4ssFile,
}

class ModLocation {
  final ModLocationKind kind;
  final String path;
  final bool isFile;

  const ModLocation(this.kind, this.path, {this.isFile = false});

  String get name => p.basename(path);

  @override
  String toString() => '${kind.name}: $path';
}

class ModLocationsService {
  static const Set<String> _packageExtensions = {'.pak', '.utoc', '.ucas'};
  static const int _maxInstalledGroups = 8;

  /// Ubicaciones existentes del mod, de la más relevante (donde están los
  /// paks) a la menos. Nunca devuelve una lista vacía: si no se encuentra
  /// nada, devuelve la carpeta del mod.
  static Future<List<ModLocation>> resolve(
    ModInfo mod, {
    required String? genericModsPath,
    required String? ue4ssModsPath,
    String? moviesPath,
    String? savesPath,
    String? configPath,
    String? splashPath,
  }) async {
    final root = mod.directory.path;
    final fallback = [ModLocation(ModLocationKind.mod, root)];

    // Desactivado: todo está dentro de su carpeta de respaldo.
    if (!mod.isEnabled) return fallback;

    if (const {'movies', 'save', 'config', 'splash'}.contains(mod.modType)) {
      return _resolveInstalledFiles(
        mod,
        fallback,
        moviesPath: moviesPath,
        savesPath: savesPath,
        configPath: configPath,
        splashPath: splashPath,
      );
    }

    // Solo los mods con partes (logic, o genérico con scripts UE4SS) reparten
    // sus archivos por el juego.
    if (!const {'logicMod', 'genericPak', 'replacement'}
        .contains(mod.modType)) {
      return fallback;
    }

    Map<String, dynamic> data;
    try {
      final info = File(p.join(root, 'nexus_info.json'));
      if (!await info.exists()) return fallback;
      final decoded = json.decode(await info.readAsString());
      if (decoded is! Map<String, dynamic>) return fallback;
      data = decoded;
    } catch (_) {
      return fallback;
    }

    final result = <ModLocation>[];
    final seen = <String>{};
    void add(ModLocation loc) {
      if (seen.add(p.normalize(loc.path).toLowerCase())) result.add(loc);
    }

    // 1) Paks de contenido (~mods/<mod>).
    final tilde = data['tildeModsComponentFolder'];
    if (tilde is String && tilde.isNotEmpty && genericModsPath != null) {
      final dir = Directory(p.join(genericModsPath, tilde));
      if (await dir.exists()) add(ModLocation(ModLocationKind.paks, dir.path));
    }

    // 2) Blueprint en LogicMods: solo interesa si de verdad trae paks (en un
    //    mod híbrido esa carpeta solo guarda nexus_info.json).
    if (await _hasPackages(mod.directory)) {
      add(ModLocation(
          mod.modType == 'logicMod'
              ? ModLocationKind.logic
              : ModLocationKind.paks,
          root));
    }

    // 3) Scripts UE4SS.
    final comps = data['ue4ssComponents'];
    if (comps is List && ue4ssModsPath != null) {
      for (final c in comps.whereType<String>()) {
        final dir = Directory(p.join(ue4ssModsPath, c));
        if (await dir.exists()) {
          add(ModLocation(ModLocationKind.ue4ssScript, dir.path));
        }
      }
    }

    // 4) Archivos sueltos en la raíz de ue4ss.
    final loose = data['ue4ssLooseFiles'];
    if (loose is List && ue4ssModsPath != null) {
      final ue4ssRoot = p.dirname(ue4ssModsPath);
      for (final f in loose.whereType<String>()) {
        final file = File(p.join(ue4ssRoot, f));
        if (await file.exists()) {
          add(ModLocation(ModLocationKind.ue4ssFile, file.path, isFile: true));
        }
      }
    }

    return result.isEmpty ? fallback : result;
  }

  /// config / save / splash / movies activos: carpeta real del juego donde
  /// quedaron sus archivos (según lo que anotó el instalador).
  static Future<List<ModLocation>> _resolveInstalledFiles(
    ModInfo mod,
    List<ModLocation> fallback, {
    String? moviesPath,
    String? savesPath,
    String? configPath,
    String? splashPath,
  }) async {
    Map<String, dynamic> data;
    try {
      final info = File(p.join(mod.directory.path, 'nexus_info.json'));
      if (!await info.exists()) return fallback;
      final decoded = json.decode(await info.readAsString());
      if (decoded is! Map<String, dynamic>) return fallback;
      data = decoded;
    } catch (_) {
      return fallback;
    }

    List<String> names(String key) => data[key] is List
        ? (data[key] as List).whereType<String>().toList()
        : const <String>[];

    String? base;
    List<String> files;
    switch (mod.modType) {
      case 'save':
        base = savesPath;
        files = names('replacedFiles');
        break;
      case 'config':
        base = configPath;
        files = names('replacedFiles');
        break;
      case 'movies':
        base = moviesPath;
        files = names('activeInstalledFiles');
        break;
      default: // splash
        files = names('activeInstalledFiles');
        if (splashPath != null && data['isRandomizerMode'] == true) {
          // Modo randomizer: splash_N.jpg dentro de ModSplash/SplashImages.
          base = p.join(splashPath, 'ModSplash', 'SplashImages');
        } else {
          // Mod 801 ('ModSplash/x.bat') y reemplazo clásico: relativos a Splash.
          base = splashPath;
        }
    }
    if (base == null) return fallback;

    // Archivos realmente presentes, agrupados por carpeta.
    final byDir = <String, List<String>>{};
    for (final f in files) {
      final path = p.normalize(p.join(base, f));
      try {
        if (await File(path).exists()) {
          byDir.putIfAbsent(p.dirname(path), () => []).add(path);
        }
      } catch (_) {}
    }

    final result = <ModLocation>[];
    for (final entry in byDir.entries.take(_maxInstalledGroups)) {
      if (entry.value.length == 1) {
        // Un solo archivo: se abre su carpeta con el archivo seleccionado.
        result.add(ModLocation(ModLocationKind.installed, entry.value.first,
            isFile: true));
      } else {
        result.add(ModLocation(ModLocationKind.installed, entry.key));
      }
    }
    if (result.isNotEmpty) return result;

    // Sin rastro de archivos: al menos la carpeta del juego donde irían.
    try {
      if (await Directory(base).exists()) {
        return [ModLocation(ModLocationKind.installed, base)];
      }
    } catch (_) {}
    return fallback;
  }

  static Future<bool> _hasPackages(Directory dir) async {
    try {
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File &&
            _packageExtensions.contains(p.extension(e.path).toLowerCase())) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}