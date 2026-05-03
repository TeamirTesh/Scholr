import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF4F8EF7);
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1C1F2E);
  static const Color accent = Color(0xFF7C5CFC);
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF8B90A7);

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
