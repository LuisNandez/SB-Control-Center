import 'package:flutter/material.dart';
import '../../services/special_mods_handler.dart';
import '../../l10n/app_localizations.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';
import '../theme/app_metrics.dart';

class SpecialModSelectionDialog extends StatefulWidget {
  final SpecialModData modData;

  const SpecialModSelectionDialog({super.key, required this.modData});

  /// Muestra el diálogo y devuelve 'true' si el usuario confirmó la selección
  static Future<bool> show(BuildContext context, SpecialModData modData) async {
    final result = await showIosDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SpecialModSelectionDialog(modData: modData),
    );
    return result ?? false;
  }

  @override
  State<SpecialModSelectionDialog> createState() =>
      _SpecialModSelectionDialogState();
}

class _SpecialModSelectionDialogState extends State<SpecialModSelectionDialog> {
  bool _showNoSelectionError = false;

  void _onTapOption(int index) {
    setState(() {
      _showNoSelectionError = false;
      final options = widget.modData.options;
      if (widget.modData.isSingleSelection) {
        // Selección única (como un grupo de radio)
        for (var o in options) {
          o.isSelected = false;
        }
        options[index].isSelected = true;
      } else {
        options[index].isSelected = !options[index].isSelected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = widget.modData.options;

    return IosDialogShell(
      title: l10n.dialogTitleSpecialModSelection(widget.modData.nexusId),
      message: widget.modData.isSingleSelection
          ? l10n.dialogContentSpecialModSingleSelection
          : l10n.dialogContentSpecialModSelection,
      width: 420,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: IosColors.overlay(0x14),
                borderRadius: AppMetrics.radius(10),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return IosCheckRow(
                    label: option.name,
                    selected: option.isSelected,
                    onTap: () => _onTapOption(index),
                  );
                },
              ),
            ),
          ),
          if (_showNoSelectionError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.snackBarSpecialModNoSelection,
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
            final hasSelection = options.any((o) => o.isSelected);
            if (!hasSelection) {
              setState(() => _showNoSelectionError = true);
              return;
            }
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}