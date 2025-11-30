import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  // Маленький цветной квадратик для демонстрации
  Widget _colorTile(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Center(
            child: Text(
              "А",
              style: GoogleFonts.pangolin(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.pangolin(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Правила игры",
          style: GoogleFonts.pangolin(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 1
              _buildRuleCard(
                number: "1",
                text:
                "У вас есть 6 попыток, чтобы угадать слово.\nВведите слово с помощью клавиатуры и нажмите «ПРОВЕРИТЬ».",
              ),

              const SizedBox(height: 20),

              // 2 + демонстрация цветов
              _buildRuleCard(
                number: "2",
                text: "Цвета букв — это подсказки:",
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 4),
                  child: Column(
                    children: [
                      _colorTile(const Color(0xFF6AAA64), "Буква на своём месте"),
                      const SizedBox(height: 12),
                      _colorTile(const Color(0xFFC9B458), "Буква есть в слове, но не на \nэтом месте"),
                      const SizedBox(height: 12),
                      _colorTile(Colors.grey[700]!, "Буквы нет в загаданном слове"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3
              _buildRuleCard(
                number: "3",
                text: "Загадываются только существительные в именительном падеже единственного числа.",
              ),

              const SizedBox(height: 20),

              // 4
              _buildRuleCard(
                number: "4",
                text: "Буква «Ё» не используется — её нет в загадываемых словах.",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Универсальная карточка правила
  Widget _buildRuleCard({
    required String number,
    required String text,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.pangolin(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.pangolin(
                    fontSize: 19,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}