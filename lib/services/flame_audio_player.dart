import 'package:flame_audio/flame_audio.dart';
import 'package:color_rash/core/audio_player.dart';

class FlameAudioPlayer implements IAudioPlayer {
  bool _isGloballyMuted = false;
  String? _currentBgmFileName;

  static const double _EffectsDefaultVolume =
      0.8; // Adjust this value (0.0 to 1.0) for desired BGM loudness
  static const double _bgmDefaultVolume =
      1; // Adjust this value (0.0 to 1.0) for desired BGM loudness

  @override
  Future<void> playSfx(String fileName) async {
    if (!_isGloballyMuted) {
      await FlameAudio.play(fileName, volume: _EffectsDefaultVolume);
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
    if (_isGloballyMuted) {
      FlameAudio.bgm.audioPlayer.setVolume(0.0); // MUTE: Set volume to 0
    } else {
      FlameAudio.bgm.audioPlayer.setVolume(
        _bgmDefaultVolume,
      ); // UNMUTE: Restore volume to default
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
      // Ensure volume is correct before playing/resuming
      FlameAudio.bgm.play(
        _currentBgmFileName!,
        volume: _bgmDefaultVolume,
      ); // Calling play will resume if paused, or restart if stopped.
    }
  }
}
