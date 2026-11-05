import 'package:flutter/material.dart';
import '../theme/minimal_style.dart';
import 'package:path/path.dart' as p;
import '../../models/mod_info.dart';
import '../../l10n/app_localizations.dart';
import '../../thumbnail_service.dart';
import '../theme/app_layout.dart';
import '../theme/ios_theme.dart';
import 'mod_image_widgets.dart';
import 'animated_mod_switch.dart';
import 'ios_widgets.dart';
import 'material_layout_widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_metrics.dart';

class ModGridCard extends StatefulWidget {
  final ModInfo modInfo;
  final AppLocalizations l10n;
  final ThumbnailService thumbnailService;
  final Map<String, dynamic>? updateInfo;
  final bool isIgnored;
  final bool isHighlighted;
  final bool showModTypeTags;
  final bool isLoading;

  /// Cuántas ediciones de este mismo mod (mismo ID de Nexus) hay instaladas.
  /// Con 2 o más se muestra un indicador junto al nombre.
  final int editionCount;

  final VoidCallback onTapDetails;
  final VoidCallback onUpdateAvailableTap;
  final VoidCallback onEditVersionTap;
  final VoidCallback onEditTagTap;
  final void Function(Offset, String) onHoverEnter;
  final void Function(Offset) onHoverMove;
  final VoidCallback onHoverExit;

  final Future<bool> Function(ModInfo) onEnable;
  final Future<bool> Function(ModInfo) onDisable;

  final VoidCallback onEditNameTap;
  final VoidCallback onSetCoverTap;
  final VoidCallback onAdjustCoverTap;
  final VoidCallback onRevertCoverTap;
  final VoidCallback onShowFolderTap;
  final VoidCallback onShowGalleryTap;
  final VoidCallback onOpenNexusTap;
  final VoidCallback onDeleteTap;

  const ModGridCard({
    super.key,
    required this.modInfo,
    required this.l10n,
    required this.thumbnailService,
    required this.updateInfo,
    required this.isIgnored,
    required this.isHighlighted,
    required this.showModTypeTags,
    required this.isLoading,
    this.editionCount = 1,
    required this.onTapDetails,
    required this.onUpdateAvailableTap,
    required this.onEditVersionTap,
    required this.onEditTagTap,
    required this.onHoverEnter,
    required this.onHoverMove,
    required this.onHoverExit,
    required this.onEnable,
    required this.onDisable,
    required this.onEditNameTap,
    required this.onSetCoverTap,
    required this.onAdjustCoverTap,
    required this.onRevertCoverTap,
    required this.onShowFolderTap,
    required this.onShowGalleryTap,
    required this.onOpenNexusTap,
    required this.onDeleteTap,
  });

  @override
  State<ModGridCard> createState() => _ModGridCardState();
}

class _ModGridCardState extends State<ModGridCard> {
  bool _hover = false;

  // Estado del resaltado de la portada (hover / presionado). Se dibuja dentro
  // de la propia tarjeta, así que se recorta junto con ella.
  bool _coverHover = false;
  bool _coverPressed = false;

  /// Capa de resaltado de la portada. Vive dentro del Stack de la tarjeta (que
  /// ya está recortada con esquinas redondeadas), por eso nunca se sale del
  /// borde de la tarjeta ni del área visible del scroll.
  Widget _coverHighlight() {
    final double alpha = _coverPressed ? 0.14 : (_coverHover ? 0.07 : 0.0);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          color: IosColors.tint(alpha),
        ),
      ),
    );
  }

  /// Etiqueta flotante sobre la portada: fondo oscuro translúcido con un
  /// punto de color (sin desenfoque, para que la cuadrícula siga siendo fluida).
  Widget _overlayPill(String text, Color dot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: MinimalStyle.on ? BoxDecoration(color: Colors.black.withOpacity(0.58), borderRadius: AppMetrics.radius(20), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: AppMetrics.radius(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: MinimalStyle.on ? BoxDecoration(color: dot, borderRadius: BorderRadius.circular(8), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Colores fijos de las insignias del diseño Material. Misma luminosidad y
  /// croma en los 8 tipos (OKLCH L≈0.5): matices bien separados y texto blanco
  /// con contraste ≥ 5:1 en cualquier tema.
  Color _mdTypeColor(String? modType) {
    switch (modType) {
      case 'replacement':
        return const Color(0xFF9A3289);
      case 'genericPak':
        return const Color(0xFF626975);
      case 'movies':
        return const Color(0xFFBE222A);
      case 'logicMod':
        return const Color(0xFF145EC1);
      case 'save':
        return const Color(0xFF0A7E3A);
      case 'config':
        return const Color(0xFF007984);
      case 'splash':
        return const Color(0xFFAB5900);
      default: // CNS
        return const Color(0xFF6D47B8);
    }
  }

  Widget _buildModTypeBadge() {
    final l10n = widget.l10n;
    final String? modType = widget.modInfo.modType;
    final String text;
    final Color dot;

    if (modType == 'replacement') {
      text = l10n.modTypeReplacement;
      dot = IosColors.purple;
    } else if (modType == 'genericPak') {
      text = l10n.modTypeGeneric;
      dot = IosColors.gray;
    } else if (modType == 'movies') {
      text = l10n.modTypeMovies;
      dot = IosColors.red;
    } else if (modType == 'logicMod') {
      text = l10n.modTypeLogic;
      dot = IosColors.blue;
    } else if (modType == 'save') {
      text = l10n.modTypeSave;
      dot = IosColors.green;
    } else if (modType == 'config') {
      text = l10n.modTypeConfig;
      dot = IosColors.teal;
    } else if (modType == 'splash') {
      text = l10n.modTypeSplash;
      dot = IosColors.orange;
    } else {
      text = l10n.modTypeCNS;
      dot = IosColors.teal;
    }
    if (AppLayouts.isMaterial) {
      return MdBadge(text: text, color: _mdTypeColor(modType));
    }
    return _overlayPill(text, dot);
  }

  PopupMenuEntry<String> _menuItem(
    String value,
    dynamic icon,
    String label, {
    bool destructive = false,
  }) {
    return iosMenuItem<String>(
      value: value,
      label: label,
      destructive: destructive,
      leading: HugeIcon(
        icon: icon,
        size: 16,
        color: destructive ? IosColors.red : IosColors.icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modInfo = widget.modInfo;
    final l10n = widget.l10n;
    final updateInfo = widget.updateInfo;
    final bool md = AppLayouts.isMaterial;
    final bool u = AppMetrics.u;

    String? coverImagePath;
    String? cacheKey;
    bool isLocalFile = false;

    if (modInfo.customCoverPath != null && modInfo.customCoverPath!.isNotEmpty) {
      coverImagePath = p.join(modInfo.directory.path, modInfo.customCoverPath!);
      cacheKey = p.basename(modInfo.directory.path) + modInfo.customCoverPath!;
      if (modInfo.customCoverLastModified != null) {
        cacheKey += modInfo.customCoverLastModified!.millisecondsSinceEpoch.toString();
      }
      isLocalFile = true;
    } else if (modInfo.gallery != null && modInfo.gallery!.isNotEmpty) {
      coverImagePath = modInfo.gallery!.first['thumbnail'] as String?;
      cacheKey = coverImagePath;
      isLocalFile = false;
    }

    final bool showUpdate = updateInfo != null && !widget.isIgnored;
    final hasCustomCover = modInfo.customCoverPath != null && modInfo.customCoverPath!.isNotEmpty;
    final displayVersion = modInfo.customVersion ?? modInfo.localVersion;
    final bool isReplacement = modInfo.replacesOutfits != null && modInfo.replacesOutfits!.isNotEmpty;
    final String displayTag = isReplacement
        ? (modInfo.replacesOutfits!.length > 1
            ? l10n.outfitsCount(modInfo.replacesOutfits!.length)
            : modInfo.replacesOutfits!.first)
        : (modInfo.customFitMeshType ?? modInfo.fitMeshType ?? l10n.modCategoryOther);

    // Aro de la tarjeta: amarillo si hay actualización, azul si es recién
    // instalado, y un filo casi invisible en el resto (como en iOS).
    final bool hasRing = showUpdate || widget.isHighlighted;
    final Color ringColor = showUpdate
        ? IosColors.yellow
        : (widget.isHighlighted
            ? IosColors.blue
            : (md ? Colors.transparent : IosColors.overlay(0x14)));

    String? updateVersionText;
    if (showUpdate) {
      final v = updateInfo!['version'] as String;
      updateVersionText = v.toLowerCase().startsWith('v') ? v.substring(1) : v;
    }

    return MouseRegion(
      key: ValueKey(modInfo.directory.path),
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: MinimalStyle.on ? 1.0 : (_hover ? 1.015 : 1.0),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          clipBehavior: Clip.antiAlias,
          decoration: MinimalStyle.on ? MinimalStyle.panel(hovered: _hover) : BoxDecoration(
                  color: IosColors.card,
                  borderRadius: AppMetrics.radius(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hover ? 0.45 : 0.25),
                      blurRadius: _hover ? 22 : 10,
                      offset: Offset(0, _hover ? 10 : 4),
                    ),
                  ],
                ),
          // El aro va por encima y no altera el tamaño del contenido.
          foregroundDecoration: BoxDecoration(
            borderRadius: AppMetrics.radius(14),
            border: Border.all(color: ringColor, width: hasRing ? 1.5 : 0.5),
          ),
          // Material local: los InkWell internos (versión, etiqueta, botones)
          // pintan sobre ESTE Material, que está dentro del recorte de la
          // tarjeta, y no sobre el Material global (que no se recorta con el
          // scroll y dejaba el destello fuera de la tarjeta).
          child: Material(
            type: MaterialType.transparency,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- PORTADA ----------
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _coverHover = true),
                  onExit: (_) => setState(() {
                    _coverHover = false;
                    _coverPressed = false;
                  }),
                  child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTapDetails,
                  onTapDown: (_) => setState(() => _coverPressed = true),
                  onTapUp: (_) => setState(() => _coverPressed = false),
                  onTapCancel: () => setState(() => _coverPressed = false),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: modInfo.isEnabled ? 1.0 : 0.5,
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          child: ModThumbnailImage(
                            imageUrl: cacheKey,
                            imagePathToProcess: coverImagePath,
                            thumbnailService: widget.thumbnailService,
                            isLocal: isLocalFile,
                            fit: BoxFit.cover,
                            alignment: modInfo.customCoverAlignment ?? Alignment.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!modInfo.isEnabled)
                              md
                                  ? MdBadge(
                                      text: l10n.modDisabledBadge,
                                      color: const Color(0xFFF9AD26),
                                      textColor: Colors.black87,
                                    )
                                  : _overlayPill(
                                      l10n.modDisabledBadge,
                                      IosColors.orange,
                                    ),
                            if (!modInfo.isEnabled && widget.showModTypeTags)
                              const SizedBox(height: 4),
                            if (widget.showModTypeTags) _buildModTypeBadge(),
                          ],
                        ),
                      ),
                      if (showUpdate)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IosToolbarButton(
                            width: 26,
                            height: 26,
                            background: IosColors.yellow,
                            tooltip: l10n.updateAvailable(updateVersionText!),
                            onPressed: widget.onUpdateAvailableTap,
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      // Resaltado de selección (encima de todo, recortado
                      // por la tarjeta y con sus esquinas redondeadas).
                      _coverHighlight(),
                    ],
                  ),
                  ),
                ),
              ),

              // ---------- INFORMACIÓN ----------
              Padding(
                padding: MinimalStyle.on
                    ? const EdgeInsets.fromLTRB(14, 12, 14, 0)
                    : u
                    ? const EdgeInsets.fromLTRB(
                        AppMetrics.cardPadding, 12, AppMetrics.cardPadding, 0)
                    : const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: modInfo.customName,
                        child: Text(
                          modInfo.customName,
                          style: TextStyle(
                            fontWeight: u ? FontWeight.w700 : FontWeight.w600,
                            fontSize: MinimalStyle.on ? 14 : (u ? 15 : 13.5),
                            letterSpacing: u ? 0 : -0.2,
                            color: IosColors.label,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (widget.editionCount > 1)
                      Tooltip(
                        message: l10n.editionsInstalledTooltip(widget.editionCount),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.layers_rounded,
                                size: 12,
                                color: IosColors.purple,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.editionCount}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: IosColors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (displayVersion != null)
                      InkWell(
                        onTap: widget.onEditVersionTap,
                        borderRadius: AppMetrics.radius(4),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            'v$displayVersion',
                            style: TextStyle(
                              fontSize: u ? 12.5 : 11,
                              color: md && !MinimalStyle.on
                                  ? IosColors.blue
                                  : IosColors.secondaryLabel,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: MinimalStyle.on
                    ? const EdgeInsets.fromLTRB(14, 8, 8, 10)
                    : u
                    ? const EdgeInsets.fromLTRB(AppMetrics.cardPadding, 8, 8, 12)
                    : const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Listener(
                          onPointerMove: (event) => widget.onHoverMove(event.position),
                          child: MouseRegion(
                            onEnter: (event) {
                              if (isReplacement) {
                                widget.onHoverEnter(event.position, modInfo.replacesOutfits!.first);
                              }
                            },
                            onExit: (_) => widget.onHoverExit(),
                            child: InkWell(
                              onTap: isReplacement ? null : widget.onEditTagTap,
                              borderRadius: BorderRadius.circular(md ? 7 : 20),
                              child: Container(
                                constraints: mdChipConstraints,
                                padding: u
                                    ? const EdgeInsets.symmetric(horizontal: 10)
                                    : const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: MinimalStyle.on ? BoxDecoration(color: MinimalStyle.mutedFill, borderRadius: BorderRadius.circular(4)) : BoxDecoration(
                                  color: md ? IosColors.overlay(0x24) : IosColors.chip,
                                  borderRadius: BorderRadius.circular(md ? 7 : 20),
                                ),
                                child: mdChipChild(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isReplacement) ...[
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedDress04,
                                        size: 11,
                                        color: IosColors.purple,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Flexible(
                                      child: Text(
                                        displayTag,
                                        style: TextStyle(
                                          fontSize: u ? 12 : 10.5,
                                          color: IosColors.secondaryLabel,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: u ? 8 : 4),
                    AnimatedModSwitch(
                      key: ValueKey('switch-grid-${modInfo.directory.path}'),
                      modInfo: modInfo,
                      isLoading: widget.isLoading,
                      onEnable: widget.onEnable,
                      onDisable: widget.onDisable,
                      // Con Material el interruptor siempre mide 52x32.
                      scale: 0.66,
                    ),
                    IosMenuButton<String>(
                      width: 28,
                      height: 28,
                      icon: Icon(
                        md ? Icons.more_vert_rounded : Icons.more_horiz_rounded,
                        size: u ? 20 : 18,
                        color: IosColors.icon,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            widget.onEditNameTap();
                            break;
                          case 'set_cover':
                            widget.onSetCoverTap();
                            break;
                          case 'adjust_cover':
                            widget.onAdjustCoverTap();
                            break;
                          case 'revert_cover':
                            widget.onRevertCoverTap();
                            break;
                          case 'folder':
                            widget.onShowFolderTap();
                            break;
                          case 'gallery':
                            widget.onShowGalleryTap();
                            break;
                          case 'nexus':
                            widget.onOpenNexusTap();
                            break;
                          case 'delete':
                            widget.onDeleteTap();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        _menuItem('edit', HugeIcons.strokeRoundedEdit01, l10n.editModNameTooltip),
                        _menuItem('set_cover', HugeIcons.strokeRoundedImageAdd02, l10n.setCoverTooltip),
                        _menuItem('adjust_cover', HugeIcons.strokeRoundedCrop, l10n.adjustCoverTooltip),
                        if (hasCustomCover)
                          _menuItem('revert_cover', HugeIcons.strokeRoundedImageCounterClockwise, l10n.restoreOriginalCoverText),
                        _menuItem('folder', HugeIcons.strokeRoundedFolderInput, l10n.showInFolder),
                        if (modInfo.nexusId != null)
                          _menuItem('gallery', HugeIcons.strokeRoundedAlbum02, l10n.viewImageGallery),
                        if (modInfo.nexusId != null)
                          _menuItem('nexus', HugeIcons.strokeRoundedLinkSquare02, l10n.openInNexusMods),
                        if (!modInfo.isEnabled) const PopupMenuDivider(height: 8),
                        if (!modInfo.isEnabled)
                          _menuItem('delete', HugeIcons.strokeRoundedDelete04, l10n.deletePermanently, destructive: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}