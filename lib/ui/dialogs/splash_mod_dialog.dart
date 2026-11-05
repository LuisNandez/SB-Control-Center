// En lib/ui/dialogs/splash_mod_dialog.dart
import 'package:flutter/material.dart';
import '../../services/splash_mods_handler.dart';
import '../../l10n/app_localizations.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';
import '../theme/app_metrics.dart';

class SplashModSelectionDialog extends StatefulWidget {
  final SplashSelectionData modData;

  const SplashModSelectionDialog({super.key, required this.modData});

  static Future<bool> show(
    BuildContext context,
    SplashSelectionData modData,
  ) async {
    final result = await showIosDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SplashModSelectionDialog(modData: modData),
    );
    return result ?? false;
  }

  @override
  State<SplashModSelectionDialog> createState() =>
      _SplashModSelectionDialogState();
}

class _SplashModSelectionDialogState extends State<SplashModSelectionDialog> {
  final Set<int> _collapsed = {};
  bool _showNoSelectionError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final folders = widget.modData.folders;

    return IosDialogShell(
      title: l10n.dialogTitleSplashOptions,
      message: l10n.dialogContentSplashOptions,
      width: 460,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: IosColors.overlay(0x14),
                borderRadius: AppMetrics.radius(10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: folders.length,
                separatorBuilder: (_, __) =>
                    Container(height: 0.5, color: IosColors.overlay(0x1F)),
                itemBuilder: (context, index) =>
                    _buildFolder(folders[index], index),
              ),
            ),
          ),
          if (_showNoSelectionError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.snackBarSplashNoSelection,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: IosColors.red),
              ),
            ),
        ],
      ),
      actions: [
        IosDialogButton(
          label: l10n.dialogActionCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        IosDialogButton(
          label: l10n.dialogActionInstallSelection,
          bold: true,
          onPressed: () {
            if (!widget.modData.hasSelection) {
              setState(() => _showNoSelectionError = true);
              return;
            }
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  Widget _buildFolder(dynamic folder, int index) {
    final l10n = AppLocalizations.of(context)!;
    final bool expanded = !_collapsed.contains(index);
    final bool? checkState = folder.isAllSelected
        ? true
        : (folder.isAnySelected ? null : false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera de carpeta
        InkWell(
          onTap: () => setState(() {
            if (expanded) {
              _collapsed.add(index);
            } else {
              _collapsed.remove(index);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    _showNoSelectionError = false;
                    // Todo/parcial -> nada; nada -> todo (igual que antes)
                    folder.toggleAll(
                      !folder.isAllSelected && !folder.isAnySelected,
                    );
                  }),
                  child: _CheckCircle(state: checkState),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.folder_rounded,
                  color: IosColors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    folder.folderName == SplashModsHandler.rootFolderKey
                        ? l10n.splashRootFolder
                        : folder.folderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: IosColors.label,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: IosColors.tertiaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Imágenes de la carpeta
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(
                  children: [
                    for (final img in folder.images) _buildImageRow(img),
                    const SizedBox(height: 4),
                  ],
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }

  Widget _buildImageRow(dynamic img) {
    final String ext =
        img.file.path.split('.').last.toLowerCase().padLeft(4, '.');
    final bool isImage = ['.bmp', '.jpg', '.jpeg', '.png'].contains(ext);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _showNoSelectionError = false;
        img.isSelected = !img.isSelected;
      }),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 5, 12, 5),
        child: Row(
          children: [
            _CheckCircle(state: img.isSelected as bool),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: IosColors.overlay(0x1F),
                borderRadius: AppMetrics.radius(8),
                border: Border.all(color: IosColors.overlay(0x1F), width: 0.5),
                image: isImage
                    ? DecorationImage(
                        image: FileImage(img.file),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: isImage
                  ? null
                  : Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: IosColors.secondaryLabel,
                    ),
            ),
            Expanded(
              child: Text(
                img.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: -0.1,
                  color: IosColors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo de selección de iOS: vacío, relleno con check o con guion (parcial).
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.state});

  /// true = marcado, false = vacío, null = parcial.
  final bool? state;

  @override
  Widget build(BuildContext context) {
    final bool filled = state != false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? IosColors.blue : Colors.transparent,
        border: Border.all(
          color: filled ? IosColors.blue : IosColors.tertiaryLabel,
          width: 1.5,
        ),
      ),
      child: filled
          ? Icon(
              state == null ? Icons.remove_rounded : Icons.check_rounded,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}