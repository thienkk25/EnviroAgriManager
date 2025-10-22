import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/screens/user_management_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider(super.connectivityProvider, super.authService);
  @override
  bool hasPermission(String permission) {
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>?> getAllUsersWithRoles() async {
    return [
      {
        "id": "462e4569-3391-469e-af42-7914de172281",
        "email": "admin@example.com",
        "full_name": "admin",
        "role_name": "admin",
        "user_created_at": "2025-10-06 04:18:02.372757+00",
        "profile_created_at": "2025-10-06 04:18:02.369172+00",
        "profile_updated_at": "2025-10-06 04:18:23.101832+00",
      },
      {
        "id": "3d625dd2-7956-46a9-a153-9dfef1316624",
        "email": "viewer@example.com",
        "full_name": "viewer",
        "role_name": "viewer",
        "user_created_at": "2025-10-06 04:58:23.539695+00",
        "profile_created_at": "2025-10-06 04:58:23.537992+00",
        "profile_updated_at": "2025-10-06 05:01:01.728886+00",
      },
      {
        "id": "f83d30af-87fb-43fe-8d5c-7a41cf75bf51",
        "email": "editor@example.com",
        "full_name": "editer",
        "role_name": "editor",
        "user_created_at": "2025-10-06 14:50:27.459222+00",
        "profile_created_at": "2025-10-06 14:50:27.457656+00",
        "profile_updated_at": "2025-10-06 14:50:45.846803+00",
      },
    ];
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

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(ConnectivityService()),
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(
            ConnectivityProvider(ConnectivityService()),
            AuthService(),
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: UserManagementScreen())),
    );
  }

  group('UserManagementScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget());
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Quản lý người dùng'), findsOneWidget);
      expect(find.byIcon(Icons.refresh).first, findsOneWidget);
      expect(find.byType(RoleBasedWidget).first, findsOneWidget);
      expect(find.text('admin@example.com'), findsOneWidget);
      expect(find.text('editor@example.com'), findsOneWidget);
      expect(find.text('viewer@example.com'), findsOneWidget);

      await widgetTester.tap(find.byType(IconButton).at(1));
      await widgetTester.pumpAndSettle();

      expect(find.textContaining('Cập nhật quyền cho'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });
  });
}
