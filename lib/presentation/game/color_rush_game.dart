import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../../core/audio_player.dart';
import '../../domain/game_constants.dart';
import '../../domain/game_notifier.dart';
import '../../domain/game_state.dart';
import '../theme/app_colors.dart';
import 'components/falling_object.dart';
import 'components/feedback_text_component.dart';

class ColorRushGame extends FlameGame {
  GameStatus status;
  final List<Color> gameColors;
  final GameNotifier notifier;
  final IAudioPlayer audioPlayer;
  late AudioPool _correctTapSoundPool; // <--- NEW
  late AudioPool _errorTapSoundPool; // <--- NEW
  late final RectangleComponent _catchZoneLineComponent;
  static const double _linePulseRange = 50.0;
  static const double _linePulseDuration = 0.3;

  double _linePulseTimer = 0.0;
  bool _isLinePulsing = false;

  ColorRushGame({
    required this.status,
    required this.gameColors,
    required this.notifier,
    required this.audioPlayer,
  });

  final Random _random = Random();
  double _spawnTimer = 0.0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    _initializeGameComponents();
    _drawReceivers();
    await _initializeAudioPools();
    return super.onLoad();
  }

  /// Initializes essential game components on load.
  void _initializeGameComponents() {
    final screenWidth = size.x;
    // final catchZoneY = size.y - AppConstants.kCatchZoneHeight;
    final catchZoneY = size.y * AppConstants.kCatchZoneHeightPercentage;

    _catchZoneLineComponent = RectangleComponent(
      position: Vector2(0, catchZoneY),
      size: Vector2(screenWidth, AppConstants.kCatchZoneLineWidth),
      paint: Paint()..color = AppColors.catchZoneLineColor.withOpacity(0.5),
    );
    add(_catchZoneLineComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (notifier.state.isPaused) {
      return;
    }
    if (status != GameStatus.playing) {
      _handleGameResetAndCleanup(); // <--- NEW: Extracted cleanup logic
      return;
    }

    _handleActiveGameUpdates(dt); // <--- NEW: Extracted active game loop logic
    _updateCatchZoneLine(dt); // Already extracted
  }

  /// Handles cleanup and resets when the game is not in a 'playing' state.
  void _handleGameResetAndCleanup() {
    children.whereType<FallingObject>().forEach(
      (obj) => obj.removeFromParent(),
    );
    _spawnTimer = 0.0;
    _catchZoneLineComponent.paint.color = AppColors.catchZoneLineColor
        .withOpacity(0.5);
    _isLinePulsing = false;
    _linePulseTimer = 0.0;
  }

  /// Manages the continuous updates during active gameplay.
  void _handleActiveGameUpdates(double dt) {
    _spawnTimer += dt;
    if (_spawnTimer >= notifier.state.currentSpawnInterval) {
      spawnObject();
      _spawnTimer = 0.0;
    }
  }

  // _updateCatchZoneLine method remains as is (already extracted)
  void _updateCatchZoneLine(double dt) {
    bool objectInZone = false;
    // final catchZoneTop = size.y - AppConstants.kCatchZoneHeight;
    final catchZoneTop = size.y * AppConstants.kCatchZoneHeightPercentage;

    for (final obj in children.whereType<FallingObject>()) {
      if (obj.position.y + obj.radius > catchZoneTop - _linePulseRange &&
          obj.position.y - obj.radius <
              catchZoneTop + AppConstants.kCatchZoneLineWidth) {
        objectInZone = true;
        break;
      }
    }

    if (objectInZone) {
      _isLinePulsing = true;
      _linePulseTimer += dt;
      final double cycle = (_linePulseTimer / _linePulseDuration) % 2;
      final double intensity = 0.5 + (0.5 * (1 - (cycle - 1).abs()));

      _catchZoneLineComponent.paint.color = AppColors.accentColor.withOpacity(
        intensity,
      );
    } else {
      if (_isLinePulsing) {
        _linePulseTimer -= dt * 2;
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
              .withOpacity(0.5);
        }
      }
    }
  }

  /// Handles player tap interaction with falling objects.
  void attemptCatch(Color tappedColor) {
    if (status != GameStatus.playing) return;

    final fallingObjects = children.whereType<FallingObject>();
    if (fallingObjects.isEmpty) return;

    final lowestObject = fallingObjects.fold<FallingObject?>(null, (
      prev,
      element,
    ) {
      if (prev == null || element.position.y > prev.position.y) {
        return element;
      }
      return prev;
    });

    if (lowestObject == null) return;

    // final catchZone = size.y - AppConstants.kCatchZoneHeight;
    final catchZone = size.y * AppConstants.kCatchZoneHeightPercentage;

    if (lowestObject.position.y + (lowestObject.radius * 2) >= catchZone) {
      if (lowestObject.color == tappedColor) {
        _handleCorrectTap(lowestObject);
      } else {
        _handleIncorrectTap(lowestObject);
      }
    }
  }

  /// Executes actions for a successful tap (score, sound, particles, feedback).
  void _handleCorrectTap(FallingObject tappedObject) {
    add(
      ParticleSystemComponent(
        position: tappedObject.position,
        particle: Particle.generate(
          count: AppConstants.kParticleCount,
          lifespan: AppConstants.kParticleLifespan,
          generator:
              (i) => AcceleratedParticle(
                speed:
                    Vector2.random() * AppConstants.kParticleSpeed -
                    Vector2.all(AppConstants.kParticleSpeed / 2),
                acceleration: Vector2(0, AppConstants.kParticleAccelerationY),
                child: CircleParticle(
                  radius: AppConstants.kParticleRadius,
                  paint: Paint()..color = tappedObject.color,
                ),
              ),
        ),
      ),
    );
    tappedObject.removeFromParent();
    notifier.incrementScore();
    audioPlayer.playSfx(AppAudioPaths.correctTap);
    add(
      FeedbackTextComponent(
        text: '+1',
        position:
            tappedObject.position - Vector2(0, AppConstants.kObjectRadius),
        color: AppColors.correctTapColor,
      ),
    );
  }

  /// Executes actions for an incorrect tap (sound, feedback, game end).
  void _handleIncorrectTap(FallingObject tappedObject) {
    audioPlayer.playSfx(AppAudioPaths.errorTap);
    notifier.endGame();
    add(
      FeedbackTextComponent(
        text: 'Miss!',
        position:
            tappedObject.position - Vector2(0, AppConstants.kObjectRadius),
        color: AppColors.incorrectTapColor,
      ),
    );
    tappedObject.removeFromParent();
  }

  // spawnObject and _drawReceivers methods remain as is (already extracted)
  void spawnObject() {
    // Define the effective width where the object's center can be,
    // ensuring it doesn't go off screen.
    // The range for randomX should be from kObjectRadius to (size.x - kObjectRadius).

    final double minSpawnX = AppConstants.kObjectRadius;
    final double maxSpawnX = size.x - AppConstants.kObjectRadius * 2;
    final double spawnableRange = maxSpawnX - minSpawnX;
    final double randomX = minSpawnX + (_random.nextDouble() * spawnableRange);

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
    final receiverWidth = screenWidth / gameColors.length;
    // final receiverHeight = AppConstants.kReceiverHeight;
    final receiverHeight =
        screenHeight *
        AppConstants
            .kReceiverHeightPercentage; // e.g., 10% of the screen height

    for (var i = 0; i < gameColors.length; i++) {
      final receiver = RectangleComponent(
        position: Vector2(i * receiverWidth, screenHeight - receiverHeight),
        size: Vector2(receiverWidth, receiverHeight),
      )..paint.color = gameColors[i];
      add(receiver);
    }
  }

  Future<void> _initializeAudioPools() async {
    _correctTapSoundPool = await FlameAudio.createPool(
      AppAudioPaths.correctTap,
      minPlayers: AppConstants.minPlayersInAudioPool,
      maxPlayers: AppConstants.maxPlayersInAudioPool,
    );
    _errorTapSoundPool = await FlameAudio.createPool(
      AppAudioPaths.errorTap,
      minPlayers: AppConstants.minPlayersInAudioPool,
      maxPlayers: AppConstants.maxPlayersInAudioPool,
    );
    audioPlayer.registerAudioPools(
      correctTapPool: _correctTapSoundPool,
      errorTapPool: _errorTapSoundPool,
    );
  }

  @override
  void onRemove() {
    audioPlayer.disposeAudioPools();
    super.onRemove();
  }
}
