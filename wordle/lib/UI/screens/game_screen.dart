import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/game/game_model.dart';
import '../../core/storage/stats_repository.dart';
import '../../UI/widgets/keyboard.dart';
import '../../core/api/yandex_dictionary_repository.dart';

class GameScreen extends StatefulWidget {
  final int wordLength;
  final String? targetWord;
  final bool useApi;

  const GameScreen({
    super.key,
    required this.wordLength,
    this.targetWord,
    this.useApi = true,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late WordleGame game;
  bool isLoading = true;
  bool _isGameOverDialogShown = false;
  bool _isCheckingWord = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    YandexDictionaryRepository? dictionaryRepository;

    if (widget.useApi) {
      dictionaryRepository = YandexDictionaryRepository(
        apiKey: 'dict.1.1.20251130T173105Z.997642bdb75df6c8.60aecc9bcd835bc3056a24650f0b513e7cef40ed',
      );
    }

    game = WordleGame(
      wordLength: widget.wordLength,
      customWord: widget.targetWord,
      dictionaryRepository: dictionaryRepository, // Может быть null
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

  // Изменен на асинхронный метод
  Future<void> _handleSubmit() async {
    if (_isCheckingWord) return;

    setState(() {
      _isCheckingWord = true;
    });

    try {
      await game.submitGuess();

      // Проверяем, нужно ли показать диалог окончания игры
      if (game.gameOver && !_isGameOverDialogShown) {
        _isGameOverDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showGameOverDialog();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingWord = false;
        });
      }
    }
  }

  void _showGameOverDialog() async {
    // Сохраняем статистику
    final statsRepo = StatsRepository();
    if (game.victory) {
      await statsRepo.recordGame(won: true, guesses: game.guesses.length);
    } else {
      await statsRepo.recordGame(won: false, guesses: 6);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          game.victory ? "Победа!" : "Игра окончена",
          style: GoogleFonts.pangolin(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: game.victory ? Colors.green[400] : Colors.red[400],
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              game.victory
                  ? "Вы угадали слово за ${game.guesses.length} ${_getAttemptWord(game.guesses.length)}!"
                  : "Загаданное слово:\n${game.targetWord}",
              style: GoogleFonts.pangolin(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                  style: GoogleFonts.pangolin(color: Colors.green[400], fontSize: 18),
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
                  style: GoogleFonts.pangolin(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((_) {
      _isGameOverDialogShown = false;
    });
  }

  // Вспомогательная функция для правильного склонения
  String _getAttemptWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return "попытку";
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) return "попытки";
    return "попыток";
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