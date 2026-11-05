import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_layout.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';

/// Dónde van los botones de cerrar / minimizar / maximizar.
enum WindowButtonsPref { auto, mac, windows }

/// Estado, preferencias y medidas de la barra de la ventana.
class WindowChrome {
  WindowChrome._();

  static const String _kButtons = 'windowButtonsPref';
  static const String _kMerged = 'windowBarMerged';

  /// Preferencias (se guardan solas).
  static final ValueNotifier<WindowButtonsPref> buttons =
      ValueNotifier<WindowButtonsPref>(WindowButtonsPref.auto);
  static final ValueNotifier<bool> merged = ValueNotifier<bool>(true);

  /// Sube cada vez que cambia una preferencia: main.dart la escucha para
  /// reconstruir TODA la interfaz (igual que con el tema y el diseño).
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Estado de la ventana.
  static final ValueNotifier<bool> maximized = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> focused = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> fullScreen = ValueNotifier<bool>(false);

  static bool _inited = false;
  static final _ChromeListener _listener = _ChromeListener();

  /// Llamar en main() una vez inicializado windowManager y leídas las prefs.
  static Future<void> init(SharedPreferences prefs) async {
    final String? b = prefs.getString(_kButtons);
    buttons.value = WindowButtonsPref.values.firstWhere(
      (e) => e.name == b,
      orElse: () => WindowButtonsPref.auto,
    );
    merged.value = prefs.getBool(_kMerged) ?? true;

    if (!_inited) {
      _inited = true;
      windowManager.addListener(_listener);
    }
    try {
      maximized.value = await windowManager.isMaximized();
      focused.value = await windowManager.isFocused();
      fullScreen.value = await windowManager.isFullScreen();
    } catch (_) {}
  }

  static Future<void> setButtons(WindowButtonsPref v) async {
    if (buttons.value == v) return;
    buttons.value = v;
    revision.value++;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kButtons, v.name);
    } catch (_) {}
  }

  static Future<void> setMerged(bool v) async {
    if (merged.value == v) return;
    merged.value = v;
    revision.value++;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kMerged, v);
    } catch (_) {}
  }

  // ------------------------------------------------------------- medidas
  /// true si los botones van a la izquierda (semáforo).
  static bool get macStyle {
    switch (buttons.value) {
      case WindowButtonsPref.mac:
        return true;
      case WindowButtonsPref.windows:
        return false;
      case WindowButtonsPref.auto:
        return !AppLayouts.isMaterial;
    }
  }

  /// Alto de la barra de herramientas de la pantalla principal (y de la
  /// cabecera de Ajustes cuando la barra está fusionada).
  static double get barHeight =>
      AppMetrics.u ? 64 : (52);

  /// Alto de la barra de título fina (solo cuando NO está fusionada).
  static double get stripHeight => 34;

  /// Ancho que ocupan los botones.
  static double get controlsWidth =>
      macStyle ? 80 : (138);

  /// Espacio que la barra de herramientas debe dejar libre a la izquierda /
  /// derecha para no quedar tapada por los botones (0 si no está fusionada).
  static double get leftInset => merged.value && macStyle ? controlsWidth : 0;
  static double get rightInset =>
      merged.value && !macStyle ? controlsWidth + (8) : 0;

  // ------------------------------------------------------------- acciones
  static Future<void> minimize() => windowManager.minimize();

  static Future<void> close() => windowManager.close();

  static Future<void> toggleMaximize() async {
    // El diálogo de reparación del juego bloquea el cierre y fija un tamaño
    // pequeño: mientras dure, no se permite maximizar.
    if (await windowManager.isPreventClose()) return;
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  /// Convierte [child] en zona de arrastre SOLO si la barra está fusionada
  /// (si no, ya hay una barra de título que arrastra).
  static Widget dragArea(Widget child) =>
      merged.value ? WindowDragArea(child: child) : child;
}

class _ChromeListener with WindowListener {
  @override
  void onWindowMaximize() => WindowChrome.maximized.value = true;

  @override
  void onWindowUnmaximize() => WindowChrome.maximized.value = false;

  @override
  void onWindowFocus() => WindowChrome.focused.value = true;

  @override
  void onWindowBlur() => WindowChrome.focused.value = false;

  // Al minimizar, Windows manda "blur" (focused = false), pero al restaurar la
  // ventana desde la barra de tareas window_manager no siempre avisa de que
  // recuperó el foco: los botones se quedaban grises hasta pulsar otra cosa.
  @override
  void onWindowRestore() {
    // Restaurar suele hacerlo el usuario, así que la ventana nace activa...
    WindowChrome.focused.value = true;
    // ...y un momento después se confirma con el estado real del sistema.
    _syncFocus();
  }

  @override
  void onWindowMinimize() => WindowChrome.focused.value = false;

  Future<void> _syncFocus() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      WindowChrome.focused.value = await windowManager.isFocused();
    } catch (_) {}
  }

  @override
  void onWindowEnterFullScreen() => WindowChrome.fullScreen.value = true;

  @override
  void onWindowLeaveFullScreen() => WindowChrome.fullScreen.value = false;
}

/// Zona que mueve la ventana al arrastrar y la maximiza / restaura con doble
/// clic. Sin hijo ocupa todo el espacio (sirve como `flexibleSpace` del AppBar).
class WindowDragArea extends StatelessWidget {
  const WindowDragArea({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: WindowChrome.toggleMaximize,
      child: child ?? const SizedBox.expand(),
    );
  }
}

// ================================================================== marco

/// Marco de la ventana. Va en `MaterialApp.builder`, por encima del Navigator,
/// así que está presente en TODAS las pantallas y los diálogos nunca lo tapan.
///
/// La estructura es siempre la misma (no cambia al fusionar / separar) para
/// que el Navigator conserve su estado al cambiar la opción.
class AppWindowFrame extends StatelessWidget {
  const AppWindowFrame({
    super.key,
    required this.child,
    this.title = 'SB Control Center',
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([WindowChrome.merged, WindowChrome.revision]),
      builder: (context, _) {
        final bool merged = WindowChrome.merged.value;
        final bool mac = WindowChrome.macStyle;
        return Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  merged ? const SizedBox.shrink() : AppTitleBar(title: title),
                  Expanded(
                    child: ClipRect(
                      child: ColoredBox(
                        color: IosColors.background,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fusionada: los botones flotan sobre la barra de herramientas.
            Positioned(
              top: 0,
              left: mac ? 0 : null,
              right: mac ? null : 0,
              height: WindowChrome.barHeight,
              child: merged
                  ? Material(
                      type: MaterialType.transparency,
                      child: WindowControls(height: WindowChrome.barHeight),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

/// Barra de título fina (solo cuando NO está fusionada con la de herramientas).
class AppTitleBar extends StatelessWidget {
  const AppTitleBar({super.key, this.title = 'SB Control Center'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        WindowChrome.fullScreen,
        WindowChrome.focused,
        WindowChrome.revision,
      ]),
      builder: (context, _) {
        if (WindowChrome.fullScreen.value) return const SizedBox.shrink();

        final double h = WindowChrome.stripHeight;
        final Widget text = IgnorePointer(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
              color: WindowChrome.focused.value
                  ? IosColors.secondaryLabel
                  : IosColors.tertiaryLabel,
            ),
          ),
        );

        final Widget content = WindowChrome.macStyle
            // Título centrado de verdad: el hueco derecho mide como el semáforo.
            ? Row(
                children: [
                  WindowControls(height: h),
                  Expanded(child: Center(child: text)),
                  const SizedBox(width: 80),
                ],
              )
            : Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: Align(alignment: Alignment.centerLeft, child: text),
                  ),
                  WindowControls(height: h),
                ],
              );

        return Material(
          // Mismo color que la barra de herramientas de debajo.
          color: IosColors.bar,
          child: SizedBox(
            height: h,
            child: Stack(
              children: [
                const Positioned.fill(child: WindowDragArea()),
                Positioned.fill(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Los tres botones de la ventana, según la preferencia y el diseño.
class WindowControls extends StatelessWidget {
  const WindowControls({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        WindowChrome.maximized,
        WindowChrome.focused,
        WindowChrome.fullScreen,
        WindowChrome.revision,
      ]),
      builder: (context, _) {
        if (WindowChrome.fullScreen.value) return const SizedBox.shrink();
        final bool focused = WindowChrome.focused.value;
        final bool maximized = WindowChrome.maximized.value;

        if (WindowChrome.macStyle) {
          return SizedBox(
            // Ancho fijo: sin él ocuparía toda la barra y taparía sus botones.
            width: WindowChrome.controlsWidth,
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: _TrafficLights(
                  focused: focused,
                  maximized: maximized,
                  onClose: WindowChrome.close,
                  onMinimize: WindowChrome.minimize,
                  onMaximize: WindowChrome.toggleMaximize,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CaptionButton(
                glyph: _Glyph.minimize,
                focused: focused,
                onTap: WindowChrome.minimize,
              ),
              _CaptionButton(
                glyph: maximized ? _Glyph.restore : _Glyph.maximize,
                focused: focused,
                onTap: WindowChrome.toggleMaximize,
              ),
              _CaptionButton(
                glyph: _Glyph.close,
                focused: focused,
                isClose: true,
                onTap: WindowChrome.close,
              ),
              SizedBox(width: 0),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================ iOS: semáforo

class _TrafficLights extends StatefulWidget {
  const _TrafficLights({
    required this.focused,
    required this.maximized,
    required this.onClose,
    required this.onMinimize,
    required this.onMaximize,
  });

  static const double dot = 12;
  static const double gap = 8;
  static const double width = dot * 3 + gap * 2;

  final bool focused;
  final bool maximized;
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;

  @override
  State<_TrafficLights> createState() => _TrafficLightsState();
}

class _TrafficLightsState extends State<_TrafficLights> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // Sin foco y sin ratón encima, los tres círculos se apagan (como en macOS).
    final bool lit = widget.focused || _hover;
    final Color off = IosColors.overlay(0x3C);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Light(
            color: lit ? IosColors.red : off,
            glyph: _LightGlyph.close,
            showGlyph: _hover,
            onTap: widget.onClose,
          ),
          const SizedBox(width: _TrafficLights.gap),
          _Light(
            color: lit ? IosColors.yellow : off,
            glyph: _LightGlyph.minimize,
            showGlyph: _hover,
            onTap: widget.onMinimize,
          ),
          const SizedBox(width: _TrafficLights.gap),
          _Light(
            color: lit ? IosColors.green : off,
            glyph: widget.maximized ? _LightGlyph.restore : _LightGlyph.maximize,
            showGlyph: _hover,
            onTap: widget.onMaximize,
          ),
        ],
      ),
    );
  }
}

class _Light extends StatefulWidget {
  const _Light({
    required this.color,
    required this.glyph,
    required this.showGlyph,
    required this.onTap,
  });

  final Color color;
  final _LightGlyph glyph;
  final bool showGlyph;
  final VoidCallback onTap;

  @override
  State<_Light> createState() => _LightState();
}

class _LightState extends State<_Light> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color shown = _pressed
        ? Color.lerp(widget.color, Colors.black, 0.22)!
        : widget.color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: _TrafficLights.dot,
          height: _TrafficLights.dot,
          decoration: BoxDecoration(
            color: shown,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withOpacity(0.14),
              width: 0.5,
            ),
          ),
          child: widget.showGlyph
              ? CustomPaint(
                  painter: _LightGlyphPainter(
                    widget.glyph,
                    Colors.black.withOpacity(0.58),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

enum _LightGlyph { close, minimize, maximize, restore }

class _LightGlyphPainter extends CustomPainter {
  _LightGlyphPainter(this.glyph, this.color);

  final _LightGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final Paint line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (glyph) {
      case _LightGlyph.close:
        canvas.drawLine(c + const Offset(-2.5, -2.5), c + const Offset(2.5, 2.5), line);
        canvas.drawLine(c + const Offset(2.5, -2.5), c + const Offset(-2.5, 2.5), line);
        break;
      case _LightGlyph.minimize:
        canvas.drawLine(c + const Offset(-3, 0), c + const Offset(3, 0), line);
        break;
      case _LightGlyph.maximize:
        // Dos triángulos que apuntan hacia fuera.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 3.4, c.dy - 3.4)
            ..lineTo(c.dx + 0.6, c.dy - 3.4)
            ..lineTo(c.dx - 3.4, c.dy + 0.6)
            ..close(),
          fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + 3.4, c.dy + 3.4)
            ..lineTo(c.dx - 0.6, c.dy + 3.4)
            ..lineTo(c.dx + 3.4, c.dy - 0.6)
            ..close(),
          fill,
        );
        break;
      case _LightGlyph.restore:
        // Dos triángulos que apuntan hacia dentro.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 0.2, c.dy - 0.2)
            ..lineTo(c.dx - 3.4, c.dy - 0.2)
            ..lineTo(c.dx - 0.2, c.dy - 3.4)
            ..close(),
          fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + 0.2, c.dy + 0.2)
            ..lineTo(c.dx + 3.4, c.dy + 0.2)
            ..lineTo(c.dx + 0.2, c.dy + 3.4)
            ..close(),
          fill,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_LightGlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}


enum _Glyph { minimize, maximize, restore, close }

class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    required this.glyph,
    required this.focused,
    required this.onTap,
    this.isClose = false,
  });

  final _Glyph glyph;
  final bool focused;
  final bool isClose;
  final VoidCallback onTap;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {

    final bool closeHot = widget.isClose && (_hover || _pressed);

    // Glifo: blanco sobre el rojo de "cerrar"; si no, color del texto
    // (atenuado cuando la ventana no tiene el foco).
    final Color glyphColor = closeHot
        ? Colors.white
        : (widget.focused || _hover
            ? IosColors.label
            : IosColors.tertiaryLabel);

    final Widget glyph = SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _GlyphPainter(widget.glyph, glyphColor)),
    );

    Widget visual;
    {
      // Material: rectángulo plano de la altura de la barra.
      // Transparente del MISMO color de destino: si fuera Colors.transparent
      // (negro con alfa 0) la animación pasaría por un gris oscuro.
      Color fill = (widget.isClose ? IosColors.red : IosColors.controlHover)
          .withAlpha(0);
      if (widget.isClose) {
        if (_pressed) {
          fill = Color.lerp(IosColors.red, Colors.black, 0.2)!;
        } else if (_hover) {
          fill = IosColors.red;
        }
      } else if (_pressed) {
        fill = IosColors.controlPressed;
      } else if (_hover) {
        fill = IosColors.controlHover;
      }
      visual = AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 46,
        color: fill,
        alignment: Alignment.center,
        child: glyph,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
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
        onTap: widget.onTap,
        // Alto: el de la barra (Row con stretch implícito vía SizedBox.expand).
        child: SizedBox(
          height: double.infinity,
          child: visual,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color);

  final _Glyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.miter;

    switch (glyph) {
      case _Glyph.minimize:
        canvas.drawLine(
          Offset(c.dx - 5, c.dy + 0.5),
          Offset(c.dx + 5, c.dy + 0.5),
          p,
        );
        break;
      case _Glyph.maximize:
        canvas.drawRect(Rect.fromLTWH(c.dx - 4.5, c.dy - 4.5, 9, 9), p);
        break;
      case _Glyph.restore:
        // Cuadrado delantero + "L" del cuadrado de atrás.
        canvas.drawRect(Rect.fromLTWH(c.dx - 5, c.dy - 2.5, 8, 8), p);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 2.5, c.dy - 2.5)
            ..lineTo(c.dx - 2.5, c.dy - 5)
            ..lineTo(c.dx + 5.5, c.dy - 5)
            ..lineTo(c.dx + 5.5, c.dy + 3)
            ..lineTo(c.dx + 3, c.dy + 3),
          p,
        );
        break;
      case _Glyph.close:
        p.strokeWidth = 1.1;
        canvas.drawLine(c + const Offset(-4.6, -4.6), c + const Offset(4.6, 4.6), p);
        canvas.drawLine(c + const Offset(4.6, -4.6), c + const Offset(-4.6, 4.6), p);
        break;
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}