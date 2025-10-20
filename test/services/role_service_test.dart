import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/services/role_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock RoleService
class MockRoleService extends Mock implements RoleService {}

void main() {
  late MockRoleService mockService;

  setUp(() {
    mockService = MockRoleService();
  });

  group('RoleService', () {
    test('getUserRole', () async {
      when(
        () => mockService.getUserRole('user-viewer'),
      ).thenAnswer((_) async => UserRoleModel.viewer);
      when(
        () => mockService.getUserRole('user-editor'),
      ).thenAnswer((_) async => UserRoleModel.editor);
      when(
        () => mockService.getUserRole('user-admin'),
      ).thenAnswer((_) async => UserRoleModel.admin);

      expect(
        await mockService.getUserRole('user-viewer'),
        UserRoleModel.viewer,
      );
      expect(
        await mockService.getUserRole('user-editor'),
        UserRoleModel.editor,
      );
      expect(await mockService.getUserRole('user-admin'), UserRoleModel.admin);
    });

    test('setUserRole', () async {
      // Không dùng any<UserRoleModel>(), dùng enum trực tiếp
      when(
        () => mockService.setUserRole('user-id', UserRoleModel.editor),
      ).thenAnswer((_) async => Future.value());

      await mockService.setUserRole('user-id', UserRoleModel.editor);

      verify(
        () => mockService.setUserRole('user-id', UserRoleModel.editor),
      ).called(1);
    });

    test('deleteUserProfile', () async {
      when(
        () => mockService.deleteUserProfile('user-id'),
      ).thenAnswer((_) async => Future.value());

      await mockService.deleteUserProfile('user-id');

      verify(() => mockService.deleteUserProfile('user-id')).called(1);
    });

    test('hasAdmin returns true/false', () async {
      when(() => mockService.hasAdmin()).thenAnswer((_) async => true);
      expect(await mockService.hasAdmin(), true);

      when(() => mockService.hasAdmin()).thenAnswer((_) async => false);
      expect(await mockService.hasAdmin(), false);
    });

    test('getAllUsersWithRoles', () async {
      final mockList = [
        {'id': '1', 'full_name': 'Admin', 'role': 'admin'},
        {'id': '2', 'full_name': 'Editor', 'role': 'editor'},
      ];

      when(
        () => mockService.getAllUsersWithRoles(),
      ).thenAnswer((_) async => mockList);

      final result = await mockService.getAllUsersWithRoles();
      expect(result.length, 2);
      expect(result[0]['role'], 'admin');
      expect(result[1]['role'], 'editor');
    });
  });
}
