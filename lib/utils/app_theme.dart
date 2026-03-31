import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Brown Shades
  static const Color primary = Color(0xFF8B5E3C);
  static const Color primaryLight = Color(0xFFA0785A);
  static const Color primaryLighter = Color(0xFFBE9880);
  static const Color primaryPale = Color(0xFFE8D5C4);
  static const Color primaryUltraLight = Color(0xFFF5EDE6);

  // Accent
  static const Color accent = Color(0xFFD4956A);
  static const Color accentLight = Color(0xFFEDB98A);

  // Neutrals
  static const Color background = Color(0xFFFDF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBrown = Color(0xFFF0E6DC);

  // Text
  static const Color textDark = Color(0xFF2C1810);
  static const Color textMedium = Color(0xFF6B4226);
  static const Color textLight = Color(0xFF9E7B65);
  static const Color textHint = Color(0xFFBCA99A);

  // Status
  static const Color success = Color(0xFF6B8F5E);
  static const Color warning = Color(0xFFD4956A);
  static const Color error = Color(0xFFB85C4A);
  static const Color info = Color(0xFF5A7A8F);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFB85C4A);
  static const Color priorityMedium = Color(0xFFD4956A);
  static const Color priorityLow = Color(0xFF6B8F5E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5E3C), Color(0xFFA0785A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFDF8F5), Color(0xFFF0E6DC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5EDE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: AppColors.textMedium,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: AppColors.textMedium,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: AppColors.textLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBrown,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.lato(color: AppColors.textHint),
        labelStyle: GoogleFonts.lato(color: AppColors.textMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
  color: AppColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),
    );
  }
}
