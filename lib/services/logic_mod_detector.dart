// lib/services/logic_mod_detector.dart
//
// Decide qué TIPO de contenido lleva un contenedor (.utoc / .pak) leyendo SOLO
// su índice de rutas:
//
//   logic     -> hay un asset "ModActor.*": es el punto de entrada que busca
//                BPModLoader (/Game/Mods/<Nombre>/ModActor). Es la ÚNICA prueba
//                que justifica meterlo en Paks/LogicMods.
//   modSpace  -> solo rutas ".../Content/Mods/..." (/Game/Mods/...) y NINGÚN
//                asset del juego ni ModActor. Son assets propios que alguien
//                más tiene que cargar (un script Lua de UE4SS, otro mod...).
//   content   -> reemplaza / añade assets del juego (../SB/Content/Art/...).
//                Un paquete HÍBRIDO (Content/Mods + assets del juego) también
//                es content: los reemplazos necesitan ir en ~mods.
//   unknown   -> no se pudo leer el índice.
//
// Antes cualquier ruta "Content/Mods" bastaba para decir "logic", y un mod
// genérico que mezcla sus blueprints en Content/Mods con reemplazos del juego
// (p. ej. Nier Dodge FX) acababa en LogicMods. Ahora un ModActor manda, y
// Content/Mods por sí solo es solo una pista débil (modSpace) que el llamador
// resuelve con el contexto (¿hay scripts UE4SS?, ¿en qué carpeta lo puso el
// autor?).
//
// Si el índice no se puede leer (cifrado / sin índice) se prueba una búsqueda
// de texto en el .ucas hermano; si tampoco hay pistas, el resultado es
// `unknown` y el llamador conserva su comportamiento de siempre.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package_index_reader.dart';

enum PackageKind {
  /// Blueprint de mod con ModActor (lo carga BPModLoader).
  logic,

  /// Solo /Content/Mods sin ModActor y sin tocar assets del juego.
  modSpace,

  /// Assets que reemplazan o añaden contenido del juego (incluye híbridos).
  content,

  /// No se pudo determinar.
  unknown,
}

class PackageVerdict {
  final PackageKind kind;
  final String reason;
  const PackageVerdict(this.kind, this.reason);

  /// ModActor presente: va a LogicMods sin discusión.
  bool get isLogic => kind == PackageKind.logic;

  /// Solo Content/Mods, sin ModActor.
  bool get isModSpace => kind == PackageKind.modSpace;

  /// Reemplaza o añade assets del juego.
  bool get isContent => kind == PackageKind.content;

  /// "Parece logic" cuando NO hay más contexto (comportamiento histórico:
  /// ModActor o Content/Mods). Úsalo solo donde no se sepa si hay UE4SS.
  bool get isLogicLike => isLogic || isModSpace;

  @override
  String toString() => '${kind.name} ($reason)';
}

class LogicModDetector {
  static const Set<String> packageExtensions = {'.pak', '.utoc', '.ucas'};
  static const int _ucasScanBytes = 16 * 1024 * 1024;

  static final Map<String, PackageVerdict> _cache = {};

  // ------------------------------------------------------------- por rutas

  static const Set<String> _assetExtensions = {
    '.uasset', '.umap', '.uexp', '.ubulk', '.uptnl',
  };

  /// Evalúa las rutas internas de un contenedor.
  static PackageVerdict evaluatePaths(Iterable<String> paths,
      {bool structured = true}) {
    var any = false;
    String? modsHit;
    String? gameHit;
    for (final raw in paths) {
      any = true;
      final lower = raw.toLowerCase().replaceAll('\\', '/');
      final slash = lower.lastIndexOf('/');
      final name = slash >= 0 ? lower.substring(slash + 1) : lower;

      final isModActor = structured
          ? name.startsWith('modactor.')
          : lower.contains('modactor.');
      if (isModActor) {
        return PackageVerdict(PackageKind.logic, 'ModActor: $raw');
      }

      final inModsSpace =
          lower.contains('/content/mods/') || lower.contains('/game/mods/');
      if (inModsSpace) {
        modsHit ??= raw;
        continue;
      }
      if (gameHit == null && _isGameAsset(lower, name, structured)) {
        gameHit = raw;
      }
    }
    if (!any) return const PackageVerdict(PackageKind.unknown, 'empty index');

    if (gameHit != null) {
      return PackageVerdict(
        PackageKind.content,
        modsHit != null
            ? 'hybrid: replaces game asset $gameHit (+ Content/Mods: $modsHit)'
            : 'game asset paths: $gameHit',
      );
    }
    if (modsHit != null) {
      return PackageVerdict(
          PackageKind.modSpace, 'Content/Mods only, no ModActor: $modsHit');
    }
    return const PackageVerdict(PackageKind.content, 'game asset paths');
  }

  /// ¿La ruta es un asset del juego (fuera de Content/Mods)?
  /// En un índice estructurado basta con que sea un archivo de asset. En un
  /// escaneo de cadenas los nombres vienen sueltos y fragmentados, así que se
  /// exige que lleve "/content/" para no confundir un nombre cualquiera.
  static bool _isGameAsset(String lower, String name, bool structured) {
    if (!structured) return lower.contains('/content/');
    final dot = name.lastIndexOf('.');
    return dot >= 0 && _assetExtensions.contains(name.substring(dot));
  }

  // ------------------------------------------------------------ por archivo

  /// Veredicto de UN contenedor (.utoc o .pak). Para un .ucas devuelve unknown.
  static Future<PackageVerdict> classifyFile(File file) async {
    final ext = p.extension(file.path).toLowerCase();
    if (ext != '.utoc' && ext != '.pak') {
      return const PackageVerdict(PackageKind.unknown, 'not a container');
    }
    String key;
    try {
      final st = await file.stat();
      key = '${file.path}|${st.size}|${st.modified.millisecondsSinceEpoch}';
    } catch (_) {
      return const PackageVerdict(PackageKind.unknown, 'unreadable');
    }
    final cached = _cache[key];
    if (cached != null) return cached;

    PackageVerdict verdict;
    final index = await PackageIndexReader.read(file);
    if (index != null && index.paths.isNotEmpty) {
      verdict = evaluatePaths(index.paths, structured: index.structured);
      // Un escaneo de cadenas que no encontró nada no demuestra que sea
      // contenido: puede ser un índice ilegible.
      if (!index.structured && verdict.kind == PackageKind.content) {
        verdict = const PackageVerdict(PackageKind.unknown, 'unstructured scan');
      }
    } else {
      verdict = const PackageVerdict(PackageKind.unknown, 'no readable index');
    }

    if (verdict.kind == PackageKind.unknown && ext == '.utoc') {
      final ucas = File(p.setExtension(file.path, '.ucas'));
      if (await ucas.exists()) {
        final hint = await _ucasHint(ucas);
        if (hint != null) verdict = hint;
      }
    }

    debugPrint('[LogicModDetector] ${p.basename(file.path)} -> $verdict');
    _cache[key] = verdict;
    return verdict;
  }

  // ------------------------------------------------------------- por carpeta

  /// Veredicto agregado de todos los contenedores de [dir]. Un .pak que tiene
  /// un .utoc hermano (stub de IoStore) se ignora: manda el .utoc.
  /// Prioridad: logic (ModActor) > content (incluye híbridos) > modSpace.
  static Future<PackageVerdict> classifyPackagesIn(Directory dir,
      {bool recursive = false}) async {
    final files = await _containers(dir, recursive: recursive);
    return classifyFiles(files);
  }

  static Future<PackageVerdict> classifyFiles(Iterable<File> files) async {
    final list = files.toList();
    final utocStems = <String>{
      for (final f in list)
        if (p.extension(f.path).toLowerCase() == '.utoc') _stemKey(f),
    };
    var sawContent = false;
    PackageVerdict? modSpace;
    PackageVerdict last =
        const PackageVerdict(PackageKind.unknown, 'no containers');
    for (final f in list) {
      final ext = p.extension(f.path).toLowerCase();
      if (ext == '.pak' && utocStems.contains(_stemKey(f))) continue;
      if (ext != '.pak' && ext != '.utoc') continue;
      final v = await classifyFile(f);
      if (v.isLogic) return v;
      if (v.isContent) sawContent = true;
      if (v.isModSpace) modSpace ??= v;
      last = v;
    }
    if (sawContent) {
      return const PackageVerdict(PackageKind.content, 'game asset paths');
    }
    return modSpace ?? last;
  }

  static Future<List<File>> _containers(Directory dir,
      {required bool recursive}) async {
    final out = <File>[];
    try {
      await for (final e in dir.list(recursive: recursive, followLinks: false)) {
        if (e is File &&
            packageExtensions.contains(p.extension(e.path).toLowerCase())) {
          out.add(e);
        }
      }
    } catch (_) {}
    return out;
  }

  static String _stemKey(File f) =>
      p.join(p.dirname(f.path), p.basenameWithoutExtension(f.path)).toLowerCase();

  // ---------------------------------------------------------------- .ucas

  /// Pista de último recurso cuando el índice no se pudo leer: ModActor es
  /// logic; solo "/Game/Mods/" es modSpace; nada -> null (sin pistas).
  static Future<PackageVerdict?> _ucasHint(File ucas) async {
    try {
      final raf = await ucas.open();
      try {
        final len = await raf.length();
        final n = math.min(len, _ucasScanBytes);
        final bytes = await raf.read(n);
        if (_containsAscii(bytes, 'ModActor')) {
          return const PackageVerdict(
              PackageKind.logic, '.ucas references ModActor');
        }
        if (_containsAscii(bytes, '/Game/Mods/')) {
          return const PackageVerdict(
              PackageKind.modSpace, '.ucas references /Game/Mods');
        }
      } finally {
        await raf.close();
      }
    } catch (_) {}
    return null;
  }

  static bool _containsAscii(Uint8List hay, String needle) {
    final n = needle.codeUnits;
    if (n.isEmpty || hay.length < n.length) return false;
    final first = n[0];
    final last = hay.length - n.length;
    for (var i = 0; i <= last; i++) {
      if (hay[i] != first) continue;
      var j = 1;
      while (j < n.length && hay[i + j] == n[j]) {
        j++;
      }
      if (j == n.length) return true;
    }
    return false;
  }
}