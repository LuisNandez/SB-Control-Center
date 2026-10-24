// Detecta qué traje(s) reemplaza un mod genérico (.pak / .utoc+.ucas) leyendo
// SOLO el índice de nombres del contenedor (nunca el .ucas entero).
//
//  - .utoc (IoStore): se parsea el índice de directorios del propio .utoc y se
//    reconstruyen las RUTAS COMPLETAS (Art/Character/PC/CH_P_EVE_28/Textures/x).
//  - .pak v10+: se parsea el "full directory index" (carpeta -> archivos).
//  - .pak antiguo / índice ilegible: plan B por escaneo de cadenas de texto.
//  Si el mod está cifrado o empaquetado SIN índice no hay nombres: devuelve
//  vacío y la app sigue con la selección manual de siempre.
//
// Decisión (ver [resolveAssets]): cada archivo aporta evidencia de un tipo y
//   4 = NÚCLEO del traje: malla, física, anim/blueprint (CH_P_EVE_53.uasset,
//       ..._PhysicsAsset, carpeta Meshes/, archivos en la raíz del traje)
//   3 = dependencia: materiales/instancias (MI_*) y otros assets sueltos
//   2 = textura (carpeta /Textures/, .ubulk, sufijo _Map01_D, _ORM, _RGB...)
//   1 = solo la carpeta del traje
// Se descartan los trajes cuya mejor evidencia es MÁS débil que la del mejor
// traje del mod. Así, un mod que trae la malla de un traje (Ultimate Bunny) y
// arrastra materiales + texturas de otro (Planet Diving Suit 7th) solo se
// asigna al primero: los materiales/texturas son dependencias, no el reemplazo.
// Si todo el mod es del mismo nivel (p. ej. un mod de solo texturas o de solo
// materiales), se aceptan todos los trajes detectados, base y variantes.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'outfit_id_map.dart';

/// Un archivo (o carpeta si [file] está vacío) dentro de un mod.
/// [dir] es la ruta de la carpeta con '/' (puede ser vacía si no se conoce).
class OutfitAsset {
  final String dir;
  final String file;
  const OutfitAsset(this.dir, this.file);

  /// Extensión con punto, en minúsculas ('' si no tiene).
  String get ext {
    final f = file.toLowerCase();
    final i = f.lastIndexOf('.');
    return i > 0 ? f.substring(i) : '';
  }

  /// Nombre sin extensión, en minúsculas.
  String get stem {
    final f = file.toLowerCase();
    final i = f.lastIndexOf('.');
    return i > 0 ? f.substring(0, i) : f;
  }
}

class OutfitDetector {
  // Grupo 1 = nombre; grupo 2 = extensión (si hay, es un ARCHIVO; si no, una
  // CARPETA). Solo se usa en el plan B (escaneo de cadenas).
  static final RegExp _token = RegExp(
      r'(CH_P_EVE_[A-Za-z0-9_]+)(\.[A-Za-z0-9]+)?',
      caseSensitive: false);
  static final RegExp _run = RegExp(r'[A-Za-z0-9_./\- ]{6,}');
  static const int _maxIndexBytes = 64 * 1024 * 1024;
  static const int _fallbackTail = 4 * 1024 * 1024;

  static const int _tierDir = 1;
  static const int _tierTexture = 2;
  static const int _tierDependency = 3; // materiales, instancias, otros
  static const int _tierCore = 4; // malla / física / anim / blueprint

  /// Carpetas que indican que el archivo es una textura.
  static const Set<String> _textureDirs = {'textures', 'texture', 'tex'};

  /// Carpetas de materiales: son dependencias, nunca el núcleo del traje.
  static const Set<String> _dependencyDirs = {
    'materials', 'material', 'materialinstances', 'mi', 'instances'
  };

  /// Carpetas que contienen el núcleo del traje (malla, física, anim...).
  static const Set<String> _coreDirs = {
    'mesh', 'meshes', 'skeletalmesh', 'skeletalmeshes', 'physics',
    'animation', 'animations', 'anim', 'blueprint', 'blueprints'
  };

  /// Claves (carpetas + stems) ordenadas de más larga a más corta.
  static final List<String> _keys = () {
    final k = <String>{};
    for (final e in kOutfitFolders.entries) {
      k.add(e.key);
      for (final o in e.value) {
        k.add(o.stem);
      }
    }
    return k.toList()..sort((a, b) => b.length.compareTo(a.length));
  }();

  /// clave (carpeta o stem) -> carpeta de traje a la que pertenece.
  static final Map<String, String> _keyFolder = () {
    final m = <String, String>{};
    for (final e in kOutfitFolders.entries) {
      for (final o in e.value) {
        m[o.stem] = e.key;
      }
    }
    for (final k in kOutfitFolders.keys) {
      m[k] = k;
    }
    return m;
  }();

  /// Devuelve los nombres (como en stellarBladeOutfits) detectados en [modDir].
  static Future<List<String>> detect(Directory modDir) async {
    final assets = <OutfitAsset>[];
    await for (final e in modDir.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final ext = p.extension(e.path).toLowerCase();
      try {
        if (ext == '.utoc') {
          assets.addAll(await _readUtoc(e));
        } else if (ext == '.pak') {
          assets.addAll(await _readPak(e));
        } else if (const ['.uasset', '.uexp', '.ubulk'].contains(ext)) {
          // Mod suelto (sin empaquetar): vale la ruta relativa.
          final rel = p.relative(e.path, from: modDir.path).replaceAll('\\', '/');
          final i = rel.lastIndexOf('/');
          assets.add(OutfitAsset(
              i < 0 ? '' : rel.substring(0, i + 1), rel.substring(i + 1)));
        }
      } catch (_) {
        // Archivo ilegible o cifrado: se ignora, no rompe la instalación.
      }
    }
    final result = resolveAssets(assets);
    debugPrint('[OutfitDetector] ${assets.length} entradas en ${modDir.path} '
        '-> ${result.length} traje(s): $result');
    return result;
  }

  // ------------------------------------------------------------------ lectura

  static Future<Uint8List> _readTail(File f, int maxBytes) async {
    final raf = await f.open();
    try {
      final len = await raf.length();
      final n = math.min(len, maxBytes);
      await raf.setPosition(len - n);
      return await raf.read(n);
    } finally {
      await raf.close();
    }
  }

  // ---- .utoc

  static Future<List<OutfitAsset>> _readUtoc(File f) async {
    final len = await f.length();
    if (len <= _maxIndexBytes) {
      final parsed = _parseUtoc(await f.readAsBytes());
      if (parsed != null && parsed.isNotEmpty) return parsed;
    }
    // Sin índice / cifrado / formato raro: plan B.
    return _scanRuns(await _readTail(f, _maxIndexBytes));
  }

  /// Parsea el índice de directorios de un .utoc (UE5). Devuelve null si no se
  /// puede (cifrado, sin índice, estructura inesperada).
  ///
  /// Layout: cabecera (headerSize) | chunkIds(12) | offsets/lengths(10) |
  /// perfect hash seeds(4) [v>=4] | chunks sin perfect hash(4) [v>=5] |
  /// bloques de compresión | nombres de compresión | [firmas si flag 0x4] |
  /// ÍNDICE DE DIRECTORIOS (flag 0x8, tamaño en cabecera +48).
  static List<OutfitAsset>? _parseUtoc(Uint8List b) {
    try {
      if (b.length < 144) return null;
      const magic = '-==--==--==--==-';
      for (var i = 0; i < 16; i++) {
        if (b[i] != magic.codeUnitAt(i)) return null;
      }
      final bd = ByteData.sublistView(b);
      final version = bd.getUint8(16);
      final headerSize = bd.getUint32(20, Endian.little);
      final entryCount = bd.getUint32(24, Endian.little);
      final blockCount = bd.getUint32(28, Endian.little);
      final blockEntrySize = bd.getUint32(32, Endian.little);
      final methodCount = bd.getUint32(36, Endian.little);
      final methodLen = bd.getUint32(40, Endian.little);
      final dirSize = bd.getUint32(48, Endian.little);
      final flags = bd.getUint8(80);
      if ((flags & 0x02) != 0) return null; // cifrado
      if ((flags & 0x08) == 0 || dirSize == 0) return null; // sin índice
      final seeds = version >= 4 ? bd.getUint32(84, Endian.little) : 0;
      final noHash = version >= 5 ? bd.getUint32(96, Endian.little) : 0;

      var o = headerSize +
          entryCount * (12 + 10) +
          seeds * 4 +
          noHash * 4 +
          blockCount * blockEntrySize +
          methodCount * methodLen;
      if ((flags & 0x04) != 0) {
        final hashSize = bd.getUint32(o, Endian.little);
        o += 4 + hashSize * 2 + blockCount * 20;
      }
      if (o < 0 || o + dirSize > b.length) return null;
      return _parseDirectoryIndex(Uint8List.sublistView(b, o, o + dirSize));
    } catch (_) {
      return null;
    }
  }

  /// FIoDirectoryIndexResource: FString MountPoint; array de directorios
  /// (name, firstChild, nextSibling, firstFile: u32 c/u); array de archivos
  /// (name, nextFile, userData: u32 c/u); tabla de FStrings.
  static List<OutfitAsset>? _parseDirectoryIndex(Uint8List d) {
    try {
      const none = 0xFFFFFFFF;
      final r = _Reader(d);
      final mount = r.fstr();
      final nd = r.u32();
      if (nd > d.length ~/ 16) return null;
      final dirs = List<int>.generate(nd * 4, (_) => r.u32());
      final nf = r.u32();
      if (nf > d.length ~/ 12) return null;
      final files = List<int>.generate(nf * 3, (_) => r.u32());
      final ns = r.u32();
      if (ns > d.length ~/ 4) return null;
      final strings = List<String>.generate(ns, (_) => r.fstr());
      if (nd == 0) return null;

      final out = <OutfitAsset>[];
      var steps = 0;
      final maxSteps = nd + nf + 8;
      void walk(int start, String path, int depth) {
        var i = start;
        while (i != none) {
          if (depth > 64 || ++steps > maxSteps) return;
          final name = dirs[i * 4];
          final child = dirs[i * 4 + 1];
          final sibling = dirs[i * 4 + 2];
          var f = dirs[i * 4 + 3];
          final cur = name == none ? path : '$path${strings[name]}/';
          while (f != none) {
            if (++steps > maxSteps) return;
            out.add(OutfitAsset(cur, strings[files[f * 3]]));
            f = files[f * 3 + 1];
          }
          if (child != none) walk(child, cur, depth + 1);
          i = sibling;
        }
      }

      walk(0, mount, 0);
      return out;
    } catch (_) {
      return null;
    }
  }

  // ---- .pak

  /// .pak: el footer (magic E1 12 6F 5A) da version, indexOffset e indexSize.
  ///  - v <= 9: el índice primario YA lleva todos los nombres (rutas completas).
  ///  - v >= 10 (UE 4.26+/5, lo normal hoy): el índice primario solo tiene
  ///    hashes; los nombres están en el "full directory index".
  static Future<List<OutfitAsset>> _readPak(File f) async {
    final raf = await f.open();
    try {
      final len = await raf.length();
      final tailLen = math.min(len, 1024);
      await raf.setPosition(len - tailLen);
      final tail = await raf.read(tailLen);
      for (var i = tail.length - 24; i >= 0; i--) {
        if (tail[i] == 0xE1 &&
            tail[i + 1] == 0x12 &&
            tail[i + 2] == 0x6F &&
            tail[i + 3] == 0x5A) {
          final bd = ByteData.sublistView(tail);
          final version = bd.getUint32(i + 4, Endian.little);
          final offset = bd.getUint64(i + 8, Endian.little);
          final size = bd.getUint64(i + 16, Endian.little);
          if (offset < 0 || size <= 0 || size > _maxIndexBytes || offset + size > len) {
            break;
          }
          await raf.setPosition(offset);
          final primary = await raf.read(size);
          if (version < 10) return _scanRuns(primary);

          final extra = await _readFullDirectoryIndex(raf, primary, len);
          if (extra == null) break; // sin directorio completo: plan B abajo
          final parsed = _parsePakDirectory(extra);
          if (parsed != null && parsed.isNotEmpty) return parsed;
          return _scanRuns(Uint8List.fromList([...primary, ...extra]));
        }
      }
      // Plan B: escanear el final del archivo (los índices secundarios van
      // justo antes del índice primario).
      final n = math.min(len, _fallbackTail);
      await raf.setPosition(len - n);
      return _scanRuns(await raf.read(n));
    } finally {
      await raf.close();
    }
  }

  /// Índice primario v10+: FString MountPoint, i32 NumEntries, u64 PathHashSeed,
  /// i32 bHasPathHashIndex [+ i64 offset, i64 size, 20B hash],
  /// i32 bHasFullDirectoryIndex [+ i64 offset, i64 size, 20B hash].
  static Future<Uint8List?> _readFullDirectoryIndex(
      RandomAccessFile raf, Uint8List primary, int fileLen) async {
    try {
      final bd = ByteData.sublistView(primary);
      var o = 0;
      final strLen = bd.getInt32(o, Endian.little);
      o += 4 + (strLen >= 0 ? strLen : -strLen * 2);
      o += 4 + 8; // NumEntries + PathHashSeed
      final hasPathHash = bd.getInt32(o, Endian.little) != 0;
      o += 4;
      if (hasPathHash) o += 8 + 8 + 20;
      final hasFullDir = bd.getInt32(o, Endian.little) != 0;
      o += 4;
      if (!hasFullDir) return null;
      final off = bd.getInt64(o, Endian.little);
      final size = bd.getInt64(o + 8, Endian.little);
      if (off < 0 || size <= 0 || size > _maxIndexBytes || off + size > fileLen) {
        return null;
      }
      await raf.setPosition(off);
      return await raf.read(size);
    } catch (_) {
      return null;
    }
  }

  /// Full directory index: i32 nDirs; por dir: FString nombre, i32 nFiles y por
  /// archivo: FString nombre + i32 offset codificado.
  static List<OutfitAsset>? _parsePakDirectory(Uint8List d) {
    try {
      final r = _Reader(d);
      final dirCount = r.i32();
      if (dirCount < 0 || dirCount > d.length) return null;
      final out = <OutfitAsset>[];
      for (var i = 0; i < dirCount; i++) {
        final dir = r.fstr();
        final fileCount = r.i32();
        if (fileCount < 0 || fileCount > d.length) return null;
        for (var j = 0; j < fileCount; j++) {
          final name = r.fstr();
          r.i32(); // offset codificado en el índice primario
          out.add(OutfitAsset(dir, name));
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  // ---- plan B

  /// Escaneo de cadenas de texto (sin estructura). Para cada token CH_P_EVE_*:
  /// con extensión = archivo (con la ruta que lo precede en la cadena, si la
  /// hay); sin extensión = carpeta.
  static List<OutfitAsset> _scanRuns(Uint8List bytes) {
    final out = <OutfitAsset>[];
    final text = String.fromCharCodes(bytes);
    for (final run in _run.allMatches(text)) {
      final s = run.group(0)!;
      for (final m in _token.allMatches(s)) {
        final name = m.group(1)!;
        final slash = m.start > 0 ? s.lastIndexOf('/', m.start - 1) : -1;
        final dir = slash >= 0 ? s.substring(0, slash + 1) : '';
        if (m.group(2) != null) {
          out.add(OutfitAsset(dir, '$name${m.group(2)}'));
        } else {
          out.add(OutfitAsset('$dir$name/', ''));
        }
      }
    }
    return out;
  }

  // ---------------------------------------------------------------- decisión

  /// Partes FUERTES de un nombre: indican TEXTURA aunque el nombre contenga
  /// también una parte de malla (CH_P_EVE_09_Body_DetailMask, _Hair_Map01...).
  static final RegExp _strongTextureToken = RegExp(
      r'^(map\d*|tex|texture|mask\d*|orm|aorm|orsss?|ssao|sssao|normal|albedo|'
      r'emissive|rgb|rgba|detailmask|diffuse|basecolor)$');

  /// Partes DÉBILES (una letra _D/_N/_E o solo dígitos): solo cuentan como
  /// textura si el nombre no contiene ninguna parte de malla.
  static final RegExp _weakTextureToken = RegExp(r'^([a-z]|\d+)$');
  static const Set<String> _meshParts = {
    'body', 'physics', 'animbp', 'anim', 'hair', 'cloth', 'skirt', 'cape',
    'skeleton', 'mesh', 'sk', 'bp'
  };

  /// Prefijos de nombres de malla que no son una parte exacta
  /// (CH_P_EVE_53_PhysicsAsset, ..._SkeletalMesh, ..._AnimBP_C).
  static const List<String> _meshPrefixes = [
    'physics', 'skeletal', 'animbp', 'skeleton'
  ];

  static bool _isMeshPart(String part) =>
      _meshParts.contains(part) || _meshPrefixes.any(part.startsWith);

  /// ¿El resto del nombre (lo que sigue a la clave del traje) es de textura?
  static bool _isTextureSuffix(String rest) {
    final parts = rest.split('_').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return false;
    var weak = false;
    var mesh = false;
    for (final part in parts) {
      if (_strongTextureToken.hasMatch(part)) return true;
      if (_isMeshPart(part)) mesh = true;
      if (_weakTextureToken.hasMatch(part)) weak = true;
    }
    return weak && !mesh;
  }

  /// ¿Es un material / instancia de material por su nombre? (MI_*, *_Inst)
  static bool _looksLikeMaterial(String stem) =>
      stem.startsWith('mi_') ||
      stem.startsWith('m_') ||
      stem.endsWith('_inst') ||
      stem.endsWith('_mat');

  /// ¿El archivo (que NO es textura) es el NÚCLEO del traje (malla, física,
  /// anim/blueprint) y no una dependencia como un material?
  ///  - Nunca si está en una carpeta de materiales o se llama MI_* / *_Inst.
  ///  - Sí si está en una carpeta Meshes/Physics/Anim..., si cuelga directamente
  ///    de la carpeta del traje (CH_P_EVE_53/CH_P_EVE_53.uasset), si se llama
  ///    exactamente como el traje, o si su sufijo es de malla (_Body, _PhysicsAsset).
  static bool _isCore(
      List<String> segs, String folder, String? key, String stem) {
    if (segs.any(_dependencyDirs.contains) || _looksLikeMaterial(stem)) {
      return false;
    }
    if (segs.any(_coreDirs.contains)) return true;
    if (segs.isNotEmpty && segs.last == folder) return true;
    if (key != null) {
      final rest = stem.substring(key.length);
      if (rest.isEmpty) return true;
      return rest.split('_').any(_isMeshPart);
    }
    return false;
  }

  /// Clave (carpeta o stem de traje) más larga que prefija a [t].
  /// (así CH_P_EVE_09_V02_* no cuenta como CH_P_EVE_09, y 09 ≠ 090)
  static String? _keyOf(String t) {
    for (final k in _keys) {
      if (!t.startsWith(k)) continue;
      final next = t.length > k.length ? t.codeUnitAt(k.length) : -1;
      if (next >= 0x30 && next <= 0x39) continue;
      return k;
    }
    return null;
  }

  /// Compatibilidad: [files] = nombres de archivo sin ruta, [dirs] = carpetas.
  static List<String> resolve(Set<String> files, [Set<String> dirs = const {}]) {
    return resolveAssets([
      for (final f in files) OutfitAsset('', f),
      for (final d in dirs) OutfitAsset('$d/', ''),
    ]);
  }

  /// Decide los trajes a partir de los archivos del mod.
  ///
  /// 1. Cada archivo se asigna a una carpeta de traje: por su RUTA (segmento
  ///    CH_P_EVE_xx) o, si no hay ruta, por el prefijo de su nombre.
  /// 2. Dentro de la carpeta, el nombre decide base o variante (CH_P_EVE_19 vs
  ///    CH_P_EVE_19_TypeB*). Archivos sin nombre de traje (EVE_COS_28_BB_N)
  ///    cuentan como la base, salvo que ya haya variantes detectadas.
  /// 3. Cada traje tiene un nivel de evidencia: 4 = núcleo (malla/física/anim),
  ///    3 = dependencia (materiales...), 2 = textura, 1 = solo carpeta.
  /// 4. Solo se conservan las carpetas cuyo mejor nivel iguala al mejor nivel
  ///    del mod (lo más débil es arrastre de otro traje). Dentro de una carpeta
  ///    conservada se devuelven base y todas las variantes con evidencia.
  static List<String> resolveAssets(Iterable<OutfitAsset> assets) {
    final defTier = <String, int>{}; // carpeta -> nivel (archivos de la base)
    final genTier = <String, int>{}; // carpeta -> nivel (archivos genéricos)
    final varTier = <String, int>{}; // stem de variante -> nivel
    void bump(Map<String, int> m, String k, int t) {
      if ((m[k] ?? 0) < t) m[k] = t;
    }

    for (final a in assets) {
      final segs =
          a.dir.toLowerCase().split('/').where((s) => s.isNotEmpty).toList();
      final stem = a.stem;
      final key = stem.isEmpty ? null : _keyOf(stem);

      String? folder; // por ruta (el último segmento que sea carpeta de traje)
      for (final s in segs) {
        if (kOutfitFolders.containsKey(s)) folder = s;
      }
      folder ??= key == null ? null : _keyFolder[key];
      if (folder == null) continue;

      // .ubulk = datos en bloque (texturas): nunca prueban que se reemplace
      // la malla, aunque el nombre no parezca de textura.
      final bool texture = segs.any(_textureDirs.contains) ||
          a.ext == '.ubulk' ||
          (key != null && _isTextureSuffix(stem.substring(key.length)));
      final int tier;
      if (stem.isEmpty) {
        tier = _tierDir;
      } else if (texture) {
        tier = _tierTexture;
      } else if (_isCore(segs, folder, key, stem)) {
        tier = _tierCore;
      } else {
        tier = _tierDependency;
      }

      final entries = kOutfitFolders[folder]!;
      final def = entries.firstWhere((e) => e.isDefault);
      if (key != null && key != def.stem && key != folder &&
          entries.any((e) => e.stem == key)) {
        bump(varTier, key, tier); // variante (TypeB, TypeC...)
      } else if (key != null && (key == def.stem || key == folder)) {
        bump(defTier, folder, tier); // traje base
      } else {
        bump(genTier, folder, tier); // archivo de la carpeta sin nombre propio
      }
    }

    final byFolder = <String, List<String>>{};
    final bestTier = <String, int>{};
    for (final entry in kOutfitFolders.entries) {
      final folder = entry.key;
      final def = entry.value.firstWhere((e) => e.isDefault);
      final hitVariants = entry.value
          .where((e) => e != def && (varTier[e.stem] ?? 0) > 0)
          .toList();
      final defT = math.max(defTier[folder] ?? 0,
          hitVariants.isEmpty ? (genTier[folder] ?? 0) : 0);
      var best = defT;
      for (final v in hitVariants) {
        best = math.max(best, varTier[v.stem]!);
      }
      if (best == 0) continue;
      bestTier[folder] = best;
      byFolder[folder] = [
        if (defT > 0) def.name,
        for (final v in hitVariants) v.name,
      ];
    }

    if (bestTier.isEmpty) return const [];
    final top = bestTier.values.reduce(math.max);
    final out = <String>{};
    final dropped = <String>[];
    for (final e in byFolder.entries) {
      if (bestTier[e.key] == top) {
        out.addAll(e.value);
      } else {
        dropped.addAll(e.value);
      }
    }
    if (dropped.isNotEmpty) {
      debugPrint('[OutfitDetector] descartados por evidencia más débil '
          '(materiales/texturas/carpeta sueltas): $dropped '
          '(nivel máximo del mod: $top, por carpeta: $bestTier)');
    }
    return out.toList()..sort();
  }
}

/// Lector binario little-endian con FStrings de Unreal.
class _Reader {
  final Uint8List d;
  final ByteData bd;
  int p = 0;
  _Reader(this.d) : bd = ByteData.sublistView(d);

  int u32() {
    final v = bd.getUint32(p, Endian.little);
    p += 4;
    return v;
  }

  int i32() {
    final v = bd.getInt32(p, Endian.little);
    p += 4;
    return v;
  }

  /// FString: i32 longitud (>0 = ASCII, <0 = UTF-16 con -longitud caracteres),
  /// incluye el terminador nulo.
  String fstr() {
    final n = i32();
    if (n == 0) return '';
    if (n > 0) {
      if (n > d.length - p) throw const FormatException('FString fuera de rango');
      final end = p + n;
      final s = String.fromCharCodes(d, p, d[end - 1] == 0 ? end - 1 : end);
      p = end;
      return s;
    }
    final c = -n;
    if (c * 2 > d.length - p) throw const FormatException('FString fuera de rango');
    final units = List<int>.generate(c, (i) => bd.getUint16(p + i * 2, Endian.little));
    p += c * 2;
    if (units.isNotEmpty && units.last == 0) units.removeLast();
    return String.fromCharCodes(units);
  }
}