// stats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  final int gamesPlayed = 142;
  final int totalWins = 118;
  final int currentStreak = 12;
  final int maxStreak = 27;
  final double winPercentage = 83.1;
  final double avgGuesses = 3.94;

  // Большая карточка статистики
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

  // Маленькая карточка статистики
  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pangolin(
              fontSize: 20,
              color: Colors.white70,
            ),
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
          style: GoogleFonts.pangolin(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
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
                  _bigStatCard(gamesPlayed.toString(), "Игр сыграно", Colors.indigo[300]!),
                  _bigStatCard(totalWins.toString(), "Побед", Colors.indigo[300]!),
                  _bigStatCard(currentStreak.toString(), "Текущая серия", Colors.indigo[300]!),
                  _bigStatCard(maxStreak.toString(), "Макс. серия", Colors.indigo[300]!),
                ],
              ),

              const SizedBox(height: 32),

              // Дополнительная статистика
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _statRow("Процент побед", "${winPercentage.toStringAsFixed(1)}%"),
                    const Divider(color: Colors.white12, height: 32),
                    _statRow(
                      "Среднее кол-во попыток",
                      avgGuesses.toStringAsFixed(2),
                      valueColor: Colors.cyan[400],
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}