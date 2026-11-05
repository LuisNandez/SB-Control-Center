// Shared visual tokens for the Minimalist desktop layout.
import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'ios_theme.dart';

class MinimalStyle {
  MinimalStyle._();

  static bool get on => AppLayouts.isMinimal;
  static const double controlRadius = 7;
  static const double cardRadius = 10;
  static const double dialogRadius = 14;
  static const double controlHeight = 34;
  static const duration = Duration(milliseconds: 160);

  // Quiet boundaries separate surfaces; controls have a stronger outline.
  static Color get outline => IosColors.overlay(
    IosColors.palette.isDark ? 0x26 : 0x22,
  );
  static Color get controlOutline => IosColors.overlay(
    IosColors.palette.isDark ? 0x55 : 0x48,
  );
  static Color get hoverFill => IosColors.overlay(0x0C);
  static Color get selectedFill =>
      Color.alphaBlend(IosColors.blue.withOpacity(0.10), IosColors.card);
  static Color get mutedFill =>
      Color.alphaBlend(IosColors.overlay(0x09), IosColors.card);

  static Color foregroundFor(Color background) =>
      background.computeLuminance() > 0.179 ? Colors.black : Colors.white;

  static BoxDecoration panel({
    Color? color,
    double radius = cardRadius,
    bool hovered = false,
  }) => BoxDecoration(
    color: color ?? IosColors.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: hovered ? controlOutline : outline),
  );

  static BoxDecoration field({bool focused = false}) => BoxDecoration(
    color: mutedFill,
    borderRadius: BorderRadius.circular(controlRadius),
    border: Border.all(
      color: focused ? IosColors.blue : controlOutline,
      width: focused ? 1.5 : 1,
    ),
  );

  static BoxDecoration tab({required bool selected, bool hovered = false}) =>
    BoxDecoration(
      color: hovered ? hoverFill : Colors.transparent,
      border: Border(bottom: BorderSide(
        color: selected ? IosColors.blue : Colors.transparent,
        width: 2,
      )),
    );

  /// Focus remains visible even when a control is already selected.
  static ButtonStyle interactionStyle(ButtonStyle base) => base.copyWith(
    animationDuration: duration,
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return Colors.transparent;
      if (states.contains(WidgetState.pressed)) return IosColors.overlay(0x1C);
      if (states.contains(WidgetState.hovered)) return hoverFill;
      return Colors.transparent;
    }),
    side: WidgetStateProperty.resolveWith((states) => BorderSide(
      color: states.contains(WidgetState.focused)
          ? IosColors.blue : Colors.transparent,
      width: 1.5,
    )),
  );
}
