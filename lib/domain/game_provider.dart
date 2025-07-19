import 'dart:ui';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/score_repository.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  // Good: _scoreRepository is declared as late final and initialized in build.
  late final ScoreRepository _scoreRepository;

  static const int _scoreThresholdForSpeedIncrease = 5;
  static const double _speedIncrementFactor = 0.1;
  static const int _scoreThresholdForIntervalDecrease =
      10; // New threshold for interval decrease
  static const double _intervalDecrementAmount =
      0.1; // Decrease interval by 0.1 seconds
  static const double _minSpawnInterval =
      0.5; // Minimum possible spawn interval to prevent it from becoming too fast

  @override
  GameState build() {
    _scoreRepository = ref.read(scoreRepositoryProvider);
    _loadHighScore();
    return GameState();
  }

  Future<void> _loadHighScore() async {
    final loadedHighScore = await _scoreRepository.getHighScore();
    if (loadedHighScore != state.highScore) {
      state = state.copyWith(highScore: loadedHighScore);
    }
  }

  void startGame() {
    state = state.copyWith(
      status: GameStatus.playing,
      score: 0,
      currentSpeed: 1.0,
    ); // <--- MODIFIED
    _loadHighScore();
  }

  void onColorTapped(Color color) {
    if (state.status != GameStatus.playing) return;
  }

  void incrementScore() {
    final newScore = state.score + 1;
    double newSpeed = state.currentSpeed;
    double newInterval = state.currentSpawnInterval; // Get current interval

    if (newScore > 0 && newScore % _scoreThresholdForSpeedIncrease == 0) {
      newSpeed += _speedIncrementFactor; // Increase the speed multiplier
      print(
        'Speed increased to: $newSpeed at score $newScore',
      ); // For debugging
    }

    // Check if it's time to decrease spawn interval
    if (newScore > 0 && newScore % _scoreThresholdForIntervalDecrease == 0) {
      newInterval = (newInterval - _intervalDecrementAmount).clamp(
        _minSpawnInterval,
        double.infinity,
      ); // Decrease and clamp
      print(
        'Spawn interval decreased to: $newInterval at score $newScore',
      ); // For debugging
    }

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
    );
  }

  void endGame() {
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      state = state.copyWith(
        highScore: newHighScore,
        status: GameStatus.gameOver,
      );
      _scoreRepository.saveHighScore(newHighScore);
    } else {
      state = state.copyWith(status: GameStatus.gameOver);
    }
    FlameAudio.play('game_over.mp3'); // Play game over sound
  }

  void restartGame() {
    // Good: Resets to initial state and reloads high score.
    state = state.copyWith(score: 0, status: GameStatus.initial);
    _loadHighScore();
  }
}

// Global Providers: These are well-defined for Riverpod.
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

final colorProvider = Provider<List<Color>>((ref) {
  // This list of colors is correctly provided. If these colors
  // are meant to be theme-related, you might consider moving
  // them to AppColors, but if they are specifically game-play colors
  // (e.g., the set of colors that falling objects can be), this is fine.
  return [Colors.red, Colors.blue, Colors.green, Colors.yellow];
});

// Assuming GameStatus and GameState are in game_state.dart as you provided earlier.
// If they were in this file, they would also be fine.
