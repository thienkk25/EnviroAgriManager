import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enviro_agri_manager/main.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:enviro_agri_manager/screens/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  group('MainApp tests', () {
    testWidgets('Ứng dụng khởi động và hiển thị AuthWrapper', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            // Connectivity
            Provider(
              create: (_) => ConnectivityService(),
              dispose: (context, connectivityService) =>
                  connectivityService.dispose(),
            ),
            ChangeNotifierProxyProvider<
              ConnectivityService,
              ConnectivityProvider
            >(
              create: (context) =>
                  ConnectivityProvider(context.read<ConnectivityService>()),
              update: (_, service, provider) =>
                  provider!..updateService(service),
            ),

            // Auth
            Provider(create: (_) => AuthService()),
            ChangeNotifierProxyProvider2<
              ConnectivityProvider,
              AuthService,
              AuthProvider
            >(
              create: (context) => AuthProvider(
                context.read<ConnectivityProvider>(),
                context.read<AuthService>(),
              ),
              update: (_, connectivity, authService, provider) =>
                  provider!..updateDependencies(connectivity, authService),
            ),
          ],
          child: const MainApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Kiểm tra xem AuthWrapper có xuất hiện
      expect(find.byType(AuthWrapper), findsOneWidget);
    });

    testWidgets('Theme thay đổi khi SettingsProvider thay đổi', (
      WidgetTester tester,
    ) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const MainApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(settingsProvider.themeMode, ThemeMode.light);

      settingsProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(settingsProvider.themeMode, ThemeMode.dark);
    });
  });
}
