import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/news_item.dart';
import '../models/course_item.dart';

class PucemApi {
  // ======================
  // BASES
  // ======================
  /// ✅ Base del backend propio (local o deploy)
  static String get _base => apiBase();

  /// ✅ Base “legacy” (API real PUCE SM) — la mantenemos para imágenes/PDF
  static const String _legacyBase = 'https://api.pucesm.edu.ec';

  // ======================
  // NEWS (BACKEND PROPIO)
  // ======================
  /// Backend nuevo: GET /api/news
  static Uri newsListUri() => Uri.parse('$_base/api/news');

  // ======================
  // NEWS FILES (LEGACY)
  // ======================
  /// ✅ URL-encoding correcto (legacy)
  static Uri contentImageUri(String name) =>
      Uri.parse('$_legacyBase/content/take/file/').replace(
        queryParameters: {'name': name},
      );

  static Uri contentFileUri(String name) =>
      Uri.parse('$_legacyBase/content/take/file/').replace(
        queryParameters: {'name': name},
      );

  /// Compat: si ya tienes pantallas usando imageUri/fileUri para NOTICIAS
  static Uri imageUri(String name) => contentImageUri(name);
  static Uri fileUri(String name) => contentFileUri(name);

  // ======================
  // COURSES (BACKEND PROPIO)
  // ======================
  /// Backend nuevo: GET /api/courses?type=grado|posgrado
  static Uri coursesListUri(int type) {
    final t = type == 2 ? 'posgrado' : 'grado';
    return Uri.parse('$_base/api/courses').replace(
      queryParameters: {'type': t},
    );
  }

  // ======================
  // COURSES FILES (LEGACY)
  // ======================
  /// ✅ URL-encoding correcto (legacy)
  static Uri courseImageUri(String name) =>
      Uri.parse('$_legacyBase/courses/take/file/').replace(
        queryParameters: {'name': name},
      );

  /// ✅ URL-encoding correcto (legacy)
  static Uri courseFileUri(String name) =>
      Uri.parse('$_legacyBase/courses/take/file/').replace(
        queryParameters: {'name': name},
      );

  /// Alias opcionales
  static Uri coursesImageUri(String name) => courseImageUri(name);
  static Uri coursesFileUri(String name) => courseFileUri(name);

  // ======================
  // HEADERS
  // ======================
  /// ✅ Para backend propio NO necesitas anti-hotlink.
  /// ✅ Para legacy sí ayuda (imágenes/pdf).
  static Map<String, String> defaultHeaders({
    bool isImage = false,
    bool isFile = false,
    bool legacy = false,
  }) {
    final headers = <String, String>{
      'Accept-Language': 'es-419,es;q=0.9',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };

    // Solo aplica Origin/Referer/User-Agent cuando pegamos a la API legacy (anti-hotlink)
    if (legacy) {
      headers.addAll({
        'Origin': 'https://pucem.edu.ec',
        'Referer': 'https://pucem.edu.ec/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      });
    }

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
  // FETCH NEWS (BACKEND)
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
  // FETCH COURSES (BACKEND)
  // ======================
  /// type: 1=Grado | 2=Posgrado
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
