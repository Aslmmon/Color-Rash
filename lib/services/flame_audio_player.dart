// lib/services/flame_audio_player.dart
import 'package:flame_audio/flame_audio.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import the interface

class FlameAudioPlayer implements IAudioPlayer {
  @override
  Future<void> playSfx(String fileName) async {
    await FlameAudio.play(fileName);
  }

  // Implement other methods from IAudioPlayer if you add them
}

final audioPlayerProvider = Provider<IAudioPlayer>((ref) {
  // Use the concrete FlameAudioPlayer implementation
  return FlameAudioPlayer();
});
