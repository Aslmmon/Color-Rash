// Global Providers: These are well-defined for Riverpod
import 'package:color_rash/firebase_options.dart' show DefaultFirebaseOptions;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ad_service.dart';
import '../core/app_monitoring_service.dart';
import '../core/audio_player.dart';
import '../services/firebase_monitoring_service.dart';
import '../services/flame_audio_player.dart';
import '../services/google_ad_service.dart';
import 'game_notifier.dart';
import 'game_state.dart';

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

// This provider will be a single source for all initialization status
final initializationProvider = FutureProvider<void>((ref) async {
  // Get all the services from Riverpod
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final adService = ref.read(adServiceProvider);
  final monitoringService = ref.read(appMonitoringServiceProvider);

  // Initialize Firebase (if not already done) and services
  await monitoringService
      .initialize(); // This includes Firebase.initializeApp()
  FlutterError.onError =
      monitoringService.recordFlutterFatalError; // <--- MODIFIED
  adService.loadInterstitialAd();
  adService.loadRewardedAd();

  // final container = ProviderContainer();
  // final appMonitoringService = container.read(appMonitoringServiceProvider);
  // await appMonitoringService.initialize();
});
