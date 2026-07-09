import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visual tokens aligned with root `DESIGN.md` (Claude / Anthropic warm canvas).
/// See https://github.com/VoltAgent/awesome-design-md design-md/claude
class AppTheme {
  // ── Claude DESIGN.md colors ──
  static const Color canvas = Color(0xFFFAF9F5);
  static const Color surfaceSoft = Color(0xFFF5F0E8);
  static const Color surfaceCard = Color(0xFFEFE9DE);
  static const Color surfaceCreamStrong = Color(0xFFE8E0D2);
  static const Color hairline = Color(0xFFE6DFD8);
  static const Color hairlineSoft = Color(0xFFEBE6DF);

  static const Color primary = Color(0xFFCC785C);
  static const Color primaryActive = Color(0xFFA9583E);
  static const Color primaryDisabled = Color(0xFFE6DFD8);
  static const Color primarySoft = Color(0xFFF3E6DF);

  static const Color ink = Color(0xFF141413);
  static const Color body = Color(0xFF3D3D3A);
  static const Color bodyStrong = Color(0xFF252523);
  static const Color muted = Color(0xFF6C6A64);
  static const Color mutedSoft = Color(0xFF8E8B82);

  static const Color accentTeal = Color(0xFF5DB8A6);
  static const Color accentAmber = Color(0xFFE8A55A);
  static const Color success = Color(0xFF5DB872);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFC64545);

  static const Color surfaceDark = Color(0xFF181715);
  static const Color onDark = Color(0xFFFAF9F5);

  // ── Legacy aliases (keep call sites working) ──
  static const Color paper = canvas;
  static const Color paperDeep = surfaceSoft;
  static const Color card = Color(0xFFFFFCF7); // slightly lifted cream card
  static const Color inkMuted = muted;
  static const Color inkFaint = mutedSoft;
  static const Color subtitle = body;
  static const Color tomato = primary;
  static const Color tomatoSoft = primarySoft;
  static const Color sleepBlue = accentTeal;
  static const Color sleepMist = Color(0xFFE8F2F0);
  static const Color tagBg = surfaceSoft;
  static const Color danger = error;
  static const Color rule = hairline;
  static const Color fold = surfaceCreamStrong;
  static const Color divider = hairlineSoft;
  static const Color barrier = Color(0x33000000);

  // ── Radius (DESIGN.md rounded.*) ──
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusPill = 999;
  static const double cardRadius = radiusXl;
  static const double pagePadding = 16;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: accentTeal,
      onSecondary: Colors.white,
      surface: canvas,
      onSurface: ink,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: hairlineSoft,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: hairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceCard,
        contentTextStyle: const TextStyle(color: ink, fontSize: 14, height: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        dialBackgroundColor: surfaceSoft,
        dialHandColor: primary,
        dialTextColor: ink,
        hourMinuteTextColor: ink,
        dayPeriodTextColor: ink,
        entryModeIconColor: muted,
        hourMinuteColor: primarySoft,
        dayPeriodColor: primarySoft,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: ink,
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.35,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: body,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          color: body,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodySmall: TextStyle(
          color: muted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          color: primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
        labelMedium: TextStyle(
          color: muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        hintStyle: const TextStyle(color: mutedSoft, fontSize: 15, height: 1.4),
        labelStyle: const TextStyle(color: muted, fontSize: 13),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: hairline, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: mutedSoft, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXs),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        selectedColor: primarySoft,
        labelStyle: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w500),
        side: const BorderSide(color: hairline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: hairline),
          backgroundColor: canvas,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryDisabled,
          disabledForegroundColor: muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: hairline,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: hairline,
      ),
    );
  }
}
