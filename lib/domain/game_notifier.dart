import 'dart:ui';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ad_service.dart';
import '../core/app_monitoring_service.dart';
import '../core/audio_player.dart';
import '../data/settings_repository.dart';
import '../presentation/theme/app_colors.dart';
import 'difficulty_params.dart';
import 'game_constants.dart';
import 'game_providers.dart';
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

  DifficultyParams _calculateDifficultyForLevel(int targetLevel) {
    targetLevel = targetLevel.clamp(1, AppConstants.kMaxLevel); // MODIFIED
    double speed = AppConstants.kObjectSpeedInitial;
    double interval = AppConstants.kObjectSpawnPeriodInitial;
    int gradientIndex = AppConstants.kGameGradientIndexInitial;
    for (
      int currentThresholdLevel = 0;
      currentThresholdLevel <= targetLevel;
      currentThresholdLevel++
    ) {
      speed += AppConstants.kSpeedIncrementFactor;
      interval = (interval - AppConstants.kIntervalDecrementAmount).clamp(
        AppConstants.kMinSpawnInterval,
        double.infinity,
      );
      gradientIndex =
          (gradientIndex + 1) % AppColors.backgroundGradients.length;
    }

    return DifficultyParams(
      speed: speed,
      interval: interval,
      gradientIndex: gradientIndex,
      level: targetLevel,
    );
  }

  /// Determines new speed, spawn interval, gradient, and level based on score.
  DifficultyUpdateResult _determineDifficultyUpdate(
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
    if (newScore > 0 &&
        newScore % AppConstants.kScoreThresholdForSpeedIncrease == 0) {
      newSpeed += AppConstants.kSpeedIncrementFactor;
      // print('Speed increased to: $newSpeed at score $newScore'); // Removed debug print
    }

    // Apply interval decrease and level up logic
    if (newScore > 0 &&
        newScore % AppConstants.kScoreThresholdForIntervalDecrease == 0) {
      newInterval = (newInterval - AppConstants.kIntervalDecrementAmount).clamp(
        AppConstants.kMinSpawnInterval,
        double.infinity,
      );
      newLevel++;
      showLevelUp = true;

      final updatedParams = _applyDifficultyIncreaseStep(
        currentSpeed: newSpeed, // Use the speed that might have just increased
        currentInterval: newInterval,
        currentGradientIndex: newGradientIndex,
      );
      newSpeed = updatedParams.speed;
      newInterval = updatedParams.interval;
      newGradientIndex = updatedParams.gradientIndex;
    }
    return DifficultyUpdateResult(
      speed: newSpeed,
      interval: newInterval,
      gradientIndex: newGradientIndex,
      level: newLevel,
      showLevelUpOverlay: showLevelUp,
    );
  }

  Future<void> restartTutorial() async {
    state = state.copyWith(
      hasSeenTutorial: false,
    ); // Update state to show tutorial
    await _settingsRepository.setHasSeenTutorial(false); // Persist the change
  }

  void returnToMainMenu() {
    _resetGameSessionState();
    state = state.copyWith(status: GameStatus.initial);
  }

  Future<void> markTutorialSeen() async {
    state = state.copyWith(hasSeenTutorial: true);
    await _settingsRepository.setHasSeenTutorial(true); // Persist the change
  }

  void _resetGameSessionState() {
    state = state.copyWith(
      score: AppConstants.kGameScoreInitial,
      currentSpeed: AppConstants.kObjectSpeedInitial,
      currentSpawnInterval: AppConstants.kObjectSpawnPeriodInitial,
      currentGradientIndex: AppConstants.kGameGradientIndexInitial,
      currentLevel: AppConstants.kGameLevelInitial,
      showLevelUpOverlay: false,
      isPaused: false,
      isMuted: state.isMuted,
      showConfetti: false,
    );
    _loadHighScoreAndSettings(); // Re-load persisted settings
  }

  /// Restarts the game, resetting current score and loading high score.
  void restartGame() {
    _resetGameSessionState();
    state = state.copyWith(
      status: GameStatus.playing,
      startLevelOverride: AppConstants.kGameLevelInitial,
    );
    _audioPlayer.playBgm(AppAudioPaths.bgm); // Play BGM on game start
    _adService.loadInterstitialAd(); // Load new ad for next game session
  }

  /// Starts a new game session, resetting scores and game state.
  void startGame() {
    _resetGameSessionState();
    int initialLevel = state.currentLevel; // Get from state after reset
    double initialSpeed = state.currentSpeed;
    double initialSpawnInterval = state.currentSpawnInterval;
    int initialGradientIndex = state.currentGradientIndex;

    if (state.startLevelOverride > AppConstants.kGameLevelInitial) {
      final calculatedParams = _calculateDifficultyForLevel(
        state.startLevelOverride,
      );
      initialLevel = calculatedParams.level;
      initialSpeed = calculatedParams.speed;
      initialSpawnInterval = calculatedParams.interval;
      initialGradientIndex = calculatedParams.gradientIndex;
    }
    state = state.copyWith(
      status: GameStatus.playing,
      score: AppConstants.kGameScoreInitial,
      currentSpeed: initialSpeed,
      currentSpawnInterval: initialSpawnInterval,
      currentGradientIndex: initialGradientIndex,
      currentLevel: initialLevel,
      isMuted: state.isMuted,
      startLevelOverride: AppConstants.kGameLevelInitial,
    );
    _audioPlayer.playBgm(AppAudioPaths.bgm);
    _appMonitoringService.logEvent(AppMonitoringLogs.gameStartedLog);
    _appMonitoringService.startTrace(AppMonitoringLogs.gameSessionDuration);
    _adService.loadRewardedAd();
  }

  /// Handles the player tapping a color.
  void onColorTapped(Color color) {
    if (state.status != GameStatus.playing) return;
  }

  /// Increments the player's score and updates difficulty/level.
  void incrementScore() {
    final newScore =
        state.score + AppConstants.kGameScoreToBeIncreaseFromCorrectTap;
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

    newSpeed = difficultyUpdateResult.speed;
    newInterval = difficultyUpdateResult.interval;
    newGradientIndex = difficultyUpdateResult.gradientIndex;
    newLevel = difficultyUpdateResult.level;
    showLevelUp = difficultyUpdateResult.showLevelUpOverlay;
    GameStatus finalStatus = state.status; // Default to current status
    if (newLevel > AppConstants.kMaxLevel) {
      // Use >= in case you skip levels
      finalStatus = GameStatus.won;
      wonGame();

    }

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
      currentGradientIndex: newGradientIndex,
      currentLevel: newLevel,
      showLevelUpOverlay: showLevelUp,
      showConfetti: showLevelUp,
      status: finalStatus,
    );

    if (showLevelUp) {
      _triggerLevelUpVisualsAndSound(); // Trigger visual and audio feedback for level up
      _appMonitoringService.logEvent(
        AppMonitoringLogs.levelUpLog,
        parameters: {'level': newLevel},
      ); // <--- NEW
    }
  }

  /// Triggers the visual overlay and sound effect for a level up.
  void _triggerLevelUpVisualsAndSound() {
    _audioPlayer.playSfx(AppAudioPaths.celebrate); // Play level up sound
    // hide the level up overlay after a delay
    Future.delayed(
      const Duration(
        milliseconds: AppConstants.kLevelUpOverlayDisplayDurationMs,
      ),
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
    _handleScoreAfterGameOver(); // Handle score saving and ad display
    _audioPlayer.playSfx(AppAudioPaths.gameOver); // Play game over sound
    _audioPlayer.stopBgm(); // Stop BGM on game over
    state = state.copyWith(status: GameStatus.gameOver);
    _handleGameOverAds();
    _appMonitoringService.logEvent(
      AppMonitoringLogs.gameEndedLog,
      parameters: {
        'score': state.score,
        'high_score': state.highScore,
        'status': state.status.toString(),
      },
    ); // <--- NEW
    _appMonitoringService.stopTrace(
      AppMonitoringLogs.gameSessionDuration,
    ); // <--- NEW
  }

  /// Ends the current game session, handles high score saving and ads.
  void wonGame() {
    _handleScoreAfterGameOver(); // Handle score saving and ad display
    _audioPlayer.playSfx(AppAudioPaths.celebrate); // Play game over sound
    state.copyWith(showConfetti: true);
    _audioPlayer.stopBgm(); // Stop BGM on game over
    _handleGameOverAds();
    _appMonitoringService.logEvent(
      AppMonitoringLogs.gameEndedLog,
      parameters: {
        'score': state.score,
        'high_score': state.highScore,
        'status': state.status.toString(),
      },
    ); // <--- NEW
    _appMonitoringService.stopTrace(
      AppMonitoringLogs.gameSessionDuration,
    ); // <--- NEW
  }

  /// Manages high score saving and interstitial ad display at game over.
  void _handleScoreAfterGameOver() {
    if (state.score > state.highScore) {
      final newHighScore = state.score;
      state = state.copyWith(highScore: newHighScore);
      _settingsRepository.saveHighScore(newHighScore); // Persist
    }
    _handleGameOverAds();
  }

  void _handleGameOverAds() {
    _gameOverCount++;
    if (_gameOverCount >= AppConstants.kAdShowFrequency) {
      _adService.showInterstitialAd();
      _gameOverCount = 0; // Reset counter
    }
  }

  void togglePause() {
    final newPauseState = !state.isPaused;
    state = state.copyWith(isPaused: newPauseState);
    newPauseState ? _audioPlayer.pauseBgm() : _audioPlayer.resumeBgm();
  }

  void grantLevelBoost() {
    final int boostedLevel = (state.startLevelOverride +
            AppConstants.kGameLevelsBoostedValueAfterReward)
        .clamp(1, AppConstants.kMaxLevel); // Boost by 2, clamp to max level
    state = state.copyWith(
      startLevelOverride: boostedLevel,
    ); // Set the override level
    _appMonitoringService.logEvent(
      AppMonitoringLogs.rewardedAdLevelBoostGranted,
      parameters: {'boosted_level': boostedLevel},
    );
  }

  void toggleMute() {
    final newMuteState = !state.isMuted;
    state = state.copyWith(isMuted: newMuteState);
    _audioPlayer.setMuted(newMuteState); // Tell the audio player to mute/unmute
  }

  // lib/domain/game_notifier.dart
  // ... (existing class definition)

  DifficultyUpdateResult _applyDifficultyIncreaseStep({
    required double currentSpeed,
    required double currentInterval,
    required int currentGradientIndex,
  }) {
    final newSpeed = currentSpeed + AppConstants.kSpeedIncrementFactor;
    final newInterval = (currentInterval -
            AppConstants.kIntervalDecrementAmount)
        .clamp(AppConstants.kMinSpawnInterval, double.infinity);
    final newGradientIndex =
        (currentGradientIndex + 1) % AppColors.backgroundGradients.length;

    return DifficultyUpdateResult(
      speed: newSpeed,
      interval: newInterval,
      gradientIndex: newGradientIndex,
      level: currentGradientIndex + 1,
      showLevelUpOverlay: false, // No overlay for this incremental change
    );
  }
}
