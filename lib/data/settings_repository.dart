import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _highScoreKey =
      'high_score'; // A key for SharedPreferences
  static const String _hasSeenTutorialKey =
      'has_seen_tutorial'; // <--- NEW CONSTANT

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  Future<bool> getHasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTutorialKey) ??
        false; // Default to false (not seen)
  }

  Future<void> setHasSeenTutorial(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTutorialKey, seen);
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());
