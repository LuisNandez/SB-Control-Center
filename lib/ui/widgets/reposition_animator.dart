// lib/ui/widgets/reposition_animator.dart
//
// Anima el desplazamiento de una tarjeta/fila cuando su sitio en la lista o la
// cuadrícula cambia (p. ej. al ordenar los mods arrastrando): en lugar de saltar
// a su nueva posición, se desliza desde la anterior.
//
// Técnica "FLIP": el hijo ya está maquetado en su sitio nuevo y, al pintarlo, se
// desplaza visualmente hasta donde estaba y vuelve a su sitio con una curva. Se
// hace en la fase de pintado, así que no hay ni un fotograma en la posición
// nueva antes de empezar. Funciona igual en GridView y en ListView (vertical).
//
// La posición se mide dentro del contenido desplazable (posición respecto a
// [reference] + el scroll actual), así que hacer scroll no se confunde con un
// movimiento. Solo anima cuando [enabled] es true; si no, solo recuerda la
// posición. Necesita una Key estable por elemento (y `findChildIndexCallback`
// en el builder) para que el estado viaje con el elemento al cambiar de índice.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class RepositionAnimator extends StatefulWidget {
  const RepositionAnimator({
    super.key,
    required this.child,
    required this.reference,
    required this.scrollController,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;

  /// Clave de un ancestro que NO se mueve con el scroll (el que envuelve a la
  /// lista/cuadrícula); sirve de referencia para medir posiciones.
  final GlobalKey reference;

  /// Controlador de la lista/cuadrícula que contiene al elemento.
  final ScrollController scrollController;

  /// Si es false los cambios de posición no se animan.
  final bool enabled;

  final Duration duration;
  final Curve curve;

  @override
  State<RepositionAnimator> createState() => _RepositionAnimatorState();
}

class _RepositionAnimatorState extends State<RepositionAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  void _onMoved() {
    if (!mounted) return;
    _controller.duration = widget.duration;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RepositionBox(
      animation: _animation,
      reference: widget.reference,
      scrollController: widget.scrollController,
      enabled: widget.enabled,
      onMoved: _onMoved,
      child: widget.child,
    );
  }
}

class _RepositionBox extends SingleChildRenderObjectWidget {
  const _RepositionBox({
    required this.animation,
    required this.reference,
    required this.scrollController,
    required this.enabled,
    required this.onMoved,
    super.child,
  });

  final Animation<double> animation;
  final GlobalKey reference;
  final ScrollController scrollController;
  final bool enabled;
  final VoidCallback onMoved;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderRepositionBox(
        animation: animation,
        reference: reference,
        scrollController: scrollController,
        enabled: enabled,
        onMoved: onMoved,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderRepositionBox renderObject,
  ) {
    renderObject
      ..animation = animation
      ..reference = reference
      ..scrollController = scrollController
      ..enabled = enabled
      ..onMoved = onMoved;
  }
}

class _RenderRepositionBox extends RenderProxyBox {
  _RenderRepositionBox({
    required Animation<double> animation,
    required this.reference,
    required this.scrollController,
    required this.enabled,
    required this.onMoved,
  }) : _animation = animation;

  Animation<double> _animation;
  GlobalKey reference;
  ScrollController scrollController;
  bool enabled;
  VoidCallback onMoved;

  /// Última posición (en coordenadas del contenido) en la que se pintó.
  Offset? _lastPos;

  /// Desplazamiento visual del que parte la animación en curso.
  Offset _from = Offset.zero;

  /// Entre detectar el movimiento y que arranque la animación (un fotograma),
  /// se pinta con t = 0 para que no haya ningún salto.
  bool _forceStart = false;

  /// Valor de la animación usado en el último pintado.
  double _lastT = 1;

  set animation(Animation<double> value) {
    if (identical(value, _animation)) return;
    if (attached) _animation.removeListener(_tick);
    _animation = value;
    if (attached) _animation.addListener(_tick);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_tick);
  }

  @override
  void detach() {
    _animation.removeListener(_tick);
    super.detach();
  }

  void _tick() {
    _forceStart = false;
    markNeedsPaint();
  }

  Offset? _contentPosition() {
    try {
      final RenderObject? ref = reference.currentContext?.findRenderObject();
      if (ref is! RenderBox || !ref.attached || !ref.hasSize) return null;
      final Offset rel = localToGlobal(Offset.zero, ancestor: ref);
      final double pixels = scrollController.positions.isNotEmpty
          ? scrollController.positions.first.pixels
          : 0;
      return rel + Offset(0, pixels);
    } catch (_) {
      return null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Offset? pos = _contentPosition();
    if (pos != null) {
      final Offset? last = _lastPos;
      if (enabled && last != null && (last - pos).distance > 0.5) {
        // Su sitio cambió: parte de donde se veía (si aún se estaba moviendo,
        // de su posición visual actual) y vuelve a su sitio.
        final Offset current = _from * (1 - _lastT);
        _from = current + (last - pos);
        _forceStart = true;
        SchedulerBinding.instance.addPostFrameCallback((_) => onMoved());
      }
      _lastPos = pos;
    }

    final double t = _forceStart ? 0.0 : math.min(1.0, _animation.value);
    _lastT = t;
    final Offset shift = _from * (1 - t);

    final RenderBox? c = child;
    if (c != null) context.paintChild(c, offset + shift);
  }
}