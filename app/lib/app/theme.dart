import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Claude / Anthropic design language for mobile (see repo DESIGN.md +
/// .grok/skills/claude-design). Cream canvas + coral + literary type.
class AppTheme {
  // ── Surfaces (trinity: canvas / card / dark) ──
  static const Color canvas = Color(0xFFFAF9F5);
  static const Color surfaceSoft = Color(0xFFF5F0E8);
  static const Color surfaceCard = Color(0xFFEFE9DE);
  static const Color surfaceCreamStrong = Color(0xFFE8E0D2);
  static const Color hairline = Color(0xFFE6DFD8);
  static const Color hairlineSoft = Color(0xFFEBE6DF);

  // ── Brand ──
  static const Color primary = Color(0xFFCC785C);
  static const Color primaryActive = Color(0xFFA9583E);
  static const Color primaryDisabled = Color(0xFFE6DFD8);
  static const Color primarySoft = Color(0xFFF3E6DF);

  // ── Text ──
  static const Color ink = Color(0xFF141413);
  static const Color body = Color(0xFF3D3D3A);
  static const Color bodyStrong = Color(0xFF252523);
  static const Color muted = Color(0xFF6C6A64);
  static const Color mutedSoft = Color(0xFF8E8B82);

  // ── Accents (scarce) ──
  static const Color accentTeal = Color(0xFF5DB8A6);
  static const Color accentAmber = Color(0xFFE8A55A);
  static const Color success = Color(0xFF5DB872);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFC64545);

  static const Color surfaceDark = Color(0xFF181715);
  static const Color surfaceDarkElevated = Color(0xFF252320);
  static const Color onDark = Color(0xFFFAF9F5);
  static const Color onDarkSoft = Color(0xFFA09D96);

  // ── Legacy aliases ──
  static const Color paper = canvas;
  static const Color paperDeep = surfaceSoft;
  static const Color card = Color(0xFFFFFCF7);
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

  // ── Radius ──
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusPill = 999;
  static const double cardRadius = radiusLg;
  static const double pagePadding = 16;

  // ── Type helpers ──
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w500,
    Color color = ink,
    double height = 1.15,
    double letterSpacing = -0.4,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = body,
    double height = 1.5,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static ThemeData light() {
    final inter = GoogleFonts.interTextTheme();
    final cormorant = GoogleFonts.cormorantGaramondTextTheme();

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

    final textTheme = inter.copyWith(
      displayLarge: cormorant.displayLarge?.copyWith(
        color: ink,
        fontSize: 34,
        fontWeight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.8,
      ),
      displayMedium: cormorant.displayMedium?.copyWith(
        color: ink,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displaySmall: cormorant.displaySmall?.copyWith(
        color: ink,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      headlineMedium: cormorant.headlineMedium?.copyWith(
        color: ink,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -0.25,
      ),
      headlineSmall: cormorant.headlineSmall?.copyWith(
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        color: ink,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: -0.1,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        color: ink,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: body,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: body,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        color: mutedSoft,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: hairlineSoft,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: hairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceCard,
        contentTextStyle: GoogleFonts.inter(
          color: ink,
          fontSize: 14,
          height: 1.4,
        ),
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
        titleTextStyle: GoogleFonts.inter(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w500,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        hintStyle: GoogleFonts.inter(
          color: mutedSoft,
          fontSize: 15,
          height: 1.4,
        ),
        labelStyle: GoogleFonts.inter(color: muted, fontSize: 13),
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
        labelStyle: GoogleFonts.inter(
          color: ink,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
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
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
