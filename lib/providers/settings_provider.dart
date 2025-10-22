import 'dart:async';

import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  Timer? _autoSyncTimer;
  late SharedPreferences _prefs;
  late AppPreferences _appPrefs;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  int _secondSync = 900;
  int get secondSync => _secondSync;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _appPrefs = AppPreferences(_prefs);

    final mode = _appPrefs.getThemeMode() ?? 'light';
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final second = _appPrefs.getScheduleAutoSyncData() ?? 900;
    _secondSync = second;

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

  Future<void> scheduleAutoSyncData(
    Future<void> Function() functionRepeat,
    int second,
  ) async {
    _secondSync = second;
    // Lưu cấu hình vào SharedPreferences
    await _appPrefs.setScheduleAutoSyncData(second);

    // Hủy timer cũ nếu có
    _autoSyncTimer?.cancel();

    // Tạo timer mới
    _autoSyncTimer = Timer.periodic(Duration(seconds: second), (_) async {
      await functionRepeat();
    });
  }

  void cancelAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }
}
