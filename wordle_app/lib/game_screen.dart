import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Wordle",
          style: GoogleFonts.pangolin(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Column(
        children: [
          SizedBox(height: 20),
          Expanded(child: WordleGrid(rows: 6, columns: 5)),
          Keyboard(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

//Сетка игрового поля
class WordleGrid extends StatelessWidget {
  final int rows;
  final int columns;

  const WordleGrid({super.key, this.rows = 6, this.columns = 5});

  BorderRadius? _borderRadius(int row, int col) {
    const r = Radius.circular(8);
    if (row == 0 && col == 0) return const BorderRadius.only(topLeft: r);
    if (row == 0 && col == columns - 1) return const BorderRadius.only(topRight: r);
    if (row == rows - 1 && col == 0) return const BorderRadius.only(bottomLeft: r);
    if (row == rows - 1 && col == columns - 1) return const BorderRadius.only(bottomRight: r);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = (constraints.maxWidth - 16) / columns; //

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(rows, (r) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(columns, (c) => Padding(
              padding: const EdgeInsets.all(2.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: tileSize - 4,
                height: tileSize - 4,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: _borderRadius(r, c),
                ),
                child: Center(
                  child: Text(
                    "",
                    style: GoogleFonts.pangolin(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )),
          )),
        );
      },
    );
  }
}

//КЛАВИАТУРА
class Keyboard extends StatelessWidget {
  const Keyboard({super.key});

  static const List<List<String>> letterRows = [
    ["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х"],
    ["Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э"],
    ["Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю", "Ъ"],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Буквенные ряды
          ...letterRows.map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) => KeyboardKey(letter)).toList(),
            ),
          )),

          const SizedBox(height: 12),

          // Кнопки Стереть + Проверить
          Row(
            children: [
              // Стереть
              Expanded(
                flex: 3,
                child: _ActionButton(
                  label: "⌫",
                  color: Colors.grey[700]!,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              // Проверить
              Expanded(
                flex: 7,
                child: _ActionButton(
                  label: "Проверить",
                  color: Colors.green[600]!,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// Обычная клавиша
class KeyboardKey extends StatelessWidget {
  final String letter;
  const KeyboardKey(this.letter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {}, // потом добавишь ввод буквы
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.pangolin(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Кнопки действий (Стереть / Проверить)
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
        child: Text(
          label,
          style: GoogleFonts.pangolin(
            fontSize: label == "⌫" ? 26 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}