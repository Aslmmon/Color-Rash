import 'package:flame_audio/flame_audio.dart';

abstract class IAudioPlayer {
  void playSfx(String fileName);

  void playBgm(String fileName);

  void stopBgm();

  void setMuted(bool muted);

  void pauseBgm();

  void resumeBgm();

  void registerAudioPools({
    // Using named parameters for clarity
    required AudioPool correctTapPool,
    required AudioPool errorTapPool,
    // Add parameters for other pools if you create them
  });

  void disposeAudioPools();
}
