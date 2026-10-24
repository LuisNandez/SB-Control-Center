import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import '../models/nexus_plan.dart';
import 'nexus_api_service.dart';
import 'download_service.dart';

enum DownloadStatus { fetching, downloading, paused, complete, error, cancelled }

class DownloadTask {
  final String id;
  final String nxmUrl;
  String fileName;
  double progress;
  String speed;
  String downloaded;
  DownloadStatus status;
  String? errorMessage;
  String? modId;
  String? version;
  File? file;
  File? targetFile; 
  final DownloadController controller = DownloadController();

  // NUEVO: Guardamos los parámetros necesarios para reintentar
  final String apiKey;
  final String linkErrorText;
  final String downloadErrorText;
  final AppLocalizations l10n; // textos localizados de estado/errores
  final Function(File, String, String) onComplete;

  /// Ya no requiere atención: terminó bien o el usuario la canceló. Las tareas
  /// con error NO cuentan como terminadas porque esperan un reintento.
  bool get isFinished =>
      status == DownloadStatus.complete || status == DownloadStatus.cancelled;

  DownloadTask({
    required this.id,
    required this.nxmUrl,
    required this.fileName,
    required this.apiKey, // <-- Añadir
    required this.linkErrorText, // <-- Añadir
    required this.downloadErrorText, // <-- Añadir
    required this.l10n,
    required this.onComplete, // <-- Añadir
    this.progress = 0.0,
    this.speed = "",
    this.downloaded = "",
    this.status = DownloadStatus.fetching,
  });
}

class DownloadManager extends ChangeNotifier {
  static final DownloadManager instance = DownloadManager._internal();
  DownloadManager._internal();

  final List<DownloadTask> activeDownloads = [];

  /// Descargas que siguen vivas (en curso, en pausa o con error pendiente).
  int get unfinishedCount => activeDownloads.where((t) => !t.isFinished).length;
  bool get hasActiveDownloads => unfinishedCount > 0;

  DownloadTask? _find(String id) {
    for (final t in activeDownloads) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Quita la tarea de la lista pasado un momento (para que la píldora pueda
  /// mostrar el check / "Cancelado" mientras haya otras descargas activas).
  void _removeLater(DownloadTask task, Duration delay) {
    Future.delayed(delay, () {
      if (activeDownloads.remove(task)) notifyListeners();
    });
  }
  NexusPlan _userPlan = NexusPlan.member;
  NexusPlan get userPlan => _userPlan;
  bool get isUserPremium => _userPlan.isPremium;

  set userPlan(NexusPlan value) {
    if (_userPlan != value) {
      _userPlan = value;
      notifyListeners(); // Actualiza la UI de descargas automáticamente
    }
  }

  void addDownload({
    required String nxmUrl, 
    required String apiKey, 
    required String fetchingText,
    required String linkErrorText,
    required String downloadErrorText,
    required AppLocalizations l10n,
    required Function(File, String, String) onComplete,
  }) {
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      nxmUrl: nxmUrl,
      fileName: fetchingText,
      apiKey: apiKey,                   // <-- NUEVO
      linkErrorText: linkErrorText,     // <-- NUEVO
      downloadErrorText: downloadErrorText, // <-- NUEVO
      l10n: l10n,
      onComplete: onComplete,           // <-- NUEVO
    );
    activeDownloads.add(task);
    notifyListeners();

    // Iniciamos el flujo de descarga separando la lógica para poder reintentar
    _executeDownloadFlow(
      task: task,
      apiKey: apiKey,
      linkErrorText: linkErrorText,
      downloadErrorText: downloadErrorText,
      onComplete: onComplete,
    );
  }

  /// Resuelve el nxm:// a sus mirrors. Si falla, deja la tarea en error con el
  /// motivo real y devuelve null.
  Future<NxmDownloadInfo?> _resolveLink(
      DownloadTask task, String apiKey, String linkErrorText) async {
    try {
      return await NexusApiService.resolveNxmDownload(task.nxmUrl, apiKey);
    } on NxmLinkException catch (e) {
      DownloadLog.write('[${task.id}] Link resolution failed: $e');
      if (task.status == DownloadStatus.cancelled ||
          task.status == DownloadStatus.paused) {
        return null;
      }
      _updateTaskError(task, _linkFailureText(task, e, linkErrorText));
      return null;
    }
  }

  String _linkFailureText(
      DownloadTask task, NxmLinkException e, String fallback) {
    if (e.kind == NxmLinkFailureKind.network) return task.l10n.downloadNoInternet;
    if (e.kind == NxmLinkFailureKind.forbidden) {
      return task.l10n.downloadErrorLinkExpired(403);
    }
    if (e.kind == NxmLinkFailureKind.unauthorized ||
        e.kind == NxmLinkFailureKind.notFound ||
        e.kind == NxmLinkFailureKind.rateLimited ||
        e.kind == NxmLinkFailureKind.server) {
      return task.l10n.downloadErrorHttp(e.statusCode ?? 0);
    }
    return fallback;
  }

  /// Mensaje visible: el genérico localizado + un motivo técnico corto
  /// (host inaccesible, TLS, disco...) para que el problema sea diagnosticable.
  String _downloadFailureText(
      DownloadTask task, DownloadFailure f, String generic) {
    if (f.kind == DownloadFailureKind.http && f.statusCode != null) {
      return task.l10n.downloadErrorHttp(f.statusCode!);
    }
    final label = f.shortLabel;
    return label.isEmpty ? generic : '$generic · $label';
  }

  Future<void> _executeDownloadFlow({
    required DownloadTask task,
    required String apiKey,
    required String linkErrorText,
    required String downloadErrorText,
    required Function(File, String, String) onComplete,
    bool isRetry = false,
  }) async {
    try {
      if (isRetry) {
        task.status = DownloadStatus.fetching;
        task.speed = task.l10n.downloadRefreshingLink;
        notifyListeners();
      }

      final info = await _resolveLink(task, apiKey, linkErrorText);
      if (info == null) return;
      if (task.status == DownloadStatus.cancelled ||
          task.status == DownloadStatus.paused) {
        return;
      }

      // Primera vez, o un reintento de una tarea que falló antes de preparar
      // el archivo (antes esto provocaba un error de null en el reintento).
      if (!isRetry || task.targetFile == null) {
        final dir = await DownloadService.prepareDownloadDir();

        String finalFileName = info.fileName;
        if (!finalFileName.contains('-${info.modId}-')) {
          final ext = p.extension(finalFileName);
          final nameWithoutExt = p.basenameWithoutExtension(finalFileName);
          final safeVersion = info.version.replaceAll('.', '-');
          finalFileName = '$nameWithoutExt-${info.modId}-$safeVersion-0$ext';
        }
        finalFileName =
            DownloadService.safeFileName(finalFileName, dirLength: dir.path.length);

        task.fileName = finalFileName;
        task.modId = info.modId;
        task.version = info.version;

        final target = File(p.join(dir.path, finalFileName));
        // Un resto de un intento anterior podría estar corrupto: empezar limpio.
        try {
          if (await target.exists()) await target.delete();
        } catch (_) {}
        task.targetFile = target;
      }

      task.status = DownloadStatus.downloading;
      notifyListeners();

      final downloadedFile = await DownloadService.downloadWithFallback(
        urls: info.urls,
        targetFile: task.targetFile!,
        controller: task.controller,
        expectedBytes: info.sizeBytes,
        logTag: task.id,
        onStatus: (status) {
          if (task.status != DownloadStatus.downloading) return;
          task.speed = status;
          notifyListeners();
        },
        onProgress: (progress, speed, downloadedStr) {
          if (task.status == DownloadStatus.cancelled) return;
          task.progress = progress;
          task.speed = speed;
          task.downloaded = downloadedStr;
          notifyListeners();
        },
      );

      if (task.status == DownloadStatus.cancelled || task.status == DownloadStatus.paused) return;

      if (downloadedFile != null) {
        task.progress = 1.0;
        task.status = DownloadStatus.complete;
        task.file = downloadedFile;
        // La píldora se cierra al instante si era la última descarga.
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 600));

        onComplete(downloadedFile, task.modId!, task.version!);
        _removeLater(task, const Duration(milliseconds: 1500));
      } else {
        _updateTaskError(task, downloadErrorText);
      }
    } catch (e) {
      if (task.status == DownloadStatus.cancelled || task.status == DownloadStatus.paused) return;
      DownloadLog.write('[${task.id}] Download error: $e');

      if (e is ExpiredLinkException && !isRetry) {
        // Enlace caducado: se pide uno nuevo a la API y se vuelve a intentar.
        await _executeDownloadFlow(
          task: task,
          apiKey: apiKey,
          linkErrorText: linkErrorText,
          downloadErrorText: downloadErrorText,
          onComplete: onComplete,
          isRetry: true,
        );
      } else if (e is ExpiredLinkException) {
        _updateTaskError(task, task.l10n.downloadErrorLinkExpired(e.statusCode ?? 0));
      } else if (e is HttpStatusException) {
        _updateTaskError(task, task.l10n.downloadErrorHttp(e.statusCode));
      } else if (e is DownloadFailure) {
        _updateTaskError(task, _downloadFailureText(task, e, downloadErrorText));
      } else {
        _updateTaskError(task, downloadErrorText);
      }
    }
  }

  void pauseTask(String id, {required String pausedText}) {
    final task = _find(id);
    if (task == null) return;
    if (task.status == DownloadStatus.downloading) {
      // 1. Cancelamos el stream para no mantener el socket abierto
      task.controller.cancel(); 
      task.status = DownloadStatus.paused;
      task.speed = pausedText; 
      notifyListeners();
    }
  }

  void resumeTask(String id) {
    final task = _find(id);
    if (task == null) return;
    if (task.status == DownloadStatus.paused) {
      task.controller.isCancelled = false; // <-- IMPORTANTE: Reactivar el controlador
      task.status = DownloadStatus.fetching;
      task.speed = task.l10n.downloadResuming;
      notifyListeners();

      // 2. Pedimos enlace fresco y usamos el Range header automático
      _executeDownloadFlow(
        task: task,
        apiKey: task.apiKey,
        linkErrorText: task.linkErrorText,
        downloadErrorText: task.downloadErrorText,
        onComplete: task.onComplete,
        isRetry: true, 
      );
    }
  }

  void cancelTask(String id) {
    final task = _find(id);
    if (task == null) return;
    task.controller.cancel();
    
    // Si el usuario cancela voluntariamente, borramos el archivo a medias para ahorrar espacio
    if (task.targetFile != null && task.targetFile!.existsSync()) {
      try {
        task.targetFile!.deleteSync();
      } catch (_) {} // Prevenir crasheos si Windows tiene bloqueado el archivo
    }

    task.status = DownloadStatus.cancelled;
    notifyListeners();
    _removeLater(task, const Duration(milliseconds: 1200));
  }

  void _updateTaskError(DownloadTask task, String error) {
    task.status = DownloadStatus.error;
    task.errorMessage = error;
    notifyListeners();
  }

  void retryTask(String id) {
    final task = _find(id);
    if (task == null) return;
    
    // Reiniciamos el estado visual
    task.status = DownloadStatus.fetching;
    task.errorMessage = null;
    task.speed = task.l10n.downloadResuming;
    notifyListeners();

    // Lanzamos el flujo indicando que es un reintento (isRetry: true)
    // Esto pedirá un enlace fresco a Nexus y usará el Range header.
    _executeDownloadFlow(
      task: task,
      apiKey: task.apiKey,
      linkErrorText: task.linkErrorText,
      downloadErrorText: task.downloadErrorText,
      onComplete: task.onComplete,
      isRetry: true, 
    );
  }
}