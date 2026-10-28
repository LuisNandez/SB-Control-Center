// lib/ui/dialogs/self_update_dialog.dart
//
// Diálogo de progreso de la auto-instalación. Lo controla el llamador mediante
// un [SelfUpdateUiState] (ValueNotifier): etapa + fracción, o un error.
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/self_update_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_progress_bar.dart';
import '../widgets/ios_widgets.dart';

class SelfUpdateUiState {
  final SelfUpdateStage stage;
  final double? fraction;
  final String? error;
  const SelfUpdateUiState(this.stage, {this.fraction, this.error});
}

class SelfUpdateDialog {
  /// Abre el diálogo (no bloquea). Ciérralo con `Navigator.of(context).pop()`.
  static void show(
    BuildContext context,
    ValueNotifier<SelfUpdateUiState> state,
  ) {
    showIosDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return PopScope(
          canPop: false,
          child: ValueListenableBuilder<SelfUpdateUiState>(
            valueListenable: state,
            builder: (ctx, s, _) {
              final failed = s.error != null;
              final String message;
              switch (s.stage) {
                case SelfUpdateStage.downloading:
                  message = l10n.appUpdateDownloading;
                  break;
                case SelfUpdateStage.extracting:
                  message = l10n.devSelfUpdateExtracting;
                  break;
                case SelfUpdateStage.installing:
                  message = l10n.devSelfUpdateInstalling;
                  break;
                case SelfUpdateStage.restarting:
                  message = l10n.devSelfUpdateRestarting;
                  break;
              }
              return IosDialogShell(
                title: failed
                    ? l10n.devSelfUpdateFailed
                    : l10n.devSelfUpdateProgressTitle,
                message: failed ? s.error : message,
                content: failed
                    ? null
                    : IosProgressBar(
                        value: s.stage == SelfUpdateStage.restarting
                            ? null
                            : s.fraction,
                      ),
                actions: [
                  if (failed)
                    IosDialogButton(
                      label: l10n.dialogActionClose,
                      bold: true,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}