import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color paper = Color(0xFFFAF6EF);
  static const Color paperDeep = Color(0xFFF0E8DA);
  static const Color card = Color(0xFFFFFCF7);
  static const Color ink = Color(0xFF1E1E1E);
  static const Color inkMuted = Color(0xFF5A554E);
  static const Color inkFaint = Color(0xFF8A837A);
  static const Color subtitle = Color(0xFF4F4A44);
  static const Color tomato = Color(0xFFC45C4A);
  static const Color tomatoSoft = Color(0xFFF3DDD8);
  static const Color sleepBlue = Color(0xFF5B7A96);
  static const Color sleepMist = Color(0xFFE8EEF3);
  static const Color tagBg = Color(0xFFF0EBE3);
  static const Color danger = Color(0xFFB85C50);

  static const double cardRadius = 16;
  static const double pagePadding = 16;
  static const Color rule = Color(0xFFE3D9C8);
  static const Color fold = Color(0xFFD4C8B5);
  static const Color divider = Color(0xFFEDE6DB);
  static const Color barrier = Color(0x33000000);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: tomato,
      onPrimary: Colors.white,
      secondary: sleepBlue,
      onSecondary: Colors.white,
      surface: paper,
      onSurface: ink,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: const TextStyle(color: ink, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        dialBackgroundColor: card,
        dialHandColor: tomato,
        dialTextColor: ink,
        hourMinuteTextColor: ink,
        dayPeriodTextColor: ink,
        entryModeIconColor: inkMuted,
        hourMinuteColor: tomatoSoft,
        dayPeriodColor: tomatoSoft,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: ink, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: subtitle, fontSize: 13, height: 1.4),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelLarge: TextStyle(
          color: tomato,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        hintStyle: const TextStyle(color: inkFaint, fontSize: 15),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: rule, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: tomato, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tomato;
          return Colors.transparent;
        }),
        side: const BorderSide(color: inkFaint, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tomato,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tomato,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}