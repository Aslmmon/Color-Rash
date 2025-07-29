// lib/domain/game_notifier.dart
import 'dart:ui';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ad_service.dart';
import '../core/app_monitoring_service.dart';
import '../core/audio_player.dart';
import '../data/settings_repository.dart';
import '../presentation/theme/app_colors.dart';
import '../services/firebase_monitoring_service.dart';
import '../services/flame_audio_player.dart';
import '../services/google_ad_service.dart';
import 'game_constants.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  late final SettingsRepository _settingsRepository;
  late final IAdService _adService;
  late final IAudioPlayer _audioPlayer;
  late final IAppMonitoringService _appMonitoringService;

  int _gameOverCount = 0;

  @override
  GameState build() {
    _initializeDependencies();
    _loadHighScoreAndSettings();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
    return GameState();
  }

  /// Initializes the necessary service dependencies from Riverpod.
  void _initializeDependencies() {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    _adService = ref.read(adServiceProvider);
    _audioPlayer = ref.read(audioPlayerProvider);
    _appMonitoringService = ref.read(appMonitoringServiceProvider);
  }

  /// Loads the high score from the repository and updates the game state.
  Future<void> _loadHighScoreAndSettings() async {
    final loadedHighScore = await _settingsRepository.getHighScore();
    final hasSeenTutorial = await _settingsRepository.getHasSeenTutorial();

    if (loadedHighScore != state.highScore) {
      state = state.copyWith(
        highScore: loadedHighScore,
        hasSeenTutorial: hasSeenTutorial,
      );
    }
  }

  Map<String, dynamic> _calculateDifficultyForLevel(int targetLevel) {
    double speed = 1.0;
    double interval = kObjectSpawnPeriodInitial;
    int gradientIndex = 0;

    // Simulate progression up to the targetLevel
    // Loop for each level-up threshold passed
    for (
      int currentThresholdLevel = 1;
      currentThresholdLevel < targetLevel;
      currentThresholdLevel++
    ) {
      // Assuming kScoreThresholdForIntervalDecrease determines when a level progresses
      // and difficulty increases.
      // We simulate moving from (currentThresholdLevel - 1) to currentThresholdLevel.

      // Increase speed for each level up
      speed += kSpeedIncrementFactor;

      // Decrease interval for each level up
      interval = (interval - kIntervalDecrementAmount).clamp(
        kMinSpawnInterval,
        double.infinity,
      );

      // Cycle gradient for each level up
      gradientIndex =
          (gradientIndex + 1) % AppColors.backgroundGradients.length;
    }

    return {
      'speed': speed,
      'interval': interval,
      'gradientIndex': gradientIndex,
      'level': targetLevel, // Return targetLevel as the calculated level
    };
  }

  Future<void> restartTutorial() async {
    state = state.copyWith(
      hasSeenTutorial: false,
    ); // Update state to show tutorial
    await _settingsRepository.setHasSeenTutorial(false); // Persist the change
    // No explicit status change here; GameScreen watches hasSeenTutorial.
    // When the user next presses 'Start Game'/'Play Again', the tutorial will appear.
  }

  void returnToMainMenu() {
    state = state.copyWith(
      status: GameStatus.initial,
      score: 0,
      currentSpeed: 1.0,
      currentSpawnInterval: kObjectSpawnPeriodInitial,
      currentGradientIndex: 0,
      currentLevel: 1,
      showLevelUpOverlay: false,
      isPaused: false,
      isMuted: state.isMuted,
      startLevelOverride: 1,
      hasSeenTutorial: true,
      showConfetti: false,
    );
    _audioPlayer.stopBgm(); // Stop BGM when returning to menu
    _adService.loadInterstitialAd(); // Load new ad for next game session
  }

  Future<void> markTutorialSeen() async {
    state = state.copyWith(hasSeenTutorial: true);
    await _settingsRepository.setHasSeenTutorial(true); // Persist the change
  }

  /// Starts a new game session, resetting scores and game state.
  void startGame() {
    int initialLevel = 1;
    double initialSpeed = 1.0;
    double initialSpawnInterval = kObjectSpawnPeriodInitial;
    int initialGradientIndex = 0;
    if (state.startLevelOverride != null && state.startLevelOverride! > 0) {
      final calculatedParams = _calculateDifficultyForLevel(
        state.startLevelOverride!,
      );
      initialLevel = calculatedParams['level'] as int;
      initialSpeed = calculatedParams['speed'] as double;
      initialSpawnInterval = calculatedParams['interval'] as double;
      initialGradientIndex = calculatedParams['gradientIndex'] as int;
    }
    state = state.copyWith(
      status: GameStatus.playing,
      score: 0,
      currentSpeed: initialSpeed,
      currentSpawnInterval: initialSpawnInterval,
      currentGradientIndex: initialGradientIndex,
      currentLevel: initialLevel,
      showLevelUpOverlay: false,
      isPaused: false,
      isMuted: state.isMuted,
      showConfetti: false,
      startLevelOverride: 1, // <--- Crucial: Reset override after use
    );
    _loadHighScoreAndSettings();
    _audioPlayer.playBgm(AppAudioPaths.bgm); // Play BGM on game start
    _appMonitoringService.logEvent('game_started'); // <--- NEW
    _appMonitoringService.startTrace('game_session_duration'); // <--- NEW
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

    GameStatus finalStatus = state.status; // Default to current status
    if (newLevel > kMaxLevel) {
      // Use >= in case you skip levels
      finalStatus = GameStatus.won;
      _audioPlayer.playSfx(
        AppAudioPaths.celebrate,
      ); // <--- NEW: Play a win sound effect
    }

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
      currentGradientIndex: newGradientIndex,
      currentLevel: newLevel,
      showLevelUpOverlay: showLevelUp,
      showConfetti: showLevelUp,
      status: finalStatus, // <--- MODIFIED: Update status if won
    );

    if (showLevelUp) {
      _triggerLevelUpVisualsAndSound(); // Trigger visual and audio feedback for level up
      _appMonitoringService.logEvent(
        'level_up',
        parameters: {'level': newLevel},
      ); // <--- NEW
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

      // Increment the index and use modulo to cycle back to 0 if it exceeds length
      newGradientIndex =
          (currentGradientIndex + 1) % AppColors.backgroundGradients.length;
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
    _audioPlayer.playSfx(AppAudioPaths.celebrate); // Play level up sound
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
    _audioPlayer.playSfx(AppAudioPaths.gameOver); // Play game over sound
    _audioPlayer.stopBgm(); // Stop BGM on game over
    state = state.copyWith(status: GameStatus.gameOver);
    _appMonitoringService.logEvent(
      'game_ended',
      parameters: {
        'score': state.score,
        'high_score': state.highScore,
        'status': state.status.toString(),
      },
    ); // <--- NEW
    _appMonitoringService.stopTrace('game_session_duration'); // <--- NEW
  }

  /// Manages high score saving and interstitial ad display at game over.
  void _handleGameOverScoreAndAds() {
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      state = state.copyWith(
        highScore: newHighScore,
      ); // Update in-memory high score
      _settingsRepository.saveHighScore(newHighScore); // Persist
    }

    _gameOverCount++;
    if (_gameOverCount >= kAdShowFrequency) {
      _adService.showInterstitialAd();
      _gameOverCount = 0; // Reset counter
    }
  }

  /// Restarts the game, resetting current score and loading high score.
  void restartGame() {
    state = state.copyWith(
      status: GameStatus.playing,
      score: 0,
      currentSpeed: 1.0,
      currentSpawnInterval: kObjectSpawnPeriodInitial,
      currentGradientIndex: 0,
      currentLevel: 1,
      startLevelOverride: 1, // <--- Crucial: Reset override
    );
    _loadHighScoreAndSettings();
    _audioPlayer.playBgm(AppAudioPaths.bgm); // Play BGM on game start
    _adService.loadInterstitialAd(); // Load new ad for next game session
  }

  void togglePause() {
    final newPauseState = !state.isPaused;
    state = state.copyWith(isPaused: newPauseState);
    if (newPauseState) {
      _audioPlayer.pauseBgm();
    } else {
      _audioPlayer.resumeBgm();
    }
  }

  void grantLevelBoost() {
    final int boostedLevel = (state.startLevelOverride + 2).clamp(
      1,
      kMaxLevel,
    ); // Boost by 2, clamp to max level
    state = state.copyWith(
      startLevelOverride: boostedLevel,
    ); // Set the override level
    _appMonitoringService.logEvent(
      'rewarded_ad_level_boost_granted',
      parameters: {'boosted_level': boostedLevel},
    );
    debugPrint('Level boosted to $boostedLevel from rewarded ad!');
  }

  // <--- NEW: Toggle Mute method
  void toggleMute() {
    final newMuteState = !state.isMuted;
    state = state.copyWith(isMuted: newMuteState);
    _audioPlayer.setMuted(newMuteState); // Tell the audio player to mute/unmute
  }
}

// Global Providers: These are well-defined for Riverpod
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

final appMonitoringServiceProvider = Provider<IAppMonitoringService>((ref) {
  final service = FirebaseMonitoringService();
  // No explicit dispose for Firebase SDKs as they are global singletons
  return service;
});
