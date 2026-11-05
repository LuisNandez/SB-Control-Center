import 'package:flutter/material.dart';
import '../theme/minimal_style.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/mod_info.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_layout.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';
import '../../services/ui_scale_service.dart';
import 'animated_mod_switch.dart';
import 'ios_widgets.dart';

class ModListTile extends StatelessWidget {
  final ModInfo modInfo;
  final AppLocalizations l10n;
  final Map<String, dynamic>? updateInfo;
  final bool isIgnored;
  final bool isHighlighted;
  final bool isLoading;

  /// Ediciones instaladas de este mismo mod (mismo ID de Nexus).
  final int editionCount;

  final VoidCallback onRepairedInfoTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onUpdateAvailableTap;
  final VoidCallback onEditNameTap;
  final VoidCallback onAdjustCoverTap;
  final VoidCallback onShowFolderTap;
  final VoidCallback onShowGalleryTap;
  final VoidCallback onOpenNexusTap;
  final Future<bool> Function(ModInfo) onEnable;
  final Future<bool> Function(ModInfo) onDisable;

  const ModListTile({
    super.key,
    required this.modInfo,
    required this.l10n,
    required this.updateInfo,
    required this.isIgnored,
    required this.isHighlighted,
    required this.isLoading,
    this.editionCount = 1,
    required this.onRepairedInfoTap,
    required this.onDeleteTap,
    required this.onUpdateAvailableTap,
    required this.onEditNameTap,
    required this.onAdjustCoverTap,
    required this.onShowFolderTap,
    required this.onShowGalleryTap,
    required this.onOpenNexusTap,
    required this.onEnable,
    required this.onDisable,
  });

  Widget _action({
    required dynamic icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return IosToolbarButton(
      width: 30,
      height: 30,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: HugeIcon(icon: icon, size: 17, color: color ?? IosColors.icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool md = AppLayouts.isMaterial;
    final bool u = AppMetrics.u;
    final bool showUpdate = updateInfo != null && !isIgnored;
    final bool enabled = modInfo.isEnabled;
    final bool hasVersion =
        modInfo.localVersion != null && modInfo.localVersion!.isNotEmpty;

    final Color ringColor = showUpdate
        ? IosColors.yellow
        : (isHighlighted
            ? IosColors.blue
            : (md ? Colors.transparent : IosColors.overlay(0x14)));
    final bool hasRing = showUpdate || isHighlighted;
    // Ajustes → Apariencia → "Tamaño de las tarjetas": alto de la fila.
    final double cs = UiScale.cards.value;

    String? updateVersionText;
    if (showUpdate) {
      final v = updateInfo!['version'] as String;
      updateVersionText = v.toLowerCase().startsWith('v') ? v.substring(1) : v;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: (u ? 6 : 3) * cs),
      padding: EdgeInsets.symmetric(
        horizontal: MinimalStyle.on ? 14 : (u ? AppMetrics.cardPadding : 12),
        vertical: (MinimalStyle.on ? 10 : (u ? 12 : 8)) * cs,
      ),
      decoration: MinimalStyle.on ? BoxDecoration(color: isHighlighted
                  ? Color.alphaBlend(IosColors.blue.withOpacity(0.16), IosColors.card)
                  : IosColors.card, borderRadius: BorderRadius.circular(md ? AppMetrics.cardRadius : 12), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
              color: isHighlighted
                  ? Color.alphaBlend(IosColors.blue.withOpacity(0.16), IosColors.card)
                  : IosColors.card,
              borderRadius: BorderRadius.circular(md ? AppMetrics.cardRadius : 12),
            ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(md ? AppMetrics.cardRadius : 12),
        border: Border.all(color: ringColor, width: hasRing ? 1.5 : 0.5),
      ),
      child: Row(
        children: [
          // Icono "squircle" como en Ajustes de iOS.
          Container(
            width: (u ? AppMetrics.iconButton : 34) * cs,
            height: (u ? AppMetrics.iconButton : 34) * cs,
            decoration: MinimalStyle.on ? BoxDecoration(
              color: MinimalStyle.mutedFill,
              borderRadius: BorderRadius.circular(MinimalStyle.controlRadius),
            ) : BoxDecoration(
              color: enabled
                  ? IosColors.blue.withOpacity(0.18)
                  : IosColors.chip,
              borderRadius: BorderRadius.circular(
                md ? AppMetrics.controlRadius : 9,
              ),
            ),
            child: Icon(
              Icons.extension_rounded,
              size: 18,
              color: enabled ? IosColors.blue : IosColors.tertiaryLabel,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Row(
              children: [
                if (isHighlighted)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: MinimalStyle.on ? BoxDecoration(color: IosColors.blue, shape: BoxShape.circle) : BoxDecoration(
                      color: IosColors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                Flexible(
                  child: Text(
                    modInfo.customName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: MinimalStyle.on ? 14 : (u ? 15 : 13.5),
                      fontWeight: u ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: u ? 0 : -0.2,
                      color: enabled
                          ? IosColors.label
                          : IosColors.secondaryLabel,
                    ),
                  ),
                ),
                if (editionCount > 1)
                  Tooltip(
                    message: l10n.editionsInstalledTooltip(editionCount),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.layers_rounded,
                            size: 13,
                            color: IosColors.purple,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$editionCount',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: IosColors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (hasVersion)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'v${modInfo.localVersion}',
                      style: TextStyle(
                        fontSize: u ? 12.5 : 11.5,
                        color: md ? IosColors.blue : IosColors.secondaryLabel,
                      ),
                    ),
                  ),
                if (modInfo.origin == 'repaired')
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: IosToolbarButton(
                      width: 26,
                      height: 26,
                      tooltip: l10n.repairedModTooltip,
                      onPressed: onRepairedInfoTap,
                      icon: Icon(
                        Icons.build_rounded,
                        size: 15,
                        color: IosColors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ---------- ACCIONES ----------
          if (showUpdate)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IosToolbarButton(
                width: 26,
                height: 26,
                background: IosColors.yellow,
                tooltip: l10n.updateAvailable(updateVersionText!),
                onPressed: onUpdateAvailableTap,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          _action(
            icon: HugeIcons.strokeRoundedEdit01,
            tooltip: l10n.editModNameTooltip,
            onPressed: isLoading ? null : onEditNameTap,
          ),
          _action(
            icon: HugeIcons.strokeRoundedCrop,
            tooltip: l10n.adjustCoverTooltip,
            onPressed: isLoading ? null : onAdjustCoverTap,
          ),
          _action(
            icon: HugeIcons.strokeRoundedFolderInput,
            tooltip: l10n.showInFolder,
            onPressed: isLoading ? null : onShowFolderTap,
          ),
          if (modInfo.nexusId != null)
            _action(
              icon: HugeIcons.strokeRoundedAlbum02,
              tooltip: l10n.viewImageGallery,
              onPressed: onShowGalleryTap,
            ),
          if (modInfo.nexusId != null)
            _action(
              icon: HugeIcons.strokeRoundedLinkSquare02,
              tooltip: l10n.openInNexusMods,
              onPressed: onOpenNexusTap,
            ),
          if (!enabled)
            _action(
              icon: HugeIcons.strokeRoundedDelete04,
              tooltip: l10n.deletePermanently,
              color: IosColors.red,
              onPressed: isLoading ? null : onDeleteTap,
            ),
          const SizedBox(width: 8),
          AnimatedModSwitch(
            key: ValueKey('switch-list-${modInfo.directory.path}'),
            modInfo: modInfo,
            isLoading: isLoading,
            onEnable: onEnable,
            onDisable: onDisable,
            // Con Material el interruptor siempre mide 52x32.
            scale: 0.8,
          ),
        ],
      ),
    );
  }
}