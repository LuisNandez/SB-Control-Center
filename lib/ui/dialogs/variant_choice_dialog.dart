// lib/ui/dialogs/variant_choice_dialog.dart
import 'package:flutter/material.dart';
import '../../services/variant_conflict_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/ios_widgets.dart';
import '../theme/ios_theme.dart';
import '../theme/app_metrics.dart';

/// Pregunta qué variante instalar cuando un mismo archivo trae varias que
/// reemplazan lo mismo. Devuelve los índices (dentro de group.variants) que se
/// deben instalar, o null si el usuario cancela.
class VariantChoiceDialog extends StatefulWidget {
  final VariantGroup group;
  final int position; // 1-based
  final int total;

  const VariantChoiceDialog({
    super.key,
    required this.group,
    required this.position,
    required this.total,
  });

  static Future<List<int>?> show(
    BuildContext context, {
    required VariantGroup group,
    int position = 1,
    int total = 1,
  }) {
    return showIosDialog<List<int>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VariantChoiceDialog(
        group: group,
        position: position,
        total: total,
      ),
    );
  }

  @override
  State<VariantChoiceDialog> createState() => _VariantChoiceDialogState();
}

class _VariantChoiceDialogState extends State<VariantChoiceDialog> {
  // -1 = "instalar todas".
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final l10n = AppLocalizations.of(context)!;
    final hasOutfits = g.outfits.isNotEmpty;
    final body = hasOutfits
        ? l10n.variantChoiceBodyOutfits(g.archiveName, g.outfits.join(', '))
        : l10n.variantChoiceBodyFiles(g.archiveName);
    final title = widget.total > 1
        ? '${l10n.variantChoiceTitle} (${widget.position}/${widget.total})'
        : l10n.variantChoiceTitle;

    return IosDialogShell(
      title: title,
      message: body,
      width: 440,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: IosColors.overlay(0x14),
            borderRadius: AppMetrics.radius(10),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              for (int i = 0; i < g.variants.length; i++)
                IosCheckRow(
                  label: g.variants[i].variantLabel ?? g.variants[i].archiveName,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                ),
              IosCheckRow(
                label: l10n.variantChoiceInstallAll,
                selected: _selected == -1,
                onTap: () => setState(() => _selected = -1),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IosDialogButton(
          label: l10n.dialogActionCancel,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        IosDialogButton(
          label: l10n.dialogActionInstall,
          bold: true,
          onPressed: () => Navigator.of(context).pop(_selected == -1
              ? List<int>.generate(g.variants.length, (i) => i)
              : <int>[_selected]),
        ),
      ],
    );
  }
}