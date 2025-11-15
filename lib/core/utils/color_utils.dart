import 'package:flutter/material.dart';

class ColorUtils {
  static Color getContrastingTextColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color getContrastingTextColorWithThreshold(
    Color backgroundColor, {
    double threshold = 0.5,
  }) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > threshold ? Colors.black : Colors.white;
  }

  static Color getAccessibleTextColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();

    const double lightThreshold = 0.6;

    return luminance > lightThreshold ? Colors.black : Colors.white;
  }
}
