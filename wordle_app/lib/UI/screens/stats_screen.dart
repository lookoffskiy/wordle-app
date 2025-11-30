import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordle_app/core/storage/stats_repository.dart';
import 'package:wordle_app/data/models/stats_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<GameStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = StatsRepository().loadStats();
  }

  // Метод для обновления статистики
  void _refreshStats() {
    setState(() {
      _statsFuture = StatsRepository().loadStats();
    });
  }

  Widget _bigStatCard(String value, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor, width: 7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.pangolin(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.pangolin(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pangolin(fontSize: 20, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.pangolin(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Сбросить статистику?",
          style: GoogleFonts.pangolin(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Text(
          "Вы уверены? Все достижения будут удалены навсегда.",
          style: GoogleFonts.pangolin(fontSize: 16, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Отмена", style: GoogleFonts.pangolin(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            onPressed: () async {
              await StatsRepository().saveStats(GameStats.empty());
              Navigator.pop(ctx);
              _refreshStats();
            },
            child: Text("Сбросить", style: GoogleFonts.pangolin(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Статистика",
          style: GoogleFonts.pangolin(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder<GameStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              final stats = snapshot.data ?? GameStats.empty();

              return Column(
                children: [
                  const SizedBox(height: 20),

                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    children: [
                      _bigStatCard(stats.gamesPlayed.toString(), "Игр сыграно", Colors.indigo[300]!),
                      _bigStatCard(stats.gamesWon.toString(), "Побед", Colors.indigo[300]!),
                      _bigStatCard(stats.currentStreak.toString(), "Текущая серия", Colors.indigo[300]!),
                      _bigStatCard(stats.maxStreak.toString(), "Макс. серия", Colors.indigo[300]!),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _statRow("Процент побед", "${stats.winPercentage.toStringAsFixed(1)}%"),
                        const Divider(color: Colors.white12, height: 32),
                        _statRow(
                          "Среднее кол-во попыток",
                          stats.averageGuesses.toStringAsFixed(2),
                          valueColor: Colors.cyan[400],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showResetDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Сбросить статистику",
                        style: GoogleFonts.pangolin(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}