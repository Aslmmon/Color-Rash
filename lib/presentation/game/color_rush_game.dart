import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
    required this.notifier, // Add notifier
  });

  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    final screenWidth = size.x;
    final catchZoneY = size.y - 200; //

    add(
      RectangleComponent(
        position: Vector2(0, catchZoneY),
        size: Vector2(screenWidth, 2.5), // A thin line 2 pixels high
        paint: Paint()..color = AppColors.catchZoneLineColor.withOpacity(0.5), // Use AppColors
      ),
    );

    _drawReceivers();
    add(
      TimerComponent(
        period: 2.0,
        repeat: true,
        onTick: () {
          // Clear old objects when the game is not playing
          if (status != GameStatus.playing) {
            children.whereType<FallingObject>().forEach(
              (obj) => obj.removeFromParent(),
            );
            return;
          }
          spawnObject();
        },
      ),
    );
    return super.onLoad();
  }

  // This is the new core logic method!
  void attemptCatch(Color tappedColor) {
    // Find all falling objects on screen
    final fallingObjects = children.whereType<FallingObject>().toList();
    if (fallingObjects.isEmpty) return;

    // Find the one that is lowest on the screen
    fallingObjects.sort((a, b) => b.position.y.compareTo(a.position.y));
    final lowestObject = fallingObjects.first;

    // Define the "catch zone"
    final catchZone = size.y - 200; // The top of our receiver blocks

    // Check if the object is in the zone
    if (lowestObject.position.y > catchZone) {
      // Check if the color matches
      if (lowestObject.color == tappedColor) {
        // Correct tap!
        lowestObject.removeFromParent();
        notifier.incrementScore();
      } else {
        // Wrong tap!
        notifier.endGame();
      }
    }
  }

  void spawnObject() {
    // ... (spawnObject method remains the same)
    final randomX = _random.nextDouble() * size.x;
    final randomColor = gameColors[_random.nextInt(gameColors.length)];
    add(FallingObject(position: Vector2(randomX, 0), color: randomColor));
  }

  void _drawReceivers() {
    // ... (_drawReceivers method remains the same)
    final screenWidth = size.x;
    final screenHeight = size.y;
    final receiverWidth = screenWidth / 4;
    final receiverHeight = 100.0;
    for (var i = 0; i < gameColors.length; i++) {
      final receiver = RectangleComponent(
        position: Vector2(i * receiverWidth, screenHeight - receiverHeight),
        size: Vector2(receiverWidth, receiverHeight),
      )..paint.color = gameColors[i];
      add(receiver);
    }
  }
}
