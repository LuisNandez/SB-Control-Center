// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../outfit_data.dart';
import '../theme/ios_theme.dart';
import 'ios_motion.dart';
import 'ios_widgets.dart';
import '../theme/app_metrics.dart';
import 'material_layout_widgets.dart';

// ============================================================================
//  UTILIDADES COMPARTIDAS
// ============================================================================

/// Ruta del asset con la imagen de un traje.
String outfitImagePath(String outfitName) {
  // 1. Minúsculas
  String safeName = outfitName.toLowerCase();
  // 2. (NG+) → ng_plus y fuera caracteres especiales
  safeName = safeName
      .replaceAll('(ng+)', 'ng_plus')
      .replaceAll(RegExp(r'[^\w\s-]'), '');
  // 3. Espacios y guiones → guion bajo
  safeName = safeName.replaceAll(RegExp(r'[\s-]+'), '_');
  return 'assets/images/outfits/$safeName.webp';
}

/// Imagen de un traje con aparición suave y un icono si no existe el asset.
class OutfitThumb extends StatelessWidget {
  const OutfitThumb({
    super.key,
    required this.outfit,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.cacheWidth,
    this.iconSize = 22,
  });

  final String outfit;
  final BoxFit fit;
  final Alignment alignment;

  /// Ancho de decodificación (en píxeles) para no gastar memoria en miniaturas.
  final int? cacheWidth;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      outfitImagePath(outfit),
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: iconSize,
          color: IosColors.tertiaryLabel,
        ),
      ),
    );
  }
}

// ============================================================================
//  HOJA DE SELECCIÓN
// ============================================================================

/// Abre el selector de trajes. Devuelve la nueva selección al pulsar
/// "Hecho", o `null` si se cancela o no hubo cambios.
Future<List<String>?> showOutfitPickerSheet(
  BuildContext context, {
  required List<String> initialSelection,
}) {
  final Size size = MediaQuery.of(context).size;
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    // El arrastre cerraría la hoja devolviendo null (perdería los cambios);
    // tocar fuera / Esc se gestiona con PopScope y guarda la selección.
    enableDrag: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: const Color(0x66000000),
    sheetAnimationStyle: const AnimationStyle(
      curve: IosMotion.sheet,
      duration: Duration(milliseconds: 460),
      reverseCurve: Curves.easeInCubic,
      reverseDuration: Duration(milliseconds: 280),
    ),
    constraints: BoxConstraints(
      maxWidth: math.min(920.0, size.width * 0.86),
      maxHeight: size.height * 0.88,
    ),
    builder: (context) => _OutfitPickerSheet(initialSelection: initialSelection),
  );
}

class _OutfitPickerSheet extends StatefulWidget {
  const _OutfitPickerSheet({required this.initialSelection});

  final List<String> initialSelection;

  @override
  State<_OutfitPickerSheet> createState() => _OutfitPickerSheetState();
}

class _OutfitPickerSheetState extends State<_OutfitPickerSheet> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _trayScroll = ScrollController();

  /// Traje que se muestra en la vista previa (el último sobre el que se pasó
  /// el cursor o se pulsó: se queda fijo al salir de la lista).
  final ValueNotifier<String?> _preview = ValueNotifier<String?>(null);

  /// Selección de trabajo. Se deduplica (conservando el orden): claves
  /// repetidas en la bandeja provocaban `debugChildrenHaveDuplicateKeys`.
  late final List<String> _selected = _dedupe(widget.initialSelection);

  static List<String> _dedupe(Iterable<String> items) {
    final Set<String> seen = <String>{};
    return <String>[
      for (final String item in items)
        if (seen.add(item)) item,
    ];
  }

  bool _closing = false;

  /// Contador que hace única la clave de cada vista previa. Con A -> B -> A
  /// el AnimatedSwitcher conserva un instante la "A" saliente; si la entrante
  /// usara la misma clave saltaba `debugChildrenHaveDuplicateKeys`.
  int _previewSeq = 0;

  /// Igual para la lista / estado vacío.
  int _listSeq = 0;
  bool _lastEmpty = false;

  void _setPreview(String name) {
    if (_preview.value == name) return;
    _previewSeq++;
    _preview.value = name;
  }
  String _query = '';
  int _filter = 0; // 0 = todos, 1 = solo seleccionados

  @override
  void initState() {
    super.initState();
    if (_selected.isNotEmpty) _preview.value = _selected.first;
  }

  @override
  void dispose() {
    _search.dispose();
    _trayScroll.dispose();
    _preview.dispose();
    super.dispose();
  }

  List<String> get _visible {
    final String q = _query.trim().toLowerCase();
    return stellarBladeOutfits.where((outfit) {
      if (_filter == 1 && !_selected.contains(outfit)) return false;
      return q.isEmpty || outfit.toLowerCase().contains(q);
    }).toList();
  }

  void _toggle(String name) {
    bool added = false;
    setState(() {
      if (_selected.contains(name)) {
        _selected.removeWhere((e) => e == name);
      } else {
        _selected.add(name);
        added = true;
      }
    });
    _setPreview(name);

    // La bandeja se desplaza hasta el traje recién añadido.
    if (added) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_trayScroll.hasClients) return;
        _trayScroll.animateTo(
          _trayScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: IosMotion.sheet,
        );
      });
    }
  }

  void _done() {
    if (_closing) return;
    _closing = true;
    final List<String> initial = widget.initialSelection;
    final bool same =
        _selected.length == initial.length &&
        _selected.every(initial.contains);
    Navigator.of(context).pop(same ? null : List<String>.from(_selected));
  }

  // --------------------------------------------------------------------------
  //  PIEZAS
  // --------------------------------------------------------------------------

  Widget _buildHeader(AppLocalizations l10n) {
    return SizedBox(
      height: 62,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: IosColors.tertiaryLabel,
                  borderRadius: AppMetrics.radius(3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IosTextButton(
                      label: l10n.dialogActionCancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.replacesOutfitTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: IosColors.label,
                        ),
                      ),
                      IosCountText(
                        text: l10n.outfitsSelectedCount(_selected.length),
                        style: TextStyle(
                          fontSize: 11.5,
                          letterSpacing: -0.05,
                          color: IosColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IosTextButton(
                      label: l10n.outfitsDone,
                      bold: true,
                      onPressed: _done,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: IosSearchField(
              controller: _search,
              placeholder: l10n.replacesOutfitSearchHint,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 190,
            child: IosAdaptiveSegmented<int>(
              value: _filter,
              labels: {0: l10n.outfitsFilterAll, 1: l10n.outfitsFilterSelected},
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
        ],
      ),
    );
  }

  /// Bandeja horizontal con los trajes ya elegidos (se quitan con un toque).
  Widget _buildSelectedTray(AppLocalizations l10n) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: IosMotion.sheet,
      alignment: Alignment.topCenter,
      child: _selected.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
              child: SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Expanded(
                      child: IosWheelToHorizontal(
                        controller: _trayScroll,
                        child: SingleChildScrollView(
                          controller: _trayScroll,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final name in _selected)
                                IosPop(
                                  key: ValueKey<String>(name),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _SelectedChip(
                                      name: name,
                                      tooltip: l10n.outfitsRemove,
                                      onRemove: () => _toggle(name),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IosTextButton(
                      label: l10n.outfitsClearAll,
                      fontSize: 12.5,
                      onPressed: () => setState(() => _selected.clear()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildList(AppLocalizations l10n, List<String> visible) {
    if (visible.isEmpty) {
      final bool hasQuery = _query.trim().isNotEmpty;
      return Center(
        key: ValueKey<String>('empty-$_listSeq'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasQuery ? Icons.search_off_rounded : Icons.checkroom_rounded,
                size: 40,
                color: IosColors.tertiaryLabel,
              ),
              const SizedBox(height: 12),
              Text(
                hasQuery
                    ? l10n.outfitsNoResults(_query.trim())
                    : l10n.outfitsSelectedEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: IosColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: ValueKey<String>('list-$_listSeq'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemExtent: 62,
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final String outfit = visible[index];
        return _OutfitRow(
          key: ValueKey<String>(outfit),
          name: outfit,
          query: _query,
          selected: _selected.contains(outfit),
          onTap: () => _toggle(outfit),
          onEnter: () {
            _setPreview(outfit);
          },
        );
      },
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x40000000),
        border: Border(
          left: BorderSide(color: IosColors.overlay(0x24), width: 0.5),
        ),
      ),
      child: ValueListenableBuilder<String?>(
        valueListenable: _preview,
        builder: (context, name, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            child: name == null
                ? Center(
                    key: const ValueKey<String>('placeholder'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 52,
                          color: IosColors.tertiaryLabel,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.replacesOutfitHover,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: IosColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                : _PreviewCard(
                    key: ValueKey<String>('preview-$_previewSeq-$name'),
                    name: name,
                    selected: _selected.contains(name),
                    selectLabel: l10n.outfitsActionSelect,
                    deselectLabel: l10n.outfitsActionDeselect,
                    noPreviewLabel: l10n.outfitsNoPreview,
                    onToggle: () => _toggle(name),
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> visible = _visible;
    if (visible.isEmpty != _lastEmpty) {
      _lastEmpty = visible.isEmpty;
      _listSeq++;
    }

    // Tocar fuera del panel (o Esc / atrás) intenta cerrar la ruta; se
    // intercepta y se guarda la selección. "Cancelar" sigue descartando.
    return PopScope<List<String>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _done();
      },
      child: SizedBox.expand(
      child: IosGlass(
        borderRadius: AppMetrics.sheetRadius(16),
        color: AppMetrics.u
            ? IosColors.background
            : IosColors.background.withAlpha(0xE0),
        child: Material(
          type: MaterialType.transparency,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // En una hoja estrecha se oculta la vista previa lateral.
              final bool wide = constraints.maxWidth >= 640;
              final Widget list = AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildList(l10n, visible),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(l10n),
                  _buildSearchRow(l10n),
                  _buildSelectedTray(l10n),
                  Container(height: 0.5, color: IosColors.overlay(0x24)),
                  Expanded(
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: list),
                              SizedBox(
                                width: math.min(300.0, constraints.maxWidth * 0.36),
                                child: _buildPreview(l10n),
                              ),
                            ],
                          )
                        : list,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}

// ============================================================================
//  WIDGETS INTERNOS
// ============================================================================

/// Chip azul con el nombre de un traje elegido y una "x" para quitarlo.
class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
    required this.name,
    required this.tooltip,
    required this.onRemove,
  });

  final String name;
  final String tooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IosPressable(
        scale: 0.94,
        onTap: onRemove,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 190,
            minHeight: AppMetrics.u ? AppMetrics.chipHeight : 0,
          ),
          padding: EdgeInsets.fromLTRB(11, AppMetrics.u ? 0 : 6, 8, AppMetrics.u ? 0 : 6),
          decoration: BoxDecoration(
            color: IosColors.blue.withOpacity(0.16),
            borderRadius: AppMetrics.radius(16),
          ),
          child: mdChipChild(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    color: IosColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 14, color: IosColors.blue),
            ],
          )),
        ),
      ),
    );
  }
}

/// Fila de la lista: miniatura, nombre (con la búsqueda resaltada) y círculo
/// de selección con rebote.
class _OutfitRow extends StatefulWidget {
  const _OutfitRow({
    super.key,
    required this.name,
    required this.query,
    required this.selected,
    required this.onTap,
    required this.onEnter,
  });

  final String name;
  final String query;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEnter;

  @override
  State<_OutfitRow> createState() => _OutfitRowState();
}

class _OutfitRowState extends State<_OutfitRow> {
  bool _hover = false;

  Widget _buildName() {
    final TextStyle base = TextStyle(
      fontSize: 14,
      letterSpacing: -0.2,
      color: IosColors.label,
    );
    final String q = widget.query.trim().toLowerCase();
    final String lower = widget.name.toLowerCase();
    final int idx = (q.isEmpty || lower.length != widget.name.length)
        ? -1
        : lower.indexOf(q);

    if (idx < 0) {
      return Text(
        widget.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: widget.name.substring(0, idx)),
          TextSpan(
            text: widget.name.substring(idx, idx + q.length),
            style: TextStyle(
              color: IosColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: widget.name.substring(idx + q.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;

    Color bg = Colors.transparent;
    if (_hover) {
      bg = IosColors.overlay(0x14);
    } else if (selected) {
      bg = IosColors.blue.withOpacity(0.08);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onEnter();
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppMetrics.radius(10),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: IosColors.card,
                  borderRadius: AppMetrics.radius(7),
                ),
                child: OutfitThumb(
                  outfit: widget.name,
                  cacheWidth: 120,
                  iconSize: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildName()),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? IosColors.blue : Colors.transparent,
                  border: Border.all(
                    color: selected ? IosColors.blue : IosColors.tertiaryLabel,
                    width: 1.5,
                  ),
                ),
                child: AnimatedScale(
                  scale: selected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista previa grande del traje con botón para elegirlo / quitarlo.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    super.key,
    required this.name,
    required this.selected,
    required this.selectLabel,
    required this.deselectLabel,
    required this.noPreviewLabel,
    required this.onToggle,
  });

  final String name;
  final bool selected;
  final String selectLabel;
  final String deselectLabel;
  final String noPreviewLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: AppMetrics.radius(14),
              child: Image.asset(
                outfitImagePath(name),
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hide_image_outlined,
                      size: 44,
                      color: IosColors.tertiaryLabel,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      noPreviewLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: IosColors.label,
          ),
        ),
        const SizedBox(height: 10),
        IosActionButton(
          label: selected ? deselectLabel : selectLabel,
          style: selected ? IosButtonStyle.gray : IosButtonStyle.filled,
          iconBuilder: (color) => Icon(
            selected ? Icons.check_rounded : Icons.add_rounded,
            size: 18,
            color: color,
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }
}