import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _kDarkModeKey = 'dark_mode';
  static const _kTextScaleKey = 'text_scale';

  bool _darkMode = false;
  double _textScale = 1.0;

  bool get darkMode => _darkMode;
  double get textScale => _textScale;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_kDarkModeKey) ?? false;
    _textScale = prefs.getDouble(_kTextScaleKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScaleKey, value);
  }
}
