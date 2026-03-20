import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF5A52E0);
  static const primaryLight = Color(0xFF8B85FF);

  // Accents
  static const secondary = Color(0xFFFF6584);
  static const accent = Color(0xFF43E97B);
  static const accentOrange = Color(0xFFFF9A3C);
  static const accentCyan = Color(0xFF38F9D7);

  // Dark theme backgrounds
  static const darkBg = Color(0xFF0F0F1A);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkCard = Color(0xFF16213E);
  static const darkElevated = Color(0xFF1F2B4D);
  static const darkBorder = Color(0xFF2A2D5E);

  // Light theme backgrounds
  static const lightBg = Color(0xFFF0F2FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E3FF);

  // Text
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFA0A8D0);
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B7280);

  // Priority
  static const priorityHigh = Color(0xFFFF4D6D);
  static const priorityMedium = Color(0xFFFF9A3C);
  static const priorityLow = Color(0xFF43E97B);

  // Chart colors
  static const List<Color> chartColors = [
    primary, secondary, accent, accentOrange, accentCyan,
    Color(0xFFF093FB), Color(0xFF4FACFE), Color(0xFFFEE140),
  ];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBg,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.outfit(
            fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleLarge: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleMedium: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        bodyLarge: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark),
        bodyMedium: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondaryDark),
        bodySmall: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondaryDark),
        labelLarge: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: AppColors.textSecondaryDark),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondaryDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkElevated,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get lightTheme {
    return darkTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBg,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
    );
  }
}
