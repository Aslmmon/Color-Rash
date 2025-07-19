import 'dart:ui';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/score_repository.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  // Good: _scoreRepository is declared as late final and initialized in build.
  late final ScoreRepository _scoreRepository;

  @override
  GameState build() {
    _scoreRepository = ref.read(scoreRepositoryProvider);
    _loadHighScore();
    return GameState();
  }

  Future<void> _loadHighScore() async {
    final loadedHighScore = await _scoreRepository.getHighScore();
    // Good: Only update if the high score has actually changed.
    if (loadedHighScore != state.highScore) {
      state = state.copyWith(highScore: loadedHighScore);
    }
  }

  void startGame() {
    // Good: Resets score and loads latest high score when starting.
    state = state.copyWith(status: GameStatus.playing, score: 0);
    _loadHighScore();
  }

  void onColorTapped(Color color) {
    // Good: Defensive check for game status.
    // The print statement is for debugging and can be removed in a final version.
    if (state.status != GameStatus.playing) return;
    print('Tapped color: $color (handled by game logic)');
  }

  void incrementScore() {
    state = state.copyWith(score: state.score + 1);
  }

  void endGame() {
    // Good: Correctly checks and saves new high score.
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      state = state.copyWith(highScore: newHighScore, status: GameStatus.gameOver);
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