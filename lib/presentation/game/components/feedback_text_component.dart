// lib/presentation/game/components/feedback_text_component.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // For Color and TextStyle

class FeedbackTextComponent extends TextComponent {
  final double _travelSpeed = -50; // Pixels per second upwards
  final double _fadeDuration = 0.5; // Seconds for fading out

  // Tracks elapsed time for fading
  double _elapsedTime = 0;
  Color _initialColor; // Store initial color to manage opacity

  FeedbackTextComponent({
    required String text,
    required Vector2 position,
    required Color color,
    double? lifeSpan, // Optional: if you want a fixed lifespan
  }) : _initialColor = color,
       super(
         text: text,
         position: position,
         anchor: Anchor.center, // Center the text on its position
         textRenderer: TextPaint(
           style: TextStyle(
             fontSize: 20.0,
             color: color,
             fontWeight: FontWeight.bold,
             // You might want to use GoogleFonts here if you did for AppTheme
             // For now, keeping it simple to avoid extra dependencies for this small component.
             shadows: [
               Shadow(
                 blurRadius: 5.0,
                 color: Colors.black.withOpacity(0.5),
                 offset: const Offset(1, 1),
               ),
             ],
           ),
         ),
       );

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;

    // Move upwards
    position.y += _travelSpeed * dt;

    // Fade out
    final opacity = 1.0 - (_elapsedTime / _fadeDuration);
    if (opacity <= 0) {
      removeFromParent(); // Remove when fully faded
    } else {
      textRenderer = TextPaint(
        style: TextStyle(
          fontSize: 20.0,
          color: _initialColor.withOpacity(opacity.clamp(0.0, 1.0)),
          // Apply opacity to the base color
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 5.0,
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
    }
  }
}
