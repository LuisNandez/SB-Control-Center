import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../l10n/app_localizations.dart';
import '../../services/nexus_api_service.dart';
import '../../services/download_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_progress_bar.dart';
import '../widgets/ios_widgets.dart';

class DownloadModDialog extends StatefulWidget {
  final String nxmUrl;
  final String apiKey;
  final Function(File downloadedFile, String modId, String version) onDownloadComplete;

  const DownloadModDialog({
    super.key,
    required this.nxmUrl,
    required this.apiKey,
    required this.onDownloadComplete,
  });

  @override
  State<DownloadModDialog> createState() => _DownloadModDialogState();
}

class _DownloadModDialogState extends State<DownloadModDialog> {
  bool _isFetchingLink = true;
  bool _isDownloading = false;
  String? _statusMessage; // Se inicializa como null
  String _fileName = "";
  double _progress = 0.0;
  String _speed = "";
  String _downloaded = "";
  bool _hasError = false;
  final DownloadController _controller = DownloadController();

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  Future<void> _startProcess() async {
    try {
      // 1. Obtener el enlace directo del CDN
      final linkData = await NexusApiService.getDownloadLinkFromNxm(widget.nxmUrl, widget.apiKey);

      if (!mounted) return;

      if (linkData == null) {
        setState(() {
          _isFetchingLink = false;
          _hasError = true;
          _statusMessage = AppLocalizations.of(context)!.downloadStatusFetchingFailed;
        });
        return;
      }

      setState(() {
        _isFetchingLink = false;
        _isDownloading = true;
        _fileName = linkData['fileName']!;
        _statusMessage = AppLocalizations.of(context)!.downloadStatusDownloading(_fileName);
      });

      final String extractedModId = linkData['modId']!;
      final String extractedVersion = linkData['version']!;

      // Ruta persistente para el targetFile, igual que en el gestor global
      final tempDir = Directory(p.join(Directory.systemTemp.path, 'sb_control_downloads'));
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final targetFile = File(p.join(tempDir.path, _fileName));

      // 2. Descargar el archivo
      final downloadedFile = await DownloadService.downloadFile(
        url: linkData['url']!,
        targetFile: targetFile,
        controller: _controller,
        onProgress: (progress, speed, downloadedStr) {
          if (mounted && !_controller.isCancelled) {
            setState(() {
              _progress = progress;
              _speed = speed;
              _downloaded = downloadedStr;
            });
          }
        },
      );
      if (_controller.isCancelled) return;

      if (!mounted) return;

      if (downloadedFile != null) {
        widget.onDownloadComplete(downloadedFile, extractedModId, extractedVersion);
      } else {
        setState(() {
          _isDownloading = false;
          _hasError = true;
          _statusMessage = AppLocalizations.of(context)!.downloadStatusError;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingLink = false;
          _isDownloading = false;
          _hasError = true;
          _statusMessage = AppLocalizations.of(context)!.downloadStatusException(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Si el mensaje es null, mostramos el mensaje por defecto (obteniendo datos)
    final displayMessage = _statusMessage ?? l10n.downloadStatusFetching;

    // Dialog transparente: funciona tanto con showDialog como con showIosDialog.
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: IosDialogShell(
        title: l10n.dialogTitleDownloadModManager,
        width: 400,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _hasError ? IosColors.red : IosColors.secondaryLabel,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            if (_isFetchingLink) ...[
              const SizedBox(height: 16),
              const Center(child: IosSpinner(radius: 10)),
            ] else if (_isDownloading) ...[
              const SizedBox(height: 16),
              IosProgressBar(value: _progress),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _downloaded,
                    style: TextStyle(
                      fontSize: 12,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                  Text(
                    _speed,
                    style: TextStyle(
                      fontSize: 12,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (_hasError)
            IosDialogButton(
              label: l10n.dialogActionClose,
              bold: true,
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            // Cancelar disponible mientras se obtiene el enlace y durante la descarga.
            IosDialogButton(
              label: l10n.dialogActionCancel,
              onPressed: () {
                _controller.cancel();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}