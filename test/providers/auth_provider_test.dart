import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -------------------- MOCKS --------------------
class MockAuthService extends Mock implements AuthService {}

class MockConnectivityProvider extends Mock implements ConnectivityProvider {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

void main() {
  late MockAuthService mockAuthService;
  late MockConnectivityProvider mockConnectivity;
  late AuthProvider provider;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(MockSession());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockAuthService = MockAuthService();
    mockConnectivity = MockConnectivityProvider();
    when(() => mockConnectivity.isOnline).thenReturn(true);
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.empty());

    provider = AuthProvider(mockConnectivity, mockAuthService);
    await Future.delayed(Duration(milliseconds: 50));
  });

  group('AuthProvider', () {
    test('signIn thành công => cập nhật user và role', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u123');
      when(() => mockUser.email).thenReturn('test@example.com');

      final mockSession = MockSession();
      when(() => mockSession.accessToken).thenReturn('token_abc');

      when(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(user: mockUser, session: mockSession),
      );

      when(
        () => mockAuthService.getCurrentUserRole(),
      ).thenAnswer((_) async => UserRoleModel.admin);

      final ok = await provider.signIn(
        email: 'test@example.com',
        password: '1234',
      );

      expect(ok, isTrue);
      expect(provider.user, equals(mockUser));
      expect(provider.userRole, equals(UserRoleModel.admin));
      expect(provider.isSignedIn, isTrue);
    });

    test('signIn thất bại => return false', () async {
      when(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('invalid'));

      final result = await provider.signIn(
        email: 'fail@example.com',
        password: 'wrong',
      );

      expect(result, isFalse);
      expect(provider.user, isNull);
    });
    test('signUp thành công => trả true và cập nhật user', () async {
      final mockUser = MockUser();
      when(
        () => mockAuthService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: mockUser, session: null));

      final result = await provider.signUp(
        email: 'test@example.com',
        password: '123456',
        fullName: 'John Doe',
      );

      expect(result, isTrue);
      expect(provider.user, equals(mockUser));
    });

    test('signUp thất bại => trả false và user null', () async {
      when(
        () => mockAuthService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: null, session: null));

      final result = await provider.signUp(
        email: 'fail@example.com',
        password: '123456',
        fullName: 'Fail User',
      );

      expect(result, isFalse);
      expect(provider.user, isNull);
    });

    test('signUp ném exception => trả false', () async {
      when(
        () => mockAuthService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await provider.signUp(
        email: 'error@example.com',
        password: '123456',
        fullName: 'Error User',
      );

      expect(result, isFalse);
      expect(provider.user, isNull);
    });
    test('resetPassword thành công => trả true', () async {
      when(
        () => mockAuthService.resetPassword(any()),
      ).thenAnswer((_) async => Future.value());

      final result = await provider.resetPassword('test@example.com');

      expect(result, isTrue);
      verify(() => mockAuthService.resetPassword('test@example.com')).called(1);
    });

    test('resetPassword thất bại => trả false', () async {
      when(
        () => mockAuthService.resetPassword(any()),
      ).thenThrow(Exception('Network error'));

      final result = await provider.resetPassword('fail@example.com');

      expect(result, isFalse);
      verify(() => mockAuthService.resetPassword('fail@example.com')).called(1);
    });

    test('updateUserRole => cập nhật local khi userId trùng', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u123');
      when(() => mockUser.email).thenReturn('user@example.com');

      final mockSession = MockSession();
      when(() => mockSession.accessToken).thenReturn('token_abc');

      when(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(user: mockUser, session: mockSession),
      );

      when(
        () => mockAuthService.getCurrentUserRole(),
      ).thenAnswer((_) async => UserRoleModel.viewer);

      await provider.signIn(email: 'user@example.com', password: 'pass');

      when(
        () => mockAuthService.updateUserRole('u123', UserRoleModel.admin),
      ).thenAnswer((_) async {});

      final res = await provider.updateUserRole('u123', UserRoleModel.admin);

      expect(res, isTrue);
      expect(provider.userRole, equals(UserRoleModel.admin));
    });

    test('signOut => clear user và role', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('u999');
      when(() => mockUser.email).thenReturn('x@example.com');

      final mockSession = MockSession();
      when(() => mockSession.accessToken).thenReturn('tok');

      when(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(user: mockUser, session: mockSession),
      );
      when(
        () => mockAuthService.getCurrentUserRole(),
      ).thenAnswer((_) async => UserRoleModel.admin);

      await provider.signIn(email: 'x@example.com', password: 'p');
      expect(provider.isSignedIn, isTrue);

      when(() => mockAuthService.signOut()).thenAnswer((_) async {});
      await provider.signOut();

      expect(provider.user, isNull);
      expect(provider.userRole, equals(UserRoleModel.viewer));
      expect(provider.isSignedIn, isFalse);
    });
  });
}
