// lib/domain/game_notifier.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ad_service.dart';
import '../core/audio_player.dart';
import '../data/score_repository.dart';
import '../presentation/theme/app_colors.dart';
import '../services/flame_audio_player.dart';
import '../services/google_ad_service.dart';
import 'game_constants.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  late final ScoreRepository _scoreRepository;
  late final IAdService _adService;
  late final IAudioPlayer _audioPlayer;

  final Random _random = Random();
  int _lastGradientIndex = 0;
  int _gameOverCount = 0;

  @override
  GameState build() {
    _initializeDependencies(); // <--- NEW: Extracted method
    _loadHighScore();
    _adService.loadInterstitialAd();
    return GameState();
  }

  /// Initializes the necessary service dependencies from Riverpod.
  void _initializeDependencies() {
    _scoreRepository = ref.read(scoreRepositoryProvider);
    _adService = ref.read(adServiceProvider);
    _audioPlayer = ref.read(audioPlayerProvider);
  }

  /// Loads the high score from the repository and updates the game state.
  Future<void> _loadHighScore() async {
    final loadedHighScore = await _scoreRepository.getHighScore();
    if (loadedHighScore != state.highScore) {
      state = state.copyWith(highScore: loadedHighScore);
    }
  }

  /// Starts a new game session, resetting scores and game state.
  void startGame() {
    state = state.copyWith(
      status: GameStatus.playing,
      score: 0,
      currentSpeed: 1.0,
      currentSpawnInterval: kObjectSpawnPeriodInitial,
      currentGradientIndex: 0,
      currentLevel: 1,
      showLevelUpOverlay: false,
      isPaused: false,
      isMuted: false,
      showConfetti: false, // Ensure confetti is off on start
    );
    _loadHighScore();
    _audioPlayer.playBgm('bg_music.mp3'); // Play BGM on game start
  }

  /// Handles the player tapping a color.
  void onColorTapped(Color color) {
    if (state.status != GameStatus.playing) return;
  }

  /// Increments the player's score and updates difficulty/level.
  void incrementScore() {
    final newScore = state.score + 1;
    double newSpeed = state.currentSpeed;
    double newInterval = state.currentSpawnInterval;
    int newGradientIndex = state.currentGradientIndex;
    int newLevel = state.currentLevel;
    bool showLevelUp = false;

    // Determine new difficulty parameters and if a level up occurs
    final difficultyUpdateResult = _determineDifficultyUpdate(
      newScore,
      newSpeed,
      newInterval,
      newGradientIndex,
      newLevel,
    );

    newSpeed = difficultyUpdateResult['speed'] as double;
    newInterval = difficultyUpdateResult['interval'] as double;
    newGradientIndex = difficultyUpdateResult['gradientIndex'] as int;
    newLevel = difficultyUpdateResult['level'] as int;
    showLevelUp = difficultyUpdateResult['showLevelUpOverlay'] as bool;

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
      currentGradientIndex: newGradientIndex,
      currentLevel: newLevel,
      showLevelUpOverlay: showLevelUp,
      showConfetti: showLevelUp, // Update confetti state
    );

    if (showLevelUp) {
      _triggerLevelUpVisualsAndSound(); // Trigger visual and audio feedback for level up
    }
  }

  /// Determines new speed, spawn interval, gradient, and level based on score.
  Map<String, dynamic> _determineDifficultyUpdate(
    int newScore,
    double currentSpeed,
    double currentInterval,
    int currentGradientIndex,
    int currentLevel,
  ) {
    double newSpeed = currentSpeed;
    double newInterval = currentInterval;
    int newGradientIndex = currentGradientIndex;
    int newLevel = currentLevel;
    bool showLevelUp = false;

    // Apply speed increase
    if (newScore > 0 && newScore % kScoreThresholdForSpeedIncrease == 0) {
      newSpeed += kSpeedIncrementFactor;
      // print('Speed increased to: $newSpeed at score $newScore'); // Removed debug print
    }

    // Apply interval decrease and level up logic
    if (newScore > 0 && newScore % kScoreThresholdForIntervalDecrease == 0) {
      newInterval = (newInterval - kIntervalDecrementAmount).clamp(
        kMinSpawnInterval,
        double.infinity,
      );
      newLevel++;
      showLevelUp = true;

      // Randomly pick a new gradient that is different from the current one
      int newRandomIndex = _random.nextInt(
        AppColors.backgroundGradients.length,
      );
      while (newRandomIndex == _lastGradientIndex &&
          AppColors.backgroundGradients.length > 1) {
        newRandomIndex = _random.nextInt(AppColors.backgroundGradients.length);
      }
      newGradientIndex = newRandomIndex;
      _lastGradientIndex = newGradientIndex;
    }

    return {
      'speed': newSpeed,
      'interval': newInterval,
      'gradientIndex': newGradientIndex,
      'level': newLevel,
      'showLevelUpOverlay': showLevelUp,
    };
  }

  /// Triggers the visual overlay and sound effect for a level up.
  void _triggerLevelUpVisualsAndSound() {
    _audioPlayer.playSfx('celebrate.wav'); // Play level up sound
    // hide the level up overlay after a delay
    Future.delayed(
      const Duration(milliseconds: kLevelUpOverlayDisplayDurationMs),
      () {
        if (state.showLevelUpOverlay) {
          state = state.copyWith(
            showLevelUpOverlay: false,
            showConfetti: false,
          );
        }
      },
    );
  }

  /// Ends the current game session, handles high score saving and ads.
  void endGame() {
    _handleGameOverScoreAndAds(); // Handle score saving and ad display
    _audioPlayer.playSfx('game_over.mp3'); // Play game over sound
    _audioPlayer.stopBgm(); // Stop BGM on game over
    state = state.copyWith(status: GameStatus.gameOver);
  }

  /// Manages high score saving and interstitial ad display at game over.
  void _handleGameOverScoreAndAds() {
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      state = state.copyWith(
        highScore: newHighScore,
      ); // Update in-memory high score
      _scoreRepository.saveHighScore(newHighScore); // Persist
    }

    _gameOverCount++;
    if (_gameOverCount >= kAdShowFrequency) {
      _adService.showInterstitialAd();
      _gameOverCount = 0; // Reset counter
    }
  }

  /// Restarts the game, resetting current score and loading high score.
  void restartGame() {
    state = state.copyWith(score: 0, status: GameStatus.initial);
    _loadHighScore();
    _audioPlayer.resumeBgm(); // Resume BGM on restart (if not muted)
  }

  // <--- NEW: Toggle Pause method
  void togglePause() {
    final newPauseState = !state.isPaused;
    state = state.copyWith(isPaused: newPauseState);
    if (newPauseState) {
      _audioPlayer.pauseBgm();
    } else {
      _audioPlayer.resumeBgm();
    }
  }

  // <--- NEW: Toggle Mute method
  void toggleMute() {
    final newMuteState = !state.isMuted;
    state = state.copyWith(isMuted: newMuteState);
    _audioPlayer.setMuted(newMuteState); // Tell the audio player to mute/unmute
  }
}

// Global Providers: These are well-defined for Riverpod.
// Ensure these providers are correctly defined in lib/domain/game_provider.dart
// and imported where needed.
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

final colorProvider = Provider<List<Color>>((ref) {
  return [Colors.red, Colors.blue, Colors.green, Colors.yellow];
});

// 2. Audio Player Provider
final audioPlayerProvider = Provider<IAudioPlayer>((ref) {
  return FlameAudioPlayer();
});


// Riverpod provider for the GoogleAdService
final adServiceProvider = Provider<IAdService>((ref) {
  final adService = GoogleAdService();
  ref.onDispose(
        () => adService.dispose(),
  ); // Dispose the service when its provider is disposed
  return adService;
});
