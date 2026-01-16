import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import '../models/course_item.dart';

class PucemApi {
  static const _base = 'https://api.pucesm.edu.ec';

  // ======================
  // NEWS (CONTENT)
  // ======================
  static Uri newsListUri() => Uri.parse('$_base/content/list/seccion/news/');

  /// Nombres explícitos (recomendado)
  static Uri contentImageUri(String name) =>
      Uri.parse('$_base/content/take/file/?name=$name');

  static Uri contentFileUri(String name) =>
      Uri.parse('$_base/content/take/file/?name=$name');

  /// Compat: si ya tienes pantallas usando imageUri/fileUri para NOTICIAS, se mantiene
  static Uri imageUri(String name) => contentImageUri(name);
  static Uri fileUri(String name) => contentFileUri(name);

  // ======================
  // COURSES (GRADO/POSGRADO)
  // ======================
  static Uri coursesListUri(int type) =>
      Uri.parse('$_base/courses/list/?id_type=$type');

  /// Imagen/archivo asociado a "courses" (carreras/programas)
  /// Endpoint correcto para cursos: /courses/take/file/
  static Uri courseImageUri(String name) =>
      Uri.parse('$_base/courses/take/file/?name=$name');

  /// PDFs/archivos asociados a cursos (si vienen por el mismo endpoint)
  static Uri courseFileUri(String name) =>
      Uri.parse('$_base/courses/take/file/?name=$name');

  /// Alias opcionales (por si te gusta más el naming)
  static Uri coursesImageUri(String name) => courseImageUri(name);
  static Uri coursesFileUri(String name) => courseFileUri(name);

  // ======================
  // HEADERS
  // ======================
  /// Headers base (imitan navegador real)
  /// - Para imágenes: usa isImage = true
  /// - Para PDFs/archivos: usa isFile = true
  static Map<String, String> defaultHeaders({
    bool isImage = false,
    bool isFile = false,
  }) {
    final headers = <String, String>{
      // Esto es lo que típicamente evita el bloqueo anti-hotlink:
      'Origin': 'https://pucem.edu.ec',
      'Referer': 'https://pucem.edu.ec/',

      // Similar a navegador real
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',

      // Extras útiles
      'Accept-Language': 'es-419,es;q=0.9',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };

    if (isImage) {
      headers['Accept'] =
          'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    } else if (isFile) {
      headers['Accept'] = 'application/pdf,application/octet-stream,*/*';
    } else {
      headers['Accept'] = 'application/json, text/plain, */*';
    }

    return headers;
  }

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
    final res = await http.get(coursesListUri(type), headers: defaultHeaders());

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
