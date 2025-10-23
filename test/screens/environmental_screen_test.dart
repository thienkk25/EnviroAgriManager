import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/screens/environmental_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:enviro_agri_manager/widgets/environmental_data_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeEnvironmentalDataProvider extends EnvironmentalDataProvider {
  final List<EnvironmentalDataModel> envr;
  FakeEnvironmentalDataProvider(super.environmentalDataRepository, this.envr);
  @override
  Future<void> fetchEnvironmentalData(bool isOnline) async {}

  @override
  List<EnvironmentalDataModel> get environmentalData => envr;

  @override
  List<EnvironmentalDataModel> getFilteredData(
    String? selectedProvince,
    String? selectedDistrict,
    String? selectedWard,
    String selectedTimeRange,
    List<RegionModel> regions,
  ) {
    return envr;
  }
}

class FakeRegionProvider extends RegionProvider {
  final List<RegionModel> regi;
  FakeRegionProvider(super.regionRepository, this.regi);
  @override
  Future<void> fetchRegions(bool isOnline) async {}

  @override
  List<RegionModel> get regions => regi;
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

  Widget buildTestWidget(
    List<EnvironmentalDataModel> envr,
    List<RegionModel> regi,
  ) {
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
        ChangeNotifierProvider<EnvironmentalDataProvider>.value(
          value: FakeEnvironmentalDataProvider(
            EnvironmentalDataRepository(null, EnvironmentalDataService()),
            envr,
          ),
        ),
        ChangeNotifierProvider<RegionProvider>.value(
          value: FakeRegionProvider(
            RegionRepository(null, RegionService()),
            regi,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: EnvironmentalScreen())),
    );
  }

  group('EnvironmentalScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      final List<EnvironmentalDataModel> envr = [];
      final List<RegionModel> regi = [];
      await widgetTester.pumpWidget(buildTestWidget(envr, regi));
      await widgetTester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on).first, findsOneWidget);
      expect(find.text('Các địa điểm hoạt động'), findsOneWidget);
      expect(find.text('Vị trí: '), findsOneWidget);
      expect(find.byType(DropdownButton<String>).first, findsOneWidget);
      expect(find.text('Tất cả').first, findsOneWidget);
      expect(find.byType(RoleBasedActionButton), findsOneWidget);
    });
    testWidgets('Kiểm tra màn hình có dữ liệu', (widgetTester) async {
      final List<EnvironmentalDataModel> envr = [
        EnvironmentalDataModel(
          id: "0233690c-b160-4421-bccd-275b94b48b50",
          regionId: "ac22044f-0382-4288-b486-458933830ba5",
          location: "Hà Nội, Đồng bằng sông Hồng",
          temperature: 28.0,
          humidity: 70.0,
          ph: 6.5,
          soilMoisture: 40.0,
          lightIntensity: 12000.0,
          co2Level: 420.0,
          nitrogen: 40.0,
          phosphorus: 25.0,
          potassium: 30.0,
          weatherCondition: "Nắng nhẹ",
          notes: "Điều kiện phù hợp cho cây trồng",
          recordedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final List<RegionModel> regi = [
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
      await widgetTester.pumpWidget(buildTestWidget(envr, regi));
      await widgetTester.pumpAndSettle();

      expect(find.byType(EnvironmentalDataCard), findsOneWidget);
    });
  });
}
