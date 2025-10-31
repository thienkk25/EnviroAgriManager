import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

// ---- MOCKS ---- //
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockUserResponse extends Mock implements UserResponse {}

class FakeUserAttributes extends Fake implements UserAttributes {}

void main() {
  SharedPreferences.setMockInitialValues({});
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;

  setUpAll(() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    registerFallbackValue(FakeUserAttributes());
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();

    // Gắn auth client giả vào supabase client
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);

    // Thay Supabase.instance.client bằng mock
    Supabase.instance.client = mockSupabaseClient;

    authService = AuthService();
  });

  group('AuthService', () {
    test('signUp() trả về AuthResponse khi thành công', () async {
      final mockResponse = MockAuthResponse();

      when(
        () => mockAuthClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.signUp(
        email: 'test@example.com',
        password: '123456',
        fullName: 'Tester',
      );

      expect(result, mockResponse);
      verify(
        () => mockAuthClient.signUp(
          email: 'test@example.com',
          password: '123456',
          data: {'full_name': 'Tester'},
        ),
      ).called(1);
    });

    test('signUp() ném lỗi khi Supabase báo AuthException', () async {
      when(
        () => mockAuthClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(AuthException('Email đã tồn tại'));

      expect(
        () async => authService.signUp(
          email: 'duplicate@example.com',
          password: '123456',
          fullName: 'Tester',
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Lỗi đăng ký'),
          ),
        ),
      );
    });

    test('signIn() trả về AuthResponse khi thành công', () async {
      final mockResponse = MockAuthResponse();

      when(
        () => mockAuthClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, mockResponse);
      verify(
        () => mockAuthClient.signInWithPassword(
          email: 'user@example.com',
          password: 'password',
        ),
      ).called(1);
    });

    test('signIn() ném lỗi khi AuthException', () async {
      when(
        () => mockAuthClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AuthException('Sai mật khẩu'));

      expect(
        () async =>
            authService.signIn(email: 'user@example.com', password: 'wrong'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Lỗi đăng nhập'),
          ),
        ),
      );
    });

    test('signOut() thành công', () async {
      when(() => mockAuthClient.signOut()).thenAnswer((_) async => {});

      await authService.signOut();

      verify(() => mockAuthClient.signOut()).called(1);
    });

    test('getCurrentUserRole() trả về viewer nếu chưa đăng nhập', () async {
      when(() => mockAuthClient.currentUser).thenReturn(null);

      final role = await authService.getCurrentUserRole();
      expect(role, UserRoleModel.viewer);
    });
  });
}
