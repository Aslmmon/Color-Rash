import 'dart:math';
import 'dart:ui'; // Not strictly needed unless you're doing custom drawing with dart:ui. Keep for now if Flutter/Flame implicitly uses it.
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart'; // Needed for Color, even in Flame components

import '../../domain/game_provider.dart';
import '../../domain/game_state.dart';
import '../theme/app_colors.dart';
import 'components/falling_object.dart';

class ColorRushGame extends FlameGame {
  GameStatus status;
  final List<Color> gameColors;
  final GameNotifier notifier; // Reference to our brain

  ColorRushGame({
    required this.status,
    required this.gameColors,
    required this.notifier,
  });

  final Random _random = Random();

  // Define constants for game parameters to make them easily adjustable and readable.
  static const double _catchZoneHeight =
      200; // This was hardcoded in multiple places
  static const double _receiverHeight = 100.0;
  static const double _catchZoneLineWidth = 2.5;
  static const double _objectSpawnPeriod =
      2.0; // The 2.0 period for TimerComponent
  double _spawnTimer = 0.0; // Timer to track when to spawn next object

  @override
  Future<void> onLoad() async {
    final screenWidth = size.x;
    // Use the defined constant
    final catchZoneY = size.y - _catchZoneHeight;

    add(
      RectangleComponent(
        position: Vector2(0, catchZoneY),
        size: Vector2(screenWidth, _catchZoneLineWidth), // Use constant
        paint: Paint()..color = AppColors.catchZoneLineColor.withOpacity(0.5),
      ),
    );

    _drawReceivers();
    // add(
    //   TimerComponent(
    //     period: _objectSpawnPeriod, // Use constant
    //     repeat: true,
    //     onTick: () {
    //       if (status != GameStatus.playing) {
    //         // A more efficient way to remove all children of a specific type
    //         // without creating a new list. `removeWhere` is generally preferred
    //         // for collections if you're modifying them during iteration.
    //         children.whereType<FallingObject>().forEach(
    //           (obj) => obj.removeFromParent(),
    //         );
    //         return;
    //       }
    //       spawnObject();
    //     },
    //   ),
    // );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (status != GameStatus.playing) {
      // Clear objects when not playing
      children.whereType<FallingObject>().forEach(
        (obj) => obj.removeFromParent(),
      );
      _spawnTimer = 0.0; // Reset timer when game is not playing
      return;
    }

    _spawnTimer += dt;
    // Check if enough time has passed based on the current spawn interval from GameNotifier
    if (_spawnTimer >= notifier.state.currentSpawnInterval) {
      spawnObject();
      _spawnTimer = 0.0; // Reset timer for the next spawn
    }
  }

  void attemptCatch(Color tappedColor) {
    // Optimization: Check for game status here too, though UI usually handles it.
    // If a button is tapped while game is not playing, this prevents unnecessary logic.
    if (status != GameStatus.playing) return;

    // Find all falling objects on screen
    // It's generally better to maintain a list of active falling objects
    // in the game class rather than iterating `children` every tap.
    // However, for simple refactor, we can optimize `whereType`.
    // Use `lastWhere` with a check for performance if you only need the lowest.
    final fallingObjects = children.whereType<FallingObject>();
    if (fallingObjects.isEmpty) return;

    // Find the one that is lowest on the screen
    // Using `fold` for a more functional approach to find the max by y-position
    final lowestObject = fallingObjects.fold<FallingObject?>(null, (
      prev,
      element,
    ) {
      if (prev == null || element.position.y > prev.position.y) {
        return element;
      }
      return prev;
    });

    if (lowestObject == null)
      return; // Should not happen if fallingObjects is not empty

    // Use the defined constant
    final catchZone = size.y - _catchZoneHeight;

    // Check if the object is in the zone
    if (lowestObject.position.y > catchZone) {
      if (lowestObject.color == tappedColor) {
        // Correct tap!
        // --- Add particle effect here ---
        add(
          ParticleSystemComponent(
            position: lowestObject.position, // Position at the tapped object
            particle: Particle.generate(
              count: 35, // Number of particles
              lifespan: 0.5, // How long each particle lives
              generator:
                  (i) => AcceleratedParticle(
                    speed: Vector2.random() * 100 - Vector2.all(50),
                    // Random direction and speed
                    acceleration: Vector2(0, 200),
                    // Gravity-like fall
                    child: CircleParticle(
                      radius: 3,
                      paint:
                          Paint()
                            ..color = lowestObject.color, // Color of the object
                    ),
                  ),
            ),
          ),
        );
        // --- End particle effect ---
        lowestObject.removeFromParent();
        notifier.incrementScore();
        FlameAudio.play('correct_tap.mp3'); // Play correct sound
      } else {
        // Play correct sound
        FlameAudio.play('error_Tap.mp3');
        notifier.endGame();
      }
    }
  }

  void spawnObject() {
    final randomX = _random.nextDouble() * size.x;
    final randomColor = gameColors[_random.nextInt(gameColors.length)];
    add(
      FallingObject(
        position: Vector2(randomX, 0),
        color: randomColor,
        speedMultiplier: notifier.state.currentSpeed,
      ),
    );
  }

  void _drawReceivers() {
    final screenWidth = size.x;
    final screenHeight = size.y;
    final receiverWidth =
        screenWidth /
        gameColors.length; // More dynamic, based on gameColors length
    // Use the defined constant
    final receiverHeight = _receiverHeight;

    for (var i = 0; i < gameColors.length; i++) {
      final receiver = RectangleComponent(
        position: Vector2(i * receiverWidth, screenHeight - receiverHeight),
        size: Vector2(receiverWidth, receiverHeight),
      )..paint.color = gameColors[i];
      add(receiver);
    }
  }
}
