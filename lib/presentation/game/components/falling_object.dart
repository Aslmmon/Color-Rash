import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../../domain/game_constants.dart';
import '../color_rush_game.dart';

class FallingObject extends CircleComponent
    with HasGameReference<ColorRushGame> {
  // Define constant for speed
  final double speedMultiplier; // <--- NEW PROPERTY

  final Color color;

  FallingObject({
    required super.position,
    required this.color,
    this.speedMultiplier = 1.0, // <--- NEW: Default to 1.0 if not provided
  }) : super(radius: AppConstants.kObjectRadius, paint: Paint()..color = color);

  @override
  Future<void> onLoad() async {
    // <--- NEW: Add a ParticleSystemComponent as a child --->
    add(
      ParticleSystemComponent(
        // Emitter is positioned at the center of the FallingObject
        position: Vector2.zero(),
        particle: Particle.generate(
          count: 50, // Adjust number of particles
          lifespan: 1, // Adjust lifespan for tail length
          generator: (i) {

            return AcceleratedParticle(
              speed: Vector2(0, 20), // Increased downward speed to create more lag
              // Emit particles slightly downwards
              acceleration: Vector2(0, 80), // Slight downward acceleration
              // Give them a slight downward acceleration
              child: CircleParticle(
                radius: 2, // Smaller radius for the tail balls
                paint: Paint()..color = color, // Fade out the tail
              ),
            );
          },

        ),
        // Emitter rate: controls how fast new particles are emitted
        // A low rate for a smooth tail. Set to 0 to emit all at once.
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Calculate effective speed


    if (game.notifier.state.isPaused) {
      return; // Don't move if game is paused
    }

    final double effectiveSpeed =
        AppConstants.kObjectBaseSpeed * speedMultiplier; // <--- MODIFIED

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
