import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../core/api/yandex_dictionary_repository.dart';

class WordleGame {
  final int wordLength;
  String targetWord = "";
  List<String> guesses = [];
  String currentGuess = "";
  bool gameOver = false;
  bool victory = false;
  Map<String, String> usedLetters = {};
  String errorMessage = "";

  List<String> targetWords = [];
  List<String> checkWords = []; // Слова для проверки

  final YandexDictionaryRepository? dictionaryRepository;

  WordleGame({
    required this.wordLength,
    String? customWord,
    this.dictionaryRepository,
  }) {
    if (customWord != null) {
      targetWord = customWord.toUpperCase().replaceAll('Ё', 'Е');
    }
  }

  Future<void> loadWords() async {
    try {
      // Загружаем слова для загадывания из локальных файлов
      String targetWordsFile = _getWordListPath(wordLength, forGuessing: true);
      String targetContent = await rootBundle.loadString(targetWordsFile);
      targetWords = targetContent.split('\n')
          .map((word) => word.trim().toUpperCase().replaceAll('Ё', 'Е'))
          .where((word) => word.length == wordLength && word.isNotEmpty)
          .toList();

      // Загружаем слова для проверки из основного словаря
      String checkWordsFile = _getWordListPath(wordLength, forGuessing: false);
      String checkContent = await rootBundle.loadString(checkWordsFile);
      checkWords = checkContent.split('\n')
          .map((word) => word.trim().toUpperCase().replaceAll('Ё', 'Е'))
          .where((word) => word.length == wordLength && word.isNotEmpty)
          .toList();

      // Добавляем targetWords в checkWords если их там нет
      for (String word in targetWords) {
        if (!checkWords.contains(word)) {
          checkWords.add(word);
        }
      }

      // Выбираем случайное слово
      if (targetWord.isEmpty) {
        final random = Random();
        targetWord = targetWords[random.nextInt(targetWords.length)];
      }

      print("Loaded ${targetWords.length} target words and ${checkWords.length} check words for length $wordLength");
      print("Using API: ${dictionaryRepository != null}");

    } catch (e) {
      print("Error loading words: $e");
      throw Exception("Не удалось загрузить словари. Проверьте файлы в assets/dict/");
    }
  }

  Future<void> submitGuess() async {
    if (currentGuess.length == wordLength && !gameOver) {
      if (dictionaryRepository != null) {
        print("Checking word with Yandex API: $currentGuess");
        await _checkWordWithYandex(currentGuess);
      } else {
        print("Checking word locally: $currentGuess");
        _checkWordLocally(currentGuess);
      }
    }
  }

  Future<void> _checkWordWithYandex(String word) async {
    try {
      // Проверяем что репозиторий не null (дополнительная проверка)
      if (dictionaryRepository == null) {
        print("DictionaryRepository is null, falling back to local check");
        _checkWordLocally(word);
        return;
      }

      final exists = await dictionaryRepository!.checkWordExists(word);

      if (exists) {
        errorMessage = "";
        _processGuess();
      } else {
        errorMessage = "Слово не найдено в словаре!";
        print("Word '$word' not found in Yandex dictionary");
        // Автоматически очищаем сообщение через 2 секунды
        Future.delayed(const Duration(seconds: 2), () {
          errorMessage = "";
        });
      }
    } catch (e) {
      // Если API недоступно, проверяем по локальному списку
      print("Yandex API error: $e, falling back to local check");
      errorMessage = "Ошибка API, проверяем локально...";
      _checkWordLocally(word);
    }
  }

  void _checkWordLocally(String word) {
    print("Local check for '$word'. Check words list: ${checkWords.length} words");
    print("Check words contains '$word': ${checkWords.contains(word)}");

    if (checkWords.contains(word)) {
      errorMessage = "";
      _processGuess();
    } else {
      errorMessage = "Слово не найдено в локальном словаре!";
      print("Word '$word' not found in local dictionary");
      Future.delayed(const Duration(seconds: 2), () {
        errorMessage = "";
      });
    }
  }

  String _getWordListPath(int length, {bool forGuessing = false}) {
    if (forGuessing) {
      switch (length) {
        case 4: return 'assets/dict/four_letter.txt';
        case 5: return 'assets/dict/five_letter.txt';
        case 6: return 'assets/dict/six_letter.txt';
        default: return 'assets/dict/five_letter.txt';
      }
    } else {
      // Для проверки используем основной словарь
      return 'assets/dict/dict.txt';
    }
  }

  void addLetter(String letter) {
    if (currentGuess.length < wordLength && !gameOver) {
      currentGuess += letter.toUpperCase().replaceAll('Ё', 'Е');
      errorMessage = "";
    }
  }

  void deleteLetter() {
    if (!gameOver && currentGuess.isNotEmpty) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      errorMessage = "";
    }
  }

  void _processGuess() {
    // Создаем копии для обработки
    List<String> targetRemaining = targetWord.split('');
    List<String> guessLetters = currentGuess.split('');

    // Массив для хранения цветов каждой буквы
    List<String?> letterColors = List<String?>.filled(wordLength, null);

    // Первый проход: точные совпадения (зеленые)
    for (int i = 0; i < wordLength; i++) {
      if (guessLetters[i] == targetRemaining[i]) {
        letterColors[i] = 'green';
        usedLetters[guessLetters[i]] = 'green';
        targetRemaining[i] = ''; // Помечаем как использованную
      }
    }

    // Второй проход: частичные совпадения (желтые)
    for (int i = 0; i < wordLength; i++) {
      if (letterColors[i] == 'green') continue; // Уже зеленые пропускаем

      if (targetRemaining.contains(guessLetters[i])) {
        int j = targetRemaining.indexOf(guessLetters[i]);
        targetRemaining[j] = ''; // Помечаем как использованную
        letterColors[i] = 'yellow';
        // Обновляем usedLetters только если не было зеленого
        if (usedLetters[guessLetters[i]] != 'green') {
          usedLetters[guessLetters[i]] = 'yellow';
        }
      }
    }

    // Третий проход: серые буквы
    for (int i = 0; i < wordLength; i++) {
      if (letterColors[i] == null) {
        letterColors[i] = 'gray';
        // Обновляем usedLetters только если не было зеленого или желтого
        if (!usedLetters.containsKey(guessLetters[i])) {
          usedLetters[guessLetters[i]] = 'gray';
        }
      }
    }

    guesses.add(currentGuess);

    if (currentGuess == targetWord) {
      victory = true;
      gameOver = true;
    } else if (guesses.length >= 6) {
      gameOver = true;
    }

    currentGuess = "";
  }

  void reset() {
    final random = Random();
    guesses.clear();
    currentGuess = "";
    gameOver = false;
    victory = false;
    usedLetters.clear();
    errorMessage = "";
    if (targetWords.isNotEmpty) {
      targetWord = targetWords[random.nextInt(targetWords.length)];
    }
  }

  // Геттер для получения буквы в определенной позиции (для отрисовки)
  String getLetterAt(int row, int col) {
    if (row < guesses.length) {
      return guesses[row][col];
    } else if (row == guesses.length && col < currentGuess.length) {
      return currentGuess[col];
    }
    return "";
  }

  // Геттер для получения цвета буквы в определенной позиции
  Color getLetterColorAt(int row, int col) {
    if (row >= guesses.length) return Colors.grey[850]!;

    String letter = guesses[row][col];

    // Точное совпадение - зеленый
    if (letter == targetWord[col]) {
      return Colors.green;
    }

    // Проверяем есть ли буква в слове
    if (targetWord.contains(letter)) {
      // Считаем количество вхождений в загаданном слове
      int targetCount = targetWord.split('').where((l) => l == letter).length;

      // Считаем количество уже правильно угаданных (зеленых) этой буквы
      int correctPositions = 0;
      for (int i = 0; i < wordLength; i++) {
        if (guesses[row][i] == letter && targetWord[i] == letter) {
          correctPositions++;
        }
      }

      // Считаем количество этой буквы в текущей догадке до текущей позиции
      int occurrencesBefore = 0;
      for (int i = 0; i <= col; i++) {
        if (guesses[row][i] == letter) {
          occurrencesBefore++;
        }
      }

      // Если это вхождение должно быть желтым
      if (occurrencesBefore <= targetCount - correctPositions) {
        return Colors.orange;
      }
    }

    // Серый цвет для остальных случаев
    return Colors.grey[700]!;
  }
}