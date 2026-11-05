import 'package:flutter/material.dart';
import '../theme/app_metrics.dart';
import '../theme/ios_theme.dart';

/// Barra de progreso fina con extremos redondeados (como en iOS / macOS).
/// Con [value] == null se muestra indeterminada.
class IosProgressBar extends StatelessWidget {
  const IosProgressBar({
    super.key,
    this.value,
    this.color,
    this.height = 4,
  });

  final double? value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Material: todas las barras de progreso miden lo mismo (6 px).
    final double h = AppMetrics.u ? 6 : height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: LinearProgressIndicator(
        value: value,
        minHeight: h,
        backgroundColor: IosColors.overlay(0x1F),
        valueColor: AlwaysStoppedAnimation<Color>(color ?? IosColors.blue),
      ),
    );
  }
}