// lib/ui/widgets/eco_mode_layer.dart
//
// Envuelve toda la app (MaterialApp.builder). En modo ahorro oculta la interfaz
// con Offstage y silencia sus animaciones con TickerMode (así conserva su estado:
// búsqueda, scroll, selección...) y muestra una pantalla estática y mínima.
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../../services/eco_mode_service.dart';
import '../theme/ios_theme.dart';

class EcoModeLayer extends StatelessWidget {
  const EcoModeLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: EcoModeService.instance.active,
      child: child,
      builder: (context, eco, appChild) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Siempre en la misma posición para no perder el estado de la app.
            Offstage(
              offstage: eco,
              child: TickerMode(enabled: !eco, child: appChild!),
            ),
            if (eco) const Positioned.fill(child: _EcoScreen()),
          ],
        );
      },
    );
  }
}

/// Pantalla estática (sin animaciones, sin imágenes) del modo ahorro.
class _EcoScreen extends StatelessWidget {
  const _EcoScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: IosColors.background,
      child: DragToMoveArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded, size: 44, color: IosColors.green),
                  const SizedBox(height: 16),
                  Text(
                    l10n.ecoModeTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: IosColors.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ecoModeMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: EcoModeService.instance.dismiss,
                    child: Text(
                      l10n.ecoModeShowApp,
                      style: TextStyle(color: IosColors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
