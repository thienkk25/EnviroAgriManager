import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences prefs;

  // inject instance khi khởi tạo
  AppPreferences(this.prefs);

  static const _keyThemeMode = 'theme_mode';
  static const _keyAccessToken = 'access_token';
  static const _keyLastSync = 'last_sync';

  // Theme Mode
  Future<void> setThemeMode(String mode) async =>
      prefs.setString(_keyThemeMode, mode);

  String? getThemeMode() => prefs.getString(_keyThemeMode);

  // Access Token
  Future<void> setAccessToken(String token) async =>
      prefs.setString(_keyAccessToken, token);

  String? getAccessToken() => prefs.getString(_keyAccessToken);

  // Last Sync
  Future<void> setLastSync(DateTime time) async =>
      prefs.setString(_keyLastSync, time.toIso8601String());

  DateTime? getLastSync() {
    final value = prefs.getString(_keyLastSync);
    return value != null ? DateTime.tryParse(value) : null;
  }
}
