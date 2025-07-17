// lib/presentation/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Core Colors
  static const Color primaryColor = Color(0xFF6200EE); // Example: Purple
  static const Color accentColor = Color(0xFF03DAC6); // Example: Teal
  static const Color backgroundColor = Color(0xFF121212); // Dark background
  static const Color surfaceColor = Color(
    0xFF1E1E1E,
  ); // Slightly lighter dark surface

  // Text Colors
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  static const Color disabledTextColor = Colors.white38;

  // Game Specific Colors
  static const Color correctTapColor = Colors.greenAccent;
  static const Color incorrectTapColor = Colors.redAccent;
  static const Color gameOverOverlayColor =
      Colors.black; // For the Game Over overlay
  static const Color catchZoneLineColor =
      Colors.red; // For the line where circles are caught

  // Button Colors
  static const Color buttonColor = Colors.blueAccent;
  static const Color buttonTextColor = Colors.white;
  static const Color buttonBorderColor = Colors.white; // For the color buttons
}
