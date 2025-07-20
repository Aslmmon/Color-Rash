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
  // Good: _scoreRepository is declared as late final and initialized in build.
  late final ScoreRepository _scoreRepository;

  int _gameOverCount = 0; // <--- NEW: Track game overs since last ad
  late final IAdService _adService; // <--- NEW: Ad service interface
  late final IAudioPlayer
  _audioPlayer; // <--- NEW: Declare the audio player interface
  final Random _random =
      Random(); // <--- NEW: Random instance for gradient selection
  int _lastGradientIndex =
      0; // <--- NEW: To ensure next random gradient is different

  @override
  GameState build() {
    _scoreRepository = ref.read(scoreRepositoryProvider);
    _adService = ref.read(
      adServiceProvider,
    ); // <--- NEW: Read the ad service provider
    _audioPlayer = ref.read(
      audioPlayerProvider,
    ); // Assuming you'll add audioPlayerProvider
    _loadHighScore();

    _adService.loadInterstitialAd(); // <--- MODIFIED: Use ad service to load
    ref.onDispose(() {
      // No need to dispose interstitialAd here, adService will handle it
      print('GameNotifier disposed.');
    });

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
      currentSpawnInterval: kObjectSpawnPeriodInitial,
      currentGradientIndex: 0,
      currentLevel: 1,
      showLevelUpOverlay: false, // Ensure hidden on start
    );
    _loadHighScore();
  }

  void onColorTapped(Color color) {
    if (state.status != GameStatus.playing) return;
  }

  void incrementScore() {
    final newScore = state.score + 1;
    double newSpeed = state.currentSpeed;
    double newInterval = state.currentSpawnInterval; // Get current interval
    int newGradientIndex = state.currentGradientIndex; // Get current index
    int newLevel = state.currentLevel;
    bool showLevelUp = false; // Assume false by default

    if (newScore > 0 && newScore % kScoreThresholdForSpeedIncrease == 0) {
      newSpeed += kSpeedIncrementFactor; // Increase the speed multiplier
      print(
        'Speed increased to: $newSpeed at score $newScore',
      ); // For debugging
    }

    // Check if it's time to decrease spawn interval
    if (newScore > 0 && newScore % kScoreThresholdForIntervalDecrease == 0) {
      newInterval = (newInterval - kIntervalDecrementAmount).clamp(
        kMinSpawnInterval,
        double.infinity,
      ); // Decrease and clamp
      newLevel++; // Increment level
      showLevelUp = true; // Trigger level up overlay
      int newRandomIndex = _random.nextInt(
        AppColors.backgroundGradients.length,
      );
      while (newRandomIndex == _lastGradientIndex &&
          AppColors.backgroundGradients.length > 1) {
        newRandomIndex = _random.nextInt(AppColors.backgroundGradients.length);
      }
      newGradientIndex = newRandomIndex;
      _lastGradientIndex = newGradientIndex; // Update last picked index
      print(
        'Level Up! To Level: $newLevel. Gradient changed to index: $newGradientIndex at score $newScore',
      ); // For debugging
      // _audioPlayer.playSfx('level_up.mp3'); // Assuming you have this sound for Day 4

      print(
        'Spawn interval decreased to: $newInterval at score $newScore',
      ); // For debugging
    }

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
      currentGradientIndex: newGradientIndex,
      currentLevel: newLevel,
      showLevelUpOverlay: showLevelUp,
    );

    if (showLevelUp) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Display for 1.5 seconds
        if (state.showLevelUpOverlay) {
          // Only hide if still showing (prevent race conditions)
          state = state.copyWith(showLevelUpOverlay: false);
        }
      });
    }
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

    _gameOverCount++;
    if (_gameOverCount >= kAdShowFrequency) {
      _adService.showInterstitialAd(); // <--- MODIFIED: Use ad service to show
      _gameOverCount = 0; // Reset counter
    }
    _audioPlayer.playSfx(
      'game_over.mp3',
    ); // <--- MODIFIED: Use the audio player interface
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
