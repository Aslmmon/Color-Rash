// lib/services/flame_audio_player.dart
import 'package:flame_audio/flame_audio.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlameAudioPlayer implements IAudioPlayer {
  bool _isGloballyMuted = false;
  String?
  _currentBgmFileName; // <--- NEW: To store the name of the currently playing BGM
  bool _wasBgmPlayingBeforePauseOrMute =
      false; // <--- NEW: To track if BGM should resume

  @override
  Future<void> playSfx(String fileName) async {
    if (!_isGloballyMuted) {
      await FlameAudio.play(fileName);
    }
  }

  @override
  void playBgm(String fileName) {
    _currentBgmFileName =
        fileName; // <--- Store the filename whenever BGM is started
    if (!_isGloballyMuted && !FlameAudio.bgm.isPlaying) {
      // If not muted and not already playing, start looping
      FlameAudio.bgm.play(fileName);
      _wasBgmPlayingBeforePauseOrMute = true; // Mark that it's now playing
    }
  }

  @override
  void stopBgm() {
    FlameAudio.bgm.stop();
    _wasBgmPlayingBeforePauseOrMute = false; // It's definitively stopped
  }

  @override
  void setMuted(bool muted) {
    _isGloballyMuted = muted;
    if (_isGloballyMuted) {
      if (FlameAudio.bgm.isPlaying) {
        // If BGM is playing when muted, pause it and remember it was playing
        FlameAudio.bgm.pause();
        _wasBgmPlayingBeforePauseOrMute = true;
      } else {
        // If it was already paused/stopped, just update mute state
        _wasBgmPlayingBeforePauseOrMute =
            false; // Or preserve its actual state if you need finer control
      }
    } else {
      // If unmuted, and it was playing before being muted, resume it
      if (_wasBgmPlayingBeforePauseOrMute && !FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.resume();
        _wasBgmPlayingBeforePauseOrMute =
            false; // Reset the flag after resuming
      }
    }
  }

  @override
  void pauseBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
      _wasBgmPlayingBeforePauseOrMute =
          true; // Remember it was playing before this pause
    }
  }

  @override
  void resumeBgm() {
    if (!_isGloballyMuted &&
        !FlameAudio.bgm.isPlaying &&
        _currentBgmFileName != null) {
      // If not muted, not currently playing, and we have a filename,
      // try to resume/restart it. FlameAudio.bgm.resume() will work if it was just paused.
      // If it was stopped, you need to call loop/play again.
      FlameAudio.bgm.play(
        _currentBgmFileName!,
      ); // Calling play will resume if paused, or restart if stopped.
      _wasBgmPlayingBeforePauseOrMute = true; // Mark as playing
    }
  }
}

final audioPlayerProvider = Provider<IAudioPlayer>((ref) {
  // Use the concrete FlameAudioPlayer implementation
  return FlameAudioPlayer();
});
