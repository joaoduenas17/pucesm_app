import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';

class PucemApi {
  static const _base = 'https://api.pucesm.edu.ec';

  static Uri newsListUri() => Uri.parse('$_base/content/list/seccion/news/');
  static Uri imageUri(String name) =>
      Uri.parse('$_base/content/take/file/?name=$name');

  /// Headers base (imitan navegador real)
  static Map<String, String> defaultHeaders({bool isImage = false}) => {
        'Origin': 'https://pucem.edu.ec',
        'Referer': 'https://pucem.edu.ec/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': isImage
            ? 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8'
            : 'application/json, text/plain, */*',
      };

  static Future<List<NewsItem>> fetchNews() async {
    final res = await http.get(newsListUri(), headers: defaultHeaders());

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) {
      throw Exception('Respuesta inesperada: no es una lista');
    }

    // OJO: decoded es List<dynamic>, cada item es Map<String, dynamic>
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(NewsItem.fromJson)
        .toList();
  }
}
