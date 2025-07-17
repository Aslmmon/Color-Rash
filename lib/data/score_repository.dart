// lib/data/score_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  static const String _highScoreKey =
      'high_score'; // A key for SharedPreferences

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }
}


final scoreRepositoryProvider = Provider((ref) => ScoreRepository());

