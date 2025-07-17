import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    return GameState();
  }

  void startGame() => state = state.copyWith(status: GameStatus.playing);

  // New method to handle player input
  void onColorTapped(Color color) {
    // We only care about taps when the game is playing.
    if (state.status != GameStatus.playing) return;

    // For now, just print to confirm it works.
    // Tomorrow, this will hold the actual game logic.
    print('Tapped color: $color');
  }

  // New method to increment score
  void incrementScore() {
    state = state.copyWith(score: state.score + 1);
  }

  // New method to end the game
  void endGame() {
    state = state.copyWith(status: GameStatus.gameOver);
  }
}

// The global provider that we will use to access the Notifier from the UI.
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

final colorProvider = Provider<List<Color>>((ref) {
  return [Colors.red, Colors.blue, Colors.green, Colors.yellow];
});
