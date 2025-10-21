import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeConnectivityProvider extends ConnectivityProvider {
  final bool isConnection;
  FakeConnectivityProvider(super.connectivityService, this.isConnection);

  @override
  bool get isOnline => isConnection;
}

class FakeAuthProvider extends AuthProvider {
  final bool isLogin;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isLogin);

  @override
  bool get isSignedIn => isLogin;
}

class FakeMainScreen extends StatelessWidget {
  const FakeMainScreen({super.key});
  @override
  Widget build(BuildContext context) => const Text('Fake Main');
}

class FakeLoginScreen extends StatelessWidget {
  const FakeLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Text('Fake Login');
}

class FakeAuthWrapper extends StatelessWidget {
  const FakeAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final connect = context.watch<ConnectivityProvider>();

    if (!connect.isOnline) {
      return const Text('Không có mạng');
    }
    if (auth.isSignedIn) {
      return const FakeMainScreen();
    }
    return const FakeLoginScreen();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  });

  Widget buildTestWidget({required bool isConnection, required bool isLogin}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityProvider>.value(
          value: FakeConnectivityProvider(ConnectivityService(), isConnection),
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(
            FakeConnectivityProvider(ConnectivityService(), isConnection),
            AuthService(),
            isLogin,
          ),
        ),
      ],
      child: const MaterialApp(home: FakeAuthWrapper()),
    );
  }

  group('AuthWrapper Test', () {
    testWidgets('Có mạng và đã đăng nhập vào MainScreen', (widgetTester) async {
      await widgetTester.pumpWidget(
        buildTestWidget(isConnection: true, isLogin: true),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text('Fake Main'), findsOneWidget);
    });

    testWidgets('Không có mạng hiển thị thông báo "Không có mạng"', (
      widgetTester,
    ) async {
      await widgetTester.pumpWidget(
        buildTestWidget(isConnection: false, isLogin: true),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text('Không có mạng'), findsOneWidget);
    });

    testWidgets('Không đăng nhập chuyển về LoginScreen', (widgetTester) async {
      await widgetTester.pumpWidget(
        buildTestWidget(isConnection: true, isLogin: false),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text('Fake Login'), findsOneWidget);
    });
  });
}
