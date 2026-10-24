import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as p;

/// (progreso 0..1, velocidad, "descargado / total")
typedef DownloadProgressCallback = void Function(
    double progress, String speed, String downloadedStr);

/// El enlace del CDN caducó o fue rechazado (403 / 410). El gestor pide uno
/// nuevo a la API de Nexus.
class ExpiredLinkException implements Exception {
  final String message;
  final int? statusCode;
  ExpiredLinkException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// Respuesta HTTP inesperada. El texto visible se genera en la UI con
/// l10n.downloadErrorHttp(statusCode).
class HttpStatusException implements Exception {
  final int statusCode;
  HttpStatusException(this.statusCode);
  @override
  String toString() => 'HTTP error: $statusCode';
}

enum DownloadFailureKind {
  /// No se pudo conectar (DNS, host bloqueado, conexión rechazada/cortada).
  network,

  /// El servidor no respondió / dejó de enviar datos.
  timeout,

  /// Falló el canal seguro (certificado, antivirus con escaneo HTTPS, etc.).
  tls,

  /// El servidor respondió con un código HTTP de error.
  http,

  /// No se pudo crear o escribir el archivo en disco.
  disk,

  /// El contenido recibido no es válido (p. ej. una página de bloqueo HTML).
  invalid,

  /// Falló un descargador externo (curl / PowerShell).
  process,

  unknown,
}

/// Fallo de descarga ya clasificado. Sustituye al antiguo `return null`, que
/// escondía la causa real detrás de un genérico "Download failed".
class DownloadFailure implements Exception {
  final DownloadFailureKind kind;
  final String detail;
  final int? statusCode;
  final String? host;

  const DownloadFailure(this.kind, this.detail, {this.statusCode, this.host});

  /// Motivo corto y técnico para mostrar junto al mensaje genérico.
  String get shortLabel {
    final h = (host == null || host!.isEmpty) ? '' : ' ($host)';
    if (kind == DownloadFailureKind.network) return 'cannot reach server$h';
    if (kind == DownloadFailureKind.timeout) return 'timed out$h';
    if (kind == DownloadFailureKind.tls) return 'secure connection failed$h';
    if (kind == DownloadFailureKind.disk) return 'cannot write file';
    if (kind == DownloadFailureKind.invalid) return 'invalid or blocked response';
    if (kind == DownloadFailureKind.process) return 'external downloader failed';
    return '';
  }

  @override
  String toString() =>
      'DownloadFailure(${kind.name}${statusCode != null ? ' $statusCode' : ''}): $detail';
}

class DownloadController {
  StreamSubscription<List<int>>? subscription;
  bool isCancelled = false;
  Function()? onCancel;

  /// Sube con cada cancelación/pausa. Un flujo antiguo que siga "vivo" entre
  /// dos intentos detecta así que ya no es el vigente y se detiene.
  int generation = 0;

  /// Método de descarga que funcionó en esta tarea (para reanudar con él).
  Object? preferredMethod;

  bool stopped(int gen) => isCancelled || gen != generation;

  void pause() => subscription?.pause();
  void resume() => subscription?.resume();
  void cancel() {
    isCancelled = true;
    generation++;
    subscription?.cancel();
    onCancel?.call();
  }
}

/// Registro de diagnóstico (sin API key ni parámetros de las URLs).
/// Windows: %LOCALAPPDATA%\SB Control Center\logs\download.log
class DownloadLog {
  static const int _maxBytes = 512 * 1024;
  static File? _file;

  static File _resolve() {
    final cached = _file;
    if (cached != null) return cached;
    final local = Platform.environment['LOCALAPPDATA'];
    final base = (local != null && local.isNotEmpty)
        ? p.join(local, 'SB Control Center', 'logs')
        : p.join(Directory.systemTemp.path, 'sb_control_logs');
    try {
      Directory(base).createSync(recursive: true);
    } catch (_) {}
    return _file = File(p.join(base, 'download.log'));
  }

  static String get path => _resolve().path;

  static void write(String message) {
    try {
      final f = _resolve();
      if (f.existsSync() && f.lengthSync() > _maxBytes) {
        final old = File('${f.path}.old');
        try {
          if (old.existsSync()) old.deleteSync();
        } catch (_) {}
        f.renameSync(old.path);
      }
      f.writeAsStringSync(
        '${DateTime.now().toIso8601String()}  $message\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // El log nunca debe romper una descarga.
    }
  }

  /// URL sin query (la query del CDN lleva tokens).
  static String redact(Uri u) => '${u.scheme}://${u.host}${u.path}';
}

/// Estrategias de descarga, de la más ligera a la más "agresiva".
enum _Method {
  dart('Standard'),
  dartSystemProxy('System proxy'),
  dartDirect('No proxy'),
  curl('curl'),
  powershell('PowerShell');

  const _Method(this.label);
  final String label;
}

class DownloadService {
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) SBControlCenter/1.0';
  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _headersTimeout = Duration(seconds: 30);
  static const Duration _stallTimeout = Duration(seconds: 30);

  /// Último método que funcionó en esta sesión: las siguientes descargas
  /// empiezan directamente por él.
  static _Method? _lastGoodMethod;

  // ---------------------------------------------------------------------------
  //  CARPETA Y NOMBRES
  // ---------------------------------------------------------------------------

  /// Devuelve una carpeta de descargas donde SÍ se puede escribir. Prueba
  /// varias ubicaciones (el %TEMP% puede estar redirigido, sin permisos o
  /// bloqueado por "Acceso controlado a carpetas" de Windows Defender).
  static Future<Directory> prepareDownloadDir() async {
    final env = Platform.environment;
    final candidates = <String>[
      p.join(Directory.systemTemp.path, 'sb_control_downloads'),
      if ((env['LOCALAPPDATA'] ?? '').isNotEmpty)
        p.join(env['LOCALAPPDATA']!, 'SB Control Center', 'downloads'),
      if ((env['USERPROFILE'] ?? '').isNotEmpty)
        p.join(env['USERPROFILE']!, 'Downloads', 'SB Control Center'),
      p.join(p.dirname(Platform.resolvedExecutable), 'downloads'),
    ];

    final errors = <String>[];
    for (final path in candidates) {
      try {
        final dir = Directory(path);
        if (!dir.existsSync()) dir.createSync(recursive: true);
        final probe = File(p.join(dir.path, '.write_test'));
        probe.writeAsStringSync('ok', flush: true);
        probe.deleteSync();
        return dir;
      } catch (e) {
        errors.add('$path -> $e');
        DownloadLog.write('Download dir not usable: $path ($e)');
      }
    }
    throw DownloadFailure(
      DownloadFailureKind.disk,
      'No writable download folder. ${errors.join(' | ')}',
    );
  }

  /// Nombre válido para Windows: sin caracteres prohibidos, sin nombres
  /// reservados y con longitud segura (la ruta completa debe caber en 260).
  static String safeFileName(String name, {int dirLength = 0}) {
    var s = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_').trim();
    s = s.replaceAll(RegExp(r'[. ]+$'), '');
    if (s.isEmpty) s = 'download.zip';

    final stem = p.basenameWithoutExtension(s).toUpperCase();
    if (RegExp(r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])$').hasMatch(stem)) {
      s = '_$s';
    }

    final maxLen = (240 - dirLength - 1).clamp(60, 200).toInt();
    if (s.length > maxLen) {
      final ext = p.extension(s);
      final base = p.basenameWithoutExtension(s);
      final keep = math.max(8, maxLen - ext.length);
      // Se recorta el principio y se conserva el final ("-modId-versión-…").
      final cut = base.length > keep ? base.substring(base.length - keep) : base;
      s = '$cut$ext';
    }
    return s;
  }

  // ---------------------------------------------------------------------------
  //  API PÚBLICA
  // ---------------------------------------------------------------------------

  /// Compatibilidad: descarga desde una única URL (con todos los métodos de
  /// respaldo). Devuelve null solo si se canceló; ante un fallo lanza
  /// [DownloadFailure] / [ExpiredLinkException].
  static Future<File?> downloadFile({
    required String url,
    required File targetFile,
    required DownloadProgressCallback onProgress,
    DownloadController? controller,
  }) {
    return downloadWithFallback(
      urls: [url],
      targetFile: targetFile,
      controller: controller ?? DownloadController(),
      onProgress: onProgress,
    );
  }

  /// Descarga con respaldo en capas:
  ///  1. Prueba cada mirror que devolvió Nexus (antes solo se usaba el primero).
  ///  2. Si fallan todos, cambia de método: proxy del sistema, sin proxy,
  ///     curl.exe (Schannel, IPv4, sin comprobación de revocación) y
  ///     PowerShell/WebClient (proxy y certificados de Windows).
  ///  3. Valida el resultado (que no sea una página HTML de bloqueo).
  ///
  /// Devuelve null únicamente si el usuario canceló/pausó.
  static Future<File?> downloadWithFallback({
    required List<String> urls,
    required File targetFile,
    required DownloadController controller,
    required DownloadProgressCallback onProgress,
    void Function(String status)? onStatus,
    int? expectedBytes,
    String logTag = '',
  }) async {
    final generation = controller.generation;
    final tag = logTag.isEmpty ? '' : '[$logTag] ';

    final mirrors = <Uri>[];
    for (final raw in urls) {
      final uri = _parseUrl(raw);
      if (uri != null && !mirrors.contains(uri)) mirrors.add(uri);
    }
    if (mirrors.isEmpty) {
      throw const DownloadFailure(
          DownloadFailureKind.unknown, 'No valid download URL');
    }

    final sysProxy = await _detectWindowsProxy();
    final methods = _buildMethodPlan(controller, sysProxy);
    DownloadLog.write(
        '$tag Start: ${mirrors.length} mirror(s), methods=${methods.map((m) => m.label).join(',')}, '
        'file=${p.basename(targetFile.path)}, expected=${expectedBytes ?? '?'}');

    var attempts = 0;
    var allExpiredPasses = 0;
    ExpiredLinkException? lastExpired;
    DownloadFailure? lastFailure;

    for (var pass = 0; pass < methods.length; pass++) {
      final method = methods[pass];
      final limit = pass == 0 ? mirrors.length : math.min(mirrors.length, 3);
      var passAttempts = 0;
      var passExpired = 0;

      for (var i = 0; i < limit; i++) {
        if (controller.stopped(generation)) return null;
        final uri = mirrors[i];

        if (attempts > 0) {
          onStatus?.call('Mirror ${i + 1}/${mirrors.length} · ${method.label}');
        }
        DownloadLog.write(
            '$tag Attempt ${attempts + 1}: ${method.label} -> ${DownloadLog.redact(uri)}');

        try {
          final file = await _runMethod(
            method: method,
            uri: uri,
            proxy: sysProxy,
            targetFile: targetFile,
            controller: controller,
            generation: generation,
            // Solo el primer intento puede continuar un archivo parcial
            // (reanudación del usuario). Tras un fallo se empieza limpio.
            allowResume: attempts == 0,
            expectedBytes: expectedBytes,
            onProgress: onProgress,
          );
          if (file == null || controller.stopped(generation)) return null;

          await _validateDownloaded(file, expectedBytes);

          _lastGoodMethod = method;
          controller.preferredMethod = method;
          DownloadLog.write(
              '$tag OK via ${method.label} (${file.lengthSync()} bytes)');
          return file;
        } on ExpiredLinkException catch (e) {
          lastExpired = e;
          passExpired++;
          DownloadLog.write('$tag ${method.label}: link rejected (${e.statusCode})');
        } on DownloadFailure catch (e) {
          lastFailure = e;
          DownloadLog.write('$tag ${method.label}: $e');
        } catch (e) {
          final f = _classify(e, host: uri.host);
          lastFailure = f;
          DownloadLog.write('$tag ${method.label}: $f');
        }

        attempts++;
        passAttempts++;
        if (controller.stopped(generation)) return null;
      }

      // Si TODOS los intentos de una pasada fueron 403/410, el enlace caducó
      // de verdad; con dos pasadas distintas (p. ej. Dart y curl, que tienen
      // huella TLS distinta) se descarta que sea un bloqueo por cliente.
      if (passAttempts > 0 && passExpired == passAttempts) {
        allExpiredPasses++;
        if (allExpiredPasses >= 2 && lastExpired != null) throw lastExpired;
      }

      if (pass < methods.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    DownloadLog.write('$tag FAILED after $attempts attempt(s)');
    if (lastFailure == null && lastExpired != null) throw lastExpired;
    throw lastFailure ??
        const DownloadFailure(DownloadFailureKind.unknown, 'Download failed');
  }

  // ---------------------------------------------------------------------------
  //  PLAN DE MÉTODOS
  // ---------------------------------------------------------------------------

  static List<_Method> _buildMethodPlan(
      DownloadController controller, String? sysProxy) {
    final plan = <_Method>[_Method.dart];

    if (sysProxy != null) plan.add(_Method.dartSystemProxy);
    if (_hasEnvProxy()) plan.add(_Method.dartDirect);

    if (Platform.isWindows) {
      if (File(_curlPath()).existsSync()) plan.add(_Method.curl);
      if (File(_powershellPath()).existsSync()) plan.add(_Method.powershell);
    }

    final preferred = (controller.preferredMethod as _Method?) ?? _lastGoodMethod;
    if (preferred != null && plan.contains(preferred) && plan.first != preferred) {
      plan.remove(preferred);
      plan.insert(0, preferred);
    }
    return plan;
  }

  static bool _hasEnvProxy() {
    final env = Platform.environment;
    for (final k in const [
      'HTTPS_PROXY', 'https_proxy', 'HTTP_PROXY', 'http_proxy', 'ALL_PROXY', 'all_proxy'
    ]) {
      if ((env[k] ?? '').isNotEmpty) return true;
    }
    return false;
  }

  static Future<File?> _runMethod({
    required _Method method,
    required Uri uri,
    required String? proxy,
    required File targetFile,
    required DownloadController controller,
    required int generation,
    required bool allowResume,
    required int? expectedBytes,
    required DownloadProgressCallback onProgress,
  }) {
    if (method == _Method.curl) {
      return _downloadViaCurl(
        uri: uri,
        targetFile: targetFile,
        controller: controller,
        generation: generation,
        allowResume: allowResume,
        expectedBytes: expectedBytes,
        onProgress: onProgress,
      );
    }
    if (method == _Method.powershell) {
      return _downloadViaPowerShell(
        uri: uri,
        targetFile: targetFile,
        controller: controller,
        generation: generation,
        expectedBytes: expectedBytes,
        onProgress: onProgress,
      );
    }
    return _downloadViaDart(
      uri: uri,
      method: method,
      proxy: proxy,
      targetFile: targetFile,
      controller: controller,
      generation: generation,
      allowResume: allowResume,
      expectedBytes: expectedBytes,
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  //  MÉTODO 1-3: dart:io (HttpClient)
  // ---------------------------------------------------------------------------

  static HttpClient _buildClient(_Method method, String? proxy) {
    final client = HttpClient()
      ..connectionTimeout = _connectTimeout
      ..idleTimeout = const Duration(seconds: 15)
      ..autoUncompress = false
      ..userAgent = _userAgent;

    switch (method) {
      case _Method.dartDirect:
        client.findProxy = (_) => 'DIRECT';
        break;
      case _Method.dartSystemProxy:
        client.findProxy = (_) => proxy ?? 'DIRECT';
        break;
      default:
        break; // proxy de variables de entorno (comportamiento por defecto)
    }
    return client;
  }

  static Future<File?> _downloadViaDart({
    required Uri uri,
    required _Method method,
    required String? proxy,
    required File targetFile,
    required DownloadController controller,
    required int generation,
    required bool allowResume,
    required int? expectedBytes,
    required DownloadProgressCallback onProgress,
  }) async {
    final client = _buildClient(method, proxy);
    try {
      var existing = 0;
      if (targetFile.existsSync()) {
        if (allowResume) {
          existing = targetFile.lengthSync();
        } else {
          _tryDelete(targetFile);
        }
      }

      // Hasta 4 rondas: si el servidor corta la conexión antes de tiempo se
      // continúa desde el byte donde quedó (Range) en vez de dar el archivo
      // truncado por bueno.
      for (var round = 0; round < 4; round++) {
        if (controller.stopped(generation)) return null;

        final request = await client.getUrl(uri).timeout(_headersTimeout);
        request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        request.headers.set(HttpHeaders.acceptHeader, '*/*');
        if (existing > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existing-');
        }

        final response = await request.close().timeout(_headersTimeout);
        final status = response.statusCode;
        final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);

        if (status == 403 || status == 410) {
          await _drainQuietly(response);
          throw ExpiredLinkException('Nexus link expired ($status)',
              statusCode: status);
        }

        if (status == 416) {
          await _drainQuietly(response);
          final total = _totalFromContentRange(contentRange);
          if (existing > 0 && total != null && total == existing) {
            return targetFile; // ya estaba completo
          }
          // Parcial inválido: se descarta y se empieza de cero.
          _tryDelete(targetFile);
          existing = 0;
          continue;
        }

        if (status != 200 && status != 206) {
          await _drainQuietly(response);
          throw HttpStatusException(status);
        }

        var append = false;
        if (status == 206 && existing > 0) {
          if (_startFromContentRange(contentRange) == existing) {
            append = true;
          } else {
            await _drainQuietly(response);
            _tryDelete(targetFile);
            existing = 0;
            continue;
          }
        } else {
          existing = 0; // 200: el servidor ignoró Range, llega el archivo entero
        }

        final contentLength = response.contentLength; // -1 si se desconoce
        final int total = contentLength >= 0
            ? contentLength + (append ? existing : 0)
            : (expectedBytes ?? -1);

        final raf =
            targetFile.openSync(mode: append ? FileMode.append : FileMode.write);
        var rafClosed = false;
        void closeRaf() {
          if (rafClosed) return;
          rafClosed = true;
          try {
            raf.flushSync();
          } catch (_) {}
          try {
            raf.closeSync();
          } catch (_) {}
        }

        var received = existing;
        var lastBytes = received;
        final sw = Stopwatch()..start();
        final done = Completer<bool>(); // true = terminó, false = cancelado
        StreamSubscription<List<int>>? sub;

        controller.onCancel = () {
          closeRaf();
          if (!done.isCompleted) done.complete(false);
        };

        sub = response.timeout(
          _stallTimeout,
          onTimeout: (s) {
            s.addError(TimeoutException(
                'No data received for ${_stallTimeout.inSeconds}s'));
            s.close();
          },
        ).listen(
          (chunk) {
            if (controller.stopped(generation)) return;
            try {
              raf.writeFromSync(chunk);
            } catch (e) {
              closeRaf();
              sub?.cancel();
              if (!done.isCompleted) {
                done.completeError(DownloadFailure(
                    DownloadFailureKind.disk, 'Write failed: $e'));
              }
              return;
            }
            received += chunk.length;

            final ms = sw.elapsedMilliseconds;
            if (ms >= 300) {
              final bps = (received - lastBytes) / (ms / 1000);
              onProgress(
                total > 0 ? (received / total).clamp(0.0, 1.0).toDouble() : 0.0,
                '${(bps / 1024 / 1024).toStringAsFixed(2)} MB/s',
                _progressText(received, total),
              );
              sw.reset();
              lastBytes = received;
            }
          },
          onDone: () {
            closeRaf();
            if (!done.isCompleted) done.complete(true);
          },
          onError: (Object e, StackTrace st) {
            closeRaf();
            if (!done.isCompleted) done.completeError(e, st);
          },
          cancelOnError: true,
        );
        controller.subscription = sub;

        final finished = await done.future.whenComplete(() {
          controller.onCancel = null;
          controller.subscription = null;
          closeRaf();
        });
        if (!finished || controller.stopped(generation)) return null;

        final size = targetFile.lengthSync();
        if (total > 0 && size < total) {
          // Conexión cerrada antes de tiempo: continuar desde `size`.
          DownloadLog.write('Truncated stream ($size/$total), resuming');
          existing = size;
          continue;
        }

        onProgress(1.0, '0 MB/s', _progressText(size, size));
        return targetFile;
      }

      throw DownloadFailure(
        DownloadFailureKind.network,
        'Connection closed before the download completed',
        host: uri.host,
      );
    } finally {
      client.close(force: true);
    }
  }

  // ---------------------------------------------------------------------------
  //  MÉTODO 4: curl.exe (incluido en Windows 10 1803+)
  // ---------------------------------------------------------------------------

  static String _systemRoot() => Platform.environment['SystemRoot'] ?? r'C:\Windows';

  static String _curlPath() => p.join(_systemRoot(), 'System32', 'curl.exe');

  static String _powershellPath() => p.join(
      _systemRoot(), 'System32', 'WindowsPowerShell', 'v1.0', 'powershell.exe');

  static Future<File?> _downloadViaCurl({
    required Uri uri,
    required File targetFile,
    required DownloadController controller,
    required int generation,
    required bool allowResume,
    required int? expectedBytes,
    required DownloadProgressCallback onProgress,
  }) async {
    Future<File?> run(bool resume) {
      final args = <String>[
        '--location',
        '--fail',
        '--silent',
        '--show-error',
        '--ipv4', // evita redes con IPv6 roto
        '--ssl-no-revoke', // evita fallos de revocación de Schannel tras antivirus/proxy
        '--connect-timeout', '20',
        '--speed-time', '30',
        '--speed-limit', '1',
        '--retry', '2',
        '--retry-delay', '2',
        '--user-agent', _userAgent,
        if (resume) ...['--continue-at', '-'],
        '--output', targetFile.path,
        uri.toString(),
      ];
      return _runExternal(
        label: 'curl',
        executable: _curlPath(),
        args: args,
        targetFile: targetFile,
        controller: controller,
        generation: generation,
        host: uri.host,
        expectedBytes: expectedBytes,
        onProgress: onProgress,
      );
    }

    final canResume =
        allowResume && targetFile.existsSync() && targetFile.lengthSync() > 0;
    if (!canResume) _tryDelete(targetFile);

    try {
      return await run(canResume);
    } on DownloadFailure {
      if (canResume && !controller.stopped(generation)) {
        // El parcial pudo ser el problema: reintento limpio.
        _tryDelete(targetFile);
        return run(false);
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  //  MÉTODO 5: PowerShell + System.Net.WebClient (proxy y certificados de Windows)
  // ---------------------------------------------------------------------------

  static const String _psScript = r'''
$ErrorActionPreference = 'Stop';
$ProgressPreference = 'SilentlyContinue';
try {
  [Net.ServicePointManager]::SecurityProtocol = 3072;
  $wc = New-Object System.Net.WebClient;
  $wc.Headers.Add('User-Agent', $env:SB_UA);
  $wc.Proxy = [System.Net.WebRequest]::GetSystemWebProxy();
  $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials;
  $wc.DownloadFile($env:SB_URL, $env:SB_OUT);
  exit 0
} catch {
  [Console]::Error.WriteLine($_.Exception.Message);
  exit 1
}
''';

  static Future<File?> _downloadViaPowerShell({
    required Uri uri,
    required File targetFile,
    required DownloadController controller,
    required int generation,
    required int? expectedBytes,
    required DownloadProgressCallback onProgress,
  }) {
    _tryDelete(targetFile); // WebClient no reanuda

    // -EncodedCommand (UTF-16LE en base64) evita cualquier problema de comillas.
    final bytes = <int>[];
    for (final unit in _psScript.codeUnits) {
      bytes
        ..add(unit & 0xFF)
        ..add(unit >> 8);
    }

    return _runExternal(
      label: 'PowerShell',
      executable: _powershellPath(),
      args: [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy', 'Bypass',
        '-EncodedCommand', base64.encode(bytes),
      ],
      environment: {
        'SB_URL': uri.toString(),
        'SB_OUT': targetFile.path,
        'SB_UA': _userAgent,
      },
      targetFile: targetFile,
      controller: controller,
      generation: generation,
      host: uri.host,
      expectedBytes: expectedBytes,
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  //  EJECUCIÓN DE DESCARGADORES EXTERNOS
  // ---------------------------------------------------------------------------

  static Future<File?> _runExternal({
    required String label,
    required String executable,
    required List<String> args,
    Map<String, String>? environment,
    required File targetFile,
    required DownloadController controller,
    required int generation,
    required String host,
    required int? expectedBytes,
    required DownloadProgressCallback onProgress,
  }) async {
    Process process;
    try {
      process = await Process.start(executable, args, environment: environment);
    } on ProcessException catch (e) {
      throw DownloadFailure(DownloadFailureKind.process,
          '$label unavailable: ${e.message}',
          host: host);
    }

    if (controller.stopped(generation)) {
      process.kill();
      return null;
    }

    final err = StringBuffer();
    final errSub = process.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen((s) {
      if (err.length < 2000) err.write(s);
    });
    process.stdout.drain<void>().catchError((_) {});
    controller.onCancel = () {
      try {
        process.kill();
      } catch (_) {}
    };

    final total = expectedBytes ?? -1;
    var lastBytes = targetFile.existsSync() ? targetFile.lengthSync() : 0;
    final sw = Stopwatch()..start();
    final timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      try {
        if (!targetFile.existsSync()) return;
        final size = targetFile.lengthSync();
        final ms = sw.elapsedMilliseconds;
        if (ms <= 0) return;
        final bps = (size - lastBytes) / (ms / 1000);
        sw.reset();
        lastBytes = size;
        onProgress(
          total > 0 ? (size / total).clamp(0.0, 1.0).toDouble() : 0.0,
          '${(bps / 1024 / 1024).toStringAsFixed(2)} MB/s',
          _progressText(size, total),
        );
      } catch (_) {}
    });

    final code = await process.exitCode.whenComplete(() {
      timer.cancel();
      controller.onCancel = null;
    });
    await errSub.cancel();

    if (controller.stopped(generation)) return null;

    final stderrText = err.toString().trim();
    if (code != 0) {
      throw _failureFromProcessError(label, code, stderrText, host);
    }
    if (!targetFile.existsSync() || targetFile.lengthSync() == 0) {
      throw DownloadFailure(DownloadFailureKind.invalid,
          '$label finished but the file is empty',
          host: host);
    }

    final size = targetFile.lengthSync();
    onProgress(1.0, '0 MB/s', _progressText(size, size));
    return targetFile;
  }

  static Object _failureFromProcessError(
      String label, int code, String stderrText, String host) {
    final lower = stderrText.toLowerCase();

    final http = RegExp(r'returned (?:an )?error:\s*\(?(\d{3})').firstMatch(lower);
    if (http != null) {
      final status = int.parse(http.group(1)!);
      if (status == 403 || status == 410) {
        return ExpiredLinkException('Nexus link expired ($status)',
            statusCode: status);
      }
      return HttpStatusException(status);
    }

    final detail = '$label exit $code: $stderrText';
    if (lower.contains('schannel') ||
        lower.contains('ssl') ||
        lower.contains('tls') ||
        lower.contains('certificate')) {
      return DownloadFailure(DownloadFailureKind.tls, detail, host: host);
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return DownloadFailure(DownloadFailureKind.timeout, detail, host: host);
    }
    if (lower.contains('resolve') ||
        lower.contains('connect') ||
        lower.contains('unable to') ||
        lower.contains('remote name')) {
      return DownloadFailure(DownloadFailureKind.network, detail, host: host);
    }
    return DownloadFailure(DownloadFailureKind.process, detail, host: host);
  }

  // ---------------------------------------------------------------------------
  //  VALIDACIÓN
  // ---------------------------------------------------------------------------

  /// Detecta descargas "exitosas" que en realidad son una página HTML de
  /// bloqueo (ISP, antivirus, portal cautivo, proxy) o un archivo vacío.
  static Future<void> _validateDownloaded(File file, int? expectedBytes) async {
    final len = file.lengthSync();
    if (len == 0) {
      _tryDelete(file);
      throw const DownloadFailure(
          DownloadFailureKind.invalid, 'Downloaded file is empty');
    }

    if (len < 1024 * 1024) {
      final raf = file.openSync();
      List<int> head;
      try {
        head = raf.readSync(math.min(len, 512));
      } finally {
        raf.closeSync();
      }
      var text = latin1.decode(head, allowInvalid: true);
      text = text.replaceFirst('\u00ef\u00bb\u00bf', '').trimLeft().toLowerCase();
      if (text.startsWith('<!doctype') ||
          text.startsWith('<html') ||
          text.startsWith('<?xml') ||
          text.startsWith('<head') ||
          text.startsWith('<body')) {
        _tryDelete(file);
        throw const DownloadFailure(DownloadFailureKind.invalid,
            'Server returned an HTML page instead of the file');
      }
    }

    if (expectedBytes != null && expectedBytes > 0 && len != expectedBytes) {
      DownloadLog.write(
          'Warning: size $len differs from API size $expectedBytes');
    }
  }

  // ---------------------------------------------------------------------------
  //  UTILIDADES
  // ---------------------------------------------------------------------------

  static Uri? _parseUrl(String raw) {
    final trimmed = raw.trim();
    Uri? candidate = Uri.tryParse(trimmed);
    if (candidate == null || !candidate.hasScheme || candidate.host.isEmpty) {
      try {
        candidate = Uri.parse(Uri.encodeFull(trimmed));
      } catch (_) {
        return null;
      }
    }
    if (!candidate.hasScheme || candidate.host.isEmpty) return null;
    return candidate;
  }

  static DownloadFailure _classify(Object e, {String? host}) {
    if (e is DownloadFailure) return e;
    if (e is HttpStatusException) {
      return DownloadFailure(DownloadFailureKind.http, 'HTTP ${e.statusCode}',
          statusCode: e.statusCode, host: host);
    }
    final text = e.toString();
    if (e is TlsException) {
      return DownloadFailure(DownloadFailureKind.tls, text, host: host);
    }
    if (e is TimeoutException) {
      return DownloadFailure(DownloadFailureKind.timeout, text, host: host);
    }
    if (e is FileSystemException) {
      return DownloadFailure(DownloadFailureKind.disk, text, host: host);
    }
    if (e is SocketException || e is HttpException) {
      return DownloadFailure(DownloadFailureKind.network, text, host: host);
    }
    if (e is FormatException) {
      return DownloadFailure(DownloadFailureKind.unknown, 'Invalid URL: $text',
          host: host);
    }
    return DownloadFailure(DownloadFailureKind.unknown, text, host: host);
  }

  static Future<void> _drainQuietly(HttpClientResponse response) async {
    try {
      await response.drain<void>();
    } catch (_) {}
  }

  static void _tryDelete(File f) {
    try {
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  static String _mb(int bytes) => (bytes / 1024 / 1024).toStringAsFixed(2);

  static String _progressText(int received, int total) =>
      total > 0 ? '${_mb(received)} / ${_mb(total)} MB' : '${_mb(received)} MB';

  /// "bytes 100-999/1000" -> 100
  static int? _startFromContentRange(String? header) {
    if (header == null) return null;
    final m = RegExp(r'bytes\s+(\d+)-').firstMatch(header);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// "bytes */1000" o "bytes 0-9/1000" -> 1000
  static int? _totalFromContentRange(String? header) {
    if (header == null) return null;
    final m = RegExp(r'/(\d+)\s*$').firstMatch(header);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  // ---------------------------------------------------------------------------
  //  PROXY DEL SISTEMA (Windows)
  // ---------------------------------------------------------------------------

  static bool _proxyChecked = false;
  static String? _cachedProxy;

  /// Lee el proxy configurado en Windows (Configuración > Proxy). Dart solo
  /// mira las variables de entorno, así que sin esto ignoraría ese proxy.
  static Future<String?> _detectWindowsProxy() async {
    if (!Platform.isWindows) return null;
    if (_proxyChecked) return _cachedProxy;
    _proxyChecked = true;
    try {
      const key =
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings';
      final enableOut = (await Process.run('reg', ['query', key, '/v', 'ProxyEnable'])
              .timeout(const Duration(seconds: 5)))
          .stdout
          .toString();
      final enabled =
          RegExp(r'ProxyEnable\s+REG_DWORD\s+0x([0-9a-fA-F]+)').firstMatch(enableOut);
      if (enabled == null || int.parse(enabled.group(1)!, radix: 16) == 0) {
        return _cachedProxy = null;
      }

      final serverOut = (await Process.run('reg', ['query', key, '/v', 'ProxyServer'])
              .timeout(const Duration(seconds: 5)))
          .stdout
          .toString();
      final m = RegExp(r'ProxyServer\s+REG_SZ\s+(.+)').firstMatch(serverOut);
      if (m == null) return _cachedProxy = null;

      final raw = m.group(1)!.trim();
      String? chosen;
      if (raw.contains('=')) {
        String? http;
        String? https;
        for (final part in raw.split(';')) {
          final kv = part.split('=');
          if (kv.length != 2) continue;
          final scheme = kv[0].trim().toLowerCase();
          if (scheme == 'https') https = kv[1].trim();
          if (scheme == 'http') http = kv[1].trim();
        }
        chosen = https ?? http; // se ignora SOCKS
      } else {
        chosen = raw;
      }
      if (chosen == null) return _cachedProxy = null;
      chosen = chosen.replaceFirst(RegExp(r'^[a-zA-Z]+://'), '').trim();
      if (chosen.isEmpty) return _cachedProxy = null;

      DownloadLog.write('Windows proxy detected: $chosen');
      return _cachedProxy = 'PROXY $chosen';
    } catch (e) {
      DownloadLog.write('Proxy detection failed: $e');
      return _cachedProxy = null;
    }
  }
}