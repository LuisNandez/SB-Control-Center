// lib/services/logic_mod_stager.dart
//
// Reconoce y prepara mods LOGIC dentro de un archivo extraído, sea cual sea su
// estructura:
//   - solo .pak/.ucas/.utoc            -> se resuelve por carpeta (ver
//                                         ModClassifierService, lee el índice)
//   - solo carpeta(s) de UE4SS         -> Scripts/main.lua (Lua) o dlls/main.dll
//   - ambas cosas (en cualquier ruta)  -> este servicio las junta
//
// El resultado se "normaliza" en una carpeta temporal con el mismo formato que
// ya entiende el instalador de main.dart:
//
//   <staging>/LogicMods/...      -> .pak/.ucas/.utoc lógicos (+ sus .json)
//   <staging>/ue4ss/Mods/<Mod>/  -> carpetas Lua/C++ (con enabled.txt)
//   <staging>/ue4ss/*            -> archivos sueltos de la raíz de ue4ss
//   <staging>/~mods/...          -> paks de contenido (reemplazos del juego,
//                                   híbridos, o assets que carga un Lua)
//
// Reparto de los .pak/.ucas/.utoc (lo decide el CONTENIDO del índice, y como
// desempate dónde los puso el autor):
//   - ModActor                       -> LogicMods (lo carga BPModLoader)
//   - reemplaza assets del juego     -> ~mods (aunque también traiga Content/Mods)
//   - solo Content/Mods, sin ModActor:
//        * en una carpeta ~mods      -> ~mods (el autor lo decidió así)
//        * suelto + hay scripts UE4SS-> ~mods (son los assets que carga el Lua)
//        * suelto sin scripts UE4SS  -> LogicMods (comportamiento de siempre)
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'logic_mod_detector.dart';
import 'hd_atool_audio_service.dart';

/// Carpetas de mods que vienen con el UE4SS base: no son mods del usuario.
const Set<String> kUe4ssBundledMods = {
  'actordumpermod',
  'bpml_genericfunctions',
  'bpmodloadermod',
  'cheatmanagerenablermod',
  'consolecommandsmod',
  'consoleenablermod',
  'jsbluaprofilermod',
  'keybinds',
  'linetracemod',
  'shared',
  'splitscreenmod',
  'dekcns', // núcleo de CNS: tiene su propio flujo de actualización
};

class LogicScan {
  final Directory root;

  /// Carpetas de mods UE4SS (con Scripts/main.lua o dlls/main.dll).
  final List<Directory> ue4ssModDirs;

  /// Carpeta "ue4ss" completa (estructura SB/Binaries/Win64/ue4ss).
  final Directory? ue4ssRootDir;

  /// Carpetas llamadas LogicMods / ~mods.
  final List<Directory> logicModsDirs;
  final List<Directory> tildeModsDirs;

  LogicScan({
    required this.root,
    required this.ue4ssModDirs,
    required this.ue4ssRootDir,
    required this.logicModsDirs,
    required this.tildeModsDirs,
  });

  bool get hasUe4ss => ue4ssModDirs.isNotEmpty || ue4ssRootDir != null;

  /// ¿Este archivo contiene un mod logic que hay que preparar aquí?
  /// (los mods de solo .pak sin estructura los resuelve el clasificador por
  /// carpeta leyendo el índice del contenedor).
  bool get isLogic => hasUe4ss || logicModsDirs.isNotEmpty;

  bool get hasDuplicateModNames {
    final seen = <String>{};
    for (final d in ue4ssModDirs) {
      if (!seen.add(p.basename(d.path).toLowerCase())) return true;
    }
    return false;
  }
}

class StagedLogicMod {
  final Directory logicDir;
  final Directory? ue4ssDir;
  final Directory? tildeDir;

  /// Subcarpeta (variante) de la que sale, o null si el archivo trae un solo mod.
  final String? variantLabel;

  /// Nombres de las carpetas de mod UE4SS preparadas (informativo).
  final List<String> ue4ssModNames;

  StagedLogicMod({
    required this.logicDir,
    this.ue4ssDir,
    this.tildeDir,
    this.variantLabel,
    this.ue4ssModNames = const [],
  });
}

class LogicModStager {
  static bool _skipName(String name) =>
      name.startsWith('__') || name.startsWith('.');

  // ------------------------------------------------------------------ scan

  static Future<bool> _exists(String path) async =>
      await File(path).exists();

  /// ¿[dir] es la carpeta de un mod de UE4SS (Lua o C++)?
  static Future<bool> isUe4ssModDir(Directory dir) async {
    for (final scripts in const ['Scripts', 'scripts']) {
      if (await _exists(p.join(dir.path, scripts, 'main.lua'))) return true;
    }
    for (final dlls in const ['dlls', 'Dlls', 'DLLs']) {
      if (await _exists(p.join(dir.path, dlls, 'main.dll'))) return true;
    }
    return false;
  }

  static Future<LogicScan> scan(Directory root) async {
    final modDirs = <Directory>[];
    Directory? ue4ssRoot;
    final logicDirs = <Directory>[];
    final tildeDirs = <Directory>[];

    Future<void> walk(Directory dir, int depth) async {
      if (depth > 12) return;
      List<FileSystemEntity> kids;
      try {
        kids = await dir.list(followLinks: false).toList();
      } catch (_) {
        return;
      }
      for (final e in kids) {
        if (e is! Directory) continue;
        final name = p.basename(e.path);
        if (_skipName(name)) continue;
        final lower = name.toLowerCase();

        if (lower == 'ue4ss') {
          ue4ssRoot ??= e;
          continue; // se copia entera; no hace falta bajar
        }
        if (lower == 'logicmods') {
          logicDirs.add(e);
          continue;
        }
        if (lower == '~mods') {
          tildeDirs.add(e);
          continue;
        }
        if (await isUe4ssModDir(e)) {
          if (!kUe4ssBundledMods.contains(lower)) modDirs.add(e);
          continue; // no buscar mods dentro de un mod
        }
        await walk(e, depth + 1);
      }
    }

    await walk(root, 0);
    return LogicScan(
      root: root,
      ue4ssModDirs: modDirs,
      ue4ssRootDir: ue4ssRoot,
      logicModsDirs: logicDirs,
      tildeModsDirs: tildeDirs,
    );
  }

  // ---------------------------------------------------------------- process

  /// Punto de entrada: devuelve los mods logic encontrados en [archiveDir]
  /// (vacío si no hay ninguno que este servicio deba preparar). Si el archivo
  /// trae varias variantes con el mismo mod UE4SS, devuelve una por variante.
  static Future<List<StagedLogicMod>> process(Directory archiveDir) async {
    final whole = await scan(archiveDir);
    if (!whole.isLogic) return const [];

    if (!whole.hasDuplicateModNames) {
      final staged = await stage(archiveDir, whole, stageName: 'main');
      return staged == null ? const [] : [staged];
    }

    // Varias variantes: una por subcarpeta de primer nivel con contenido logic.
    final base = await _unwrap(archiveDir);
    final result = <StagedLogicMod>[];
    var n = 0;
    // Se lista ANTES de crear carpetas de staging dentro de la misma ruta.
    final entries = await base.list(followLinks: false).toList();
    for (final e in entries) {
      if (e is! Directory) continue;
      final name = p.basename(e.path);
      if (_skipName(name)) continue;
      final sub = await scan(e);
      if (!sub.isLogic) continue;
      final staged = await stage(archiveDir, sub,
          stageName: 'variant_${n++}', variantLabel: name);
      if (staged != null) result.add(staged);
    }
    if (result.isNotEmpty) return result;

    // No se pudo separar: se prepara todo junto (el primer mod de cada nombre).
    final staged = await stage(archiveDir, whole, stageName: 'main');
    return staged == null ? const [] : [staged];
  }

  /// Desciende por carpetas envoltorio (una sola subcarpeta y solo archivos
  /// de documentación al lado).
  static Future<Directory> _unwrap(Directory dir) async {
    var cur = dir;
    for (var i = 0; i < 4; i++) {
      final dirs = <Directory>[];
      var hasRealFile = false;
      try {
        await for (final e in cur.list(followLinks: false)) {
          final name = p.basename(e.path);
          if (_skipName(name)) continue;
          if (e is Directory) {
            dirs.add(e);
          } else if (e is File && !_isDocFile(e.path)) {
            hasRealFile = true;
          }
        }
      } catch (_) {
        break;
      }
      if (dirs.length == 1 && !hasRealFile) {
        cur = dirs.first;
      } else {
        break;
      }
    }
    return cur;
  }

  /// Si [dir] contiene una única subcarpeta y ningún archivo propio
  /// (~mods/NierDodgeFX/*.pak), devuelve esa subcarpeta; si no, [dir].
  static Future<Directory> _unwrapSingleFolder(Directory dir) async {
    var cur = dir;
    for (var i = 0; i < 4; i++) {
      final dirs = <Directory>[];
      var hasFile = false;
      try {
        await for (final e in cur.list(followLinks: false)) {
          if (_skipName(p.basename(e.path))) continue;
          if (e is Directory) {
            dirs.add(e);
          } else if (e is File) {
            hasFile = true;
          }
        }
      } catch (_) {
        break;
      }
      if (dirs.length == 1 && !hasFile) {
        cur = dirs.first;
      } else {
        break;
      }
    }
    return cur;
  }

  static bool _isDocFile(String path) => const [
        '.txt', '.md', '.png', '.jpg', '.jpeg', '.url', '.pdf', '.webp', '.gif'
      ].contains(p.extension(path).toLowerCase());

  // ------------------------------------------------------------------ stage

  static Future<StagedLogicMod?> stage(
    Directory archiveDir,
    LogicScan scan, {
    required String stageName,
    String? variantLabel,
  }) async {
    final stagingRoot =
        Directory(p.join(archiveDir.path, '__logic_staged__', stageName));
    if (await stagingRoot.exists()) await stagingRoot.delete(recursive: true);
    final logicOut = Directory(p.join(stagingRoot.path, 'LogicMods'));
    final ue4ssOut = Directory(p.join(stagingRoot.path, 'ue4ss'));
    final tildeOut = Directory(p.join(stagingRoot.path, '~mods'));
    await logicOut.create(recursive: true);

    final copied = <String>{}; // rutas de origen ya copiadas
    final modNames = <String>[];

    // 1) Carpetas LogicMods del archivo: se copian tal cual.
    for (final d in scan.logicModsDirs) {
      await _copyTree(d, logicOut, copied);
    }

    // 2) UE4SS: carpeta ue4ss completa y/o carpetas de mod sueltas.
    final ue4ssRoot = scan.ue4ssRootDir;
    if (ue4ssRoot != null) {
      await _copyTree(ue4ssRoot, ue4ssOut, copied, skipRel: _skipUe4ssRel);
      final modsDir = Directory(p.join(ue4ssOut.path, 'Mods'));
      if (await modsDir.exists()) {
        await for (final e in modsDir.list(followLinks: false)) {
          if (e is Directory) modNames.add(p.basename(e.path));
        }
      }
    }
    for (final d in scan.ue4ssModDirs) {
      if (ue4ssRoot != null && p.isWithin(ue4ssRoot.path, d.path)) continue;
      final name = p.basename(d.path);
      if (modNames.any((n) => n.toLowerCase() == name.toLowerCase())) continue;
      await _copyTree(d, Directory(p.join(ue4ssOut.path, 'Mods', name)), copied);
      modNames.add(name);
    }

    // 3) Carpetas ~mods: si contienen paks LOGIC van a LogicMods; si no, se
    //    conservan como contenido (~mods).
    for (final d in scan.tildeModsDirs) {
      if (ue4ssRoot != null && p.isWithin(ue4ssRoot.path, d.path)) continue;
      // Solo un ModActor justifica sacarlos de la carpeta ~mods donde el autor
      // los puso: Content/Mods a secas, o mezclado con reemplazos del juego,
      // se queda en ~mods (así lo empaquetó el autor y así funciona).
      final verdict =
          await LogicModDetector.classifyPackagesIn(d, recursive: true);
      if (verdict.isLogic) {
        await _copyTree(d, logicOut, copied);
      } else {
        // ~mods/<Nombre>/*.pak -> se aplana: el instalador ya crea
        // ~mods/<Nombre vX>/ para este mod.
        await _copyTree(await _unwrapSingleFolder(d), tildeOut, copied);
      }
    }

    // 4) Contenedores sueltos fuera de las carpetas anteriores.
    final skipRoots = <String>[
      for (final d in scan.logicModsDirs) d.path,
      for (final d in scan.tildeModsDirs) d.path,
      for (final d in scan.ue4ssModDirs) d.path,
      if (ue4ssRoot != null) ue4ssRoot.path,
      p.join(archiveDir.path, '__logic_staged__'),
    ];
    final loose = <File>[];
    await _collectContainers(scan.root, skipRoots, loose);
    final groups = <String, List<File>>{}; // carpeta|stem -> archivos
    for (final f in loose) {
      final key = p
          .join(p.dirname(f.path), p.basenameWithoutExtension(f.path))
          .toLowerCase();
      groups.putIfAbsent(key, () => []).add(f);
    }
    final jsonDirsDone = <String>{};
    for (final files in groups.values) {
      final verdict = await LogicModDetector.classifyFiles(files);
      final bool toLogic;
      if (verdict.isLogic) {
        toLogic = true; // ModActor
      } else if (verdict.isModSpace) {
        // Content/Mods sin ModActor: con scripts UE4SS son los assets que
        // carga el Lua (van con los demás paks, en ~mods); sin ellos se
        // conserva el comportamiento histórico (LogicMods).
        toLogic = !scan.hasUe4ss;
      } else if (verdict.kind == PackageKind.unknown) {
        // Sin pistas (índice ilegible): en un archivo con UE4SS lo normal es
        // que el pak sea la parte blueprint del mod.
        toLogic = scan.hasUe4ss;
      } else {
        toLogic = false; // content: reemplazos / híbridos
      }
      debugPrint('[LogicModStager] ${p.basename(files.first.path)} -> '
          '${toLogic ? 'LogicMods' : '~mods'} ($verdict)');
      final dest = toLogic ? logicOut : tildeOut;
      await dest.create(recursive: true);
      for (final f in files) {
        if (copied.add(f.path)) {
          await f.copy(p.join(dest.path, p.basename(f.path)));
        }
      }
      // Los .json de al lado (config del mod) acompañan a la parte logic.
      if (toLogic) {
        final dir = p.dirname(files.first.path);
        if (jsonDirsDone.add(dir)) {
          await for (final e in Directory(dir).list(followLinks: false)) {
            if (e is File &&
                p.extension(e.path).toLowerCase() == '.json' &&
                p.basename(e.path).toLowerCase() != 'nexus_info.json' &&
                copied.add(e.path)) {
              await e.copy(p.join(logicOut.path, p.basename(e.path)));
            }
          }
        }
      }
    }

    // 4b) Mod logic hecho para HD-ATOOL: sus audios numerados (1.wav, 12.mp3...)
    //     no son contenedores y no van en la carpeta del mod, sino en
    //     LogicMods/HD-ATOOL_P/audio. Se guardan dentro del mod
    //     (_hd_atool_audio) y el instalador/activador los coloca en el juego.
    if (await HdAtoolAudio.dependsOnHdAtool(logicOut)) {
      await HdAtoolAudio.stageAudio(
        archiveRoot: scan.root,
        logicOut: logicOut,
        skipRoots: skipRoots,
      );
    }

    // 5) UE4SS carga una carpeta de mod si tiene enabled.txt (o si está en
    //    mods.txt, que NO tocamos para no pisar el del usuario).
    final modsRoot = Directory(p.join(ue4ssOut.path, 'Mods'));
    if (await modsRoot.exists()) {
      await for (final e in modsRoot.list(followLinks: false)) {
        if (e is Directory && await isUe4ssModDir(e)) {
          await _ensureEnabledFlag(e);
        }
      }
    }

    final hasLogicFiles = await _hasAnyFile(logicOut);
    final hasUe4ssFiles = await _hasAnyFile(ue4ssOut);
    final hasTildeFiles = await _hasAnyFile(tildeOut);
    if (!hasLogicFiles && !hasUe4ssFiles) return null;

    return StagedLogicMod(
      logicDir: logicOut,
      ue4ssDir: hasUe4ssFiles ? ue4ssOut : null,
      tildeDir: hasTildeFiles ? tildeOut : null,
      variantLabel: variantLabel,
      ue4ssModNames: modNames,
    );
  }

  // ---------------------------------------------------------------- helpers

  /// No se copian los listados de mods del UE4SS del usuario.
  static bool _skipUe4ssRel(String rel) {
    final r = rel.replaceAll('\\', '/').toLowerCase();
    return r == 'mods/mods.txt' || r == 'mods/mods.json';
  }

  static Future<void> _ensureEnabledFlag(Directory modDir) async {
    try {
      await for (final e in modDir.list(followLinks: false)) {
        if (e is File && p.basename(e.path).toLowerCase() == 'enabled.txt') {
          return;
        }
      }
      await File(p.join(modDir.path, 'enabled.txt')).create();
    } catch (_) {}
  }

  static Future<bool> _hasAnyFile(Directory d) async {
    if (!await d.exists()) return false;
    try {
      await for (final e in d.list(recursive: true, followLinks: false)) {
        if (e is File) return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<void> _collectContainers(
      Directory dir, List<String> skipRoots, List<File> out) async {
    List<FileSystemEntity> kids;
    try {
      kids = await dir.list(followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final e in kids) {
      if (skipRoots.any((s) => p.equals(s, e.path))) continue;
      final name = p.basename(e.path);
      if (e is Directory) {
        if (_skipName(name)) continue;
        await _collectContainers(e, skipRoots, out);
      } else if (e is File &&
          LogicModDetector.packageExtensions
              .contains(p.extension(e.path).toLowerCase())) {
        out.add(e);
      }
    }
  }

  static Future<void> _copyTree(
    Directory src,
    Directory dst,
    Set<String> copied, {
    bool Function(String rel)? skipRel,
  }) async {
    await dst.create(recursive: true);
    await for (final e in src.list(recursive: true, followLinks: false)) {
      final rel = p.relative(e.path, from: src.path);
      if (p.split(rel).any(_skipName)) continue;
      if (skipRel != null && skipRel(rel)) continue;
      final target = p.join(dst.path, rel);
      if (e is Directory) {
        await Directory(target).create(recursive: true);
      } else if (e is File) {
        if (!copied.add(e.path)) continue;
        await Directory(p.dirname(target)).create(recursive: true);
        await e.copy(target);
      }
    }
  }
}