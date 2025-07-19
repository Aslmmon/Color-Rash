import 'dart:io';
import 'dart:ui';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart'; // Still needed for `Color`
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_service.dart';
import '../core/audio_player.dart';
import '../data/score_repository.dart';
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
      currentSpawnInterval: 2.0,
    ); // <--- MODIFIED
    _loadHighScore();
  }

  void onColorTapped(Color color) {
    if (state.status != GameStatus.playing) return;
  }

  void incrementScore() {
    final newScore = state.score + 1;
    double newSpeed = state.currentSpeed;
    double newInterval = state.currentSpawnInterval; // Get current interval

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
      print(
        'Spawn interval decreased to: $newInterval at score $newScore',
      ); // For debugging
    }

    state = state.copyWith(
      score: newScore,
      currentSpeed: newSpeed,
      currentSpawnInterval: newInterval,
    );
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
