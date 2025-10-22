import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/screens/simple_home_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeProductProvider extends ProductProvider {
  FakeProductProvider(super.productRepository);
  @override
  Future<void> fetchProducts(BuildContext context) async {}
  @override
  List<ProductModel> get products => [];
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
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            ConnectivityProvider(ConnectivityService()),
            AuthService(),
          ),
        ),
        ChangeNotifierProvider<ProductProvider>.value(
          value: FakeProductProvider(ProductRepository(null, ProductService())),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: SimpleHomeScreen())),
    );
  }

  group('SimpleHomeScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget());
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(
        find.widgetWithText(AppBar, 'Hệ thống Quản lý Danh mục'),
        findsOneWidget,
      );
      expect(find.text('Nông nghiệp & Môi trường'), findsOneWidget);
      expect(
        find.text('Hệ thống quản lý danh mục điện tử dùng chung'),
        findsOneWidget,
      );
      expect(find.text('Tính năng chính'), findsOneWidget);
      expect(find.text('Quản lý Sản phẩm'), findsOneWidget);
      expect(find.text('Quản lý Danh mục'), findsOneWidget);
      expect(find.text('Giám sát Môi trường'), findsOneWidget);
      expect(find.text('Báo cáo Thống kê'), findsOneWidget);
      expect(find.text('Dữ liệu Môi trường Hiện tại'), findsOneWidget);
      expect(find.text('Sản phẩm gần đây'), findsOneWidget);
    });
  });
}
