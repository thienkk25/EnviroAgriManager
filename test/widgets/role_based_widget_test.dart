import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  final UserRoleModel role;
  final bool hasEditPermission;

  FakeAuthProvider(this.role, this.hasEditPermission)
    : super(ConnectivityProvider(ConnectivityService()), AuthService());

  @override
  UserRoleModel get userRole => role;

  @override
  bool hasPermission(String permission) => hasEditPermission;
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

  Widget buildTestWidget({
    required AuthProvider authProvider,
    required Widget child,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('RoleBasedWidget', () {
    testWidgets('Hiển thị adminChild khi role là admin', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.admin, true),
          child: RoleBasedWidget(
            adminChild: const Text('Admin View'),
            editorChild: const Text('Editor View'),
            viewerChild: const Text('Viewer View'),
          ),
        ),
      );

      expect(find.text('Admin View'), findsOneWidget);
      expect(find.text('Editor View'), findsNothing);
      expect(find.text('Viewer View'), findsNothing);
    });

    testWidgets('Hiển thị editorChild khi role là editor', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.editor, true),
          child: RoleBasedWidget(
            adminChild: const Text('Admin View'),
            editorChild: const Text('Editor View'),
          ),
        ),
      );

      expect(find.text('Editor View'), findsOneWidget);
    });

    testWidgets('Hiển thị viewerChild khi role là viewer', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.viewer, true),
          child: RoleBasedWidget(
            adminChild: const Text('Admin View'),
            editorChild: const Text('Editor View'),
            viewerChild: const Text('Viewer View'),
          ),
        ),
      );

      expect(find.text('Viewer View'), findsOneWidget);
    });

    testWidgets('ẩn widget nếu không có quyền (permission=false)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.admin, false),
          child: RoleBasedWidget(
            adminChild: const Text('Admin View'),
            permission: 'edit',
          ),
        ),
      );

      expect(find.text('Admin View'), findsNothing);
    });
  });

  group('RoleBasedActionButton', () {
    testWidgets('Hiển thị nút khi có quyền', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.admin, true),
          child: RoleBasedActionButton(
            permission: 'edit',
            child: ElevatedButton(onPressed: () {}, child: const Text('Sửa')),
          ),
        ),
      );

      expect(find.text('Sửa'), findsOneWidget);
    });

    testWidgets('ẩn nút khi không có quyền', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.admin, false),
          child: RoleBasedActionButton(
            permission: 'edit',
            child: ElevatedButton(onPressed: () {}, child: const Text('Sửa')),
          ),
        ),
      );

      expect(find.text('Sửa'), findsNothing);
    });
  });

  group('RoleBasedMenuItem', () {
    testWidgets('Hiển thị item khi có quyền', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.editor, true),
          child: RoleBasedMenuItem(
            permission: 'view',
            child: const Text('Xem dữ liệu'),
          ),
        ),
      );

      expect(find.text('Xem dữ liệu'), findsOneWidget);
    });

    testWidgets('ẩn item khi không có quyền', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          authProvider: FakeAuthProvider(UserRoleModel.editor, false),
          child: RoleBasedMenuItem(
            permission: 'view',
            child: const Text('Xem dữ liệu'),
          ),
        ),
      );

      expect(find.text('Xem dữ liệu'), findsNothing);
    });
  });

  group('NoPermissionWidget', () {
    testWidgets('Hiển thị thông báo mặc định', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NoPermissionWidget())),
      );

      expect(find.textContaining('không có quyền'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
