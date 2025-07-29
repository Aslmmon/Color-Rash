import 'package:flame_audio/flame_audio.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:flutter/cupertino.dart';

import '../domain/game_constants.dart';

class FlameAudioPlayer implements IAudioPlayer {
  bool _isGloballyMuted = false;
  String? _currentBgmFileName;
  late AudioPool _correctTapPool;
  late AudioPool _errorTapPool;

  static const double _EffectsDefaultVolume =
      0.5; // Adjust this value (0.0 to 1.0) for desired BGM loudness
  static const double _bgmDefaultVolume =
      1; // Adjust this value (0.0 to 1.0) for desired BGM loudness

  @override
  void playSfx(String fileName) {
    if (!_isGloballyMuted) {
      switch (fileName) {
        case AppAudioPaths.correctTap:
          _correctTapPool.start(volume: _EffectsDefaultVolume);
          break;
        case AppAudioPaths.errorTap:
          _errorTapPool.start(volume: _EffectsDefaultVolume);
          break;
        // For other SFX that are less frequent, you can still use FlameAudio.play directly
        // or create pools for them as well.
        case AppAudioPaths.celebrate:
        case AppAudioPaths.gameOver:
          FlameAudio.play(
            fileName,
            volume: _EffectsDefaultVolume,
          ); // Use direct play for less frequent sounds
          break;
        default:
          // Fallback for unknown SFX if any
          FlameAudio.play(fileName, volume: _EffectsDefaultVolume);
          break;
      }
    }
  }

  @override
  void playBgm(String fileName) {
    _currentBgmFileName = fileName;
    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play(
        fileName,
        volume: _isGloballyMuted ? 0.0 : _bgmDefaultVolume,
      ); // Play BGM
    }
  }

  @override
  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  @override
  void setMuted(bool muted) {
    _isGloballyMuted = muted;
    debugPrint("isGloballyMuted  " +_isGloballyMuted.toString());
    if (_isGloballyMuted) {
      FlameAudio.bgm.audioPlayer.setVolume(0.0); // MUTE: Set volume to 0
    } else {
      FlameAudio.bgm.audioPlayer.setVolume(
        _bgmDefaultVolume,
      );
      FlameAudio.bgm.resume();

    }
  }

  @override
  void pauseBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
    }
  }

  @override
  void resumeBgm() {
    if (!_isGloballyMuted && _currentBgmFileName != null) {
      FlameAudio.bgm.resume();
    }
  }

  @override
  void registerAudioPools({
    required AudioPool correctTapPool,
    required AudioPool errorTapPool,
  }) {
    _correctTapPool = correctTapPool;
    _errorTapPool = errorTapPool;
  }

  @override
  void disposeAudioPools() {
    _correctTapPool.dispose();
    _errorTapPool.dispose();
  }
}
