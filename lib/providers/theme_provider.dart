import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _isDarkMode = preferences.getBool(_darkModeKey) ?? false;
      notifyListeners();
    } catch (error) {
      debugPrint('Unable to load theme preference: $error');
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_darkModeKey, value);
    } catch (error) {
      _isDarkMode = !value;
      notifyListeners();
      rethrow;
    }
  }
}
