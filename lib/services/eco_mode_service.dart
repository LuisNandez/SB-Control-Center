// lib/services/eco_mode_service.dart
//
// Modo ahorro mientras Stellar Blade está en ejecución.
//
// Con el juego abierto la app no debe competir con él por CPU, GPU ni memoria.
// En modo ahorro:
//   * la interfaz se oculta y se congela (ver [EcoModeLayer]): no se pinta nada
//     y las animaciones se silencian, así que Flutter deja de producir fotogramas;
//   * se vacía la caché de imágenes (libera memoria);
//   * el proceso baja a prioridad "inactiva" de Windows;
//   * el vigilante del juego consulta con menos frecuencia (lo decide main.dart).
//
// NO se activa mientras la app está ocupada con algo (reparar el inicio, lanzar
// el juego, instalar mods, descargas, ventanas o ajustes abiertos...): quien
// llama indica eso con `busy`. Tampoco hasta que el juego lleva un rato estable.
// Todo vuelve a la normalidad solo en cuanto el juego se cierra.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class EcoModeService {
  EcoModeService._();
  static final EcoModeService instance = EcoModeService._();

  /// true = modo ahorro activo.
  final ValueNotifier<bool> active = ValueNotifier<bool>(false);

  bool get isActive => active.value;

  /// Tiempo con el juego abierto Y la app libre antes de entrar en modo ahorro
  /// (evita entrar durante el arranque o justo después de una reparación).
  static const Duration settleTime = Duration(seconds: 15);

  DateTime? _idleSince;
  bool _dismissed = false; // el usuario pulsó "Mostrar la app igualmente"

  /// Llamar en cada comprobación del juego y cuando cambie algo de lo que
  /// ocupa a la app. [busy] = la app está haciendo algo que no debe interrumpirse.
  void evaluate({required bool gameRunning, required bool busy}) {
    if (!Platform.isWindows) return;
    if (!gameRunning) {
      _idleSince = null;
      _dismissed = false;
      _set(false);
      return;
    }
    if (busy || _dismissed) {
      _idleSince = null; // al quedar libre, vuelve a esperar [settleTime]
      _set(false);
      return;
    }
    _idleSince ??= DateTime.now();
    if (DateTime.now().difference(_idleSince!) >= settleTime) _set(true);
  }

  /// "Mostrar la app igualmente": sale del modo ahorro hasta que el juego se cierre.
  void dismiss() {
    _dismissed = true;
    _idleSince = null;
    _set(false);
  }

  void _set(bool value) {
    if (active.value == value) return;
    active.value = value;
    if (value) {
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();
    }
    _setPriority(value ? 'Idle' : 'Normal');
  }

  /// Prioridad del proceso de la app en Windows (Idle / Normal). Es un ajuste de
  /// cortesía: si falla no pasa nada.
  static void _setPriority(String priorityClass) {
    Process.run('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-WindowStyle',
      'Hidden',
      '-Command',
      "(Get-Process -Id $pid).PriorityClass = '$priorityClass'",
    ]).then((_) {}, onError: (Object e) {
      debugPrint('EcoModeService._setPriority($priorityClass): $e');
    });
  }
}
