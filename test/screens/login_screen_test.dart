import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Mock AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          // định nghĩa các route phụ để tránh lỗi khi điều hướng
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/forgot':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Quên mật khẩu')),
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Đăng ký')),
                );
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Trang chủ')),
                );
            }
            return null;
          },
        ),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('Hiển thị đầy đủ các thành phần UI', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.widgetWithText(AppBar, 'Đăng nhập'), findsOneWidget);
      expect(find.text('Chào mừng trở lại'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Đăng nhập'), findsOneWidget);
    });

    testWidgets('Báo lỗi khi bỏ trống email và mật khẩu', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pump(); // để validator chạy

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('Hiển thị SnackBar xanh khi đăng nhập thành công', (
      tester,
    ) async {
      when(
        () => mockAuthProvider.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Đăng nhập thành công!'), findsOneWidget);
    });

    testWidgets('Hiển thị SnackBar đỏ khi đăng nhập thất bại', (tester) async {
      when(
        () => mockAuthProvider.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => false);

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Đăng nhập thất bại'), findsOneWidget);
    });

    testWidgets('Điều hướng sang màn hình quên mật khẩu', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();

      expect(find.text('Quên mật khẩu'), findsOneWidget);
    });
  });
}
