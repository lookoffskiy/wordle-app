// core/storage/stats_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle_app/data/models/stats_model.dart';
import 'dart:convert';
import 'dart:math';

class StatsRepository {
  static const _statsKey = 'game_stats';

  Future<GameStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statsKey);
    if (jsonString == null) return GameStats.empty();

    final Map<String, dynamic> json = Map.from(jsonDecode(jsonString));
    return GameStats.fromJson(json);
  }

  Future<void> saveStats(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> recordGame({required bool won, required int guesses}) async {
    final stats = await loadStats();

    final newStats = GameStats(
      gamesPlayed: stats.gamesPlayed + 1,
      gamesWon: won ? stats.gamesWon + 1 : stats.gamesWon,
      currentStreak: won ? stats.currentStreak + 1 : 0,
      maxStreak: won ? max(stats.maxStreak, stats.currentStreak + 1) : stats.maxStreak,
      guessDistribution: won
          ? stats.guessDistribution.mapIndexed((i, v) => i == guesses - 1 ? v + 1 : v).toList()
          : stats.guessDistribution,
    );

    await saveStats(newStats);
  }
}

// Вспомогательный extension
extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}