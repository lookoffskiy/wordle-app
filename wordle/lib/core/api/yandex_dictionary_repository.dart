import 'dart:convert';
import 'package:http/http.dart' as http;

class YandexDictionaryRepository {
  static const String _baseUrl = 'https://dictionary.yandex.net/api/v1/dicservice.json';
  final String _apiKey;
  final http.Client client;

  YandexDictionaryRepository({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        client = client ?? http.Client();

  /// Проверяет существование слова в словаре
  Future<bool> checkWordExists(String word) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/lookup?key=$_apiKey&lang=ru-ru&text=${Uri.encodeComponent(word)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Если есть определения - слово существует
        final hasDefinitions = (data['def'] as List).isNotEmpty;

        if (hasDefinitions) {
          final firstDefinition = data['def'][0];
          final dictionaryWord = firstDefinition['text'] as String;

          return _normalizeWord(dictionaryWord) == _normalizeWord(word);
        }

        return hasDefinitions;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else {
        return false;
      }
    } catch (e) {
      print('Yandex Dictionary API error: $e');
      return false;
    }
  }

  /// Получает информацию о слове
  Future<Map<String, dynamic>?> getWordInfo(String word) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/lookup?key=$_apiKey&lang=ru-ru&text=${Uri.encodeComponent(word)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['def'] as List).isNotEmpty) {
          return data['def'][0];
        }
      }
      return null;
    } catch (e) {
      print('Yandex Dictionary API error: $e');
      return null;
    }
  }

  /// Нормализует слово для сравнения
  String _normalizeWord(String word) {
    return word.toUpperCase().replaceAll('Ё', 'Е');
  }

  /// Получает список поддерживаемых языков
  Future<List<String>> getSupportedLanguages() async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/getLangs?key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      print('Yandex Dictionary API error: $e');
      return [];
    }
  }
}