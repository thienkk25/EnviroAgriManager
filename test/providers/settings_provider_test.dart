import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  late SettingsProvider provider;
  late MockAppPreferences mockAppPrefs;
  late SharedPreferences prefs;

  setUpAll(() {
    // Đăng ký fallback cho Duration (mocktail yêu cầu nếu có Duration hoặc Function)
    registerFallbackValue(Duration.zero);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    mockAppPrefs = MockAppPreferences();

    // Khởi tạo provider (bỏ qua _init bất đồng bộ)
    provider = SettingsProvider(prefs: prefs, appPrefs: mockAppPrefs);
  });

  group('SettingsProvider', () {
    test('mặc định themeMode là light', () {
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme() chuyển đổi giữa light và dark', () async {
      when(
        () => mockAppPrefs.setThemeMode(any()),
      ).thenAnswer((_) async => Future.value());

      expect(provider.themeMode, ThemeMode.light);

      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      verify(() => mockAppPrefs.setThemeMode('dark')).called(1);

      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      verify(() => mockAppPrefs.setThemeMode('light')).called(1);
    });

    test('scheduleAutoSyncData() lưu cấu hình và gọi functionRepeat', () async {
      bool functionCalled = false;

      when(
        () => mockAppPrefs.setScheduleAutoSyncData(any()),
      ).thenAnswer((_) async => Future.value());

      await provider.scheduleAutoSyncData(() async {
        functionCalled = true;
      }, 1);

      // Chờ timer chạy
      await Future.delayed(const Duration(seconds: 2));

      expect(functionCalled, true);
      verify(() => mockAppPrefs.setScheduleAutoSyncData(1)).called(1);

      provider.cancelAutoSync();
    });

    test('cancelAutoSync() hủy Timer đang chạy mà không lỗi', () async {
      when(
        () => mockAppPrefs.setScheduleAutoSyncData(any()),
      ).thenAnswer((_) async => Future.value());

      await provider.scheduleAutoSyncData(() async {}, 2);

      provider.cancelAutoSync();
      // Gọi lại cancelAutoSync() để chắc chắn không crash
      provider.cancelAutoSync();
    });
  });
}
