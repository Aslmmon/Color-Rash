// Global Providers: These are well-defined for Riverpod
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
