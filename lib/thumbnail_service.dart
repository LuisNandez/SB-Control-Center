// Servicio de miniaturas de portadas (descargadas de Nexus o locales).
//
// Optimización tomada de GVortex: la reducción de la imagen ya no se hace en
// Dart (paquete `image` dentro de un isolate: decodifica la imagen COMPLETA en
// RAM, la reescala y la recodifica a JPEG) sino con `cwebp.exe`, un binario
// nativo que corre en un proceso aparte, usa mucha menos memoria, es bastante
// más rápido y genera archivos WebP más pequeños.
//
//  * `assets/cwebp.exe` se extrae una sola vez a la carpeta de datos de la app.
//  * Si cwebp no está disponible (no es Windows, falta el asset) o no puede
//    leer el formato (GIF, AVIF...), se usa el método anterior en un isolate
//    (`compute`) como respaldo, así que nada deja de funcionar.
//  * Todo se escribe primero a un archivo `.tmp` y solo se renombra al
//    terminar bien: si la app se cierra a mitad de una miniatura o de una
//    descarga no queda un archivo a medias que luego se dé por bueno.
//  * Caché en memoria con límite (LRU), miniaturas de 0 bytes se descartan y
//    se limpian los `.tmp` huérfanos de sesiones anteriores.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------
// RESPALDO: reducción en un isolate con el paquete `image`
// ---------------------------------------------------------------------------

// Clase de ayuda para pasar datos al Isolate (debe estar fuera de la clase).
class _ProcessImageRequest {
  final String originalPath;
  final String thumbnailPath;
  final int targetHeight;

  _ProcessImageRequest({
    required this.originalPath,
    required this.thumbnailPath,
    required this.targetHeight,
  });
}

// Decodificador "inteligente": primero la auto-detección y, si falla, cada
// formato por separado (algunas imágenes tienen la cabecera algo rara).
// Debe ser de nivel superior para poder usarse dentro de un Isolate.
img.Image? _smartDecodeIsolate(Uint8List bytes) {
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
    } catch (_) {
      // Ese decodificador no sirve para este archivo: se prueba el siguiente.
    }
  }
  return null;
}

// Función pesada que se ejecuta en el Isolate. Devuelve la ruta de la
// miniatura generada o null si falló.
Future<String?> _processImageIsolate(_ProcessImageRequest request) async {
  final tmp = File('${request.thumbnailPath}.tmp');
  try {
    final Uint8List originalBytes =
        await File(request.originalPath).readAsBytes();

    img.Image? image = _smartDecodeIsolate(originalBytes);
    if (image == null) {
      debugPrint(
          '⚠️ [ISOLATE] No se pudo decodificar: ${request.originalPath}');
      return null;
    }

    if (image.height > request.targetHeight) {
      image = img.copyResize(image, height: request.targetHeight);
    }

    await tmp.writeAsBytes(img.encodeJpg(image, quality: 85));
    await tmp.rename(request.thumbnailPath);
    return request.thumbnailPath;
  } catch (e, s) {
    debugPrint('🛑 Error en el isolate de miniaturas: ${request.originalPath}\n'
        '$e\n$s');
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
    return null;
  }
}

// ---------------------------------------------------------------------------
// LIMITADOR DE TRABAJO PESADO
// ---------------------------------------------------------------------------
//
// Sin límite, al hacer scroll rápido por una lista con muchas portadas sin
// miniatura se lanzaban decenas de descargas y procesos a la vez. Con esto
// solo se procesan unas pocas a la vez, y las más recientes (las que el
// usuario está viendo ahora) pasan primero.
class _TaskGate {
  _TaskGate(this.limit);

  final int limit;
  int _running = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running < limit) {
      _running++;
    } else {
      final waiter = Completer<void>();
      _waiters.addLast(waiter);
      await waiter.future; // el hueco se traspasa tal cual (no se recuenta)
    }
    try {
      return await task();
    } finally {
      if (_waiters.isNotEmpty) {
        // LIFO: la última petición suele ser la que está en pantalla.
        _waiters.removeLast().complete();
      } else {
        _running--;
      }
    }
  }
}

// ---------------------------------------------------------------------------
// SERVICIO PRINCIPAL
// ---------------------------------------------------------------------------

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  /// Alto máximo de la miniatura (igual que antes: solo se reduce, no se
  /// recorta). Bájalo (p. ej. 320) si quieres aún menos RAM y disco.
  static const int _thumbHeight = 400;

  /// Calidad WebP (0-100). 80 es prácticamente indistinguible a este tamaño.
  static const int _webpQuality = 80;

  /// Máximo de miniaturas recordadas en memoria (solo son rutas de archivo).
  static const int _maxMemoryEntries = 400;

  /// Si cwebp tarda más que esto con una imagen se cancela y se usa el respaldo.
  static const Duration _cwebpTimeout = Duration(seconds: 30);

  static const Duration _downloadTimeout = Duration(seconds: 30);

  Directory? _imageCacheDir;
  Directory? _thumbnailCacheDir;
  File? _cwebpExe;
  bool _isInitialized = false;
  Future<void>? _initFuture;

  /// Caché LRU en memoria. Un Map de Dart conserva el orden de inserción, así
  /// que la primera clave es siempre la menos usada recientemente.
  final Map<String, File> _memoryCache = {};

  /// Peticiones en curso por clave: si dos tarjetas piden la misma portada a
  /// la vez (p. ej. al cambiar de cuadrícula a lista) se comparte el trabajo.
  final Map<String, Future<File?>> _inFlight = {};

  /// Máximo de portadas descargándose / comprimiéndose a la vez. cwebp es
  /// nativo y ligero, así que se puede paralelizar más que con isolates.
  final _TaskGate _gate =
      _TaskGate(math.max(2, math.min(4, Platform.numberOfProcessors ~/ 2)));

  // -------------------------------------------------------------------------
  // INICIALIZACIÓN
  // -------------------------------------------------------------------------

  /// Idempotente y segura si varias partes la llaman a la vez.
  Future<void> initialize() => _initFuture ??= _doInitialize();

  Future<void> _doInitialize() async {
    if (_isInitialized) return;
    try {
      final appDir = await getApplicationSupportDirectory();

      _imageCacheDir = Directory(p.join(appDir.path, 'image_cache'));
      if (!await _imageCacheDir!.exists()) {
        await _imageCacheDir!.create(recursive: true);
      }

      _thumbnailCacheDir = Directory(p.join(appDir.path, 'thumbnail_cache'));
      if (!await _thumbnailCacheDir!.exists()) {
        await _thumbnailCacheDir!.create(recursive: true);
      }

      await _prepareCwebp(appDir);

      debugPrint('--- CACHÉ DE MINIATURAS EN: ${_thumbnailCacheDir!.path} '
          '(motor: ${_cwebpExe != null ? 'cwebp' : 'isolate/image'}) ---');

      _isInitialized = true;
      // En segundo plano: la carpeta puede tener miles de archivos.
      unawaited(_sweepTemporaryFiles());
    } catch (e) {
      debugPrint('Error al inicializar ThumbnailService: $e');
      _initFuture = null; // permitir reintentar
    }
  }

  /// Extrae cwebp.exe de los assets (una sola vez). Si no se puede, el
  /// servicio sigue funcionando con el método de respaldo.
  Future<void> _prepareCwebp(Directory appDir) async {
    if (!Platform.isWindows) return;
    final exe = File(p.join(appDir.path, 'cwebp.exe'));
    try {
      if (!await exe.exists() || await exe.length() == 0) {
        final data = await rootBundle.load('assets/cwebp.exe');
        // Se extrae a un temporal y se renombra: nunca queda un .exe a medias.
        final tmp = File('${exe.path}.tmp');
        await tmp.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        await tmp.rename(exe.path);
      }
      _cwebpExe = exe;
    } catch (e) {
      debugPrint('cwebp.exe no disponible (¿falta "assets/cwebp.exe" en el '
          'pubspec.yaml?): $e. Se usará el método de respaldo.');
    }
  }

  /// Borra restos de descargas/miniaturas interrumpidas (.tmp) de sesiones
  /// anteriores. Solo toca archivos de más de 10 minutos para no pisar el
  /// trabajo de esta misma sesión.
  Future<void> _sweepTemporaryFiles() async {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));
    for (final dir in [_thumbnailCacheDir, _imageCacheDir]) {
      if (dir == null) continue;
      try {
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is! File) continue;
          if (!entity.path.endsWith('.tmp')) continue;
          try {
            if ((await entity.lastModified()).isBefore(cutoff)) {
              await entity.delete();
            }
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  // -------------------------------------------------------------------------
  // CACHÉ EN MEMORIA (LRU)
  // -------------------------------------------------------------------------

  /// Miniatura ya conocida, al instante (sin pasar por disco). Marca la
  /// entrada como "usada hace poco".
  File? getFromMemoryCache(String key) {
    final file = _memoryCache.remove(key);
    if (file != null) _memoryCache[key] = file;
    return file;
  }

  void _remember(String key, File file) {
    _memoryCache.remove(key);
    _memoryCache[key] = file;
    while (_memoryCache.length > _maxMemoryEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }

  void clearMemoryCache() => _memoryCache.clear();

  /// true si [file] es una miniatura generada por este servicio. Si no lo es
  /// (p. ej. cuando falló la reducción y se muestra el original) conviene
  /// decodificarla a un tamaño reducido para no gastar RAM.
  bool isGeneratedThumbnail(File file) {
    final dir = _thumbnailCacheDir;
    return dir != null && p.isWithin(dir.path, file.path);
  }

  // -------------------------------------------------------------------------
  // API PÚBLICA
  // -------------------------------------------------------------------------

  Future<File?> getThumbnail(
    String cacheKey,
    String sourcePath, {
    bool isLocalFile = false,
  }) {
    final File? cached = getFromMemoryCache(cacheKey);
    if (cached != null) return Future<File?>.value(cached);

    final Future<File?>? running = _inFlight[cacheKey];
    if (running != null) return running;

    final Future<File?> future = _getThumbnailImpl(
      cacheKey,
      sourcePath,
      isLocalFile: isLocalFile,
    );
    _inFlight[cacheKey] = future;
    // .ignore(): el error (si lo hay) le llega a quien espera `future`.
    future.whenComplete(() => _inFlight.remove(cacheKey)).ignore();
    return future;
  }

  Future<File?> _getThumbnailImpl(
    String cacheKey,
    String sourcePath, {
    required bool isLocalFile,
  }) async {
    if (!_isInitialized) await initialize();
    if (_thumbnailCacheDir == null) return null;

    final String hash = _hash(cacheKey);

    // Revisar la caché en disco.
    final File? onDisk = await _findOnDisk(hash);
    if (onDisk != null) {
      _remember(cacheKey, onDisk);
      return onDisk;
    }

    // Descargar + comprimir es lo pesado: se hace de pocas en pocas.
    return _gate.run(
      () => _createThumbnail(cacheKey, sourcePath, hash, isLocalFile),
    );
  }

  // -------------------------------------------------------------------------
  // CREACIÓN DE LA MINIATURA
  // -------------------------------------------------------------------------

  String _hash(String key) => sha1.convert(utf8.encode(key)).toString();

  /// Busca la miniatura en disco: primero el WebP nuevo y luego el JPEG de las
  /// versiones anteriores (así no se regeneran las que ya existen). Descarta
  /// archivos vacíos.
  Future<File?> _findOnDisk(String hash) async {
    for (final ext in const ['.webp', '.jpg']) {
      final file = File(p.join(_thumbnailCacheDir!.path, '$hash$ext'));
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) continue;
      if (stat.size > 0) return file;
      try {
        await file.delete(); // miniatura corrupta (0 bytes): se regenera
      } catch (_) {}
    }
    return null;
  }

  Future<File?> _createThumbnail(
    String cacheKey,
    String sourcePath,
    String hash,
    bool isLocalFile,
  ) async {
    // Mientras esperaba su turno otra petición pudo dejarla ya lista.
    final File? alreadyThere = getFromMemoryCache(cacheKey);
    if (alreadyThere != null) return alreadyThere;
    final File? onDisk = await _findOnDisk(hash);
    if (onDisk != null) {
      _remember(cacheKey, onDisk);
      return onDisk;
    }

    final File? source = await _obtainSource(sourcePath, hash, isLocalFile);
    if (source == null) return null;

    final File? thumb = await _compress(source, hash);
    if (thumb != null) {
      _remember(cacheKey, thumb);
      return thumb;
    }

    // Fallback: se usa la imagen original (sin procesar). Solo se recuerda en
    // memoria, así la próxima sesión se vuelve a intentar.
    debugPrint('⚠️ Fallback: usando la imagen original para '
        '${p.basename(sourcePath)}');
    _remember(cacheKey, source);
    return source;
  }

  /// Devuelve el archivo original: el propio archivo local o la descarga
  /// (guardada en image_cache).
  Future<File?> _obtainSource(
    String sourcePath,
    String hash,
    bool isLocalFile,
  ) async {
    if (isLocalFile) {
      final localFile = File(sourcePath);
      if (await localFile.exists()) return localFile;
      debugPrint('⚠️ Archivo local no encontrado: $sourcePath');
      return null;
    }

    if (_imageCacheDir == null) return null;
    final String extension =
        p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final originalFile =
        File(p.join(_imageCacheDir!.path, '$hash$extension'));

    final stat = await originalFile.stat();
    if (stat.type == FileSystemEntityType.file && stat.size > 0) {
      return originalFile;
    }

    final tmp = File('${originalFile.path}.tmp');
    try {
      final response = await http
          .get(Uri.parse(sourcePath))
          .timeout(_downloadTimeout);
      if (response.statusCode != 200) {
        debugPrint('No se pudo descargar $sourcePath '
            '(estado ${response.statusCode})');
        return null;
      }
      // Descarga a un temporal y renombra: sin originales a medias en caché.
      await tmp.writeAsBytes(response.bodyBytes);
      await tmp.rename(originalFile.path);
      return originalFile;
    } catch (e) {
      debugPrint('Error descargando $sourcePath: $e');
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      return null;
    }
  }

  /// Genera la miniatura. Primero cwebp (rápido, poca RAM) y, si no está o no
  /// entiende el formato, el isolate con el paquete `image`.
  Future<File?> _compress(File source, String hash) async {
    final cwebp = _cwebpExe;
    if (cwebp != null) {
      final webp = File(p.join(_thumbnailCacheDir!.path, '$hash.webp'));
      if (await _runCwebp(cwebp, source.path, webp)) return webp;
    }

    final jpgPath = p.join(_thumbnailCacheDir!.path, '$hash.jpg');
    try {
      final String? result = await compute(
        _processImageIsolate,
        _ProcessImageRequest(
          originalPath: source.absolute.path,
          thumbnailPath: jpgPath,
          targetHeight: _thumbHeight,
        ),
      );
      return result == null ? null : File(result);
    } catch (e) {
      debugPrint('Error al llamar al isolate de miniaturas: $e');
      return null;
    }
  }

  /// Ejecuta cwebp: reduce a [_thumbHeight] px de alto manteniendo el aspecto.
  /// Escribe a un .tmp y solo renombra si todo salió bien.
  Future<bool> _runCwebp(File exe, String inputPath, File output) async {
    final tmp = File('${output.path}.tmp');
    try {
      final process = await Process.start(exe.path, [
        '-quiet',
        '-q', '$_webpQuality',
        '-resize', '0', '$_thumbHeight',
        inputPath,
        '-o', tmp.path,
      ]);
      // Hay que vaciar stdout/stderr siempre para que el proceso no se bloquee.
      unawaited(process.stdout.drain<void>());
      unawaited(process.stderr.drain<void>());

      final int exitCode = await process.exitCode.timeout(
        _cwebpTimeout,
        onTimeout: () {
          process.kill();
          return -1;
        },
      );
      if (exitCode != 0) return false;

      final stat = await tmp.stat();
      if (stat.type != FileSystemEntityType.file || stat.size < 100) {
        return false;
      }
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
}