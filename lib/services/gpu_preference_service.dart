// lib/services/gpu_preference_service.dart
//
// Opción "Usar la tarjeta gráfica" (Ajustes → General). Desactivada por defecto.
//
// Flutter ya dibuja la interfaz con la GPU en Windows; lo que se puede elegir
// es CUÁL. En equipos con dos gráficas (integrada + dedicada) Windows suele
// ejecutar las apps normales en la integrada. Esta opción registra el .exe de
// la app como "Alto rendimiento" (Configuración → Sistema → Pantalla →
// Gráficos), que es la preferencia por aplicación de Windows:
//
//   HKCU\Software\Microsoft\DirectX\UserGpuPreferences
//     "<ruta del .exe de la app>" = "GpuPreference=2;"
//
//  * Es por usuario (HKCU): no pide permisos de administrador.
//  * Windows la lee al ABRIR el proceso, así que se aplica al reiniciar la app.
//  * Si la entrada ya existía (p. ej. la puso el usuario a mano en Windows) se
//    guarda su valor y se restaura al desactivar la opción; si no existía, se
//    borra. Volver a "desactivada" deja Windows exactamente como estaba.
//  * Con una sola gráfica no cambia nada (por eso Ajustes deshabilita la opción
//    cuando [physicalGpuCount] detecta una única tarjeta).
//  * Tras cambiarla, Ajustes pregunta si reiniciar ya: [restartApp] abre una
//    copia nueva de la app y cierra la actual.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../config/app_prefs.dart';
import 'self_update_service.dart';

class GpuPreferenceService {
  GpuPreferenceService._();

  static const String _regKey =
      r'HKCU\Software\Microsoft\DirectX\UserGpuPreferences';
  static const String _highPerformanceToken = 'GpuPreference=2';

  /// Solo existe en Windows.
  static bool get isSupported => Platform.isWindows;

  /// El valor del registro se llama igual que la ruta del ejecutable.
  static String get _exePath => Platform.resolvedExecutable;

  // ------------------------------------------------------------------ registro

  /// Datos guardados para el .exe de la app, o null si no hay entrada.
  static Future<String?> _readEntry() async {
    final r = await Process.run('reg', ['query', _regKey, '/v', _exePath]);
    if (r.exitCode != 0) return null;
    for (final line in r.stdout.toString().split(RegExp(r'\r?\n'))) {
      final i = line.indexOf('REG_SZ');
      if (i >= 0) return line.substring(i + 'REG_SZ'.length).trim();
    }
    return null;
  }

  static Future<bool> _writeEntry(String data) async {
    final r = await Process.run('reg', [
      'add', _regKey, '/v', _exePath, '/t', 'REG_SZ', '/d', data, '/f',
    ]);
    return r.exitCode == 0;
  }

  static Future<bool> _deleteEntry() async {
    // Si ya no existe, el objetivo está cumplido.
    if (await _readEntry() == null) return true;
    final r = await Process.run('reg', [
      'delete', _regKey, '/v', _exePath, '/f',
    ]);
    return r.exitCode == 0;
  }

  static List<String> _tokens(String? data) => (data ?? '')
      .split(';')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  static bool _isHighPerformance(String? data) =>
      _tokens(data).contains(_highPerformanceToken);

  /// Pone GpuPreference=2 conservando cualquier otro ajuste de esa entrada
  /// (Windows 11 añade, por ejemplo, SwapEffectUpgradeEnable=1).
  static String _withHighPerformance(String? current) {
    final others =
        _tokens(current).where((t) => !t.startsWith('GpuPreference='));
    return '${[_highPerformanceToken, ...others].join(';')};';
  }

  // ------------------------------------------------------- tarjetas gráficas

  static int? _gpuCountCache;

  /// Número de tarjetas gráficas FÍSICAS (las que cuelgan del bus PCI; se
  /// ignoran adaptadores virtuales como Remote Desktop, Parsec o el controlador
  /// básico de Microsoft). Devuelve null si no se pudo averiguar, y entonces la
  /// opción se deja disponible.
  static Future<int?> physicalGpuCount() async {
    if (!isSupported) return null;
    if (_gpuCountCache != null) return _gpuCountCache;
    try {
      final r = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-WindowStyle',
        'Hidden',
        '-Command',
        r"(Get-CimInstance Win32_VideoController | Where-Object { $_.PNPDeviceID -like 'PCI\*' } | Measure-Object).Count",
      ]).timeout(const Duration(seconds: 10));
      if (r.exitCode != 0) return null;
      final int? n = int.tryParse(r.stdout.toString().trim());
      // 0 = no se vio ninguna gráfica PCI (p. ej. una máquina virtual): no es
      // fiable para decir "solo hay una", así que se trata como desconocido.
      if (n == null || n < 1) return null;
      return _gpuCountCache = n;
    } catch (e) {
      debugPrint('GpuPreferenceService.physicalGpuCount: $e');
      return null;
    }
  }

  // -------------------------------------------------------------- reinicio

  /// Valor de la opción con el que se ABRIÓ este proceso (lo que Windows aplicó
  /// de verdad a esta ejecución). Lo fija [syncOnStartup].
  static bool? _startupEnabled;

  /// true si, con la opción en [enabled], hace falta reiniciar la app para que
  /// Windows aplique el cambio (el valor difiere del de este arranque).
  static bool restartPending(bool enabled) =>
      _startupEnabled != null && _startupEnabled != enabled;

  /// Abre una copia nueva de la app y cierra la actual. La nueva espera a que
  /// este proceso termine (control de instancia única) con `--sbcc-wait-pid`.
  /// Si todo va bien no vuelve; devuelve false solo si no se pudo relanzar.
  static Future<bool> restartApp() async {
    if (!isSupported) return false;
    try {
      await Process.start(
        Platform.resolvedExecutable,
        ['${SelfUpdateService.waitPidArg}$pid'],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      debugPrint('GpuPreferenceService.restartApp: $e');
      return false;
    }
    try {
      await windowManager.destroy();
    } catch (_) {}
    exit(0);
  }

  // ------------------------------------------------------------------- público

  /// Activa o desactiva la opción. Devuelve true si Windows quedó como se pidió
  /// (en ese caso también guarda la preferencia de la app); false si falló.
  static Future<bool> setEnabled(bool enabled) async {
    if (!isSupported) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (enabled) {
        final current = await _readEntry();
        // Recuerda lo que había (si algo) para poder restaurarlo después.
        if (current != null) {
          await prefs.setString(AppPrefs.gpuPreviousPreference, current);
        } else {
          await prefs.remove(AppPrefs.gpuPreviousPreference);
        }
        if (!_isHighPerformance(current) &&
            !await _writeEntry(_withHighPerformance(current))) {
          return false;
        }
      } else {
        final previous = prefs.getString(AppPrefs.gpuPreviousPreference);
        final ok =
            previous != null ? await _writeEntry(previous) : await _deleteEntry();
        if (!ok) return false;
        await prefs.remove(AppPrefs.gpuPreviousPreference);
      }
      await prefs.setBool(AppPrefs.useGpuAcceleration, enabled);
      return true;
    } catch (e) {
      debugPrint('GpuPreferenceService.setEnabled($enabled): $e');
      return false;
    }
  }

  /// Al abrir la app con la opción activa, comprueba que la entrada de Windows
  /// sigue apuntando a ESTE ejecutable (por si la carpeta de la app cambió o
  /// se borró la entrada) y la repone si falta. Nunca toca nada si la opción
  /// está desactivada. Surte efecto en el siguiente arranque.
  static Future<void> syncOnStartup(SharedPreferences prefs) async {
    if (!isSupported) return;
    _startupEnabled = prefs.getBool(AppPrefs.useGpuAcceleration) ?? false;
    if (!_startupEnabled!) return;
    try {
      final current = await _readEntry();
      if (!_isHighPerformance(current)) {
        await _writeEntry(_withHighPerformance(current));
      }
    } catch (e) {
      debugPrint('GpuPreferenceService.syncOnStartup: $e');
    }
  }
}