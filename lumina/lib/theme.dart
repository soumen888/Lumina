import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF060E20);
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  
  static const Color primary = Color(0xFFC0C1FF);
  static const Color secondary = Color(0xFF4EDEA3); // Mint
  static const Color tertiary = Color(0xFFFFB2B7); // Rose
  static const Color error = Color(0xFFFFB4AB);
  static const Color accent = Color(0xFF6366F1); // Indigo from mockup

  static const Color onBackground = Color(0xFFDAE2FD);
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFC7C4D7);
  
  static const Color surfaceContainerHigh = Color(0xFF222A3D);
  static const Color surfaceContainerLowest = Color(0xFF060E20);
  static const Color outline = Color(0xFF908FA0);
  static const Color inversePrimary = Color(0xFF494BD6);
  static const Color onPrimaryContainer = Color(0xFF0D0096);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        surface: surface,
        background: background,
        onBackground: onBackground,
        onSurface: onBackground,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sora(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.96,
          color: onBackground,
        ),
        displayMedium: GoogleFonts.sora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          color: onBackground,
        ),
        headlineMedium: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        headlineSmall: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        bodyLarge: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: onBackground,
        ),
        bodyMedium: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onBackground,
        ),
        bodySmall: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onBackground,
        ),
        labelMedium: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: onBackground,
        ),
      ),
    );
  }
}
