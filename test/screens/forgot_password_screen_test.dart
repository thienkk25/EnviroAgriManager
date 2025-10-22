import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/screens/forgot_password_screen.dart';
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

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const ForgotPasswordScreen(),
        ),
      ),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('Hiển thị UI cơ bản', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.text('Đặt lại mật khẩu'), findsOneWidget);
      expect(
        find.text('Nhập email để nhận liên kết đặt lại mật khẩu'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Hiển thị lỗi khi email trống', (WidgetTester tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Gửi liên kết'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('Hiển thị lỗi khi email không hợp lệ', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.tap(find.text('Gửi liên kết'));
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('Gửi email thành công -> hiển thị SnackBar xanh', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthProvider.resetPassword(any()),
      ).thenAnswer((_) async => true);

      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Gửi liên kết'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Vui lòng kiểm tra email'), findsOneWidget);
    });

    testWidgets('Gửi email thất bại -> hiển thị SnackBar đỏ', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthProvider.resetPassword(any()),
      ).thenAnswer((_) async => false);

      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Gửi liên kết'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Gửi email thất bại'), findsOneWidget);
    });
  });
}
