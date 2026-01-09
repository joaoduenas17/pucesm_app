import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import '../models/course_item.dart';

class PucemApi {
  static const _base = 'https://api.pucesm.edu.ec';

  // ======================
  // NEWS
  // ======================
  static Uri newsListUri() => Uri.parse('$_base/content/list/seccion/news/');
  static Uri imageUri(String name) =>
      Uri.parse('$_base/content/take/file/?name=$name');

  // ======================
  // COURSES (GRADO/POSGRADO)
  // ======================
  static Uri coursesListUri(int type) =>
      Uri.parse('$_base/courses/list/?id_type=$type');

  // ======================
  // FILES (PDF/IMAGES)
  // ======================
  static Uri fileUri(String name) =>
      Uri.parse('$_base/content/take/file/?name=$name');

  /// Headers base (imitan navegador real)
  /// - Para imágenes/PDFs: pon isImage/isFile en true para Accept correcto.
  static Map<String, String> defaultHeaders({
    bool isImage = false,
    bool isFile = false,
  }) =>
      {
        'Origin': 'https://pucem.edu.ec',
        'Referer': 'https://pucem.edu.ec/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': isImage
            ? 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8'
            : isFile
                ? 'application/pdf,application/octet-stream,*/*'
                : 'application/json, text/plain, */*',
      };

  // ======================
  // FETCH NEWS
  // ======================
  static Future<List<NewsItem>> fetchNews() async {
    final res = await http.get(newsListUri(), headers: defaultHeaders());

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) {
      throw Exception('Respuesta inesperada: no es una lista');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(NewsItem.fromJson)
        .toList();
  }

  // ======================
  // FETCH COURSES
  // type: 1=Grado | 2=Posgrado
  // ======================
  static Future<List<CourseItem>> fetchCourses(int type) async {
    final res = await http.get(
      coursesListUri(type),
      headers: defaultHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) {
      throw Exception('Respuesta inesperada: no es una lista');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CourseItem.fromJson)
        .toList();
  }
}
