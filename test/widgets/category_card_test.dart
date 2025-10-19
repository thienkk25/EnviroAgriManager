import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  final bool isOpen;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isOpen);

  @override
  bool hasPermission(String permission) => isOpen;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late CategoryModel categoryModel;

  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    categoryModel = CategoryModel(
      id: '123',
      name: 'Cây trồng',
      description: 'Danh mục các loại cây trồng',
      icon: '🌾',
      color: '#4CAF50',
      parentId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
  });

  Widget buildTestWidget({
    required CategoryModel category,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onLongPress,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              CategoryProvider(CategoryRepository(null, CategoryService())),
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
          body: CategoryCard(
            category: category,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }

  group('CategoryCard', () {
    testWidgets('Hiển thị đúng thông tin CategoryCard', (tester) async {
      await tester.pumpWidget(buildTestWidget(category: categoryModel));

      await tester.pumpAndSettle();

      expect(find.textContaining('Cây trồng'), findsOneWidget);
      expect(find.textContaining('Hoạt động'), findsOneWidget);
      expect(find.textContaining('🌾'), findsOneWidget);
      expect(find.textContaining('0 loại'), findsOneWidget);
    });

    testWidgets('Hiển thị thông tin CategoryCard khi onTap và onLongPress', (
      tester,
    ) async {
      bool tapped = false;
      bool longPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          category: categoryModel,
          onTap: () => tapped = true,
          onLongPress: () => longPressed = true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, isTrue);

      // Long press
      await tester.longPress(find.byType(InkWell).first);
      await tester.pump();
      expect(longPressed, isTrue);
    });

    testWidgets('Hiển thị menu khi có quyền và gọi onEdit/onDelete', (
      tester,
    ) async {
      bool edited = false;
      bool deleted = false;

      await tester.pumpWidget(
        buildTestWidget(
          category: categoryModel,
          onEdit: () => edited = true,
          onDelete: () => deleted = true,
        ),
      );
      await tester.pumpAndSettle();

      final popupFinder = find.byType(PopupMenuButton<String>);
      expect(popupFinder, findsOneWidget);

      await tester.tap(popupFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chỉnh sửa'));
      await tester.pumpAndSettle();
      expect(edited, isTrue);

      await tester.tap(popupFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets('Ẩn menu khi không có quyền', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) =>
                  CategoryProvider(CategoryRepository(null, CategoryService())),
            ),
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
              body: CategoryCard(
                category: categoryModel,
                onTap: () {},
                onEdit: () {},
                onDelete: () {},
                onLongPress: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });
  });
}
