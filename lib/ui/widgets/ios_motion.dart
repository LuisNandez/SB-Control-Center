// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/ios_theme.dart';

/// Curvas y duraciones compartidas para que TODA la app se mueva igual.
class IosMotion {
  IosMotion._();

  /// Curva de las hojas (sheets) de iOS: arranque rápido y frenado muy suave.
  static const Curve sheet = Cubic(0.32, 0.72, 0.0, 1.0);

  static const Curve standard = Curves.easeOutCubic;

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
}

// ============================================================================
//  APARICIÓN ESCALONADA
// ============================================================================

/// Hace aparecer a su hijo con un fundido + desplazamiento suave hacia arriba.
/// Con [index] distinto se consigue el efecto "cascada" de iOS: cada sección
/// entra unos milisegundos después de la anterior.
///
/// Solo anima UNA vez (cuando el widget entra al árbol), no en cada rebuild.
class IosReveal extends StatefulWidget {
  const IosReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 45),
    this.offset = 14,
    this.duration = const Duration(milliseconds: 460),
  });

  final Widget child;
  final int index;
  final Duration step;
  final double offset;
  final Duration duration;

  @override
  State<IosReveal> createState() => _IosRevealState();
}

class _IosRevealState extends State<IosReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: IosMotion.sheet,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final int steps = widget.index < 0 ? 0 : (widget.index > 12 ? 12 : widget.index);
    final Duration delay = widget.step * steps;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      // RepaintBoundary: la sección se dibuja UNA vez y la animación (y luego
      // el scroll) solo mueve esa capa ya dibujada, en vez de repintar todo su
      // contenido en cada fotograma.
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        final double t = _curved.value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
//  PULSACIÓN CON MUELLE
// ============================================================================

/// Envuelve cualquier widget con el comportamiento táctil de iOS/macOS:
/// al pulsar se encoge un poco y al soltar vuelve con un pequeño rebote.
class IosPressable extends StatefulWidget {
  const IosPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.onHoverChanged,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<IosPressable> createState() => _IosPressableState();
}

class _IosPressableState extends State<IosPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => widget.onHoverChanged?.call(true),
      onExit: (_) {
        if (_pressed) setState(() => _pressed = false);
        widget.onHoverChanged?.call(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1.0,
          duration: Duration(milliseconds: _pressed ? 90 : 320),
          curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================================
//  APARICIÓN CON "POP"
// ============================================================================

/// Aparición con escala + fundido y un leve rebote (chips, insignias...).
class IosPop extends StatelessWidget {
  const IosPop({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 340),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutBack,
      child: child,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
        );
      },
    );
  }
}

// ============================================================================
//  TEXTO QUE "RUEDA" AL CAMBIAR (contadores)
// ============================================================================

/// Texto que al cambiar entra deslizándose desde abajo, como los contadores
/// de iOS. Úsalo para "3 seleccionados", "12 trajes", etc.
class IosCountText extends StatelessWidget {
  const IosCountText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

// ============================================================================
//  CONTENIDO PLEGABLE ("Mostrar más / menos")
// ============================================================================

/// Limita la altura de un contenido largo y lo difumina por abajo; con el
/// botón "Mostrar más" se despliega con una animación suave.
///
/// Mide el contenido real: si cabe en [collapsedHeight] no muestra ni el
/// difuminado ni el botón.
class IosCollapsible extends StatefulWidget {
  const IosCollapsible({
    super.key,
    required this.child,
    required this.moreLabel,
    required this.lessLabel,
    this.collapsedHeight = 160,
    this.enabled = true,
  });

  final Widget child;
  final String moreLabel;
  final String lessLabel;
  final double collapsedHeight;
  final bool enabled;

  @override
  State<IosCollapsible> createState() => _IosCollapsibleState();
}

class _IosCollapsibleState extends State<IosCollapsible> {
  final GlobalKey _contentKey = GlobalKey();
  bool _expanded = false;
  bool _overflowing = true;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  @override
  void didUpdateWidget(covariant IosCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    _measure();
  }

  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderObject? ro = _contentKey.currentContext?.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize) return;
      final bool over = ro.size.height > widget.collapsedHeight + 28;
      if (over != _overflowing) setState(() => _overflowing = over);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final bool collapsed = !_expanded && _overflowing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 340),
          curve: IosMotion.sheet,
          alignment: Alignment.topCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: collapsed ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 340),
            curve: IosMotion.sheet,
            builder: (context, t, child) {
              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Color.lerp(Colors.white, const Color(0x00FFFFFF), t)!,
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ).createShader(rect);
                },
                child: child,
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: collapsed ? widget.collapsedHeight : double.infinity,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (_) {
                    _measure();
                    return false;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: KeyedSubtree(
                      key: _contentKey,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_overflowing) ...[
          const SizedBox(height: 6),
          Center(
            child: IosPressable(
              scale: 0.95,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? widget.lessLabel : widget.moreLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: IosColors.blue,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: IosMotion.sheet,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: IosColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
//  RUEDA DEL RATÓN → SCROLL HORIZONTAL
// ============================================================================

/// En escritorio la rueda del ratón solo mueve el scroll vertical, así que un
/// carrusel horizontal quedaría inaccesible sin arrastrar la barra. Este widget
/// convierte la rueda en desplazamiento horizontal mientras el cursor está
/// encima y, al llegar a un extremo, deja pasar la rueda al scroll de la página.
class IosWheelToHorizontal extends StatelessWidget {
  const IosWheelToHorizontal({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is! PointerScrollEvent) return;
        if (!controller.hasClients) return;
        // Gestos ya horizontales (touchpad): los gestiona el propio scroll.
        if (event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()) return;

        final ScrollPosition pos = controller.position;
        final double target = (pos.pixels + event.scrollDelta.dy)
            .clamp(pos.minScrollExtent, pos.maxScrollExtent)
            .toDouble();
        if (target == pos.pixels) return;

        GestureBinding.instance.pointerSignalResolver.register(event, (_) {
          if (controller.hasClients) controller.jumpTo(target);
        });
      },
      child: child,
    );
  }
}