// lib/services/game_repair_service.dart
//
// Reparación de "el juego no inicia (se cierra o crashea)".
// Proceso:
//   1. Cierra el juego si estuviera abierto.
//   2. Desinstala CNS y UE4SS guardando sus archivos (no se borran: se apartan).
//   3. Inicia el juego hasta que arranque, espera unos segundos y lo cierra solo.
//   4. Reinstala UE4SS y CNS con los archivos guardados.
//   5. Lanza el juego.
//
// Es lógica pura (sin interfaz): el progreso se publica en un
// [GameRepairController] que la ventana emergente observa.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'core_installer_service.dart';

enum RepairStepId {
  closeGame,
  stashCns,
  stashUe4ss,
  launchClean,
  waitInit,
  closeAuto,
  restoreUe4ss,
  restoreCns,
  launchFinal,
}

enum RepairStepStatus { pending, running, done, skipped, error }

class RepairStep {
  RepairStep(this.id);

  final RepairStepId id;
  RepairStepStatus status = RepairStepStatus.pending;
  String? detail;
}

/// El juego no apareció como proceso dentro del tiempo máximo de espera.
class RepairGameNotStartedException implements Exception {
  const RepairGameNotStartedException();

  @override
  String toString() => 'The game did not start in time.';
}

/// El proceso del juego no se pudo cerrar. El texto visible se genera en la UI
/// con l10n.repairErrorGameNotClosed.
class RepairGameNotClosedException implements Exception {
  const RepairGameNotClosedException();

  @override
  String toString() => 'The game process could not be closed.';
}

/// Estado observable del proceso de reparación.
class GameRepairController extends ChangeNotifier {
  final List<RepairStep> steps =
      RepairStepId.values.map(RepairStep.new).toList(growable: false);

  bool finished = false;
  bool success = false;

  /// false si los archivos de UE4SS/CNS NO pudieron devolverse a su sitio
  /// (se recuperarán automáticamente en el próximo inicio de la app).
  bool filesRestored = true;
  Object? error;

  /// Segundos restantes de la espera con el juego abierto (null = no aplica).
  int? countdown;

  RepairStep step(RepairStepId id) => steps.firstWhere((s) => s.id == id);

  void setStatus(RepairStepId id, RepairStepStatus status, {String? detail}) {
    final s = step(id);
    s.status = status;
    if (detail != null) s.detail = detail;
    notifyListeners();
  }

  void setCountdown(int? value) {
    countdown = value;
    notifyListeners();
  }

  void finish({
    required bool success,
    required bool filesRestored,
    Object? error,
  }) {
    this.success = success;
    this.filesRestored = filesRestored;
    this.error = error;
    countdown = null;
    finished = true;
    notifyListeners();
  }
}

class GameRepairService {
  GameRepairService._();

  /// Tiempo máximo esperando a que el juego aparezca como proceso.
  static const Duration gameStartTimeout = Duration(seconds: 90);

  /// Tiempo que se deja el juego abierto una vez arrancado.
  static const Duration gameRunTime = Duration(seconds: 10);

  /// Espera máxima tras el lanzamiento final (solo informativa).
  static const Duration finalLaunchWait = Duration(seconds: 45);

  /// Ejecuta todo el proceso. NUNCA lanza excepciones: el resultado queda en
  /// [controller]. Pase lo que pase, al final se intentan devolver los
  /// archivos de UE4SS y CNS a su sitio.
  static Future<void> run({
    required GameRepairController controller,
    required String gameRootPath,
    required Future<void> Function() launchGame,
    required Future<Set<String>?> Function() findGameProcesses,
  }) async {
    final c = controller;
    Object? failure;
    RepairStepId? current;

    Future<void> step(
      RepairStepId id,
      Future<RepairStepStatus> Function() body,
    ) async {
      current = id;
      c.setStatus(id, RepairStepStatus.running);
      final result = await body();
      c.setStatus(id, result);
      current = null;
    }

    // ---------------------------------------------------- Fase 1: preparar
    try {
      // Marca de seguridad: si la app se cierra a mitad de camino, en el
      // próximo inicio se devuelven los archivos apartados.
      await CoreInstallerService.beginRepairJournal(gameRootPath);

      await step(RepairStepId.closeGame, () async {
        final procs = await findGameProcesses();
        if (procs == null || procs.isEmpty) return RepairStepStatus.skipped;
        await _closeGame(findGameProcesses);
        return RepairStepStatus.done;
      });

      // CNS primero: vive dentro de la carpeta de UE4SS.
      await step(RepairStepId.stashCns, () async {
        final moved = await CoreInstallerService.stashCoreComponent(
          isUe4ss: false,
          gameRootPath: gameRootPath,
        );
        return moved ? RepairStepStatus.done : RepairStepStatus.skipped;
      });

      await step(RepairStepId.stashUe4ss, () async {
        final moved = await CoreInstallerService.stashCoreComponent(
          isUe4ss: true,
          gameRootPath: gameRootPath,
        );
        return moved ? RepairStepStatus.done : RepairStepStatus.skipped;
      });

      // ----------------------------------------- Fase 2: arranque limpio
      await step(RepairStepId.launchClean, () async {
        await launchGame();
        final started = await _waitForProcess(
          findGameProcesses,
          gameStartTimeout,
        );
        if (!started) throw const RepairGameNotStartedException();
        return RepairStepStatus.done;
      });

      await step(RepairStepId.waitInit, () async {
        var left = gameRunTime.inSeconds;
        while (left > 0) {
          c.setCountdown(left);
          await Future.delayed(const Duration(seconds: 1));
          left--;
          final procs = await findGameProcesses();
          // Si el juego se cerró por sí solo, no hace falta seguir esperando.
          if (procs != null && procs.isEmpty) break;
        }
        c.setCountdown(null);
        return RepairStepStatus.done;
      });

      await step(RepairStepId.closeAuto, () async {
        await _closeGame(findGameProcesses);
        return RepairStepStatus.done;
      });
    } catch (e) {
      failure = e;
      final id = current;
      if (id != null) c.setStatus(id, RepairStepStatus.error, detail: '$e');
    }

    // ------------------------------- Fase 3: reinstalar (SIEMPRE se intenta)
    bool restoreOk = true;

    try {
      current = null;
      await step(RepairStepId.restoreUe4ss, () async {
        final restored = await CoreInstallerService.restoreStashedComponent(
          isUe4ss: true,
          gameRootPath: gameRootPath,
        );
        return restored ? RepairStepStatus.done : RepairStepStatus.skipped;
      });
    } catch (e) {
      restoreOk = false;
      failure ??= e;
      final id = current;
      if (id != null) c.setStatus(id, RepairStepStatus.error, detail: '$e');
    }

    try {
      current = null;
      await step(RepairStepId.restoreCns, () async {
        final restored = await CoreInstallerService.restoreStashedComponent(
          isUe4ss: false,
          gameRootPath: gameRootPath,
        );
        return restored ? RepairStepStatus.done : RepairStepStatus.skipped;
      });
    } catch (e) {
      restoreOk = false;
      failure ??= e;
      final id = current;
      if (id != null) c.setStatus(id, RepairStepStatus.error, detail: '$e');
    }

    if (restoreOk) {
      try {
        await CoreInstallerService.cleanupRepairBackup(gameRootPath);
      } catch (_) {
        // Limpieza no crítica.
      }
    }

    // --------------------------------------------- Fase 4: lanzar el juego
    if (failure == null) {
      try {
        current = null;
        await step(RepairStepId.launchFinal, () async {
          await launchGame();
          await _waitForProcess(findGameProcesses, finalLaunchWait);
          return RepairStepStatus.done;
        });
      } catch (e) {
        failure = e;
        final id = current;
        if (id != null) c.setStatus(id, RepairStepStatus.error, detail: '$e');
      }
    }

    c.finish(
      success: failure == null,
      filesRestored: restoreOk,
      error: failure,
    );
  }

  /// Devuelve true en cuanto el juego aparece como proceso.
  static Future<bool> _waitForProcess(
    Future<Set<String>?> Function() find,
    Duration timeout,
  ) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final procs = await find();
      if (procs != null && procs.isNotEmpty) {
        // Margen para que el juego termine de crear su ventana.
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  /// Cierra el juego: primero con una petición normal y, si no responde,
  /// de forma forzada. Lanza excepción si sigue abierto al final (sus
  /// archivos estarían bloqueados y no se podrían reinstalar los mods).
  static Future<void> _closeGame(
    Future<Set<String>?> Function() find,
  ) async {
    Future<bool> isGone() async {
      final procs = await find();
      return procs != null && procs.isEmpty;
    }

    // 1) Cierre normal.
    for (final name in await find() ?? <String>{}) {
      await Process.run('taskkill', ['/IM', name, '/T']);
    }
    bool gone = false;
    for (int i = 0; i < 10 && !gone; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      gone = await isGone();
    }

    // 2) Cierre forzado.
    if (!gone) {
      for (final name in await find() ?? <String>{}) {
        await Process.run('taskkill', ['/F', '/IM', name, '/T']);
      }
      for (int i = 0; i < 10 && !gone; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        gone = await isGone();
      }
    }

    if (!gone) {
      throw const RepairGameNotClosedException();
    }

    // Deja que Windows libere los archivos (DLLs) del juego.
    await Future.delayed(const Duration(seconds: 2));
  }
}