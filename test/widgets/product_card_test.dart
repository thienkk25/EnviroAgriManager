import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends AuthProvider {
  final bool isOpen;
  FakeAuthProvider(super.connectivityProvider, super.authService, this.isOpen);

  @override
  UserRoleModel get userRole => UserRoleModel.admin;

  @override
  bool hasPermission(String permission) => isOpen;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late ProductModel model;

  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    final now = DateTime.parse('2025-10-19T08:00:00Z');
    model = ProductModel(
      id: 'prd_001',
      name: 'Phân bón hữu cơ sinh học',
      description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
      categoryId: 'cat_001',
      price: 150000,
      quantity: 50,
      unit: 'kg',
      imageUrl: 'https://example.com/images/product1.jpg',
      createdAt: now,
      updatedAt: now,
      status: 'active',
    );
  });
  Widget buildTestWidget({
    required ProductModel product,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MultiProvider(
      providers: [
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
          body: ProductCard(
            product: product,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('ProductCard', () {
    testWidgets('Hiển thị dữ liệu', (widgetTester) async {
      await widgetTester.pumpWidget(buildTestWidget(product: model));
      await widgetTester.pumpAndSettle();

      expect(find.textContaining('Phân bón hữu cơ sinh học'), findsOneWidget);
      expect(
        find.textContaining('Phân bón giúp cải thiện độ phì nhiêu của đất'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
          ).format(150000).toString(),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('50 kg'), findsOneWidget);
    });
    testWidgets('Hiển thị thông tin khi onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(product: model, onTap: () => tapped = true),
      );
      await tester.pumpAndSettle();

      // Tap
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Hiển thị menu khi có quyền và gọi onEdit/onDelete', (
      tester,
    ) async {
      bool edited = false;
      bool deleted = false;

      await tester.pumpWidget(
        buildTestWidget(
          product: model,
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
            ChangeNotifierProvider<AuthProvider>.value(
              value: FakeAuthProvider(
                ConnectivityProvider(ConnectivityService()),
                AuthService(),
                false,
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ProductCard(product: model)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });
  });
}
