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
