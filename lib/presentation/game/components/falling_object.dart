import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../color_rush_game.dart';

class FallingObject extends CircleComponent
    with HasGameReference<ColorRushGame> {
  // Define constant for speed
  // This makes the speed easily adjustable and discoverable.
  static const double _baseSpeed = 150; // Pixels per second
  static const double _objectRadius = 30.0; // The radius of the circle
  final double speedMultiplier; // <--- NEW PROPERTY

  final Color color;

  FallingObject({
    required super.position,
    required this.color,
    this.speedMultiplier = 1.0, // <--- NEW: Default to 1.0 if not provided
  })
    : super(radius: _objectRadius, paint: Paint()..color = color);

  @override
  void update(double dt) {
    super.update(dt);
    // Calculate effective speed
    final double effectiveSpeed = _baseSpeed * speedMultiplier; // <--- MODIFIED

    // Move the circle downwards using the constant speed
    position.y += effectiveSpeed * dt;

    // Remove the component if it goes off screen
    // This logic is good, it correctly triggers endGame via the notifier
    // when an object is missed.
    if (position.y > game.size.y) {
      game.notifier.endGame();
      removeFromParent();
    }
  }
}
