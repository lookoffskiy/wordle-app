import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_model.dart';

class GameScreen extends StatefulWidget {
  final int wordLength;
  final String? targetWord;

  const GameScreen({
    super.key,
    required this.wordLength,
    this.targetWord,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late WordleGame game;
  bool isLoading = true;
  bool _isGameOverDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    game = WordleGame(
      wordLength: widget.wordLength,
      customWord: widget.targetWord,
    );
    await game.loadWords();
    setState(() {
      isLoading = false;
    });
  }

  void _handleKeyPress(String letter) {
    setState(() {
      game.addLetter(letter);
    });
  }

  void _handleDelete() {
    setState(() {
      game.deleteLetter();
    });
  }

  void _handleSubmit() {
    setState(() {
      game.submitGuess();
    });

    // Проверяем, нужно ли показать диалог окончания игры
    if (game.gameOver && !_isGameOverDialogShown) {
      _isGameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          game.victory ? "Победа! 🎉" : "Игра окончена",
          style: GoogleFonts.pangolin(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          game.victory
              ? "Вы угадали слово!"
              : "Загаданное слово: ${game.targetWord}",
          style: GoogleFonts.pangolin(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                game.reset();
                _isGameOverDialogShown = false;
              });
            },
            child: Text(
              "Играть снова",
              style: GoogleFonts.pangolin(color: Colors.green),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "В меню",
              style: GoogleFonts.pangolin(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isGameOverDialogShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange[600]),
              const SizedBox(height: 20),
              Text(
                "Загрузка...",
                style: GoogleFonts.pangolin(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
      body: Column(
        children: [
          if (game.errorMessage.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                game.errorMessage,
                style: GoogleFonts.pangolin(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: WordleGrid(
              columns: widget.wordLength,
              game: game,
            ),
          ),
          Keyboard(
            game: game,
            onKeyPress: _handleKeyPress,
            onDelete: _handleDelete,
            onSubmit: _handleSubmit,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// Сетка игрового поля
class WordleGrid extends StatelessWidget {
  final int columns;
  final int rows = 6;
  final WordleGame game;

  const WordleGrid({
    super.key,
    required this.columns,
    required this.game,
  });

  Color _getCellColor(int row, int col) {
    // Активная клетка для текущего ввода
    if (row == game.guesses.length && col == game.currentGuess.length && !game.gameOver) {
      return Colors.grey[800]!;
    }

    // Заполненные клетки с угаданными словами
    if (row < game.guesses.length) {
      return game.getLetterColorAt(row, col);
    }

    // Пустые клетки
    return Colors.grey[850]!;
  }

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
        final availableWidth = constraints.maxWidth - 28;
        final tileSize = availableWidth / columns;
        final totalHeight = tileSize * rows + (rows - 1) * 4;

        return Center(
          child: SizedBox(
            width: availableWidth,
            height: totalHeight,
            child: Column(
              children: List.generate(rows, (r) => Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(columns, (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _getCellColor(r, c),
                          borderRadius: _borderRadius(r, c),
                          border: _getCellBorder(r, c),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              game.getLetterAt(r, c),
                              key: ValueKey('${r}_${c}_${game.getLetterAt(r, c)}'),
                              style: GoogleFonts.pangolin(
                                fontSize: tileSize * 0.55,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              )),
            ),
          ),
        );
      },
    );
  }

  Border? _getCellBorder(int row, int col) {
    if (row == game.guesses.length && col == game.currentGuess.length && !game.gameOver) {
      return Border.all(color: Colors.white, width: 2);
    }
    return null;
  }
}

// Клавиатура
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