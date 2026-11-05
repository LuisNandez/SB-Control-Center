import 'package:flutter/material.dart';

/// A null background opts out (dark themes keep the author's exact colors).
/// Darkens only text below the target contrast, retaining its hue.
Color readableDescriptionColor(Color color, Color? background) {
  if (background == null) return color;

  double contrast(Color foreground) {
    final visible = Color.alphaBlend(foreground, background);
    final a = visible.computeLuminance();
    final b = background.computeLuminance();
    return ((a > b ? a : b) + 0.05) / ((a > b ? b : a) + 0.05);
  }

  const target = 4.5;
  if (contrast(color) >= target) return color;

  // Find the smallest darkening that meets the target. Blending toward opaque
  // black also makes transparent light text legible on the actual surface.
  if (contrast(Colors.black) < target) return Colors.black;
  double low = 0;
  double high = 1;
  for (var i = 0; i < 16; i++) {
    final mid = (low + high) / 2;
    if (contrast(Color.lerp(color, Colors.black, mid)!) >= target) {
      high = mid;
    } else {
      low = mid;
    }
  }
  return Color.lerp(color, Colors.black, high)!;
}
