// lib/ui/dialogs/repair_game_dialog.dart
//
// Ventana emergente de la reparación "el juego no inicia".
// Mientras dura el proceso la ventana de la app se reduce a un tamaño
// compacto, se coloca SIEMPRE POR ENCIMA de todos los programas (incluido el
// juego al abrirse) y no se puede cerrar hasta que termine. Al acabar se
// restaura el tamaño/posición originales.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../../services/game_repair_service.dart';
import '../../services/window_state_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';

/// Ignora las peticiones de cierre de la ventana mientras dura la reparación
/// (cerrar la app a mitad dejaría UE4SS/CNS apartados).
class _CloseBlocker with WindowListener {
  @override
  void onWindowClose() {}
}

class RepairGameDialog {
  RepairGameDialog._();

  static const Size _overlaySize = Size(500, 640);
  static const Size _normalMinimumSize = Size(680, 700);

  /// Ejecuta la reparación mostrando la ventana de progreso.
  /// Devuelve true si todo terminó bien.
  static Future<bool> run({
    required BuildContext context,
    required String gameRootPath,
    required Future<void> Function() launchGame,
    required Future<Set<String>?> Function() findGameProcesses,
  }) async {
    final controller = GameRepairController();
    final blocker = _CloseBlocker();

    Timer? keepOnTop;
    Offset? savedPosition;
    Size? savedSize;
    bool wasMaximized = false;
    bool wasFullScreen = false;

    // El tamaño compacto es temporal: no debe guardarse como el de la ventana.
    WindowStateService.suspend();

    // ------------------------------------------ Ventana compacta y al frente
    try {
      savedPosition = await windowManager.getPosition();
      savedSize = await windowManager.getSize();
      wasMaximized = await windowManager.isMaximized();
      wasFullScreen = await windowManager.isFullScreen();

      windowManager.addListener(blocker);
      await windowManager.setPreventClose(true);

      if (wasFullScreen) await windowManager.setFullScreen(false);
      if (wasMaximized) await windowManager.unmaximize();
      await windowManager.setMinimumSize(const Size(420, 420));
      await windowManager.setSize(_overlaySize);
      await windowManager.center();
      await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
      await windowManager.focus();

      // El juego se abre en pantalla: reafirmamos "siempre al frente".
      keepOnTop = Timer.periodic(
        const Duration(seconds: 2),
        (_) => windowManager.setAlwaysOnTop(true),
      );
    } catch (_) {
      // Los cambios de ventana son cosméticos: el proceso sigue igualmente.
    }

    // --------------------------------------------------- Arranca el proceso
    // (nunca lanza excepciones; el resultado queda en el controller)
    unawaited(
      GameRepairService.run(
        controller: controller,
        gameRootPath: gameRootPath,
        launchGame: launchGame,
        findGameProcesses: findGameProcesses,
      ),
    );

    // ---------------------------------------------------- Ventana de estado
    // Solo se puede cerrar con el botón, y este se activa al terminar.
    await showIosDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => _buildShell(ctx, controller),
      ),
    );

    // ------------------------------------------------ Restaurar la ventana
    keepOnTop?.cancel();
    try {
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setPreventClose(false);
      windowManager.removeListener(blocker);
      await windowManager.setMinimumSize(_normalMinimumSize);
      if (savedSize != null) await windowManager.setSize(savedSize);
      if (savedPosition != null) await windowManager.setPosition(savedPosition);
      if (wasMaximized) await windowManager.maximize();
      await windowManager.focus();
    } catch (_) {}
    WindowStateService.resume();

    return controller.success;
  }

  // --------------------------------------------------------------------------
  //  UI
  // --------------------------------------------------------------------------

  static Widget _buildShell(BuildContext ctx, GameRepairController c) {
    final l10n = AppLocalizations.of(ctx)!;

    final String message;
    if (!c.finished) {
      message = l10n.repairOverlayWarning;
    } else if (c.success) {
      message = l10n.repairResultSuccess;
    } else if (c.filesRestored) {
      message = l10n.repairResultErrorRestored;
    } else {
      message = l10n.repairResultErrorRestoreFailed;
    }

    String? errorText;
    if (c.finished && c.error != null) {
      errorText = c.error is RepairGameNotStartedException
          ? l10n.repairErrorGameNotStarted
          : c.error is RepairGameNotClosedException
              ? l10n.repairErrorGameNotClosed
              : c.error.toString();
    }

    return IosDialogShell(
      title: l10n.repairOverlayTitle,
      message: message,
      width: 420,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final s in c.steps)
                _StepRow(
                  label: _labelFor(l10n, s, c),
                  status: s.status,
                  skippedLabel: l10n.repairStatusSkipped,
                ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    errorText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: IosColors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IosDialogButton(
          label: l10n.repairButtonClose,
          bold: true,
          onPressed: c.finished ? () => Navigator.of(ctx).pop() : null,
        ),
      ],
    );
  }

  static String _labelFor(
    AppLocalizations l10n,
    RepairStep step,
    GameRepairController c,
  ) {
    switch (step.id) {
      case RepairStepId.closeGame:
        return l10n.repairStepCloseGame;
      case RepairStepId.stashCns:
        return l10n.repairStepStashCns;
      case RepairStepId.stashUe4ss:
        return l10n.repairStepStashUe4ss;
      case RepairStepId.launchClean:
        return l10n.repairStepLaunchClean;
      case RepairStepId.waitInit:
        final left = c.countdown;
        final base = l10n.repairStepWaitInit;
        return (step.status == RepairStepStatus.running && left != null)
            ? '$base ($left s)'
            : base;
      case RepairStepId.closeAuto:
        return l10n.repairStepCloseAuto;
      case RepairStepId.restoreUe4ss:
        return l10n.repairStepRestoreUe4ss;
      case RepairStepId.restoreCns:
        return l10n.repairStepRestoreCns;
      case RepairStepId.launchFinal:
        return l10n.repairStepLaunchFinal;
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.status,
    required this.skippedLabel,
  });

  final String label;
  final RepairStepStatus status;
  final String skippedLabel;

  @override
  Widget build(BuildContext context) {
    final Widget icon;
    Color textColor;
    FontWeight weight = FontWeight.w400;
    String text = label;

    switch (status) {
      case RepairStepStatus.pending:
        icon = Icon(
          Icons.radio_button_unchecked,
          size: 18,
          color: IosColors.tertiaryLabel,
        );
        textColor = IosColors.tertiaryLabel;
        break;
      case RepairStepStatus.running:
        icon = const IosSpinner(radius: 8);
        textColor = IosColors.label;
        weight = FontWeight.w600;
        break;
      case RepairStepStatus.done:
        icon = Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: IosColors.green,
        );
        textColor = IosColors.secondaryLabel;
        break;
      case RepairStepStatus.skipped:
        icon = Icon(
          Icons.remove_circle_outline,
          size: 18,
          color: IosColors.gray,
        );
        textColor = IosColors.tertiaryLabel;
        text = '$label · $skippedLabel';
        break;
      case RepairStepStatus.error:
        icon = Icon(
          Icons.cancel_rounded,
          size: 18,
          color: IosColors.red,
        );
        textColor = IosColors.red;
        weight = FontWeight.w600;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 20, height: 20, child: Center(child: icon)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}