import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  // ===== Tema / accesibilidad =====
  bool darkMode = false;
  double textScale = 1.0;
  bool reduceMotion = false;

  // ===== Perfil =====
  String? profileImagePath;

  String fullName = 'Joao Dueñas';
  String email = 'joao.duenas@puce.edu.ec';
  String career = 'Ingeniería de Software';
  String campus = 'PUCE Manabí';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    darkMode = prefs.getBool('darkMode') ?? false;
    textScale = prefs.getDouble('textScale') ?? 1.0;
    reduceMotion = prefs.getBool('reduceMotion') ?? false;

    // datos de perfil
    fullName = prefs.getString('fullName') ?? fullName;
    email = prefs.getString('email') ?? email;
    career = prefs.getString('career') ?? career;
    campus = prefs.getString('campus') ?? campus;

    // foto
    final savedPath = prefs.getString('profileImagePath');
    if (savedPath != null && savedPath.isNotEmpty) {
      if (File(savedPath).existsSync()) {
        profileImagePath = savedPath;
      } else {
        profileImagePath = null;
        await prefs.remove('profileImagePath');
      }
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setTextScale(double value) async {
    textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', value);
  }

  Future<void> setReduceMotion(bool value) async {
    reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
  }

  Future<void> setProfileImagePath(String? value) async {
    profileImagePath = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    if (value == null || value.isEmpty) {
      await prefs.remove('profileImagePath');
    } else {
      await prefs.setString('profileImagePath', value);
    }
  }

  Future<void> clearProfilePhoto() async {
    if (profileImagePath != null) {
      final f = File(profileImagePath!);
      if (await f.exists()) {
        await f.delete().catchError((_) {});
      }
    }
    await setProfileImagePath(null);
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String career,
    required String campus,
  }) async {
    this.fullName = fullName.trim();
    this.email = email.trim();
    this.career = career.trim();
    this.campus = campus.trim();

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', this.fullName);
    await prefs.setString('email', this.email);
    await prefs.setString('career', this.career);
    await prefs.setString('campus', this.campus);
  }
}
