import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/screens/register_screen.dart';
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

  Future<void> pumpRegisterScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
  }

  group('RegisterScreen', () {
    testWidgets('Hiển thị đầy đủ giao diện đăng ký', (tester) async {
      await pumpRegisterScreen(tester);

      expect(find.text('Tạo tài khoản mới'), findsOneWidget);
      expect(
        find.text('Điền thông tin để bắt đầu sử dụng hệ thống'),
        findsOneWidget,
      );
      expect(
        find.byType(TextFormField),
        findsNWidgets(4),
      ); // Họ tên, email, mật khẩu, xác nhận
      expect(find.text('Tạo tài khoản'), findsOneWidget);
    });

    testWidgets('Báo lỗi khi bỏ trống các trường', (tester) async {
      await pumpRegisterScreen(tester);

      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump();

      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
      expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('Báo lỗi khi email không hợp lệ hoặc mật khẩu không khớp', (
      tester,
    ) async {
      await pumpRegisterScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'T',
      ); // họ tên quá ngắn
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'saiemail',
      ); // email sai
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '1234567',
      ); // không khớp

      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump();

      expect(find.text('Họ tên quá ngắn'), findsOneWidget);
      expect(find.text('Email không hợp lệ'), findsOneWidget);
      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    });

    testWidgets('Hiển thị SnackBar xanh khi đăng ký thành công', (
      tester,
    ) async {
      when(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => true);

      await pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Nguyen Van A');
      await tester.enterText(find.byType(TextFormField).at(1), 'a@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');

      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Đăng ký thành công'), findsOneWidget);
    });

    testWidgets('Hiển thị SnackBar đỏ khi đăng ký thất bại', (tester) async {
      when(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => false);

      await pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Nguyen Van B');
      await tester.enterText(find.byType(TextFormField).at(1), 'b@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');

      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Đăng ký thất bại'), findsOneWidget);
    });
  });
}
