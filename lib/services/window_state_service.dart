// lib/services/window_state_service.dart
//
// Recuerda el tamaño y la posición de la ventana entre sesiones.
//
//  * Opción en Ajustes → Apariencia → Ventana → "Recordar tamaño y posición"
//    (activada por defecto). Al desactivarla se borra lo guardado y la app
//    vuelve a abrirse con el tamaño y la posición por defecto.
//  * Se guarda (con un pequeño retardo) cada vez que el usuario mueve,
//    redimensiona, maximiza o restaura la ventana.
//  * Si la ventana estaba maximizada se conserva el último tamaño "normal",
//    para que al restaurarla vuelva a donde estaba.
//  * Al arrancar se comprueba que la ventana guardada siga siendo visible en
//    alguna pantalla (por si se desconectó un monitor o cambió la resolución);
//    si no, se corrige o se centra con el tamaño por defecto.
//  * No guarda nada en minimizado ni a pantalla completa, ni mientras otra
//    parte de la app cambia la ventana temporalmente (ver [suspend]).
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Offset, Rect, Size;
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../config/app_prefs.dart';

/// Lo que hay que aplicar a la ventana al arrancar.
class WindowStartupState {
  const WindowStartupState({this.bounds, this.maximized = false});

  /// Tamaño y posición normales (null = usar los de por defecto y centrar).
  final Rect? bounds;

  /// Si la ventana estaba maximizada al cerrar la app.
  final bool maximized;
}

class WindowStateService {
  WindowStateService._();

  /// Tamaño mínimo de la ventana (el mismo que usa main.dart).
  static const Size minimumSize = Size(680, 700);

  static const Duration _debounce = Duration(milliseconds: 400);

  /// Estado de la opción de Ajustes (por defecto: activada).
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);

  static final _Listener _listener = _Listener();
  static bool _tracking = false;
  static Timer? _timer;
  static int _suspended = 0;

  // ------------------------------------------------------------- arranque

  /// Lee la opción y el estado guardado. Llamar en main() ANTES de crear la
  /// ventana. Devuelve null si la opción está desactivada o no hay nada
  /// guardado.
  static Future<WindowStartupState?> loadForStartup(
    SharedPreferences prefs,
  ) async {
    enabled.value = prefs.getBool(AppPrefs.rememberWindowState) ?? true;
    if (!enabled.value) return null;

    final Map<String, dynamic>? m = _decode(prefs.getString(AppPrefs.windowState));
    if (m == null) return null;

    Rect? bounds = _readRect(m);
    if (bounds != null) bounds = await _fitToScreens(bounds);
    return WindowStartupState(bounds: bounds, maximized: m['max'] == true);
  }

  /// Empieza a guardar los cambios de la ventana. Llamar cuando la ventana ya
  /// se mostró (así los ajustes iniciales no se guardan por error).
  static void startTracking() {
    if (_tracking) return;
    _tracking = true;
    windowManager.addListener(_listener);
  }

  // ------------------------------------------------------------- opción

  static Future<void> setEnabled(bool value) async {
    if (enabled.value == value) return;
    enabled.value = value;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppPrefs.rememberWindowState, value);
      if (value) {
        // Guarda ya el estado actual (no hace falta mover la ventana).
        await _saveNow();
      } else {
        _timer?.cancel();
        await prefs.remove(AppPrefs.windowState);
      }
    } catch (_) {}
  }

  // ------------------------------------------------- cambios temporales

  /// Pausa el guardado mientras otra parte de la app cambia la ventana de forma
  /// temporal (p. ej. el diálogo de reparación la reduce y luego la restaura).
  /// Cada [suspend] debe tener su [resume].
  static void suspend() {
    _suspended++;
    _timer?.cancel();
  }

  /// Reanuda el guardado. Espera un instante para ignorar los eventos que la
  /// propia restauración de la ventana todavía está emitiendo.
  static void resume() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (_suspended > 0) _suspended--;
    });
  }

  // ------------------------------------------------------------- guardado

  static void _schedule() {
    if (!enabled.value || _suspended > 0) return;
    _timer?.cancel();
    _timer = Timer(_debounce, () => unawaited(_saveNow()));
  }

  static Future<void> _saveNow() async {
    if (!enabled.value || _suspended > 0) return;
    try {
      // Minimizada, Windows la sitúa en (-32000, -32000); a pantalla completa
      // el tamaño no es el "normal": en ambos casos se deja lo guardado.
      if (await windowManager.isMinimized() ||
          await windowManager.isFullScreen()) {
        return;
      }
      final bool maximized = await windowManager.isMaximized();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> m =
          _decode(prefs.getString(AppPrefs.windowState)) ?? <String, dynamic>{};
      m['max'] = maximized;

      // Maximizada: solo se anota que lo está y se conserva el último tamaño
      // normal, para que "restaurar" vuelva a donde estaba.
      if (!maximized) {
        final Offset pos = await windowManager.getPosition();
        final Size size = await windowManager.getSize();
        if (size.width < 200 || size.height < 200) return; // dato absurdo
        m['x'] = pos.dx;
        m['y'] = pos.dy;
        m['w'] = size.width;
        m['h'] = size.height;
      }

      // Pudo suspenderse o desactivarse mientras se esperaban los datos.
      if (!enabled.value || _suspended > 0) return;
      await prefs.setString(AppPrefs.windowState, jsonEncode(m));
    } catch (_) {}
  }

  // ------------------------------------------------------------- utilidades

  static Map<String, dynamic>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? v = jsonDecode(raw);
      if (v is Map) return Map<String, dynamic>.from(v);
    } catch (_) {}
    return null;
  }

  static Rect? _readRect(Map<String, dynamic> m) {
    double? n(String k) {
      final Object? v = m[k];
      if (v is num && v.isFinite) return v.toDouble();
      return null;
    }

    final double? x = n('x'), y = n('y'), w = n('w'), h = n('h');
    if (x == null || y == null || w == null || h == null) return null;
    if (w <= 0 || h <= 0) return null;
    return Rect.fromLTWH(x, y, w, h);
  }

  static double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  /// Comprueba que [r] se vea en alguna pantalla. Ajusta el tamaño a la
  /// pantalla donde cae y, si la barra superior quedaría inalcanzable, la mete
  /// dentro. Devuelve null si está completamente fuera de todas las pantallas
  /// (monitor desconectado): entonces se usa el tamaño por defecto, centrada.
  static Future<Rect?> _fitToScreens(Rect r) async {
    try {
      final List<Display> displays = await screenRetriever.getAllDisplays();
      if (displays.isEmpty) return r;

      Rect? best;
      double bestArea = 0;
      for (final Display d in displays) {
        final Rect area =
            (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size);
        final Rect inter = r.intersect(area);
        if (inter.width <= 0 || inter.height <= 0) continue;
        final double a = inter.width * inter.height;
        if (a > bestArea) {
          bestArea = a;
          best = area;
        }
      }
      if (best == null) return null;

      // Nunca más grande que la pantalla ni más pequeña que el mínimo.
      final double w = _clamp(
        r.width,
        minimumSize.width,
        math.max(minimumSize.width, best.width),
      );
      final double h = _clamp(
        r.height,
        minimumSize.height,
        math.max(minimumSize.height, best.height),
      );
      Rect fitted = Rect.fromLTWH(r.left, r.top, w, h);

      // Debe quedar una parte razonable a la vista y la barra superior (zona de
      // arrastre) dentro de la pantalla; si no, se mete entera en ella.
      final Rect inter = fitted.intersect(best);
      final bool reachable = inter.width >= 160 &&
          inter.height >= 80 &&
          fitted.top >= best.top - 8 &&
          fitted.top <= best.bottom - 80;
      if (!reachable) {
        fitted = Rect.fromLTWH(
          _clamp(fitted.left, best.left, math.max(best.left, best.right - w)),
          _clamp(fitted.top, best.top, math.max(best.top, best.bottom - h)),
          w,
          h,
        );
      }
      return fitted;
    } catch (_) {
      // Sin poder consultar las pantallas, se confía en lo guardado.
      return r;
    }
  }
}

class _Listener with WindowListener {
  // Eventos "durante" (por si el sistema no avisa al terminar, p. ej. al
  // acoplar la ventana con Win + flechas) y eventos "al terminar".
  @override
  void onWindowMove() => WindowStateService._schedule();

  @override
  void onWindowMoved() => WindowStateService._schedule();

  @override
  void onWindowResize() => WindowStateService._schedule();

  @override
  void onWindowResized() => WindowStateService._schedule();

  @override
  void onWindowMaximize() => WindowStateService._schedule();

  @override
  void onWindowUnmaximize() => WindowStateService._schedule();

  @override
  void onWindowRestore() => WindowStateService._schedule();

  @override
  void onWindowLeaveFullScreen() => WindowStateService._schedule();
}