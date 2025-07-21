abstract class IAudioPlayer {
  Future<void> playSfx(String fileName);

  void playBgm(String fileName); // <--- NEW
  void stopBgm(); // <--- NEW
  void setMuted(bool muted); // <--- NEW: For global mute control
  void pauseBgm(); // <--- NEW: For pausing
  void resumeBgm(); // <--- NEW: For resuming
}
