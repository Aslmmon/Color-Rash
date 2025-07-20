import 'dart:math';
import 'dart:ui'; // Not strictly needed unless you're doing custom drawing with dart:ui. Keep for now if Flutter/Flame implicitly uses it.
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart'; // Needed for Color, even in Flame components
import '../../core/audio_player.dart';
import '../../domain/game_constants.dart';
import '../../domain/game_provider.dart';
import '../../domain/game_state.dart';
import '../theme/app_colors.dart';
import 'components/falling_object.dart';
import 'components/feedback_text_component.dart';

class ColorRushGame extends FlameGame {
  GameStatus status;
  final List<Color> gameColors;
  final GameNotifier notifier; // Reference to our brain
  final IAudioPlayer audioPlayer; // <--- NEW: Accept the audio player interface
  late final RectangleComponent _catchZoneLineComponent;
  static const double _linePulseRange =
      50.0; // Distance from line to trigger pulse
  static const double _linePulseDuration = 0.3; // How fast the pulse happens
  double _linePulseTimer = 0.0;
  bool _isLinePulsing = false;

  ColorRushGame({
    required this.status,
    required this.gameColors,
    required this.notifier,
    required this.audioPlayer, // <--- NEW: Require audioPlayer
  });

  final Random _random = Random();

  double _spawnTimer = 0.0; // Timer to track when to spawn next object

  @override
  Color backgroundColor() => Colors.transparent; // <--- ADD THIS LINE

  @override
  Future<void> onLoad() async {
    final screenWidth = size.x;
    final catchZoneY = size.y - kCatchZoneHeight;
    _catchZoneLineComponent = RectangleComponent(
      // <--- Assign to the new field
      position: Vector2(0, catchZoneY),
      size: Vector2(screenWidth, kCatchZoneLineWidth),
      paint: Paint()..color = AppColors.catchZoneLineColor.withOpacity(0.5),
    );
    add(_catchZoneLineComponent); // Add the component

    _drawReceivers();

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
      _catchZoneLineComponent.paint.color = AppColors.catchZoneLineColor
          .withOpacity(0.5);
      _isLinePulsing = false;
      _linePulseTimer = 0.0;
      return;
    }

    _spawnTimer += dt;
    // Check if enough time has passed based on the current spawn interval from GameNotifier
    if (_spawnTimer >= notifier.state.currentSpawnInterval) {
      spawnObject();
      _spawnTimer = 0.0; // Reset timer for the next spawn
    }
    _updateCatchZoneLine(dt);
  }

  void _updateCatchZoneLine(double dt) {
    bool objectInZone = false;
    final catchZoneTop = size.y - kCatchZoneHeight;

    // Check if any falling object is near the catch zone
    for (final obj in children.whereType<FallingObject>()) {
      if (obj.position.y + obj.radius > catchZoneTop - _linePulseRange &&
          obj.position.y - obj.radius < catchZoneTop + kCatchZoneLineWidth) {
        objectInZone = true;
        break;
      }
    }

    if (objectInZone) {
      _isLinePulsing = true;
      _linePulseTimer += dt;
      final double cycle = (_linePulseTimer / _linePulseDuration) % 2;
      final double intensity =
          0.5 +
          (0.5 * (1 - (cycle - 1).abs())); // Pulse from 0.5 to 1.0 opacity

      _catchZoneLineComponent.paint.color = AppColors.accentColor.withOpacity(
        intensity,
      ); // Pulse with accent color
    } else {
      if (_isLinePulsing) {
        // Fade out pulse effect
        _linePulseTimer -= dt * 2; // Fade out faster
        final double opacity = (_linePulseTimer / _linePulseDuration).clamp(
          0.0,
          1.0,
        );
        _catchZoneLineComponent.paint.color = AppColors.accentColor.withOpacity(
          opacity,
        );
        if (opacity <= 0.0) {
          _isLinePulsing = false;
          _catchZoneLineComponent.paint.color = AppColors.catchZoneLineColor
              .withOpacity(0.5); // Reset to default
        }
      }
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
    final catchZone = size.y - kCatchZoneHeight;

    // Check if the object is in the zone
    if (lowestObject.position.y > catchZone) {
      if (lowestObject.color == tappedColor) {
        // Correct tap!
        // --- Add particle effect here ---
        add(
          ParticleSystemComponent(
            position: lowestObject.position, // Position at the tapped object
            particle: Particle.generate(
              count: kParticleCount, // Number of particles
              lifespan: kParticleLifespan, // How long each particle lives
              generator:
                  (i) => AcceleratedParticle(
                    speed:
                        Vector2.random() * kParticleSpeed -
                        Vector2.all(kParticleSpeed / 2),
                    // Random direction and speed
                    acceleration: Vector2(0, kParticleAccelerationY),
                    // Gravity-like fall
                    child: CircleParticle(
                      radius: kParticleRadius,
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
        audioPlayer.playSfx(
          'correct_tap.mp3',
        ); // <--- MODIFIED: Use the interface

        // <--- NEW: Add "+1" feedback
        add(
          FeedbackTextComponent(
            text: '+1',
            position: lowestObject.position - Vector2(0, kObjectRadius),
            // Above the object
            color: AppColors.correctTapColor,
          ),
        );
      } else {
        // Play correct sound
        audioPlayer.playSfx(
          'error_tap.mp3',
        ); // <--- MODIFIED: Use the interface
        notifier.endGame();

        add(
          FeedbackTextComponent(
            text: 'Miss!',
            position: lowestObject.position - Vector2(0, kObjectRadius),
            // Above the object
            color: AppColors.incorrectTapColor,
          ),
        );
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
    final receiverHeight = kReceiverHeight;

    for (var i = 0; i < gameColors.length; i++) {
      final receiver = RectangleComponent(
        position: Vector2(i * receiverWidth, screenHeight - receiverHeight),
        size: Vector2(receiverWidth, receiverHeight),
      )..paint.color = gameColors[i];
      add(receiver);
    }
  }
}
