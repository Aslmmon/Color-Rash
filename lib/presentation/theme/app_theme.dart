// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure you have google_fonts in pubspec.yaml
import 'app_colors.dart'; // Import your colors

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // Define primary colors
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      hintColor: AppColors.accentColor,
      // Used for accent color in some widgets
      scaffoldBackgroundColor: AppColors.backgroundColor,
      canvasColor: AppColors.surfaceColor,
      // Often used for Card, Dialog backgrounds

      // Define text themes
      // Using GoogleFonts for a custom font, ensure it's added in pubspec.yaml
      textTheme: GoogleFonts.pressStart2pTextTheme(
        // Example: A pixel art font
        ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.primaryTextColor,
          displayColor: AppColors.primaryTextColor,
        ),
      ),
      // Define button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.buttonTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // Add other themes like AppBarTheme, CardTheme, etc., as needed
    );
  }

  // You can add a lightTheme here if you plan to support it later
  // static ThemeData get lightTheme { ... }
}
