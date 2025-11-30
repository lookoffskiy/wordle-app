import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/game/game_model.dart';

class Keyboard extends StatelessWidget {
  final WordleGame game;
  final Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const Keyboard({
    super.key,
    required this.game,
    required this.onKeyPress,
    required this.onDelete,
    required this.onSubmit,
  });

  static const List<List<String>> letterRows = [
    ["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х"],
    ["Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э"],
    ["Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю", "Ъ"],
  ];

  Color _getKeyColor(String letter) {
    String displayLetter = letter.replaceAll('Ё', 'Е');
    if (game.usedLetters.containsKey(displayLetter)) {
      switch (game.usedLetters[displayLetter]) {
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.orange;
        case 'gray':
          return Colors.grey[700]!;
        default:
          return Colors.grey[850]!;
      }
    }
    return Colors.grey[850]!;
  }

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
              children: row.map((letter) => KeyboardKey(
                letter: letter,
                color: _getKeyColor(letter),
                onPressed: () => onKeyPress(letter),
              )).toList(),
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
                  onPressed: onDelete,
                ),
              ),
              const SizedBox(width: 12),
              // Проверить
              Expanded(
                flex: 7,
                child: _ActionButton(
                  label: "Проверить",
                  color: game.currentGuess.length == game.wordLength
                      ? Colors.green[600]!
                      : Colors.grey[600]!,
                  onPressed: game.currentGuess.length == game.wordLength
                      ? onSubmit
                      : () {}, // Если слово неполное - кнопка неактивна
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
  final Color color;
  final VoidCallback onPressed;

  const KeyboardKey({
    super.key,
    required this.letter,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 58,
              decoration: BoxDecoration(
                color: color,
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

// Кнопки действий
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