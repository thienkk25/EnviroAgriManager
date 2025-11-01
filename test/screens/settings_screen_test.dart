import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/screens/settings_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeProductProvider extends ProductProvider {
  final List<ProductModel> prod;
  FakeProductProvider(super.productRepository, this.prod);
  @override
  Future<void> fetchProducts(bool isOnline) async {}
  @override
  List<ProductModel> get products => prod;
}

class FakeEnvironmentalDataProvider extends EnvironmentalDataProvider {
  final List<EnvironmentalDataModel> envr;
  FakeEnvironmentalDataProvider(super.environmentalDataRepository, this.envr);
  @override
  Future<void> fetchEnvironmentalData(bool isOnline) async {}

  @override
  List<EnvironmentalDataModel> get environmentalData => envr;
}

class FakeCategoryProvider extends CategoryProvider {
  final List<CategoryModel> categ;
  FakeCategoryProvider(super.categoryRepository, this.categ);
  @override
  Future<void> fetchCategories(bool isOnline) async {}
  @override
  List<CategoryModel> get categories => categ;

  @override
  List<CategoryModel> getMainCategories() => categ;
}

class FakeSettingsProvider extends SettingsProvider {
  @override
  Future<void> scheduleAutoSyncData(
    Future<void> Function() functionRepeat,
    int second,
  ) async {}
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
    List<ProductModel>? prod,
    List<EnvironmentalDataModel>? envr,
    List<CategoryModel>? categ,
  }) {
    final products = prod ?? [];
    final environmentalData = envr ?? [];
    final categories = categ ?? [];
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
        ChangeNotifierProvider<SettingsProvider>.value(
          value: FakeSettingsProvider(),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: SettingsScreen())),
    );
  }

  group('SettingsScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget());
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Cài đặt'), findsOneWidget);
      expect(find.text('Tên'), findsOneWidget);
      expect(find.text('email@example.com'), findsOneWidget);
      expect(find.text('Cài đặt hệ thống'), findsOneWidget);
      expect(find.text('Chế độ tối'), findsOneWidget);
      expect(find.text('Đồng bộ dữ liệu'), findsOneWidget);
      expect(find.text('Thông tin ứng dụng'), findsOneWidget);
      expect(find.text('Phiên bản'), findsOneWidget);
      final tileFinder = find.byType(ListTile).at(2);

      await widgetTester.scrollUntilVisible(tileFinder, 50.0);

      await widgetTester.tap(tileFinder);
      await widgetTester.pumpAndSettle();
      expect(find.text('Nhà phát triển: Thien Nguyen'), findsOneWidget);
    });
  });
}
