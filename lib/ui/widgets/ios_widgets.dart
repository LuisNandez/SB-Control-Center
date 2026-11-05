// ignore_for_file: deprecated_member_use
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoSearchTextField,
        CupertinoSlidingSegmentedControl,
        CupertinoSwitch,
        OverlayVisibilityMode;
import 'package:flutter/material.dart';
import '../theme/minimal_style.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';
import 'material_layout_widgets.dart';

/// Botón de icono de barra de herramientas (como en macOS):
/// sin borde, con un resaltado redondeado al pasar el cursor.
/// Si [background] no es null se dibuja como cápsula rellena (p. ej. "Jugar").
class IosToolbarButton extends StatefulWidget {
  const IosToolbarButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.background,
    this.width = 32,
    this.height = 32,
    this.busy = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? background;
  final double width;
  final double height;

  /// Mientras es true el botón ignora los clics pero NO se atenúa, para que
  /// el indicador de carga que lleva dentro se vea con total nitidez.
  final bool busy;

  @override
  State<IosToolbarButton> createState() => _IosToolbarButtonState();
}

class _IosToolbarButtonState extends State<IosToolbarButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    final bg = widget.background;
    final bool md = AppMetrics.md;
    final bool u = AppMetrics.u;
    final double boxW = u ? AppMetrics.iconButton : widget.width;
    final double boxH = u ? AppMetrics.iconButton : widget.height;

    Color fill;
    if (bg != null) {
      fill = _pressed
          ? Color.lerp(bg, Colors.black, 0.2)!
          : (_hover && enabled ? Color.lerp(bg, Colors.white, 0.12)! : bg);
    } else {
      fill = _pressed && enabled
          ? IosColors.overlay(0x24)
          : (_hover && enabled ? IosColors.overlay(0x14) : Colors.transparent);
    }

    Widget box = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: boxW,
      height: boxH,
      alignment: Alignment.center,
      decoration: MinimalStyle.on ? BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(MinimalStyle.controlRadius),
      ) : BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(
                md ? AppMetrics.controlRadius : (bg != null ? widget.height / 2 : 8),
              ),
            ),
      child: Opacity(
        opacity: (enabled || widget.busy) ? 1 : 0.35,
        // Material: el icono también mide siempre lo mismo.
        child: u
            ? SizedBox(
                width: AppMetrics.iconSize,
                height: AppMetrics.iconSize,
                child: FittedBox(fit: BoxFit.contain, child: widget.icon),
              )
            : widget.icon,
      ),
    );

    box = MouseRegion(
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
        child: box,
      ),
    );

    return widget.tooltip == null
        ? box
        : Tooltip(message: widget.tooltip!, child: box);
  }
}

/// Botón principal relleno (acción destacada, p. ej. "Instalar nuevo mod").
class IosButton extends StatefulWidget {
  const IosButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.height = 34,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double height;

  @override
  State<IosButton> createState() => _IosButtonState();
}

class _IosButtonState extends State<IosButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Material: botón de tamaño único.
    if (AppMetrics.md) {
      return MdButton(
        label: widget.label,
        icon: widget.icon,
        color: widget.color,
        onPressed: widget.onPressed,
      );
    }
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
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
          ),
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
                  letterSpacing: -0.1,
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

/// Campo de búsqueda al estilo iOS (cápsula gris con lupa y botón de borrar).
/// Usa iconos de Material para no depender del paquete cupertino_icons.
class IosSearchField extends StatelessWidget {
  const IosSearchField({
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
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      return MdSearchField(
        controller: controller,
        placeholder: placeholder,
        onChanged: onChanged,
        autofocus: autofocus,
      );
    }
    return SizedBox(
      height: 34,
      child: CupertinoSearchTextField(
        controller: controller,
        placeholder: placeholder,
        onChanged: onChanged,
        autofocus: autofocus,
        style: TextStyle(
          color: IosColors.label,
          fontSize: 13.5,
          letterSpacing: -0.1,
        ),
        placeholderStyle: TextStyle(
          color: IosColors.secondaryLabel,
          fontSize: 13.5,
          letterSpacing: -0.1,
        ),
        backgroundColor: IosColors.fill,
        borderRadius: BorderRadius.circular(10),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 17,
          color: IosColors.secondaryLabel,
        ),
        suffixIcon: Icon(
          Icons.cancel_rounded,
          size: 16,
          color: IosColors.secondaryLabel,
        ),
        suffixMode: OverlayVisibilityMode.editing,
      ),
    );
  }
}

/// Control segmentado de iOS (con "píldora" deslizante).
class IosSegmented<T extends Object> extends StatelessWidget {
  const IosSegmented({
    super.key,
    required this.value,
    required this.children,
    required this.onChanged,
    this.segmentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  final T value;
  final Map<T, Widget> children;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry segmentPadding;

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      return MdSegmented<T>(
        value: value,
        children: children,
        onChanged: onChanged,
      );
    }
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: value,
      backgroundColor: IosColors.fill,
      thumbColor: IosColors.gray,
      padding: const EdgeInsets.all(2),
      children: {
        for (final e in children.entries)
          e.key: Padding(
            padding: segmentPadding,
            child: e.value,
          ),
      },
      onValueChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// Chip de filtro (cápsula). Seleccionado = relleno con el color de acento.
class IosChip extends StatefulWidget {
  const IosChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<IosChip> createState() => _IosChipState();
}

class _IosChipState extends State<IosChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      // Material: chip rectangular con contorno; seleccionado = tintado.
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
            height: AppMetrics.chipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel
                  ? IosColors.blue.withOpacity(0.22)
                  : (_hover ? IosColors.overlay(0x10) : Colors.transparent),
              borderRadius: BorderRadius.circular(AppMetrics.smallRadius),
              border: Border.all(
                color: sel ? IosColors.blue : IosColors.overlay(0x38),
                width: 1,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                color: sel ? IosColors.blue : IosColors.label,
              ),
            ),
          ),
        ),
      );
    }

    final Color fill = widget.selected
        ? IosColors.blue
        : (_hover ? IosColors.chipHover : IosColors.chip);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
              color: widget.selected ? Colors.white : IosColors.label.withAlpha(0xCC),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de menú estilo macOS: icono opcional, texto y marca de selección.
PopupMenuItem<T> iosMenuItem<T>({
  required T value,
  required String label,
  Widget? leading,
  bool selected = false,
  bool destructive = false,
  bool enabled = true,
}) {
  final Color color = !enabled
      ? IosColors.tertiaryLabel
      : (destructive ? IosColors.red : IosColors.label);

  final bool md = AppMetrics.u;
  return PopupMenuItem<T>(
    value: value,
    enabled: enabled,
    height: md ? AppMetrics.controlHeight : 34,
    padding: EdgeInsets.symmetric(horizontal: md ? 16 : 12),
    child: Row(
      children: [
        if (leading != null) ...[
          Opacity(opacity: enabled ? 1 : 0.4, child: leading),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: md ? 14 : 13,
              color: color,
              letterSpacing: md ? 0 : -0.1,
            ),
          ),
        ),
        if (selected)
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.check_rounded, size: 16, color: IosColors.blue),
          ),
      ],
    ),
  );
}

/// Botón de barra que abre un menú justo debajo de él.
class IosMenuButton<T> extends StatelessWidget {
  const IosMenuButton({
    super.key,
    required this.icon,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip,
    this.enabled = true,
    this.width = 32,
    this.height = 32,
  });

  final Widget icon;
  final String? tooltip;
  final bool enabled;
  final double width;
  final double height;
  final List<PopupMenuEntry<T>> Function(BuildContext context) itemBuilder;
  final ValueChanged<T> onSelected;

  Future<void> _open(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final topLeft = button.localToGlobal(
      Offset(0, button.size.height + 4),
      ancestor: overlay,
    );
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      overlay.size.width - topLeft.dx - button.size.width,
      overlay.size.height - topLeft.dy,
    );

    final result = await showMenu<T>(
      context: context,
      position: position,
      items: itemBuilder(context),
      constraints: const BoxConstraints(minWidth: 190),
    );
    if (result != null) onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) => IosToolbarButton(
        icon: icon,
        tooltip: tooltip,
        width: width,
        height: height,
        onPressed: enabled ? () => _open(buttonContext) : null,
      ),
    );
  }
}


// ============================================================================
//  COMPONENTES NUEVOS (panel de detalles, hojas y diálogos)
// ============================================================================

/// Superficie de "vidrio" (material translúcido de iOS/macOS): desenfoca lo que
/// hay detrás, aplica un tinte semitransparente y un filo de 0.8 px.
class IosGlass extends StatelessWidget {
  const IosGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.blur = 30,
    this.blurEnabled = true,
    this.color,
    this.borderColor,
    this.shadow = false,
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double blur;

  /// Apaga el desenfoque SIN quitar el BackdropFilter del árbol (si se quitara,
  /// Flutter reconstruiría todo el contenido y perdería su estado: scroll,
  /// animaciones...). Sirve para pausarlo mientras algo lo tapa por completo.
  final bool blurEnabled;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    // Material: superficie sólida (sin desenfoque), con filo de 1 px y una
    // sombra de elevación; el redondeo de las ventanas grandes se respeta.
    if (AppMetrics.md) {
      BorderRadiusGeometry br = MinimalStyle.on
          ? BorderRadius.circular(MinimalStyle.dialogRadius) : borderRadius;
      if (!MinimalStyle.on && br is BorderRadius && br.topLeft.x <= 16) {
        br = AppMetrics.radius(br.topLeft.x);
      }
      
      final Widget surface = DecoratedBox(
        decoration: MinimalStyle.on ? BoxDecoration(color: color ?? IosColors.card, borderRadius: br, border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
          color: color ?? IosColors.card,
          borderRadius: br,
          border: Border.all(
            color: borderColor ?? IosColors.overlay(0x1F),
            width: 1,
          ),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(borderRadius: br, child: child),
      );
      return surface;
    }

    final Widget panel = DecoratedBox(
      decoration: MinimalStyle.on ? BoxDecoration(color: color ?? IosColors.card.withAlpha(0xD9), borderRadius: borderRadius, border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
        color: color ?? IosColors.card.withAlpha(0xD9),
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? IosColors.overlay(0x24), width: 0.8),
      ),
      child: child,
    );

    // Con blur <= 0 no se crea el BackdropFilter: desenfocar lo que hay detrás
    // se repite en cada fotograma y es lo más caro de pintar, así que las
    // superficies grandes que se desplazan lo evitan (y usan un color casi
    // opaco).
    final Widget glass = ClipRRect(
      borderRadius: borderRadius,
      child: blur > 0
          ? BackdropFilter(
              enabled: blurEnabled,
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: panel,
            )
          : panel,
    );

    if (!shadow) return glass;
    return DecoratedBox(
      decoration: MinimalStyle.on ? BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: borderRadius, border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: glass,
    );
  }
}

/// Sección agrupada (como en Ajustes de iOS): título pequeño arriba, a la
/// izquierda, con acciones a la derecha, y una tarjeta translúcida debajo.
class IosGroup extends StatelessWidget {
  const IosGroup({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.actions = const [],
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final String? title;
  final Widget? icon;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bool md = AppMetrics.md;
    final bool u = AppMetrics.u;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          SizedBox(
            height: u ? 40 : 32,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 6)],
                  Expanded(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: u ? 14 : 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: u ? 0 : -0.1,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        Container(
          padding: u ? const EdgeInsets.all(AppMetrics.cardPadding) : padding,
          decoration: MinimalStyle.on ? BoxDecoration(color: md ? IosColors.card : IosColors.overlay(0x14), borderRadius: BorderRadius.circular(
                    md ? AppMetrics.cardRadius : 12,
                  ), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
                  color: md ? IosColors.card : IosColors.overlay(0x14),
                  borderRadius: BorderRadius.circular(
                    md ? AppMetrics.cardRadius : 12,
                  ),
                  border: Border.all(
                    color: IosColors.overlay(md ? 0x1F : 0x14),
                    width: md ? 1 : 0.5,
                  ),
                ),
          child: child,
        ),
      ],
    );
  }
}

enum IosButtonStyle { filled, tinted, gray }

/// Botón ancho con tres estilos de iOS: relleno, tintado y gris.
/// [iconBuilder] recibe el color correcto para el icono según el estilo.
class IosActionButton extends StatefulWidget {
  const IosActionButton({
    super.key,
    required this.label,
    this.iconBuilder,
    this.onPressed,
    this.style = IosButtonStyle.tinted,
    this.color,
    this.height = 38,
  });

  final String label;
  final Widget Function(Color color)? iconBuilder;
  final VoidCallback? onPressed;
  final IosButtonStyle style;
  final Color? color;
  final double height;

  @override
  State<IosActionButton> createState() => _IosActionButtonState();
}

class _IosActionButtonState extends State<IosActionButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final Color c = widget.color ?? IosColors.blue;

    Color bg;
    Color fg;
    switch (widget.style) {
      case IosButtonStyle.filled:
        bg = _pressed
            ? Color.lerp(c, Colors.black, 0.2)!
            : (_hover ? Color.lerp(c, Colors.white, 0.1)! : c);
        fg = Colors.white;
        break;
      case IosButtonStyle.tinted:
        bg = c.withOpacity(_pressed ? 0.30 : (_hover ? 0.24 : 0.16));
        fg = c;
        break;
      case IosButtonStyle.gray:
        bg = _pressed
            ? IosColors.overlay(0x38)
            : (_hover ? IosColors.chipHover : IosColors.chip);
        fg = c;
        break;
    }

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
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: AppMetrics.u ? AppMetrics.controlHeight : widget.height,
              padding: EdgeInsets.symmetric(
                horizontal: AppMetrics.u ? 20 : 12,
              ),
              decoration: MinimalStyle.on ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(
                        AppMetrics.md ? AppMetrics.controlRadius : 10,
                      ), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(
                        AppMetrics.md ? AppMetrics.controlRadius : 10,
                      ),
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.iconBuilder != null) ...[
                    widget.iconBuilder!(fg),
                    const SizedBox(width: 7),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppMetrics.u ? 15 : 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppMetrics.u ? 0 : -0.1,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de texto sin fondo (azul), con resaltado redondeado al pasar el cursor.
class IosTextButton extends StatefulWidget {
  const IosTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.fontSize = 13.5,
    this.bold = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double fontSize;
  final bool bold;

  /// Solo para enlaces pequeños dentro de cabeceras de formulario: en Material
  /// miden lo mismo que una etiqueta en lugar de lo que mide un botón.
  final bool compact;

  @override
  State<IosTextButton> createState() => _IosTextButtonState();
}

class _IosTextButtonState extends State<IosTextButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
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
          alignment: AppMetrics.u ? Alignment.center : null,
          height: AppMetrics.u
              ? (widget.compact ? AppMetrics.chipHeight : AppMetrics.controlHeight)
              : null,
          padding: AppMetrics.u
              ? const EdgeInsets.symmetric(horizontal: 14)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: _pressed && enabled
                ? IosColors.overlay(0x24)
                : (_hover && enabled
                    ? IosColors.overlay(0x14)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(
              AppMetrics.md ? AppMetrics.controlRadius : 8,
            ),
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppMetrics.u ? (widget.compact ? 13 : 14) : widget.fontSize,
              fontWeight: (widget.bold || AppMetrics.u)
                  ? FontWeight.w600
                  : FontWeight.w500,
              letterSpacing: AppMetrics.u ? 0 : -0.1,
              color: enabled ? (widget.color ?? IosColors.blue) : IosColors.tertiaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular gris con una "x" (cerrar hojas y paneles, como en iOS).
class IosCloseButton extends StatefulWidget {
  const IosCloseButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback onPressed;
  final String? tooltip;

  @override
  State<IosCloseButton> createState() => _IosCloseButtonState();
}

class _IosCloseButtonState extends State<IosCloseButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Widget btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: AppMetrics.u ? AppMetrics.iconButton : 28,
          height: AppMetrics.u ? AppMetrics.iconButton : 28,
          alignment: Alignment.center,
          decoration: MinimalStyle.on ? BoxDecoration(color: _pressed
                ? IosColors.fill.withAlpha(0x66)
                : (_hover ? IosColors.fill.withAlpha(0x52) : IosColors.fill), borderRadius: AppMetrics.md
                ? BorderRadius.circular(AppMetrics.controlRadius)
                : null, border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
            shape: AppMetrics.md ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: AppMetrics.md
                ? BorderRadius.circular(AppMetrics.controlRadius)
                : null,
            color: _pressed
                ? IosColors.fill.withAlpha(0x66)
                : (_hover ? IosColors.fill.withAlpha(0x52) : IosColors.fill),
          ),
          child: Icon(
            Icons.close_rounded,
            size: AppMetrics.u ? AppMetrics.iconSize : 16,
            color: IosColors.secondaryLabel,
          ),
        ),
      ),
    );
    return widget.tooltip == null
        ? btn
        : Tooltip(message: widget.tooltip!, child: btn);
  }
}

/// Fila con título, subtítulo opcional e interruptor estilo iOS.
class IosSwitchRow extends StatelessWidget {
  const IosSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool md = AppMetrics.md;
    final bool u = AppMetrics.u;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: u ? AppMetrics.tileMinHeight : 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: u ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: u ? 0 : -0.2,
                    color: IosColors.label,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: u ? 13 : 12,
                      height: 1.3,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (md)
            MdSwitch(value: value, onChanged: onChanged)
          else
            CupertinoSwitch(
              value: value,
              activeColor: IosColors.green,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

/// Fila seleccionable con círculo de verificación (lista de selección múltiple).
class IosCheckRow extends StatefulWidget {
  const IosCheckRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onEnter,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEnter;

  @override
  State<IosCheckRow> createState() => _IosCheckRowState();
}

class _IosCheckRowState extends State<IosCheckRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onEnter?.call();
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: AppMetrics.u ? 0 : 9,
          ),
          constraints: BoxConstraints(
            minHeight: AppMetrics.u ? AppMetrics.tileMinHeight : 0,
          ),
          decoration: BoxDecoration(
            color: _hover ? IosColors.overlay(0x14) : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppMetrics.md ? AppMetrics.controlRadius : 8,
            ),
          ),
          child: Row(
            children: [
              if (AppMetrics.md)
                MdCheckbox(selected: widget.selected)
              else
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selected ? IosColors.blue : Colors.transparent,
                  border: Border.all(
                    color: widget.selected
                        ? IosColors.blue
                        : IosColors.tertiaryLabel,
                    width: 1.5,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppMetrics.u ? 15 : 14,
                    letterSpacing: AppMetrics.u ? 0 : -0.2,
                    color: IosColors.label,
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

/// Decoración de campo de texto estilo iOS (relleno gris, sin borde).
InputDecoration iosInputDecoration({String? hint}) {
  
  if (AppMetrics.md) {
    // Material: campo con contorno (mismo alto y redondeo en toda la app).
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: IosColors.tertiaryLabel, fontSize: 15),
      filled: false,
      isDense: true,
      counterStyle: TextStyle(fontSize: 12, color: IosColors.secondaryLabel),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: border(IosColors.overlay(0x38), 1),
      enabledBorder: border(IosColors.overlay(0x38), 1),
      focusedBorder: border(IosColors.blue, 2),
    );
  }
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: IosColors.tertiaryLabel, fontSize: 14),
    filled: true,
    fillColor: IosColors.fill,
    isDense: true,
    counterStyle: TextStyle(
      fontSize: 11,
      color: IosColors.secondaryLabel,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: IosColors.blue, width: 1.5),
    ),
  );
}

/// Botón de una alerta de iOS/macOS (texto centrado, la acción principal en negrita).
class IosDialogButton extends StatefulWidget {
  const IosDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.bold = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool bold;
  final bool destructive;

  @override
  State<IosDialogButton> createState() => _IosDialogButtonState();
}

class _IosDialogButtonState extends State<IosDialogButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final Color color = !enabled
        ? IosColors.tertiaryLabel
        : (widget.destructive ? IosColors.red : IosColors.blue);

    if (AppMetrics.md) {
      // Material: botón de texto de tamaño único; la acción principal va
      // tintada. Se coloca a la derecha del diálogo (ver IosDialogShell).
      final Color bg = _pressed && enabled
          ? color.withOpacity(0.26)
          : (_hover && enabled
              ? color.withOpacity(0.18)
              : (widget.bold && enabled ? color.withOpacity(0.12) : Colors.transparent));
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
            duration: const Duration(milliseconds: 100),
            height: 46,
            constraints: const BoxConstraints(minWidth: 72),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: MinimalStyle.on ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(
                      AppMetrics.controlRadius,
                    ), border: Border.all(color: MinimalStyle.outline)) : BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(
                      AppMetrics.controlRadius,
                    ),
                  ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      );
    }

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
          duration: const Duration(milliseconds: 100),
          height: 46,
          alignment: Alignment.center,
          color: _pressed && enabled
              ? IosColors.overlay(0x24)
              : (_hover && enabled
                  ? IosColors.overlay(0x0F)
                  : Colors.transparent),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: widget.bold ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: -0.2,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cuerpo de una alerta de vidrio: título, contenido y fila de botones
/// separados por filos de 0.5 px.
class IosDialogShell extends StatelessWidget {
  const IosDialogShell({
    super.key,
    required this.title,
    required this.actions,
    this.message,
    this.content,
    this.width = 320,
    this.stacked = false,
  });

  final String title;
  final String? message;
  final Widget? content;
  final List<IosDialogButton> actions;
  final double width;

  /// Si es true, los botones se apilan en vertical (3 o más acciones / textos largos),
  /// como en las alertas de iOS.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    // Material: ventana de tamaño único (mismo ancho y redondeo en todas),
    // título a la izquierda y botones alineados a la derecha.
    if (AppMetrics.md) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppMetrics.dialogWidthFor(width)),
        child: IosGlass(
          shadow: true,
          borderRadius: BorderRadius.circular(AppMetrics.dialogRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: IosColors.label,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: IosColors.secondaryLabel,
                        ),
                      ),
                    ],
                    if (content != null) ...[
                      const SizedBox(height: 14),
                      content!,
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: IosGlass(
        shadow: true,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: IosColors.label,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ],
                  if (content != null) ...[
                    const SizedBox(height: 14),
                    content!,
                  ],
                ],
              ),
            ),
            Container(height: 0.5, color: IosColors.overlay(0x38)),
            if (stacked)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0)
                      Container(height: 0.5, color: IosColors.overlay(0x38)),
                    actions[i],
                  ],
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0)
                        Container(width: 0.5, color: IosColors.overlay(0x38)),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Muestra una alerta de vidrio con la animación de iOS (fundido + escala suave).
Future<T?> showIosDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dismiss',
    barrierColor: (AppMetrics.md ? const Color(0x80000000) : const Color(0x66000000)),
    transitionDuration: Duration(milliseconds: AppMetrics.md ? 220 : 180),
    pageBuilder: (ctx, _, __) => SafeArea(
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: builder(ctx),
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: AppMetrics.md ? 0.92 : 1.08,
            end: 1.0,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Indicador de actividad pequeño (rueda de iOS) para botones y cabeceras.
class IosSpinner extends StatelessWidget {
  const IosSpinner({super.key, this.radius = 8});

  final double radius;

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CircularProgressIndicator(
          strokeWidth: radius >= 10 ? 3 : 2.5,
          color: IosColors.blue,
        ),
      );
    }
    return CupertinoActivityIndicator(
      radius: radius,
      color: IosColors.secondaryLabel,
    );
  }
}


// ============================================================================
//  SEGMENTADO ADAPTABLE
// ============================================================================

/// Control segmentado que se adapta al ancho disponible, como haría Apple:
///  1. Si cabe, se muestra completo y centrado (con la píldora deslizante).
///  2. Si no cabe, reduce progresivamente la tipografía y el espaciado.
///  3. Si ni así cabe, se convierte en un selector desplegable (pop-up).
/// El ancho se calcula midiendo los textos reales, así que funciona con
/// cualquier idioma o número de categorías.
class IosAdaptiveSegmented<T extends Object> extends StatelessWidget {
  const IosAdaptiveSegmented({
    super.key,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  // (tamaño de letra, padding horizontal por segmento), de mayor a menor.
  static const List<(double, double)> _levels = [
    (12.5, 12),
    (12.5, 9),
    (12.0, 7),
    (11.5, 5),
    (11.0, 4),
  ];

  // Padding interno del CupertinoSlidingSegmentedControl (2 + 2) + holgura.
  static const double _controlChrome = 4 + 8;

  double _requiredWidth(BuildContext context, double fontSize, double hPad) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    double widest = 0;
    for (final label in labels.values) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          // Se mide en negrita (el caso más ancho) para no desbordar al seleccionar.
          style: base.merge(
            TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      if (tp.width > widest) widest = tp.width;
    }
    // Todos los segmentos miden lo mismo: el ancho del más largo.
    final segment = widest.ceilToDouble() + hPad * 2 + 2;
    return segment * labels.length + _controlChrome;
  }

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      return MdTabs<T>(value: value, labels: labels, onChanged: onChanged);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxWidth;

        for (final (fontSize, hPad) in _levels) {
          if (_requiredWidth(context, fontSize, hPad) <= available) {
            return Center(
              child: IosSegmented<T>(
                value: value,
                onChanged: onChanged,
                segmentPadding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: 6,
                ),
                children: {
                  for (final e in labels.entries)
                    e.key: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        fontSize: fontSize,
                        letterSpacing: -0.1,
                        fontWeight: e.key == value
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: e.key == value
                            ? IosColors.label
                            : IosColors.secondaryLabel,
                      ),
                      child: Text(
                        e.value,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                },
              ),
            );
          }
        }

        // No cabe ni en el nivel más compacto: selector desplegable.
        return Center(
          child: _IosPopupSelector<T>(
            value: value,
            labels: labels,
            onChanged: onChanged,
            maxWidth: available,
          ),
        );
      },
    );
  }
}

/// Botón tipo "pop-up" de macOS: muestra la opción actual con un indicador de
/// menú (⌃⌄) y abre la lista de opciones justo debajo.
class _IosPopupSelector<T extends Object> extends StatefulWidget {
  const _IosPopupSelector({
    required this.value,
    required this.labels,
    required this.onChanged,
    required this.maxWidth,
  });

  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;
  final double maxWidth;

  @override
  State<_IosPopupSelector<T>> createState() => _IosPopupSelectorState<T>();
}

class _IosPopupSelectorState<T extends Object>
    extends State<_IosPopupSelector<T>> {
  bool _hover = false;
  bool _pressed = false;

  Future<void> _open(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final topLeft = button.localToGlobal(
      Offset(0, button.size.height + 4),
      ancestor: overlay,
    );
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      overlay.size.width - topLeft.dx - button.size.width,
      overlay.size.height - topLeft.dy,
    );

    final result = await showMenu<T>(
      context: context,
      position: position,
      constraints: BoxConstraints(minWidth: button.size.width.clamp(190, 400)),
      items: [
        for (final e in widget.labels.entries)
          iosMenuItem<T>(
            value: e.key,
            label: e.value,
            selected: e.key == widget.value,
          ),
      ],
    );
    if (result != null) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final Color fill = _pressed
        ? IosColors.fill.withAlpha(0x66)
        : (_hover ? IosColors.fill.withAlpha(0x52) : IosColors.fill);

    return Builder(
      builder: (buttonContext) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() {
          _hover = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () => _open(buttonContext),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: BoxConstraints(
              minWidth: 150,
              maxWidth: widget.maxWidth,
            ),
            height: 34,
            padding: const EdgeInsets.only(left: 14, right: 8),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.labels[widget.value] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: IosColors.label,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 17,
                  color: IosColors.secondaryLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
//  FORMULARIOS
// ============================================================================

/// Campo de formulario estilo iOS: etiqueta pequeña arriba, a la izquierda,
/// con un enlace opcional "Restablecer" a la derecha, y debajo el campo gris.
class IosFormField extends StatelessWidget {
  const IosFormField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hint,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.resetLabel,
    this.onReset,
    this.canReset = true,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hint;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;

  /// Si [onReset] no es null se muestra el enlace [resetLabel].
  final String? resetLabel;
  final VoidCallback? onReset;
  final bool canReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppMetrics.u ? 32 : 26,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppMetrics.u ? 13 : 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: AppMetrics.u ? 0 : -0.1,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ),
              ),
              if (onReset != null && resetLabel != null)
                IosTextButton(
                  label: resetLabel!,
                  fontSize: 12,
                  compact: true,
                  onPressed: canReset ? onReset : null,
                ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          autofocus: autofocus,
          minLines: 1,
          maxLines: maxLines,
          maxLength: maxLength,
          cursorColor: IosColors.blue,
          style: TextStyle(
            fontSize: AppMetrics.u ? 15 : 14,
            height: 1.35,
            letterSpacing: AppMetrics.u ? 0 : -0.15,
            color: IosColors.label,
          ),
          decoration: iosInputDecoration(hint: hint),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}