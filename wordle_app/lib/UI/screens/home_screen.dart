import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mode_screen.dart';
import 'rules_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _currentScreen() {
    switch (_currentIndex) {
      case 0:
        return const ModeScreen(key: ValueKey('mode'));
      case 1:
        return const RulesScreen(key: ValueKey('rules'));
      case 2:
        return const StatsScreen(key: ValueKey('stats'));
      default:
        return const ModeScreen(key: ValueKey('mode'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        child: _currentScreen(),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: GoogleFonts.pangolin(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: GoogleFonts.pangolin(fontSize: 14),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.play_arrow_rounded),
                activeIcon: Icon(Icons.play_arrow_rounded, size: 32), label: 'Играть'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded),
                activeIcon: Icon(Icons.menu_book_rounded, size: 32), label: 'Правила'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),
                activeIcon: Icon(Icons.bar_chart_rounded, size: 32), label: 'Статистика'),
          ],
        ),
      ),
    );
  }
}