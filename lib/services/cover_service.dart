// Portadas de los mods: carpeta `nexus_cover` con TRES imágenes.
//
//   <mod>/nexus_cover/
//     _nexus_cover.jpg   (o _custom_cover.png...)  → la ORIGINAL, intacta
//     card.webp                                    → miniatura de la tarjeta
//     detail.webp                                  → imagen del panel de detalles
//     .source                                      → a qué original corresponden
//
//  * Las miniaturas se generan UNA vez (al instalar el mod, al cambiar la
//    portada, o la primera vez que hacen falta si el mod es anterior a esto) y
//    después solo se leen del disco: no se reduce nada en tiempo real.
//  * Son WebP optimizados con `cwebp` (el mismo que ya usa ThumbnailService).
//    Si cwebp no está disponible o no entiende el formato, se usa un JPEG
//    generado con el paquete `image` en un isolate (card.jpg / detail.jpg).
//  * `.source` guarda "nombre|tamaño" del original usado. Si no coincide con el
//    original actual (cambió la portada) las miniaturas se regeneran solas.
//  * Las rutas guardadas en nexus_info.json son RELATIVAS a la carpeta del mod
//    (`nexus_cover/_nexus_cover.jpg`), así siguen valiendo al activar o
//    desactivar el mod (que mueve la carpeta).
//  * Las portadas de versiones anteriores (en la raíz del mod) se mueven a la
//    carpeta al cargar la lista (solo mover: rápido); sus miniaturas se crean
//    cuando una tarjeta o el panel las necesitan.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../thumbnail_service.dart';

// ---------------------------------------------------------------------------
// RESPALDO: JPEG con el paquete `image` en un isolate
// ---------------------------------------------------------------------------

class _JpgRequest {
  const _JpgRequest({
    required this.input,
    required this.output,
    required this.quality,
    this.maxWidth,
    this.maxHeight,
  });

  final String input;
  final String output;
  final int quality;
  final int? maxWidth;
  final int? maxHeight;
}

img.Image? _decodeAny(Uint8List bytes) {
  final decoders = <img.Image? Function(Uint8List)>[
    img.decodeImage,
    img.decodeJpg,
    img.decodePng,
    img.decodeWebP,
  ];
  for (final decode in decoders) {
    try {
      final image = decode(bytes);
      if (image != null) return image;
    } catch (_) {}
  }
  return null;
}

Future<bool> _jpgFallback(_JpgRequest r) async {
  final tmp = File('${r.output}.tmp');
  try {
    img.Image? image = _decodeAny(await File(r.input).readAsBytes());
    if (image == null) return false;
    if (r.maxHeight != null && image.height > r.maxHeight!) {
      image = img.copyResize(image, height: r.maxHeight);
    } else if (r.maxWidth != null && image.width > r.maxWidth!) {
      image = img.copyResize(image, width: r.maxWidth);
    }
    await tmp.writeAsBytes(img.encodeJpg(image, quality: r.quality));
    await tmp.rename(r.output);
    return true;
  } catch (e) {
    debugPrint('Error en el respaldo de portadas: $e');
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
    return false;
  }
}

// ---------------------------------------------------------------------------
// SERVICIO
// ---------------------------------------------------------------------------

class CoverService {
  CoverService._();

  static const String dirName = 'nexus_cover';
  static const String cardBase = 'card';
  static const String detailBase = 'detail';
  static const String _markerName = '.source';

  /// Miniatura de la tarjeta: alto máximo (solo se reduce, nunca se amplía).
  static const int cardHeight = 400;
  static const int cardQuality = 80;

  /// Imagen del panel de detalles: ancho máximo. 1600 px cubre un panel ancho
  /// en una pantalla con escala 2x sin que se vea blanda.
  static const int detailWidth = 1600;
  static const int detailQuality = 82;

  static const Duration _cwebpTimeout = Duration(seconds: 30);

  /// Generaciones en curso por carpeta: la tarjeta y el panel pueden pedirlo a
  /// la vez y así comparten el trabajo.
  static final Map<String, Future<bool>> _running = {};

  // -------------------------------------------------------------------------
  // RUTAS Y NOMBRES
  // -------------------------------------------------------------------------

  static bool _isOriginalName(String name) {
    final l = name.toLowerCase();
    return l.startsWith('_nexus_cover.') || l.startsWith('_custom_cover.');
  }

  static bool _inCoverDir(String relative) =>
      relative.replaceAll('\\', '/').startsWith('$dirName/');

  /// ¿[path] es una portada ORIGINAL guardada dentro de `nexus_cover`?
  static bool isCoverOriginalPath(String path) =>
      p.basename(p.dirname(path)) == dirName &&
      _isOriginalName(p.basename(path));

  /// ¿[path] es una miniatura (tarjeta o detalle) generada por este servicio?
  static bool isCoverThumbPath(String path) {
    if (p.basename(p.dirname(path)) != dirName) return false;
    final n = p.basename(path).toLowerCase();
    return n.startsWith('$cardBase.') || n.startsWith('$detailBase.');
  }

  static Future<File?> _find(Directory dir, String base) async {
    for (final ext in const ['.webp', '.jpg']) {
      final f = File(p.join(dir.path, '$base$ext'));
      try {
        final stat = await f.stat();
        if (stat.type == FileSystemEntityType.file && stat.size > 0) return f;
      } catch (_) {}
    }
    return null;
  }

  static File? _findSync(Directory dir, String base) {
    for (final ext in const ['.webp', '.jpg']) {
      final f = File(p.join(dir.path, '$base$ext'));
      try {
        if (f.existsSync() && f.lengthSync() > 0) return f;
      } catch (_) {}
    }
    return null;
  }

  static String _stampOf(File original, int length) =>
      '${p.basename(original.path)}|$length';

  static Future<bool> _isFresh(Directory dir, String stamp) async {
    try {
      final marker = File(p.join(dir.path, _markerName));
      if (!await marker.exists()) return false;
      if ((await marker.readAsString()).trim() != stamp) return false;
    } catch (_) {
      return false;
    }
    return await _find(dir, cardBase) != null &&
        await _find(dir, detailBase) != null;
  }

  // -------------------------------------------------------------------------
  // CONSULTAS RÁPIDAS (sin generar nada)
  // -------------------------------------------------------------------------

  /// Miniatura de tarjeta ya lista y al día, o null si falta o está obsoleta.
  static Future<File?> readyCard(File original) async {
    try {
      final int len = await original.length();
      if (len == 0) return null;
      final Directory dir = original.parent;
      if (!await _isFresh(dir, _stampOf(original, len))) return null;
      return _find(dir, cardBase);
    } catch (_) {
      return null;
    }
  }

  /// Imagen de detalle lista y al día (versión síncrona, para el panel: son
  /// unas pocas lecturas diminutas, una sola vez al abrirlo). Null si falta.
  static File? detailFileSync(File original) {
    try {
      final Directory dir = original.parent;
      final marker = File(p.join(dir.path, _markerName));
      if (!marker.existsSync()) return null;
      final int len = original.lengthSync();
      if (marker.readAsStringSync().trim() != _stampOf(original, len)) {
        return null;
      }
      return _findSync(dir, detailBase);
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // GENERACIÓN
  // -------------------------------------------------------------------------

  /// Miniatura de tarjeta del [original]; si no está lista, genera las dos
  /// miniaturas. Null si no se pudo.
  static Future<File?> cardFor(File original) async {
    await ensureThumbnails(original);
    return _find(original.parent, cardBase);
  }

  /// Genera en segundo plano (sin esperar ni propagar errores) las miniaturas
  /// que falten. Sirve para el panel cuando abre un mod que aún no las tiene.
  static void ensureInBackground(File original) {
    unawaited(
      ThumbnailService()
          .runLimited(() => ensureThumbnails(original))
          .catchError((Object e) {
        debugPrint('No se pudieron generar las miniaturas de portada: $e');
        return false;
      }),
    );
  }

  /// Asegura `card` y `detail` para [original]. Con [force] las rehace aunque
  /// parezcan al día. Devuelve true si quedaron las dos.
  ///
  /// NO limita la concurrencia por sí misma: quien llame desde fuera de
  /// ThumbnailService debe envolverla en `ThumbnailService().runLimited`.
  static Future<bool> ensureThumbnails(File original, {bool force = false}) {
    final String key = original.parent.path;
    final Future<bool>? running = _running[key];
    if (running != null) return running;
    final Future<bool> future = _ensure(original, force);
    _running[key] = future;
    future.whenComplete(() => _running.remove(key)).ignore();
    return future;
  }

  static Future<bool> _ensure(File original, bool force) async {
    try {
      if (!await original.exists()) return false;
      final int len = await original.length();
      if (len == 0) return false;

      final Directory dir = original.parent;
      final String stamp = _stampOf(original, len);
      final File? cwebp = await ThumbnailService().getCwebp();

      // Si cwebp ya funciona, los .jpg que dejó el respaldo se consideran
      // obsoletos y se rehacen como .webp.
      final bool jpgOld = cwebp != null &&
          (File(p.join(dir.path, '$cardBase.jpg')).existsSync() ||
              File(p.join(dir.path, '$detailBase.jpg')).existsSync());
      if (!force && !jpgOld && await _isFresh(dir, stamp)) return true;

      final ({int w, int h})? size = await _probeSize(original);

      // Si ya había miniaturas (obsoletas) se van a reemplazar: Flutter debe
      // olvidar las que tiene decodificadas con la misma ruta.
      final bool hadOld = await _find(dir, cardBase) != null ||
          await _find(dir, detailBase) != null;
      await _deleteThumbs(dir);

      final bool okCard = await _make(
        cwebp: cwebp,
        original: original,
        dir: dir,
        base: cardBase,
        maxHeight: cardHeight,
        quality: cardQuality,
        size: size,
      );
      final bool okDetail = await _make(
        cwebp: cwebp,
        original: original,
        dir: dir,
        base: detailBase,
        maxWidth: detailWidth,
        quality: detailQuality,
        size: size,
      );

      if (okCard && okDetail) {
        final marker = File(p.join(dir.path, _markerName));
        final tmp = File('${marker.path}.tmp');
        await tmp.writeAsString(stamp, flush: true);
        if (await marker.exists()) await marker.delete();
        await tmp.rename(marker.path);
      }

      if (hadOld) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        // Las tarjetas recuerdan la RUTA de la miniatura anterior (p. ej.
        // card.jpg) y ahora puede ser otra (card.webp): se olvida y se avisa.
        ThumbnailService().forgetFilesIn(dir.path);
      }
      return okCard && okDetail;
    } catch (e) {
      debugPrint('Error generando miniaturas de portada: $e');
      return false;
    }
  }

  static Future<void> _deleteThumbs(Directory dir) async {
    for (final base in const [cardBase, detailBase]) {
      for (final ext in const ['.webp', '.jpg']) {
        try {
          final f = File(p.join(dir.path, '$base$ext'));
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    try {
      final marker = File(p.join(dir.path, _markerName));
      if (await marker.exists()) await marker.delete();
    } catch (_) {}
  }

  /// Borra card/detail/.source de la carpeta del mod (cuando ya no hay
  /// portada local a la que correspondan).
  static Future<void> clearThumbnails(Directory modDir) async {
    final dir = Directory(p.join(modDir.path, dirName));
    if (await dir.exists()) await _deleteThumbs(dir);
  }

  /// Crea una miniatura. Solo reduce (si la imagen ya es más pequeña que el
  /// objetivo se recomprime sin cambiar su tamaño).
  static Future<bool> _make({
    required File? cwebp,
    required File original,
    required Directory dir,
    required String base,
    required int quality,
    required ({int w, int h})? size,
    int? maxWidth,
    int? maxHeight,
  }) async {
    // Tamaño desconocido (formato raro): se reduce igualmente.
    final bool resize = size == null
        ? true
        : (maxHeight != null ? size.h > maxHeight : size.w > maxWidth!);

    if (cwebp != null) {
      final out = File(p.join(dir.path, '$base.webp'));
      final bool ok = await _runCwebp(
        cwebp,
        original.path,
        out,
        quality: quality,
        width: resize ? (maxWidth ?? 0) : null,
        height: resize ? (maxHeight ?? 0) : null,
      );
      if (ok) {
        try {
          final old = File(p.join(dir.path, '$base.jpg'));
          if (await old.exists()) await old.delete();
        } catch (_) {}
        return true;
      }
    }

    debugPrint('Portada "$base": se usa el respaldo JPEG '
        '(cwebp ${cwebp == null ? 'no disponible' : 'falló'}).');
    try {
      final bool ok = await compute(
        _jpgFallback,
        _JpgRequest(
          input: original.absolute.path,
          output: p.join(dir.path, '$base.jpg'),
          quality: quality,
          maxWidth: resize ? maxWidth : null,
          maxHeight: resize ? maxHeight : null,
        ),
      );
      if (ok) {
        try {
          final old = File(p.join(dir.path, '$base.webp'));
          if (await old.exists()) await old.delete();
        } catch (_) {}
      }
      return ok;
    } catch (e) {
      debugPrint('Error al llamar al respaldo de portadas: $e');
      return false;
    }
  }

  static Future<bool> _runCwebp(
    File exe,
    String inputPath,
    File output, {
    required int quality,
    int? width,
    int? height,
  }) async {
    final tmp = File('${output.path}.tmp');
    try {
      final process = await Process.start(exe.path, [
        '-quiet',
        '-m', '6', // máxima compresión (se hace una sola vez)
        '-mt',
        '-q', '$quality',
        if (width != null && height != null) ...[
          '-resize', '$width', '$height',
        ],
        inputPath,
        '-o', tmp.path,
      ]);
      final StringBuffer err = StringBuffer();
      final Future<void> errDone =
          process.stderr.transform(systemEncoding.decoder).forEach(err.write);
      unawaited(process.stdout.drain<void>());

      final int exitCode = await process.exitCode.timeout(
        _cwebpTimeout,
        onTimeout: () {
          process.kill();
          return -1;
        },
      );
      await errDone.timeout(const Duration(seconds: 1), onTimeout: () {});
      if (exitCode != 0) {
        debugPrint('cwebp falló (código $exitCode) con '
            '${p.basename(inputPath)}: $err');
        return false;
      }

      final stat = await tmp.stat();
      if (stat.type != FileSystemEntityType.file || stat.size < 100) {
        return false;
      }
      if (await output.exists()) await output.delete();
      await tmp.rename(output.path);
      return true;
    } catch (e) {
      debugPrint('Error ejecutando cwebp: $e');
      return false;
    } finally {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
    }
  }

  // -------------------------------------------------------------------------
  // GUARDAR / MIGRAR ORIGINALES
  // -------------------------------------------------------------------------

  /// Guarda el original en `<mod>/nexus_cover/[fileName]` (desde un archivo o
  /// desde bytes) y devuelve la ruta RELATIVA para nexus_info.json.
  static Future<String> storeOriginal(
    Directory modDir,
    String fileName, {
    File? from,
    Uint8List? bytes,
  }) async {
    assert((from == null) != (bytes == null), 'Pasa `from` o `bytes`');
    final dir = Directory(p.join(modDir.path, dirName));
    await dir.create(recursive: true);

    final target = File(p.join(dir.path, fileName));
    final tmp = File('${target.path}.tmp');
    if (from != null) {
      await from.copy(tmp.path);
    } else {
      await tmp.writeAsBytes(bytes!, flush: true);
    }
    if (await target.exists()) await target.delete();
    await tmp.rename(target.path);
    return '$dirName/$fileName';
  }

  /// Ruta relativa de la portada ORIGINAL de Nexus del mod (en la carpeta, o
  /// en la raíz si es de una versión anterior), o null si no hay.
  static Future<String?> findNexusOriginalRelative(Directory modDir) async {
    for (final entry in {
      Directory(p.join(modDir.path, dirName)): '$dirName/',
      modDir: '',
    }.entries) {
      try {
        if (!await entry.key.exists()) continue;
        await for (final e in entry.key.list(followLinks: false)) {
          if (e is File &&
              p.basename(e.path).toLowerCase().startsWith('_nexus_cover.')) {
            return '${entry.value}${p.basename(e.path)}';
          }
        }
      } catch (_) {}
    }
    return null;
  }

  static Future<void> _move(File from, File to) async {
    try {
      await from.rename(to.path);
    } on FileSystemException {
      await from.copy(to.path);
      await from.delete();
    }
  }

  /// Mueve a `nexus_cover/` las portadas guardadas en la raíz del mod por
  /// versiones anteriores y actualiza `data['customCoverPath']`. Solo MUEVE
  /// archivos (rápido); las miniaturas se crean cuando hacen falta.
  /// Devuelve true si cambió `data` (hay que guardar el JSON).
  static Future<bool> migrateLegacyCover(
    Directory modDir,
    Map<String, dynamic> data,
  ) async {
    bool changed = false;
    try {
      final dir = Directory(p.join(modDir.path, dirName));

      Future<void> moveIn(File legacy) async {
        await dir.create(recursive: true);
        final target = File(p.join(dir.path, p.basename(legacy.path)));
        if (await target.exists()) await target.delete();
        await _move(legacy, target);
      }

      // 1. La portada que usa el mod ahora.
      final String? rel = data['customCoverPath'] as String?;
      if (rel != null && rel.isNotEmpty && !_inCoverDir(rel)) {
        final legacy = File(p.join(modDir.path, rel));
        if (await legacy.exists()) {
          await moveIn(legacy);
          data['customCoverPath'] = '$dirName/${p.basename(rel)}';
          changed = true;
        }
      }

      // 2. Otras portadas sueltas en la raíz (p. ej. la de Nexus mientras hay
      //    una personalizada activa).
      await for (final e in modDir.list(followLinks: false)) {
        if (e is File && _isOriginalName(p.basename(e.path))) {
          await moveIn(e);
        }
      }
    } catch (e) {
      debugPrint('No se pudo migrar la portada de ${modDir.path}: $e');
    }
    return changed;
  }

  // -------------------------------------------------------------------------
  // TAMAÑO DE LA IMAGEN (solo la cabecera: no se decodifica nada)
  // -------------------------------------------------------------------------

  /// Lee el ancho y el alto de la cabecera del archivo (PNG, JPEG, WebP, GIF,
  /// BMP). Null si el formato no se reconoce. Sirve para no AMPLIAR imágenes
  /// pequeñas (`cwebp -resize` amplía si la imagen es menor que el objetivo).
  static Future<({int w, int h})?> _probeSize(File f) async {
    RandomAccessFile? raf;
    try {
      raf = await f.open();
      final Uint8List head = Uint8List.fromList(await raf.read(32));
      if (head.length < 30) return null;
      final bd = ByteData.sublistView(head);

      // PNG
      if (head[0] == 0x89 && head[1] == 0x50 && head[2] == 0x4E) {
        return (w: bd.getUint32(16), h: bd.getUint32(20));
      }
      // GIF
      if (head[0] == 0x47 && head[1] == 0x49 && head[2] == 0x46) {
        return (w: bd.getUint16(6, Endian.little), h: bd.getUint16(8, Endian.little));
      }
      // BMP
      if (head[0] == 0x42 && head[1] == 0x4D) {
        return (
          w: bd.getInt32(18, Endian.little).abs(),
          h: bd.getInt32(22, Endian.little).abs(),
        );
      }
      // WebP
      if (head[0] == 0x52 && head[1] == 0x49 && head[8] == 0x57 && head[9] == 0x45) {
        final String chunk = String.fromCharCodes(head.sublist(12, 16));
        if (chunk == 'VP8 ') {
          return (
            w: bd.getUint16(26, Endian.little) & 0x3FFF,
            h: bd.getUint16(28, Endian.little) & 0x3FFF,
          );
        }
        if (chunk == 'VP8L') {
          final int bits = bd.getUint32(21, Endian.little);
          return (w: (bits & 0x3FFF) + 1, h: ((bits >> 14) & 0x3FFF) + 1);
        }
        if (chunk == 'VP8X') {
          final int w = 1 + (head[24] | (head[25] << 8) | (head[26] << 16));
          final int h = 1 + (head[27] | (head[28] << 8) | (head[29] << 16));
          return (w: w, h: h);
        }
        return null;
      }
      // JPEG: se recorren los segmentos hasta el marcador SOF.
      if (head[0] == 0xFF && head[1] == 0xD8) {
        final int total = await raf.length();
        int pos = 2;
        while (pos + 9 < total) {
          await raf.setPosition(pos);
          final List<int> h = await raf.read(4);
          if (h.length < 4 || h[0] != 0xFF) return null;
          final int marker = h[1];
          if (marker == 0xFF) {
            pos += 1; // relleno
            continue;
          }
          if (marker == 0xD8 || marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
            pos += 2;
            continue;
          }
          final bool isSof = marker >= 0xC0 &&
              marker <= 0xCF &&
              marker != 0xC4 &&
              marker != 0xC8 &&
              marker != 0xCC;
          if (isSof) {
            await raf.setPosition(pos + 5);
            final List<int> d = await raf.read(4);
            if (d.length < 4) return null;
            return (h: (d[0] << 8) | d[1], w: (d[2] << 8) | d[3]);
          }
          pos += 2 + ((h[2] << 8) | h[3]);
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      try {
        await raf?.close();
      } catch (_) {}
    }
  }
}