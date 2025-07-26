abstract class IAudioPlayer {
  Future<void> playSfx(String fileName);

  void playBgm(String fileName);

  void stopBgm();

  void setMuted(bool muted);

  void pauseBgm();

  void resumeBgm();
}
