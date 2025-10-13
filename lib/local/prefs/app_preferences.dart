import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static const _keyThemeMode = 'theme_mode';
  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserRole = 'user_role';

  // Theme
  Future<void> setThemeMode(String mode) async =>
      _prefs.setString(_keyThemeMode, mode);
  String? getThemeMode() => _prefs.getString(_keyThemeMode);

  // Auth
  Future<void> setAccessToken(String token) async =>
      _prefs.setString(_keyAccessToken, token);
  String? getAccessToken() => _prefs.getString(_keyAccessToken);
  Future<void> clearAccessToken() async => _prefs.remove(_keyAccessToken);

  Future<void> setCachedUser({
    required String id,
    required String email,
    required String role,
  }) async {
    await _prefs.setString(_keyUserId, id);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserRole, role);
  }

  Map<String, String?> getCachedUser() => {
    'id': _prefs.getString(_keyUserId),
    'email': _prefs.getString(_keyUserEmail),
    'role': _prefs.getString(_keyUserRole),
  };

  Future<void> clearCachedUser() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserRole);
    await clearAccessToken();
  }
}
