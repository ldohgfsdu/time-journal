import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Claude-inspired warm, low-contrast, editorial palette
  static const Color background = Color(0xFFFAF8F3); // warm ivory / paper
  static const Color paper = Color(0xFFFAF8F3);
  static const Color paperDeep = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFFFEFA); // soft warm white
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2C2A27); // deep ink, not pure black
  static const Color inkMuted = Color(0xFF5C5750);
  static const Color inkFaint = Color(0xFF8A837A);
  static const Color subtitle = Color(0xFF6B665E);
  static const Color clay = Color(0xFFD17B5F); // soft clay / muted coral accent
  static const Color tomato = Color(0xFFD17B5F); // alias for backward compat in accents
  static const Color tomatoSoft = Color(0xFFF5E6DF);
  static const Color sleepBlue = Color(0xFF5B7A96);
  static const Color sleepMist = Color(0xFFE8EEF3);
  static const Color tagBg = Color(0xFFF5F0E8);
  static const Color danger = Color(0xFFB85C50);

  static const double cardRadius = 20; // larger rounded surfaces
  static const double pagePadding = 16;
  static const Color rule = Color(0xFFEDE6DC); // much weaker divider
  static const Color fold = Color(0xFFD4C8B5);

  static BoxDecoration cardDecoration({double? radius}) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius ?? cardRadius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 10,
          offset: Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: clay,
      onPrimary: Colors.white,
      secondary: sleepBlue,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: ink,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(color: rule, thickness: 0.5, space: 8),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: ink, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: subtitle, fontSize: 13, height: 1.4),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelLarge: TextStyle(
          color: clay,
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
          borderSide: BorderSide(color: rule, width: 0.75),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: clay, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return clay;
          return Colors.transparent;
        }),
        side: const BorderSide(color: inkFaint, width: 1.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: clay,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: clay,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}