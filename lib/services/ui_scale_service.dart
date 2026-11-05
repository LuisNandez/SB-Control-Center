// lib/services/ui_scale_service.dart
//
// Escala de la interfaz ajustable por el usuario (Ajustes → Apariencia):
//   * [text]  → tamaño de letra de TODA la interfaz (lo aplica main.dart con
//               MediaQuery.textScaler, así que afecta a cualquier Text).
//   * [cards] → tamaño de las tarjetas de mods: ancho de las tarjetas de la
//               cuadrícula y alto/espaciado de las filas de la lista.
//
// Ambas son ValueNotifier (1.0 = 100 %, valor por defecto) y se guardan en
// SharedPreferences.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_prefs.dart';

class UiScale {
  UiScale._();

  static const double textMin = 0.85;
  static const double textMax = 1.50;
  static const double cardsMin = 0.75;
  static const double cardsMax = 1.50;

  /// Paso de los deslizadores (5 %).
  static const double step = 0.05;

  static final ValueNotifier<double> text = ValueNotifier<double>(1.0);
  static final ValueNotifier<double> cards = ValueNotifier<double>(1.0);

  /// Llamar en main() tras leer las preferencias y antes de runApp.
  static void init(SharedPreferences prefs) {
    text.value = _clamp(prefs.getDouble(AppPrefs.uiTextScale), textMin, textMax);
    cards.value =
        _clamp(prefs.getDouble(AppPrefs.uiCardScale), cardsMin, cardsMax);
  }

  static double _clamp(double? v, double min, double max) {
    if (v == null || v.isNaN) return 1.0;
    // Redondea al paso para evitar valores como 1.0500000000000003.
    final double r = (v / step).round() * step;
    return r.clamp(min, max).toDouble();
  }

  static Future<void> setText(double v) async {
    final double next = _clamp(v, textMin, textMax);
    if (next == text.value) return;
    text.value = next;
    await _save(AppPrefs.uiTextScale, next);
  }

  static Future<void> setCards(double v) async {
    final double next = _clamp(v, cardsMin, cardsMax);
    if (next == cards.value) return;
    cards.value = next;
    await _save(AppPrefs.uiCardScale, next);
  }

  /// Vuelve ambas escalas al 100 %.
  static Future<void> reset() async {
    await setText(1.0);
    await setCards(1.0);
  }

  static Future<void> _save(String key, double v) async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setDouble(key, v);
    } catch (_) {}
  }
}
