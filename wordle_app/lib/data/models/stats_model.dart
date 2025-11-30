class GameStats {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;

  GameStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.currentStreak,
    required this.maxStreak,
    required this.guessDistribution,
  });

  double get winPercentage => gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed * 100);

  double get averageGuesses {
    if (gamesWon == 0) return 0;
    double total = 0;
    for (int i = 0; i < guessDistribution.length; i++) {
      total += guessDistribution[i] * (i + 1);
    }
    return total / gamesWon;
  }

  factory GameStats.empty() => GameStats(
    gamesPlayed: 0,
    gamesWon: 0,
    currentStreak: 0,
    maxStreak: 0,
    guessDistribution: List.filled(6, 0),
  );

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'currentStreak': currentStreak,
    'maxStreak': maxStreak,
    'guessDistribution': guessDistribution,
  };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    gamesPlayed: json['gamesPlayed'] ?? 0,
    gamesWon: json['gamesWon'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    maxStreak: json['maxStreak'] ?? 0,
    guessDistribution: List<int>.from(json['guessDistribution'] ?? List.filled(6, 0)),
  );
}