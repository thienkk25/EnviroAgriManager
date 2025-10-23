import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/screens/categories_screen.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/widgets/category_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeCategoryProvider extends CategoryProvider {
  final List<CategoryModel> data;
  FakeCategoryProvider(super.categoryRepository, this.data);
  @override
  Future<void> fetchCategories(bool isOnline) async {}

  @override
  List<CategoryModel> get categories => data;

  @override
  List<CategoryModel> getMainCategories() => data;
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

  Widget buildTestWidget(List<CategoryModel> data) {
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
        ChangeNotifierProvider<CategoryProvider>.value(
          value: FakeCategoryProvider(
            CategoryRepository(null, CategoryService()),
            data,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: CategoriesScreen())),
    );
  }

  group('CategoriesScreen', () {
    testWidgets('Kiểm tra có CategoriesScreen', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget([]));
      await widgetTester.pumpAndSettle();

      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(find.byType(RoleBasedActionButton), findsOneWidget);
    });
  });
  group('CategoryScreen', () {
    testWidgets('Kiểm tra có CategoryScreen không có dữ liệu', (
      widgetTester,
    ) async {
      List<CategoryModel> data = [];
      await widgetTester.pumpWidget(buildTestWidget(data));
      await widgetTester.pumpAndSettle();

      expect(find.text('Quản lý Danh mục'), findsOneWidget);
      expect(find.text('Không có danh mục'), findsOneWidget);
    });

    testWidgets('Kiểm tra có CategoryScreen có dữ liệu', (widgetTester) async {
      List<CategoryModel> data = [
        CategoryModel(
          id: '1',
          name: 'Cây trồng',
          description: 'Danh mục các loại cây trồng',
          icon: '🌾',
          color: '#4CAF50',
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        CategoryModel(
          id: '2',
          name: 'Động vật',
          description: 'Danh mục các loại Động vật',
          icon: '',
          color: '#4CAF50',
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      ];
      await widgetTester.pumpWidget(buildTestWidget(data));
      await widgetTester.pumpAndSettle();

      expect(find.text('Quản lý Danh mục'), findsOneWidget);
      expect(find.byType(CategoryCard).first, findsOneWidget);
    });
  });
}
