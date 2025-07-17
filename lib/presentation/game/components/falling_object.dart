import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../color_rush_game.dart';

class FallingObject extends CircleComponent
    with HasGameReference<ColorRushGame> {
  final double speed = 150; // Pixels per second
  final Color color; // <-- The new property to store the color

  FallingObject({required super.position, required this.color})
    : super(radius: 30.0, paint: Paint()..color = color);

  @override
  void update(double dt) {
    super.update(dt);
    // Move the circle downwards
    position.y += speed * dt;

    // Remove the component if it goes off screen
    if (position.y > game.size.y) {
      game.notifier.endGame();
      removeFromParent();
    }
  }
}
