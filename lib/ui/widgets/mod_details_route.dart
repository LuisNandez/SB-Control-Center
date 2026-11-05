import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Uses the normal bottom-sheet barrier for dismissal and accessibility.
/// Only the content behind the route is blurred, never the details sheet.
Future<T?> showModDetailsSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool isScrollControlled,
  Color? backgroundColor,
  AnimationStyle? sheetAnimationStyle,
}) {
  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);
  return navigator.push<T>(_ModDetailsRoute<T>(
    builder: builder,
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    modalBarrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
    barrierLabel: localizations.scrimLabel,
    barrierOnTapHint: localizations.scrimOnTapHint(localizations.bottomSheetLabel),
    sheetAnimationStyle: sheetAnimationStyle,
  ));
}

class _ModDetailsRoute<T> extends ModalBottomSheetRoute<T> {
  _ModDetailsRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.backgroundColor,
    super.modalBarrierColor,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.sheetAnimationStyle,
  });

  @override
  Widget buildModalBarrier() {
    return ClipRect(
      child: AnimatedBuilder(
        animation: animation!,
        child: super.buildModalBarrier(),
        builder: (context, child) {
          // Reverse follows the same route animation on every closing path.
          final progress = Curves.easeOut.transform(
            animation!.value.clamp(0.0, 1.0).toDouble(),
          );
          final sigma = offstage ? 0.0 : 4.0 * progress;
          return BackdropFilter(
            enabled: sigma > 0,
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          );
        },
      ),
    );
  }
}
