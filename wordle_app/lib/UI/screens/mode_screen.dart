import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_screen.dart';
import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  bool _useApi = true;

  @override
  void initState() {
    super.initState();
    _loadApiPreference();
  }

  // Загрузка настройки API из SharedPreferences
  Future<void> _loadApiPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useApi = prefs.getBool('use_api') ?? true;
    });
  }

  // Сохранение настройки API в SharedPreferences
  Future<void> _saveApiPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_api', value);
  }

  // Диалог ввода своего слова
  Future<void> _showCustomWordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final String? word = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Загадайте слово",
          style: GoogleFonts.pangolin(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            style: GoogleFonts.pangolin(fontSize: 22, color: Colors.white),
            decoration: InputDecoration(
              hintText: "Слово 5-6 букв",
              hintStyle: GoogleFonts.pangolin(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[850],
              counterText: "",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[А-ЯЁ]')), // ТОЛЬКО РУССКИЕ БУКВЫ
              UpperCaseTextFormatter(), // автоматически в верхний регистр
            ],
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) return "Введите слово";
              if (value.length < 4) return "Минимум 4 буквы";
              if (value.length > 6) return "Максимум 6 букв";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Отмена", style: GoogleFonts.pangolin(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cleanWord = controller.text.replaceAll('Ё', 'Е');
                Navigator.pop(context, cleanWord);
              }
            },
            child: Text("Играть", style: GoogleFonts.pangolin(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (word != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            wordLength: word.length,
            targetWord: word,
            useApi: _useApi,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Переключатель API в AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  "API",
                  style: GoogleFonts.pangolin(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _useApi,
                  onChanged: (value) {
                    setState(() {
                      _useApi = value;
                    });
                    _saveApiPreference(value);
                  },
                  activeColor: Colors.green[400],
                  inactiveThumbColor: Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text("WORDLE", style: GoogleFonts.pangolin(fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
                shadows: const [
                  Shadow(color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8)
                ])),
            Text("на русском", style: GoogleFonts.pangolin(
                fontSize: 18, color: Colors.white60, letterSpacing: 4)),

            // Информация о режиме API
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _useApi ? Colors.green[900]!.withOpacity(0.3) : Colors.blue[900]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _useApi ? Colors.green[400]! : Colors.blue[400]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _useApi ? Icons.cloud : Icons.storage,
                    color: _useApi ? Colors.green[400] : Colors.blue[400],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _useApi ? "Режим: Яндекс API" : "Режим: Локальный словарь",
                    style: GoogleFonts.pangolin(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _modeButton(
              context: context,
              title: "4 буквы",
              buttonColor: Colors.indigo[400],
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GameScreen(
                        wordLength: 4,
                        useApi: _useApi,
                      ))),
            ),
            _modeButton(
              context: context,
              title: "5 букв",
              buttonColor: Colors.deepPurple[400],
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GameScreen(
                        wordLength: 5,
                        useApi: _useApi,
                      ))),
            ),
            _modeButton(
              context: context,
              title: "6 букв",
              buttonColor: Colors.purple[400],
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GameScreen(
                        wordLength: 6,
                        useApi: _useApi,
                      ))),
            ),
            _modeButton(
              context: context,
              title: "Загадайте другу",
              subtitle: "Придумайте своё слово",
              buttonColor: Colors.orange[400],
              icon: Icons.queue_sharp,
              onPressed: () => _showCustomWordDialog(context),
            ),

            const Spacer(),

            // Подсказка внизу экрана
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                _useApi
                    ? "Слова проверяются через Яндекс Словарь"
                    : "Слова проверяются по локальному списку",
                style: GoogleFonts.pangolin(
                  fontSize: 14,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                    Text(title, style: GoogleFonts.pangolin(fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    if (subtitle != null) ...[
                      Text(subtitle, style: GoogleFonts.pangolin(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70)),
                    ],
                  ],
                ),
              ),
              const Icon(
                  Icons.arrow_forward_ios, size: 20, color: Colors.white),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}