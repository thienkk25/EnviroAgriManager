import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/screens/products_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:enviro_agri_manager/widgets/product_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
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

  @override
  List<String> getCategoryIds(String categoryId) {
    return ["9b4ac943-b435-4eef-81e6-03e9f41cadcb"];
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

  Widget buildTestWidget(
    Widget child,
    List<ProductModel> prod,
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
        ChangeNotifierProvider<CategoryProvider>.value(
          value: FakeCategoryProvider(
            CategoryRepository(null, CategoryService()),
            categ,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('ProductsScreen', () {
    testWidgets('Kiểm tra màn hình', (widgetTester) async {
      final List<ProductModel> prod = [];
      final List<CategoryModel> categ = [];
      await widgetTester.pumpWidget(
        buildTestWidget(ProductsScreen(), prod, categ),
      );
      await widgetTester.pumpAndSettle();

      expect(find.byType(Scaffold).first, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Quản lý Sản phẩm'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.byType(RoleBasedActionButton), findsOneWidget);
    });
    testWidgets('Kiểm tra màn hình không có dữ liệu', (widgetTester) async {
      final List<ProductModel> prod = [];
      final List<CategoryModel> categ = [];
      await widgetTester.pumpWidget(
        buildTestWidget(ProductsScreen(), prod, categ),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text('Không tìm thấy sản phẩm nào'), findsOneWidget);
      expect(
        find.text('Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc'),
        findsOneWidget,
      );
      expect(find.byType(ProductCard), findsNothing);
    });
    testWidgets('Kiểm tra màn hình có dữ liệu', (widgetTester) async {
      final List<ProductModel> prod = [
        ProductModel.fromJson({
          "id": "01614003-dccc-40a5-85cf-95839c15ad1d",
          "name": "Hồ tiêu Gia Lai",
          "description": "Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay",
          "category_id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
          "price": 120000.0,
          "quantity": 200,
          "unit": "kg",
          "image_url": "",
          "created_at": "2025-10-17 21:58:19+00",
          "updated_at": "2025-10-18 02:46:40.29249+00",
          "status": "active",
        }),
      ];
      final List<CategoryModel> categ = [
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
      ];
      await widgetTester.pumpWidget(
        buildTestWidget(ProductsScreen(), prod, categ),
      );
      await widgetTester.pumpAndSettle();

      expect(find.byType(ProductCard).first, findsOneWidget);
    });
  });

  group('ProductFormScreen', () {
    testWidgets('Khi view', (widgetTester) async {
      final List<ProductModel> prod = [
        ProductModel.fromJson({
          "id": "01614003-dccc-40a5-85cf-95839c15ad1d",
          "name": "Hồ tiêu Gia Lai",
          "description": "Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay",
          "category_id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
          "price": 120000.0,
          "quantity": 200,
          "unit": "kg",
          "image_url": "",
          "created_at": "2025-10-17 21:58:19+00",
          "updated_at": "2025-10-18 02:46:40.29249+00",
          "status": "active",
        }),
      ];
      final List<CategoryModel> categ = [
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
      ];
      await widgetTester.pumpWidget(
        buildTestWidget(
          ProductFormScreen(mode: ProductFormMode.view, product: prod[0]),
          prod,
          categ,
        ),
      );
      await widgetTester.pumpAndSettle();
      expect(find.text('Thông tin sản phẩm'), findsOneWidget);
      expect(find.text('Tên sản phẩm *'), findsOneWidget);
      expect(find.text('Hồ tiêu Gia Lai'), findsOneWidget);
      expect(find.text('Mô tả sản phẩm *'), findsOneWidget);
      expect(
        find.text('Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay'),
        findsOneWidget,
      );
      expect(find.text('Ảnh sản phẩm'), findsOneWidget);
      expect(find.text('Giá và Số lượng'), findsOneWidget);
      expect(find.text('Đơn vị *'), findsOneWidget);
      expect(find.text('Phân loại'), findsOneWidget);
      expect(find.text('Trạng thái sản phẩm'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined).first, findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
    testWidgets('Khi add', (widgetTester) async {
      final List<ProductModel> prod = [
        ProductModel.fromJson({
          "id": "01614003-dccc-40a5-85cf-95839c15ad1d",
          "name": "Hồ tiêu Gia Lai",
          "description": "Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay",
          "category_id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
          "price": 120000.0,
          "quantity": 200,
          "unit": "kg",
          "image_url": "",
          "created_at": "2025-10-17 21:58:19+00",
          "updated_at": "2025-10-18 02:46:40.29249+00",
          "status": "active",
        }),
      ];
      final List<CategoryModel> categ = [
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
      ];
      await widgetTester.pumpWidget(
        buildTestWidget(
          ProductFormScreen(mode: ProductFormMode.add),
          prod,
          categ,
        ),
      );
      await widgetTester.pumpAndSettle();
      expect(find.text('Thông tin sản phẩm'), findsOneWidget);
      expect(find.text('Tên sản phẩm *'), findsOneWidget);
      expect(find.text('Mô tả sản phẩm *'), findsOneWidget);
      expect(find.text('Ảnh sản phẩm'), findsOneWidget);
      expect(find.text('Giá và Số lượng'), findsOneWidget);
      expect(find.text('Đơn vị *'), findsOneWidget);
      expect(find.text('Phân loại'), findsOneWidget);
      expect(find.text('Trạng thái sản phẩm'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined).first, findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Lưu sản phẩm').first,
        findsOneWidget,
      );
    });
    testWidgets('Khi update', (widgetTester) async {
      final List<ProductModel> prod = [
        ProductModel.fromJson({
          "id": "01614003-dccc-40a5-85cf-95839c15ad1d",
          "name": "Hồ tiêu Gia Lai",
          "description": "Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay",
          "category_id": "9b4ac943-b435-4eef-81e6-03e9f41cadcb",
          "price": 120000.0,
          "quantity": 200,
          "unit": "kg",
          "image_url": "",
          "created_at": "2025-10-17 21:58:19+00",
          "updated_at": "2025-10-18 02:46:40.29249+00",
          "status": "active",
        }),
      ];
      final List<CategoryModel> categ = [
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
      ];
      await widgetTester.pumpWidget(
        buildTestWidget(
          ProductFormScreen(mode: ProductFormMode.edit, product: prod[0]),
          prod,
          categ,
        ),
      );
      await widgetTester.pumpAndSettle();
      expect(find.text('Thông tin sản phẩm'), findsOneWidget);
      expect(find.text('Tên sản phẩm *'), findsOneWidget);
      expect(find.text('Hồ tiêu Gia Lai'), findsOneWidget);
      expect(find.text('Mô tả sản phẩm *'), findsOneWidget);
      expect(
        find.text('Sản phẩm đặc sản Tây Nguyên, hạt tiêu thơm cay'),
        findsOneWidget,
      );
      expect(find.text('Ảnh sản phẩm'), findsOneWidget);
      expect(find.text('Giá và Số lượng'), findsOneWidget);
      expect(find.text('Đơn vị *'), findsOneWidget);
      expect(find.text('Phân loại'), findsOneWidget);
      expect(find.text('Trạng thái sản phẩm'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined).first, findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Cập nhật sản phẩm').first,
        findsOneWidget,
      );
    });
  });
}
