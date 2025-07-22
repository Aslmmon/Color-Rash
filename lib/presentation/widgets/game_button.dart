// lib/presentation/widgets/game_button.dart
import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart'; // <--- Import AnimatedButton

// This GameButton no longer needs to be a StatefulWidget as it manages no internal animation state.
// It simply configures and wraps an AnimatedButton.
class GameButton extends StatelessWidget {
  // <--- CHANGE to StatelessWidget
  final VoidCallback onPressed;
  final Widget child; // <--- NEW: Direct child for the button content
  final double width;
  final double height;
  final Color color; // <--- NEW: Background color for AnimatedButton
  final double borderRadius; // <--- NEW: Border radius for AnimatedButton
  final ShadowDegree shadowDegree; // <--- NEW: Shadow degree for AnimatedButton
  final Duration
  duration; // <--- NEW: Duration for AnimatedButton's internal animation

  const GameButton({
    super.key,
    required this.onPressed,
    required this.child, // Child is now required
    this.width = 45.0,
    this.height = 45.0,
    this.color = Colors.blueAccent, // Default button color
    this.borderRadius = 15.0, // Default border radius

    this.shadowDegree = ShadowDegree.light, // Default shadow
    this.duration = const Duration(
      milliseconds: 85,
    ), // Default animation duration
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      width: width,
      height: height,
      color: color,
      borderRadius: borderRadius,
      shadowDegree: shadowDegree,
      duration: 15,
      enabled: true,
      // Assuming enabled by default
      disabledColor: Colors.grey,
      // Default disabled color
      child: child, // Pass the child directly
    );
  }
}
