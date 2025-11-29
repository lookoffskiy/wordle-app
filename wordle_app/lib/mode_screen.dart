import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModeScreen extends StatelessWidget {
  const ModeScreen({super.key});

  Widget _modeButton({
    required BuildContext context,
    required String title,
    String? subtitle,
    Color? buttonColor,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        height: 92,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor ?? Colors.grey[850],
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(double.infinity, 50),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                icon ?? Icons.play_circle_outline,
                size: 44,
                color: iconColor ?? Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: GoogleFonts.pangolin(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (subtitle != null) ...[
                      Text(subtitle, style: GoogleFonts.pangolin(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
              const SizedBox(width: 16),
            ],
          ),
        ),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            //ЛОГОТИП
            Text(
              "WORDLE",
              style: GoogleFonts.pangolin(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Text(
              "на русском",
              style: GoogleFonts.pangolin(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 60),

            //КНОПКИ РЕЖИМОВ
            _modeButton(
              context: context,
              title: "4 буквы",
              buttonColor: Colors.indigo[400],
              onPressed: () {
                // Пока просто заглушка
              },
            ),
            _modeButton(
              context: context,
              title: "5 букв",
              buttonColor: Colors.deepPurple[400],
              onPressed: () {},
            ),
            _modeButton(
              context: context,
              title: "6 букв",
              buttonColor: Colors.purple[400],
              onPressed: () {},
            ),
            _modeButton(
              context: context,
              title: "Загадайте другу",
              subtitle: "Придумайте своё слово",
              buttonColor: Colors.orange[400],
              icon: Icons.queue_sharp,
              onPressed: () {},
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}