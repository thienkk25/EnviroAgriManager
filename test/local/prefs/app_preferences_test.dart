import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late AppPreferences appPrefs;

  setUp(() async {
    // Dùng SharedPreferences giả (mock)
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    appPrefs = AppPreferences(prefs);
  });

  group('AppPreferences', () {
    test('Lưu và đọc theme mode', () async {
      await appPrefs.setThemeMode('dark');
      expect(appPrefs.getThemeMode(), 'dark');
    });

    test('Lưu, đọc và xóa access token', () async {
      await appPrefs.setAccessToken('abc123');
      expect(appPrefs.getAccessToken(), 'abc123');

      await appPrefs.clearAccessToken();
      expect(appPrefs.getAccessToken(), isNull);
    });

    test('Lưu và lấy thông tin user cache', () async {
      await appPrefs.setCachedUser(
        id: 'u001',
        email: 'user@test.com',
        role: 'admin',
      );

      final user = appPrefs.getCachedUser();
      expect(user['id'], 'u001');
      expect(user['email'], 'user@test.com');
      expect(user['role'], 'admin');
    });

    test('Xóa thông tin user cache', () async {
      await appPrefs.setCachedUser(
        id: 'u002',
        email: 'delete@test.com',
        role: 'editor',
      );

      await appPrefs.clearCachedUser();
      final user = appPrefs.getCachedUser();
      expect(user['id'], isNull);
      expect(user['email'], isNull);
      expect(user['role'], isNull);
    });

    test('Lưu và lấy thời gian auto sync', () async {
      await appPrefs.setScheduleAutoSyncData(300);
      expect(appPrefs.getScheduleAutoSyncData(), 300);
    });
  });
}
