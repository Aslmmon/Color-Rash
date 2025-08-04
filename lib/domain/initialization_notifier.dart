// lib/domain/initialization_notifier.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:color_rash/data/settings_repository.dart';
import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/domain/game_state.dart';
import 'package:color_rash/core/app_monitoring_service.dart';
import 'package:color_rash/core/ad_service.dart';
import 'package:flame_audio/flame_audio.dart';

import '../firebase_options.dart';
import 'game_providers.dart';

// The state class to hold progress and messages
class InitializationState {
  final double progress;
  final String message;

  const InitializationState({
    this.progress = 0.0,
    this.message = "Initializing...",
  });

  InitializationState copyWith({double? progress, String? message}) {
    return InitializationState(
      progress: progress ?? this.progress,
      message: message ?? this.message,
    );
  }
}

// The notifier that will manage the state and perform all async tasks
class InitializationNotifier extends StateNotifier<InitializationState> {
  InitializationNotifier(this.ref) : super(const InitializationState());

  final Ref ref;

  // This method will run all your initialization tasks sequentially
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final adService = ref.read(adServiceProvider);
    final monitoringService = ref.read(appMonitoringServiceProvider);

    // Initialize Firebase (if not already done) and services
    await monitoringService
        .initialize(); // This includes Firebase.initializeApp()
    FlutterError.onError =
        monitoringService.recordFlutterFatalError; // <--- MODIFIED
    adService.loadInterstitialAd();
    adService.loadRewardedAd();
    await Future.delayed(const Duration(milliseconds: 500));

    // --- Step 1: Load Settings and High Score (approx. 25% of progress) ---
    state = state.copyWith(message: "Loading settings...", progress: 0.25);
    await Future.delayed(const Duration(milliseconds: 500));

    // --- Step 2: Load Audio Assets (approx. 50% of progress) ---
    state = state.copyWith(message: "Loading sounds...", progress: 0.5);
    await FlameAudio.audioCache.loadAll([
      AppAudioPaths.correctTap,
      AppAudioPaths.errorTap,
      AppAudioPaths.gameOver,
      AppAudioPaths.celebrate,
      AppAudioPaths.bgm,
    ]);

    await Future.delayed(const Duration(milliseconds: 500));

    // --- Step 3: Load Ads (approx. 75% of progress) ---
    state = state.copyWith(message: "Preparing ads...", progress: 0.75);
    adService.loadInterstitialAd();
    adService.loadRewardedAd();
    await Future.delayed(const Duration(milliseconds: 500));

    // --- Step 4: Finalize Setup (approx. 100% of progress) ---
    state = state.copyWith(message: "Finalizing...", progress: 1.0);

    // A small delay to ensure the UI has time to show 100% before transitioning
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// The provider to expose the notifier
final initializationNotifierProvider =
    StateNotifierProvider<InitializationNotifier, InitializationState>((ref) {
      return InitializationNotifier(ref);
    });
