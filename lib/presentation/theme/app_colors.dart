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

  // Expanded Gradient Palettes for Background (aim for 15+)
  static const List<List<Color>> backgroundGradients = [
    // Ensure you have at least 15 distinct lists here!
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    // 0: Dark Blue/Greenish
    [Color(0xFF4B79A1), Color(0xFF283E51)],
    // 1: Muted Blue/Grey
    [Color(0xFFDA22FF), Color(0xFF9733EE)],
    // 2: Purple
    [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
    // 3: Pink/Blue
    [Color(0xFFFFB347), Color(0xFFFFCC33)],
    // 4: Orange/Yellow (Warm)
    [Color(0xFF00B0FF), Color(0xFF0072FF)],
    // 5: Sky Blue
    [Color(0xFF1D976C), Color(0xFF93F9B9)],
    // 6: Mint Green
    [Color(0xFFB721FF), Color(0xFF21D4FD)],
    // 7: Deep Purple/Cyan
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    // 8: Sunset Orange
    [Color(0xFFE44D26), Color(0xFFF16529)],
    // 9: Fiery Red/Orange
    [Color(0xFF7F00FF), Color(0xFFE100FF)],
    // 10: Violet/Magenta
    [Color(0xFF00F260), Color(0xFF0575E6)],
    // 11: Green/Blue Fresh
    [Color(0xFFF09819), Color(0xFFEDDE5D)],
    // 12: Golden
    [Color(0xFF333333), Color(0xFFDD1818)],
    // 13: Dark Grey/Red
    [Color(0xFF43C6AC), Color(0xFFF8FFAE)],
    // 14: Teal/Light Yellow
    // Add more here to reach your desired number (e.g., 15-20)
  ];
}
