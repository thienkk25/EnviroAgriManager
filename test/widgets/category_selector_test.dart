import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/widgets/category_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  final bool isOpen;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isOpen);

  @override
  bool hasPermission(String permission) => isOpen;
}

// Fake provider để test
class FakeCategoryProvider extends CategoryProvider {
  FakeCategoryProvider(super.categoryRepository);

  @override
  List<CategoryModel> getMainCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Cây Trồng',
        icon: '🌾',
        color: '#4CAF50',
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        description: '123',
      ),
    ];
  }

  @override
  List<CategoryModel> getSubCategories(String parentId) {
    if (parentId == '1') {
      return [
        CategoryModel(
          id: '1-1',
          name: 'Lúa',
          icon: '🌾',
          color: '#4CAF50',
          parentId: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          description: '123',
        ),
      ];
    }
    return [];
  }

  @override
  List<String> getCategoryIds(String categoryId) => [categoryId];
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
  testWidgets('CategorySelector hiển thị và chọn dropdown', (tester) async {
    String? selectedValue;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CategoryProvider>.value(
            value: FakeCategoryProvider(
              CategoryRepository(null, CategoryService()),
            ),
          ),
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
            body: CategorySelector(
              isView: false,
              isAdd: true,
              onChanged: (val) {
                selectedValue = val;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Danh mục cấp 1 *'), findsOneWidget);

    // // Mở dropdown cấp 1
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cây Trồng').first);
    await tester.pumpAndSettle();

    expect(find.text('Danh mục cấp 2 *'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lúa').last);
    await tester.pumpAndSettle();

    expect(selectedValue, '1-1');
  });

  testWidgets('CategorySelector isView=true không cho chọn', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CategoryProvider>.value(
            value: FakeCategoryProvider(
              CategoryRepository(null, CategoryService()),
            ),
          ),
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
            body: CategorySelector(
              isView: true,
              isAdd: false,
              selectedCategoryId: '1',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cây Trồng'), findsOneWidget);
  });
}
