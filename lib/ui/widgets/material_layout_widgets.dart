import 'package:flutter/material.dart';
import '../theme/minimal_style.dart';
import 'minimal_controls.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';

/// Borde fino de los controles del diseño Material.
Color get _mdOutline => IosColors.overlay(0x38);

// ============================================================================
//  BOTÓN PRINCIPAL
// ============================================================================

/// Botón relleno con el color de acento (p. ej. "Instalar mod").
class MdButton extends StatefulWidget {
  const MdButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Color de relleno (por defecto, el de acento del tema).
  final Color? color;

  @override
  State<MdButton> createState() => _MdButtonState();
}

class _MdButtonState extends State<MdButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalButton(label: widget.label, icon: widget.icon, onPressed: widget.onPressed, color: widget.color);

    final enabled = widget.onPressed != null;
    Color fill = widget.color ?? IosColors.blue;
    if (_pressed) {
      fill = Color.lerp(fill, Colors.black, 0.2)!;
    } else if (_hover) {
      fill = Color.lerp(fill, Colors.white, 0.1)!;
    }
    if (!enabled) fill = fill.withOpacity(0.4);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: AppMetrics.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
                ),
          foregroundDecoration: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  CAMPO DE BÚSQUEDA
// ============================================================================

/// Campo de búsqueda con contorno (se resalta con el acento al enfocarlo).
class MdSearchField extends StatefulWidget {
  const MdSearchField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<MdSearchField> createState() => _MdSearchFieldState();
}

class _MdSearchFieldState extends State<MdSearchField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalSearchField(controller: widget.controller, placeholder: widget.placeholder, onChanged: widget.onChanged, autofocus: widget.autofocus);

    final bool focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: AppMetrics.controlHeight,
      padding: EdgeInsets.only(left: 10, right: 2),
      decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
              border: Border.all(
                color: focused ? IosColors.blue : _mdOutline,
                width: focused ? 1.6 : 1,
              ),
            ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 17, color: IosColors.secondaryLabel),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              cursorColor: IosColors.blue,
              style: TextStyle(fontSize: 13.5, color: IosColors.label),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  letterSpacing: 0.3,
                  color: IosColors.secondaryLabel,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 8);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  SEGMENTADO DE ICONOS (cuadrícula / lista)
// ============================================================================

class MdSegmentItem {
  const MdSegmentItem({required this.icon, required this.tooltip});

  /// Icono de HugeIcons (p. ej. `HugeIcons.strokeRoundedLayoutGrid`).
  final dynamic icon;
  final String tooltip;
}

class MdIconSegmented<T extends Object> extends StatelessWidget {
  const MdIconSegmented({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, MdSegmentItem> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalSegmented<T>(
      value: value, onChanged: onChanged,
      children: {for (final entry in items.entries)
        entry.key: Tooltip(message: entry.value.tooltip,
          child: HugeIcon(icon: entry.value.icon, size: 17,
            color: entry.key == value ? IosColors.label : IosColors.secondaryLabel))},
    );

    return Container(
      height: AppMetrics.controlHeight,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
              border: Border.all(color: _mdOutline, width: 1),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in items.entries)
            _MdSegmentCell(
              item: e.value,
              selected: e.key == value,
              onTap: () => onChanged(e.key),
            ),
        ],
      ),
    );
  }
}

class _MdSegmentCell extends StatefulWidget {
  const _MdSegmentCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MdSegmentItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MdSegmentCell> createState() => _MdSegmentCellState();
}

class _MdSegmentCellState extends State<_MdSegmentCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.selected;
    return Tooltip(
      message: widget.item.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 40,
            height: AppMetrics.controlHeight - 8,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppMetrics.controlRadius - 3),
                    color: sel
                        ? IosColors.blue.withOpacity(0.22)
                        : (_hover ? IosColors.overlay(0x14) : Colors.transparent),
                  ),
            child: HugeIcon(
              icon: widget.item.icon,
              size: 17,
              color: sel ? IosColors.blue : IosColors.label,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  PESTAÑAS DE FILTRO (Todos / CNS / Reemplazo ...)
// ============================================================================

/// Pestañas con contorno. Si no caben en el ancho disponible se reducen
/// (FittedBox), así que funcionan con cualquier idioma o número de categorías.
class MdTabs<T extends Object> extends StatelessWidget {
  const MdTabs({
    super.key,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalTabs<T>(value: value, labels: labels, onChanged: onChanged);

    final entries = labels.entries.toList();
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
                  border: Border.all(color: _mdOutline, width: 1),
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: AppMetrics.controlHeight,
                    color: _mdOutline,
                  ),
                _MdTab(
                  label: entries[i].value,
                  selected: entries[i].key == value,
                  onTap: () => onChanged(entries[i].key),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MdTab extends StatefulWidget {
  const _MdTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MdTab> createState() => _MdTabState();
}

class _MdTabState extends State<_MdTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: AppMetrics.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          color: (sel
                  ? IosColors.blue.withOpacity(0.22)
                  : (_hover ? IosColors.overlay(0x10) : Colors.transparent)),
          decoration: null,
          child: Text(
            widget.label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: sel ? IosColors.blue : IosColors.label,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  INSIGNIA RECTANGULAR (tipo de mod / "Desactivado")
// ============================================================================

/// Insignia sólida de esquinas poco redondeadas, para encima de la portada.
class MdBadge extends StatelessWidget {
  const MdBadge({
    super.key,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppMetrics.chipHeight),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          AppMetrics.smallRadius,
        ),
        boxShadow: MinimalStyle.on ? const [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
//  INTERRUPTOR (el mismo tamaño en TODA la app)
// ============================================================================

/// Interruptor de Material de tamaño único (52x32) con el color de acento.
class MdSwitch extends StatelessWidget {
  const MdSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalSwitch(value: value, onChanged: onChanged);

    
    return SizedBox(
      width: AppMetrics.switchWidth,
      height: AppMetrics.switchHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color.lerp(IosColors.blue, Colors.white, 0.72),
          activeTrackColor: IosColors.blue,
          inactiveThumbColor: IosColors.label,
          inactiveTrackColor: IosColors.sunken,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// ============================================================================
//  CASILLA DE VERIFICACIÓN (listas de selección múltiple)
// ============================================================================

/// Casilla cuadrada de Material (22x22) que se rellena con el acento.
class MdCheckbox extends StatelessWidget {
  const MdCheckbox({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: selected ? IosColors.blue : Colors.transparent,
        border: Border.all(
          color: selected ? IosColors.blue : IosColors.secondaryLabel,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

// ============================================================================
//  SEGMENTADO GENÉRICO (cualquier widget en cada celda)
// ============================================================================

/// Control segmentado con contorno para el diseño Material. Cada celda puede
/// contener cualquier widget (texto, icono...). Misma altura que el resto.
class MdSegmented<T extends Object> extends StatelessWidget {
  const MdSegmented({
    super.key,
    required this.value,
    required this.children,
    required this.onChanged,
  });

  final T value;
  final Map<T, Widget> children;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
if (MinimalStyle.on) return MinimalSegmented<T>(value: value, children: children, onChanged: onChanged);

    final entries = children.entries.toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
              border: Border.all(color: _mdOutline, width: 1),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: AppMetrics.controlHeight,
                color: _mdOutline,
              ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(entries[i].key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  height: AppMetrics.controlHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  color: (entries[i].key == value
                          ? IosColors.blue.withOpacity(0.22)
                          : Colors.transparent),
                  decoration: null,
                  child: entries[i].value,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
//  AYUDAS PARA ETIQUETAS / CHIPS (alto único en Material)
// ============================================================================

/// Restricciones que dan a TODAS las etiquetas el mismo alto con el diseño
/// Material (null con iOS, así que no cambia nada).
BoxConstraints? get mdChipConstraints => AppMetrics.u
    ? const BoxConstraints(minHeight: AppMetrics.chipHeight)
    : null;

/// Centra el contenido de una etiqueta dentro de su alto único (solo Material).
Widget mdChipChild(Widget child) =>
    AppMetrics.u ? Center(widthFactor: 1, child: child) : child;