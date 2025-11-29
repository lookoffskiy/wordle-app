import 'package:flutter/material.dart';
import 'package:wordle_app/home_screen.dart';
import 'package:wordle_app/mode_screen.dart';
import 'package:wordle_app/rules_screen.dart';
import 'package:wordle_app/stats_screen.dart';
import 'game_screen.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}