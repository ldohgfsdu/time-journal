import 'package:flutter/material.dart';

class AppTheme {
  static const Color paper = Color(0xFFF5F0E8);
  static const Color ink = Color(0xFF2C2C2C);
  static const Color tomato = Color(0xFFE85D4A);
  static const Color sleepBlue = Color(0xFF4A6FA5);
  static const Color divider = Color(0xFFD8D0C4);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tomato,
        brightness: Brightness.light,
        surface: paper,
      ),
      scaffoldBackgroundColor: paper,
      fontFamily: null,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: tomato.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, color: ink)),
      ),
    );
  }
}
