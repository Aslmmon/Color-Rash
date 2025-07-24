import 'package:flame_audio/flame_audio.dart';
import 'package:color_rash/core/audio_player.dart';

class FlameAudioPlayer implements IAudioPlayer {
  bool _isGloballyMuted = false;
  String? _currentBgmFileName;
  bool _wasBgmPlayingBeforePauseOrMute = false;

  // Define a default/unmuted volume level for BGM
  static const double _bgmDefaultVolume =
      0.5; // Adjust this value (0.0 to 1.0) for desired BGM loudness

  @override
  Future<void> playSfx(String fileName) async {
    if (!_isGloballyMuted) {
      await FlameAudio.play(fileName);
    }
  }

  @override
  void playBgm(String fileName) {
    _currentBgmFileName = fileName;
    if (!FlameAudio.bgm.isPlaying) {
      // Only start if not muted and not already playing, setting volume based on current mute state
      FlameAudio.bgm.audioPlayer.setVolume(
        _isGloballyMuted ? 0.0 : _bgmDefaultVolume,
      ); // Set initial volume
      FlameAudio.bgm.play(fileName);
      _wasBgmPlayingBeforePauseOrMute = true;
    }
  }

  @override
  void stopBgm() {
    FlameAudio.bgm.stop();
    _wasBgmPlayingBeforePauseOrMute = false;
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
      _wasBgmPlayingBeforePauseOrMute = true;
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
      _wasBgmPlayingBeforePauseOrMute = true;
    }
  }
}
