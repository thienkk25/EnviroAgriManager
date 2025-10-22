import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/screens/main_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSettingsProvider extends SettingsProvider {
  @override
  Future<void> scheduleAutoSyncData(
    Future<void> Function() functionRepeat,
    int second,
  ) async {}
}

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

class FakeRegionProvider extends RegionProvider {
  final List<RegionModel> regi;
  FakeRegionProvider(super.regionRepository, this.regi);
  @override
  Future<void> fetchRegions(BuildContext context) async {}

  @override
  List<RegionModel> get regions => regi;
}

class FakeAuthProvider extends AuthProvider {
  final bool isTrue;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isTrue);
  @override
  UserRoleModel get userRole =>
      isTrue ? UserRoleModel.admin : UserRoleModel.viewer;

  @override
  bool hasPermission(String permission) {
    return isTrue;
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

  Widget buildTestWidget({
    required bool isTrue,
    List<ProductModel>? prod,
    List<EnvironmentalDataModel>? envr,
    List<CategoryModel>? categ,
    List<RegionModel>? regi,
  }) {
    final products = prod ?? [];
    final environmentalData = envr ?? [];
    final categories = categ ?? [];
    final regions = regi ?? [];
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(ConnectivityService()),
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(
            ConnectivityProvider(ConnectivityService()),
            AuthService(),
            isTrue,
          ),
        ),
        ChangeNotifierProvider<ProductProvider>.value(
          value: FakeProductProvider(
            ProductRepository(null, ProductService()),
            products,
          ),
        ),
        ChangeNotifierProvider<EnvironmentalDataProvider>.value(
          value: FakeEnvironmentalDataProvider(
            EnvironmentalDataRepository(null, EnvironmentalDataService()),
            environmentalData,
          ),
        ),
        ChangeNotifierProvider<CategoryProvider>.value(
          value: FakeCategoryProvider(
            CategoryRepository(null, CategoryService()),
            categories,
          ),
        ),
        ChangeNotifierProvider<RegionProvider>.value(
          value: FakeRegionProvider(
            RegionRepository(null, RegionService()),
            regions,
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: FakeSettingsProvider(),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: MainScreen())),
    );
  }

  group('MainScreen', () {
    testWidgets('Kiểm tra màn hình viewer/editer', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(isTrue: false));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.dashboard),
        findsOneWidget,
      );
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.inventory_2),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.category),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.eco),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.analytics),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.settings),
        findsOneWidget,
      );
    });
    testWidgets('Kiểm tra màn hình admin', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(isTrue: true));
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.dashboard),
        findsOneWidget,
      );
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.inventory_2),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.category),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.eco),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.analytics),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.people),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(BottomNavigationBar, Icons.settings),
        findsOneWidget,
      );
    });
  });
}
