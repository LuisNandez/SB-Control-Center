import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/mod_info.dart';
import '../../l10n/app_localizations.dart';
import '../theme/ios_theme.dart';
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
    Color color = IosColors.icon,
  }) {
    return IosToolbarButton(
      width: 30,
      height: 30,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: HugeIcon(icon: icon, size: 17, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showUpdate = updateInfo != null && !isIgnored;
    final bool enabled = modInfo.isEnabled;
    final bool hasVersion =
        modInfo.localVersion != null && modInfo.localVersion!.isNotEmpty;

    final Color ringColor = showUpdate
        ? IosColors.yellow
        : (isHighlighted ? IosColors.blue : const Color(0x14FFFFFF));
    final bool hasRing = showUpdate || isHighlighted;

    String? updateVersionText;
    if (showUpdate) {
      final v = updateInfo!['version'] as String;
      updateVersionText = v.toLowerCase().startsWith('v') ? v.substring(1) : v;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Color.alphaBlend(IosColors.blue.withOpacity(0.16), IosColors.card)
            : IosColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ringColor, width: hasRing ? 1.5 : 0.5),
      ),
      child: Row(
        children: [
          // Icono "squircle" como en Ajustes de iOS.
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: enabled
                  ? IosColors.blue.withOpacity(0.18)
                  : IosColors.chip,
              borderRadius: BorderRadius.circular(9),
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
                    decoration: const BoxDecoration(
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
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
                          const Icon(
                            Icons.layers_rounded,
                            size: 13,
                            color: IosColors.purple,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$editionCount',
                            style: const TextStyle(
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
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: IosColors.secondaryLabel,
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
                      icon: const Icon(
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
            scale: 0.8,
          ),
        ],
      ),
    );
  }
}