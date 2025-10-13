import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  late AppPreferences _appPrefs;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _initTheme();
  }

  Future<void> _initTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _appPrefs = AppPreferences(_prefs);

    final mode = _appPrefs.getThemeMode() ?? 'light';
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await _appPrefs.setThemeMode('dark');
    } else {
      _themeMode = ThemeMode.light;
      await _appPrefs.setThemeMode('light');
    }
    notifyListeners();
  }
}
