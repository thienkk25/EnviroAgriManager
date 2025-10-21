import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/screens/region_manager_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeRegionProvider extends RegionProvider {
  final List<RegionModel> regi;
  FakeRegionProvider(super.regionRepository, this.regi);
  @override
  Future<void> fetchRegions(BuildContext context) async {}

  @override
  List<RegionModel> get regions => regi;

  @override
  List<RegionModel> getMainRegions() => regi;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late List<RegionModel> regi;
  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    regi = [
      RegionModel.fromJson({
        "id": "ac22044f-0382-4288-b486-458933830ba5",
        "name": "Hà Nội",
        "description": "Thủ đô, phát triển rau an toàn và hoa cảnh",
        "parent_id": "74968ce2-95d6-418d-ac13-bea30b78395c",
        "is_active": true,
        "created_at": "2025-10-17 21:36:23+00",
        "updated_at": "2025-10-18 02:28:55.82842+00",
      }),
    ];
  });

  Widget buildTestWidget(List<RegionModel> data) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(ConnectivityService()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            ConnectivityProvider(ConnectivityService()),
            AuthService(),
          ),
        ),
        ChangeNotifierProvider<RegionProvider>.value(
          value: FakeRegionProvider(
            RegionRepository(null, RegionService()),
            data,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: RegionManagerScreen())),
    );
  }

  group('RegionManagerScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget([]));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.byIcon(Icons.refresh).first, findsOneWidget);
      expect(
        find.widgetWithText(AppBar, 'Các địa điểm hoạt động'),
        findsOneWidget,
      );
      expect(find.byType(RoleBasedActionButton).first, findsOneWidget);
    });
    testWidgets('Kiểm tra màn hình không có dữ liệu', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget([]));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.byIcon(Icons.refresh).first, findsOneWidget);
      expect(
        find.widgetWithText(AppBar, 'Các địa điểm hoạt động'),
        findsOneWidget,
      );
      expect(find.text('Không có vị trí nào'), findsOneWidget);
      expect(find.text('Thêm vị trí để bắt đầu'), findsOneWidget);
      expect(find.byType(RoleBasedActionButton).first, findsOneWidget);
    });
    testWidgets('Kiểm tra màn hình có dữ liệu', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(regi));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.byIcon(Icons.refresh).first, findsOneWidget);
      expect(
        find.widgetWithText(AppBar, 'Các địa điểm hoạt động'),
        findsOneWidget,
      );
      expect(find.text('Hà Nội'), findsOneWidget);
      expect(find.byType(RoleBasedActionButton).first, findsOneWidget);
    });
  });
}
