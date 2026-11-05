// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import '../theme/minimal_style.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';
import 'material_layout_widgets.dart';
import '../theme/app_metrics.dart';

/// Insignia de icono de Ajustes de iOS: cuadrado redondeado con degradado
/// sutil y el icono en blanco.
class IosIconBadge extends StatelessWidget {
  const IosIconBadge({
    super.key,
    required this.color,
    required this.child,
    this.size = 28,
  });

  final Color color;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Material: las insignias de las filas miden todas lo mismo, son planas
    // (sin degradado) y con el redondeo de los controles.
    final bool md = AppMetrics.md && size == 28;
    final double s = AppMetrics.u && size == 28 ? AppMetrics.iconButton : size;
    
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: md
            ? BorderRadius.circular(AppMetrics.controlRadius)
            : BorderRadius.circular(size * 0.23),
        color: md ? color : null,
        boxShadow: null,
        gradient: md
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(color, Colors.white, 0.14)!, color],
              ),
      ),
      child: AppMetrics.u
          ? SizedBox(
              width: AppMetrics.iconSize,
              height: AppMetrics.iconSize,
              child: FittedBox(fit: BoxFit.contain, child: child),
            )
          : child,
    );
  }
}

/// Sección agrupada ("inset grouped") como en Ajustes de iOS / Ajustes del
/// Sistema de macOS: título pequeño arriba, tarjeta redondeada con filas
/// separadas por filos de 0.5 px y, opcionalmente, un pie de texto.
class IosSettingsSection extends StatelessWidget {
  const IosSettingsSection({
    super.key,
    required this.children,
    this.title,
    this.footer,
    this.dividerIndent = 54,
  });

  final List<Widget> children;
  final String? title;
  final String? footer;

  /// Sangría izquierda del separador (alinea con el texto, no con el icono).
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final bool md = AppMetrics.md;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            // Material: el separador ocupa todo el ancho de la tarjeta.
            padding: EdgeInsets.only(left: md ? 0 : dividerIndent),
            child: Container(
              height: AppMetrics.hairline,
              color: IosColors.separator,
            ),
          ),
        );
      }
      rows.add(children[i]);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppMetrics.u ? 24 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MinimalStyle.on ? 10 : (AppMetrics.u ? 8 : 7)),
              child: Text(
                md ? title! : title!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MinimalStyle.on ? 13 : (AppMetrics.u ? 14 : 12),
                  fontWeight: md ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: md ? 0 : 0.2,
                  color: md && !MinimalStyle.on
                      ? IosColors.blue
                      : IosColors.secondaryLabel,
                ),
              ),
            ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                    color: IosColors.card,
                    borderRadius:
                        BorderRadius.circular(md ? AppMetrics.cardRadius : 12),
                    border: Border.all(
                      color: IosColors.overlay(md ? 0x1F : 0x0F),
                      width: AppMetrics.hairline,
                    ),
                  ),
            child: Column(children: rows),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
              child: Text(
                footer!,
                style: TextStyle(
                  fontSize: AppMetrics.u ? 13 : 12,
                  height: 1.35,
                  color: IosColors.secondaryLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fila de Ajustes: insignia + título (+ subtítulo) + valor + accesorio.
/// Con [onTap] se resalta al pasar el cursor y al pulsar.
class IosSettingsTile extends StatefulWidget {
  const IosSettingsTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.subtitleColor,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.destructive = false,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final Color? subtitleColor;

  /// Texto secundario alineado a la derecha (p. ej. el idioma actual).
  final String? value;

  /// Widget al final de la fila (botón, interruptor…). Va antes del chevron.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool destructive;

  @override
  State<IosSettingsTile> createState() => _IosSettingsTileState();
}

class _IosSettingsTileState extends State<IosSettingsTile> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    final Color bg = !enabled
        ? Colors.transparent
        : (_pressed
            ? IosColors.overlay(0x1F)
            : (_hover ? IosColors.overlay(0x0F) : Colors.transparent));

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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          color: bg,
          constraints: BoxConstraints(
            minHeight: AppMetrics.u ? AppMetrics.tileMinHeight : 48,
          ),
          padding: AppMetrics.u
              ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
              : const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppMetrics.u ? 15 : 13.5,
                        letterSpacing: AppMetrics.u ? 0 : -0.15,
                        color: widget.destructive
                            ? IosColors.red
                            : IosColors.label,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppMetrics.u ? 13 : 11.5,
                          height: 1.3,
                          color:
                              widget.subtitleColor ?? IosColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.value != null) ...[
                const SizedBox(width: 10),
                // Sin Flexible: un hijo flexible se reparte el ancho a medias con
                // el Expanded del título y el valor quedaba en el centro. Con un
                // tope de ancho el título ocupa el resto y el valor va al borde.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    widget.value!,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppMetrics.u ? 14 : 13,
                      letterSpacing: AppMetrics.u ? 0 : -0.15,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ),
              ],
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
              if (widget.showChevron) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppMetrics.u ? AppMetrics.iconSize : 20,
                  color: IosColors.tertiaryLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila con interruptor verde de iOS. Pulsar en cualquier parte de la fila
/// cambia el valor.
class IosSettingsSwitchTile extends StatelessWidget {
  const IosSettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.leading,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// false = fila atenuada y sin respuesta al toque (opción no disponible).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Widget tile = IosSettingsTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: AppMetrics.md
          ? MdSwitch(value: value, onChanged: onChanged)
          : CupertinoSwitch(
              value: value,
              activeColor: IosColors.green,
              onChanged: onChanged,
            ),
    );
    if (enabled) return tile;
    return Opacity(opacity: 0.45, child: IgnorePointer(child: tile));
  }
}
