// Defines the possible states of our game.
import 'package:color_rash/domain/game_constants.dart'; // <--- NEW

enum GameStatus { initial, playing, gameOver }

// A class to hold all our game's state data in one place.
class GameState {
  final int score;
  final int highScore;
  final GameStatus status;
  final double currentSpeed;
  final double currentSpawnInterval; // <--- NEW PROPERTY
  final int currentGradientIndex; // <--- NEW PROPERTY
  final int currentLevel; // <--- NEW PROPERTY
  final bool showLevelUpOverlay;

  GameState({
    this.score = 0,
    this.highScore = 0,
    this.status = GameStatus.initial,
    this.currentSpeed = 1.0,
    this.currentSpawnInterval = kObjectSpawnPeriodInitial,
    this.currentGradientIndex = 0,
    this.currentLevel = 1, // <--- NEW: Start at Level 1
    this.showLevelUpOverlay = false, // <--- NEW: Default hidden
  });

  // A convenience method to create a copy of the state with new values.
  GameState copyWith({
    int? score,
    int? highScore,
    GameStatus? status,
    double? currentSpeed,
    double? currentSpawnInterval, // <--- NEW
    int? currentGradientIndex, // <--- NEW
    int? currentLevel, // <--- NEW
    bool? showLevelUpOverlay, // <--- NEW
  }) {
    return GameState(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      currentSpawnInterval: currentSpawnInterval ?? this.currentSpawnInterval,
      currentGradientIndex: currentGradientIndex ?? this.currentGradientIndex,
      currentLevel: currentLevel ?? this.currentLevel,
      showLevelUpOverlay: showLevelUpOverlay ?? this.showLevelUpOverlay,
    );
  }
}
