import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/widgets/environmental_data_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  final bool isOpen;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isOpen);

  @override
  UserRoleModel get userRole => UserRoleModel.admin;

  @override
  bool hasPermission(String permission) => isOpen;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late EnvironmentalDataModel model;

  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    final now = DateTime.parse('2025-10-19T08:00:00Z');
    model = EnvironmentalDataModel(
      id: 'env_001',
      regionId: 'reg_001',
      location: 'Cần Thơ',
      temperature: 29.3,
      humidity: 76.5,
      ph: 6.2,
      soilMoisture: 40.1,
      lightIntensity: 800.0,
      co2Level: 380.0,
      nitrogen: 12.0,
      phosphorus: 6.0,
      potassium: 9.5,
      weatherCondition: 'Nắng nhẹ',
      notes: 'Độ ẩm cao buổi sáng',
      recordedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  });

  Widget buildTestWidget({
    required EnvironmentalDataModel environmentalData,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(
            ConnectivityProvider(ConnectivityService()),
            AuthService(),
            true,
          ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: EnvironmentalDataCard(
            environmentalData: environmentalData,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('EnvironmentalDataCard', () {
    testWidgets('Hiển thị dữ liệu', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(environmentalData: model));
      await widgetTester.pumpAndSettle();

      expect(find.text('Cần Thơ'), findsOneWidget);
      expect(find.text('Nhiệt độ'), findsOneWidget);
      expect(find.text('29.3°C'), findsOneWidget);
      expect(find.text('Độ ẩm'), findsOneWidget);
      expect(find.text('76.5%'), findsOneWidget);
      expect(find.text('Độ pH'), findsOneWidget);
      expect(find.text('Độ ẩm đất'), findsOneWidget);
      expect(find.text('CO2'), findsOneWidget);
      expect(find.textContaining('Ghi nhận:'), findsOneWidget);
    });

    testWidgets('Khi onTap', (widgetTester) async {
      bool onTap = false;
      await widgetTester.pumpWidget(
        buildTestWidget(environmentalData: model, onTap: () => onTap = true),
      );
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(InkWell));
      await widgetTester.pump();

      expect(onTap, isTrue);
    });
    testWidgets('Có quyền onEdit/onDelete', (widgetTester) async {
      bool onEdit = false;
      bool onDelete = false;
      await widgetTester.pumpWidget(
        buildTestWidget(
          environmentalData: model,
          onEdit: () => onEdit = true,
          onDelete: () => onDelete = true,
        ),
      );
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(RoleBasedActionButton).first);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(RoleBasedActionButton).last);
      await widgetTester.pumpAndSettle();

      expect(onEdit, isTrue);
      expect(onDelete, isTrue);
    });
    testWidgets('Không có quyền onEdit/onDelete', (widgetTester) async {
      await widgetTester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
              value: FakeAuthProvider(
                ConnectivityProvider(ConnectivityService()),
                AuthService(),
                false,
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EnvironmentalDataCard(environmentalData: model),
            ),
          ),
        ),
      );
      await widgetTester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
