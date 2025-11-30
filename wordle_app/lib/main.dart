import 'package:flutter/material.dart';
import 'package:wordle_app/UI/screens/home_screen.dart';
import 'package:wordle_app/UI/screens/mode_screen.dart';
import 'package:wordle_app/UI/screens/rules_screen.dart';
import 'package:wordle_app/UI/screens/stats_screen.dart';
import 'UI/screens/game_screen.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}