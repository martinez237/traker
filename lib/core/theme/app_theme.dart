import 'package:flutter/material.dart';

class AppTheme {
  static const seed = Color(0xFF4F46E5);

  static ThemeData _base(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      sliderTheme: const SliderThemeData(
        showValueIndicator: ShowValueIndicator.never,
      ),
    );
  }

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);
}