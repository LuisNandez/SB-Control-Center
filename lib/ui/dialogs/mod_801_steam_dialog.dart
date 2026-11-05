import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../l10n/app_localizations.dart';
import '../../notification_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';
import '../theme/app_metrics.dart';

class Mod801SteamDialog extends StatefulWidget {
  final String gameRootPath;

  const Mod801SteamDialog({super.key, required this.gameRootPath});

  static Future<void> show(BuildContext context, String gameRootPath) async {
    await showIosDialog<void>(
      context: context,
      barrierDismissible: false, // Obliga al usuario a interactuar o cerrar explícitamente
      builder: (context) => Mod801SteamDialog(gameRootPath: gameRootPath),
    );
  }

  @override
  State<Mod801SteamDialog> createState() => _Mod801SteamDialogState();
}

class _Mod801SteamDialogState extends State<Mod801SteamDialog> {
  final TextEditingController _pathController = TextEditingController();
  bool _isGenerated = false;

  void _generatePath() {
    final l10n = AppLocalizations.of(context)!;
    // Ruta dinámica real basada en la instalación del usuario,
    // manteniendo exactamente el formato SplashRandomizer.bat
    final batPath = p.join(widget.gameRootPath, 'SB', 'Content', 'Splash',
        'ModSplash', 'SplashRandomizer.bat');
    final command = '"$batPath" %command%';

    setState(() {
      _pathController.text = command;
      _isGenerated = true;
    });

    NotificationService.instance.show(
      context: context,
      type: NotificationType.info,
      title: l10n.mod801PathGenerated,
    );
  }

  Future<void> _openSteam() async {
    // Protocolo estándar para abrir la biblioteca de Steam
    final url = Uri.parse('steam://open/games');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _copyToClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pathController.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _pathController.text));
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: l10n.mod801PathCopied,
        );
      }
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final steps = [
      l10n.mod801Step1,
      l10n.mod801Step2,
      l10n.mod801Step3,
      l10n.mod801Step4,
    ];

    return IosDialogShell(
      title: l10n.mod801DialogTitle,
      message: l10n.mod801DialogIntro,
      width: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instrucciones paso a paso
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: IosColors.overlay(0x14),
              borderRadius: AppMetrics.radius(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      letterSpacing: -0.1,
                      color: IosColors.label,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Acciones principales (Generar y Steam)
          Row(
            children: [
              Expanded(
                child: IosActionButton(
                  label: l10n.mod801BtnGenerate,
                  style: IosButtonStyle.filled,
                  iconBuilder: (c) => HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings02,
                    color: c,
                    size: 18.0,
                  ),
                  onPressed: _generatePath,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IosActionButton(
                  label: l10n.mod801BtnSteam,
                  style: IosButtonStyle.gray,
                  color: IosColors.label,
                  iconBuilder: (c) => HugeIcon(
                    icon: HugeIcons.strokeRoundedLinkSquare01,
                    color: c,
                    size: 18.0,
                  ),
                  onPressed: _openSteam,
                ),
              ),
            ],
          ),

          // Ruta generada con botón de copiar integrado
          if (_isGenerated) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              decoration: BoxDecoration(
                color: IosColors.fill,
                borderRadius: AppMetrics.radius(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _pathController.text,
                      style: TextStyle(
                        fontFamily: 'Menlo',
                        fontFamilyFallback: ['SF Mono', 'Consolas', 'monospace'],
                        fontSize: 11.5,
                        height: 1.35,
                        color: IosColors.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IosToolbarButton(
                    width: 32,
                    height: 32,
                    tooltip: l10n.mod801BtnCopy,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCopy01,
                      color: IosColors.blue,
                      size: 18.0,
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        IosDialogButton(
          label: l10n.dialogActionClose,
          bold: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}