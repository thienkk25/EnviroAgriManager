import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/screens/reports_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeProductProvider extends ProductProvider {
  final List<ProductModel> prod;
  FakeProductProvider(super.productRepository, this.prod);
  @override
  Future<void> fetchProducts(BuildContext context) async {}
  @override
  List<ProductModel> get products => prod;

  @override
  Map<String, double> getTrendByCategory(BuildContext context, String type) {
    return {'Cây công nghiệp': 200, 'Rau ăn quả': 100};
  }

  @override
  Map<String, double> getCategoryDistributionData(
    BuildContext context,
    String type,
  ) {
    return {'Cây công nghiệp': 200, 'Rau ăn quả': 100};
  }
}

class FakeEnvironmentalDataProvider extends EnvironmentalDataProvider {
  final List<EnvironmentalDataModel> envr;
  FakeEnvironmentalDataProvider(super.environmentalDataRepository, this.envr);
  @override
  Future<void> fetchEnvironmentalData(BuildContext context) async {}

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

  @override
  List<EnvironmentalDataModel> getEnvironmentalDataByTime(String type) {
    return envr;
  }
}

class FakeCategoryProvider extends CategoryProvider {
  final List<CategoryModel> categ;
  FakeCategoryProvider(super.categoryRepository, this.categ);
  @override
  Future<void> fetchCategories(BuildContext context) async {}
  @override
  List<CategoryModel> get categories => categ;

  @override
  List<CategoryModel> getMainCategories() => categ;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late List<ProductModel> prod;
  late List<EnvironmentalDataModel> envr;
  late List<CategoryModel> categ;
  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    prod = [
      ProductModel.fromJson({
        "id": "01614003-dccc-40a5-85cf-95839c15ad1d",
        "name": "Hồ tiêu Gia Lai",
        "description": "Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay",
        "category_id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
        "price": 120000,
        "quantity": 200,
        "unit": "kg",
        "image_url": "",
        "created_at": "2025-10-17 21:58:19+00",
        "updated_at": "2025-10-18 02:46:40.29249+00",
        "status": "active",
      }),
      ProductModel.fromJson({
        "id": "b4dde929-505d-49c0-981d-1d3373270214",
        "name": "Cà chua bi",
        "description": "Cà chua nhỏ, ngọt, dùng cho salad",
        "category_id": "ccfe4dcc-b95c-45a1-9695-874d762b4c72",
        "price": 25000,
        "quantity": 100,
        "unit": "kg",
        "image_url":
            "https://fvcmpmemafogezilylcc.supabase.co/storage/v1/object/public/product-images/Product%20Images/1760712162444.jpg",
        "created_at": "2025-10-17 21:22:10+00",
        "updated_at": "2025-10-18 02:46:40.29249+00",
        "status": "active",
      }),
    ];
    envr = [
      EnvironmentalDataModel(
        id: "0233690c-b160-4421-bccd-275b94b48b50",
        regionId: "ac22044f-0382-4288-b486-458933830ba5",
        location: "Hà Nội, Đồng bằng sông Hồng",
        temperature: 28.0,
        humidity: 70.0,
        ph: 6.5,
        soilMoisture: 40.0,
        lightIntensity: 12000,
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
      EnvironmentalDataModel(
        id: "e8969776-53e7-43e4-82eb-bb8ea5191a0d",
        regionId: "77f8b591-e84c-4258-b1b8-803c4cd7f7ad",
        location: "Vĩnh Long, Đồng bằng sông Cửu Long",
        temperature: 28.0,
        humidity: 70.0,
        ph: 6.5,
        soilMoisture: 40.0,
        lightIntensity: 12000,
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
    categ = [
      CategoryModel.fromJson({
        "id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
        "name": "Cây công nghiệp",
        "description": "Cây trồng có giá trị kinh tế cao",
        "icon": "🌾",
        "color": "#9C27B0",
        "parent_id": null,
        "created_at": "2025-10-18 04:21:50+00",
        "updated_at": "2025-10-18 05:11:17.744005+00",
        "is_active": true,
      }),
      CategoryModel.fromJson({
        "id": "ccfe4dcc-b95c-45a1-9695-874d762b4c72",
        "name": "Rau ăn quả",
        "description": "Cà chua, dưa leo, ớt...",
        "icon": "🌱",
        "color": "#4CAF50",
        "parent_id": "e0c5e5ac-470d-46da-b6fb-020eb9ff5fa6",
        "created_at": "2025-10-17 21:21:50+00",
        "updated_at": "2025-10-18 02:46:40.312839+00",
        "is_active": true,
      }),
    ];
  });

  Widget buildTestWidget(
    List<ProductModel> prod,
    List<EnvironmentalDataModel> envr,
    List<CategoryModel> categ,
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
        ChangeNotifierProvider<ProductProvider>.value(
          value: FakeProductProvider(
            ProductRepository(null, ProductService()),
            prod,
          ),
        ),
        ChangeNotifierProvider<EnvironmentalDataProvider>.value(
          value: FakeEnvironmentalDataProvider(
            EnvironmentalDataRepository(null, EnvironmentalDataService()),
            envr,
          ),
        ),
        ChangeNotifierProvider<CategoryProvider>.value(
          value: FakeCategoryProvider(
            CategoryRepository(null, CategoryService()),
            categ,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: ReportsScreen())),
    );
  }

  group('ReportsScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget([], [], []));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Báo cáo & Thống kê'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.text('Kỳ báo cáo: '), findsOneWidget);
      expect(find.text('Tổng quan'), findsOneWidget);
      expect(find.text('Xu hướng sản phẩm theo danh mục'), findsOneWidget);
      expect(find.text('Phân bố theo danh mục'), findsOneWidget);
      expect(find.text('Dữ liệu môi trường'), findsOneWidget);
    });
    testWidgets('Kiểm tra màn hình có dữ liệu', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(prod, envr, categ));
      await widgetTester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
      final lineChart = widgetTester.widget<LineChart>(find.byType(LineChart));
      final lineBarsData = lineChart.data.lineBarsData;
      expect(lineBarsData.first.spots.length, 2);
      expect(lineBarsData.first.spots[0].y, 200);
      expect(lineBarsData.first.spots[1].y, 100);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Cây công nghiệp'), findsOneWidget);
      expect(find.text('Rau ăn quả').first, findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
      final barChart = widgetTester.widget<BarChart>(find.byType(BarChart));
      expect(barChart.data.barGroups.length, 2);
      expect(barChart.data.barGroups[0].barRods[0].toY, 28.0);
    });
  });
}
