import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const background = Color(0xFF070B11);
  static const backgroundRaised = Color(0xFF0D131B);
  static const panel = Color(0xFF121922);
  static const panelRaised = Color(0xFF182231);
  static const accent = Color(0xFFE85D04);
  static const accentBright = Color(0xFFFF8A00);
  static const accentSoft = Color(0xFFFFD29A);
  static const textPrimary = Color(0xFFF5F7FB);
  static const textMuted = Color(0xFF9AA6B8);
  static const border = Color(0xFF293446);
  static const error = Color(0xFFFF6B6B);
  static const success = Color(0xFF63D2A1);

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: accent,
      secondary: accentSoft,
      surface: panel,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: panelRaised,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.soraTextTheme(),
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme)
        .apply(bodyColor: textPrimary, displayColor: textPrimary)
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 46,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.6,
            color: textPrimary,
          ),
          headlineLarge: GoogleFonts.spaceGrotesk(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.sora(
            fontSize: 15,
            height: 1.5,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.sora(
            fontSize: 13,
            height: 1.55,
            color: textMuted,
          ),
          labelLarge: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          labelMedium: GoogleFonts.sora(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: textMuted,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundRaised,
        selectedColor: accent.withValues(alpha: 0.18),
        disabledColor: panel,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium!,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}
