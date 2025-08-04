// lib/domain/initialization_notifier.dart
import 'package:color_rash/domain/game_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  get waitScreenDurationInMillis => null;

  // This method will run all your initialization tasks sequentially
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _prepareEnvironmentIdsVariables();

    final adService = ref.read(adServiceProvider);
    final monitoringService = ref.read(appMonitoringServiceProvider);
    if (!kIsWeb) {
      MobileAds.instance.initialize();
    }
    // Initialize Firebase (if not already done) and services
    await monitoringService
        .initialize(); // This includes Firebase.initializeApp()
    FlutterError.onError =
        monitoringService.recordFlutterFatalError; // <--- MODIFIED
    adService.loadInterstitialAd();
    adService.loadRewardedAd();
    await Future.delayed(
      Duration(milliseconds: AppConstants.waitScreenDurationInMillis),
    );

    // --- Step 1: Load Settings and High Score (approx. 25% of progress) ---
    state = state.copyWith(message: "Loading settings...", progress: 0.25);
    await Future.delayed(
      Duration(milliseconds: AppConstants.waitScreenDurationInMillis),
    );

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
    await Future.delayed(
      Duration(milliseconds: AppConstants.waitScreenDurationInMillis),
    );

    // --- Step 4: Finalize Setup (approx. 100% of progress) ---
    state = state.copyWith(message: "Finalizing...", progress: 1.0);
    // A small delay to ensure the UI has time to show 100% before transitioning
    await Future.delayed(
      Duration(milliseconds: AppConstants.waitScreenDurationInMillis),
    );
  }
}

// The provider to expose the notifier
final initializationNotifierProvider =
    StateNotifierProvider<InitializationNotifier, InitializationState>((ref) {
      return InitializationNotifier(ref);
    });

Future<void> _prepareEnvironmentIdsVariables() async {
  String envFileName =
      kDebugMode
          ? AppFilePaths.devEnvironment
          : AppFilePaths
              .prodEnvironment; // Assuming .env is for production in CI/CD.

  if (kDebugMode && !kIsWeb) {
    final RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: <String>[
        'F2386F50E5601E10DD63F1C43F4B26B2',
        // Replace with your actual device hash ID from logs
        // 'ANOTHER_DEVICE_HASH_ID_2', // Add more if you have other test devices
        // For Android emulators, you can sometimes use 'EMULATOR', but it's less reliable
      ],
    );
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  await dotenv.load(fileName: envFileName); // <--- Load your default dev file
}
