// Defines the possible states of our game.
import 'package:color_rash/domain/game_constants.dart'; // <--- NEW

enum GameStatus { initial, playing, gameOver, won }

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
  final bool isPaused; // <--- NEW
  final bool isMuted; // <--- NEW
  final bool showConfetti; // <--- NEW
  final bool hasSeenTutorial; // <--- NEW PROPERTY
  final int
  startLevelOverride; // <--- NEW PROPERTY: Nullable int for level boost

  GameState({
    this.score = 0,
    this.highScore = 0,
    this.status = GameStatus.initial,
    this.currentSpeed = 1.0,
    this.currentSpawnInterval = AppConstants.kObjectSpawnPeriodInitial,
    this.currentGradientIndex = 0,
    this.currentLevel = 1,
    this.showLevelUpOverlay = false,
    this.isPaused = false,
    this.isMuted = false,
    this.showConfetti = false,
    this.hasSeenTutorial = false,
    this.startLevelOverride = 1,
  });

  // A convenience method to create a copy of the state with new values.
  GameState copyWith({
    int? score,
    int? highScore,
    GameStatus? status,
    double? currentSpeed,
    double? currentSpawnInterval,
    int? currentGradientIndex,
    int? currentLevel,
    bool? showLevelUpOverlay,
    bool? isPaused,
    bool? isMuted,
    bool? showConfetti,
    bool? hasSeenTutorial,
    int? startLevelOverride,
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
      isPaused: isPaused ?? this.isPaused,
      isMuted: isMuted ?? this.isMuted,
      showConfetti: showConfetti ?? this.showConfetti,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      startLevelOverride: startLevelOverride ?? this.startLevelOverride,
    );
  }

  @override
  String toString() {
    return 'GameState('
        'score: $score, '
        'highScore: $highScore, '
        'status: ${status.toString().split('.').last}, ' // Gets enum name (e.g., 'playing')
        'currentSpeed: $currentSpeed, '
        'currentSpawnInterval: $currentSpawnInterval, '
        'currentGradientIndex: $currentGradientIndex, '
        'currentLevel: $currentLevel, '
        'showLevelUpOverlay: $showLevelUpOverlay, '
        'isPaused: $isPaused, '
        'isMuted: $isMuted, '
        'showConfetti: $showConfetti, '
        'hasSeenTutorial: $hasSeenTutorial, '
        'startLevelOverride: $startLevelOverride'
        ')';
  }
}
