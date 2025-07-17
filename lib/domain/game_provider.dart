import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/score_repository.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  late final ScoreRepository _scoreRepository;

  @override
  GameState build() {
    // Initialize the ScoreRepository from the provider
    _scoreRepository = ref.read(scoreRepositoryProvider);

    // Load the high score asynchronously when the Notifier is built
    _loadHighScore();
    return GameState();
  }

  Future<void> _loadHighScore() async {
    final loadedHighScore = await _scoreRepository.getHighScore();
    // Update the state with the loaded high score
    if (loadedHighScore != state.highScore) {
      state = state.copyWith(highScore: loadedHighScore);
    }
  }

  void startGame() {
    // When starting a new game, reset current score, set status to playing
    // and explicitly ensure the latest high score from storage is loaded.
    state = state.copyWith(status: GameStatus.playing, score: 0);
    _loadHighScore(); // Reload high score to display the most current value
  }

  void onColorTapped(Color color) {
    // This method is called from ColorRushGame's attemptCatch.
    // The actual game logic for score increment/game over is in ColorRushGame,
    // which then calls incrementScore() or endGame() on this notifier.
    if (state.status != GameStatus.playing) return;
    // No direct game logic here, as per your setup.
    // The `print` statement can remain for debugging if you wish, or be removed.
    print('Tapped color: $color (handled by game logic)');
  }

  // New method to increment score
  void incrementScore() {
    state = state.copyWith(score: state.score + 1);
  }

  // New method to end the game
  // *** MODIFIED: endGame method ***
  void endGame() {
    // First, check if the current score is greater than the stored high score
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      // Update the state with the new high score BEFORE saving
      state = state.copyWith(highScore: newHighScore, status: GameStatus.gameOver);
      // Save the new high score to persistent storage
      _scoreRepository.saveHighScore(newHighScore);
    } else {
      // If current score is not a new high score, just set status to gameOver
      state = state.copyWith(status: GameStatus.gameOver);
    }
    // No need to call _loadHighScore() here because the new high score is already set in state
    // or the existing one is correctly retrieved by the next startGame().
  }

  // You need a restartGame method for Day 7's "Restart" button, which you already have.
  // Let's ensure it exists and properly leverages _loadHighScore().
  void restartGame() {
    // Reset to initial state, which typically precedes startGame()
    state = state.copyWith(score: 0, status: GameStatus.initial);
    // Ensure the latest high score is loaded for display when the game is not playing
    _loadHighScore();
  }
}

// The global provider that we will use to access the Notifier from the UI.
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

final colorProvider = Provider<List<Color>>((ref) {
  return [Colors.red, Colors.blue, Colors.green, Colors.yellow];
});
