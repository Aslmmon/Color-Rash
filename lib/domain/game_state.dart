// Defines the possible states of our game.
enum GameStatus { initial, playing, gameOver }

// A class to hold all our game's state data in one place.
class GameState {
  final int score;
  final int highScore;
  final GameStatus status;

  GameState({
    this.score = 0,
    this.highScore = 0,
    this.status = GameStatus.initial,
  });

  // A convenience method to create a copy of the state with new values.
  GameState copyWith({int? score, int? highScore, GameStatus? status}) {
    return GameState(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
    );
  }
}
