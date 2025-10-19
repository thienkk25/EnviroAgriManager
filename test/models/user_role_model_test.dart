import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';

void main() {
  group('UserRoleModel', () {
    test('Giá trị và mô tả của từng role đúng', () {
      expect(UserRoleModel.admin.value, 'admin');
      expect(UserRoleModel.admin.displayName, 'Admin');
      expect(UserRoleModel.admin.description, contains('toàn quyền'));

      expect(UserRoleModel.editor.value, 'editor');
      expect(UserRoleModel.viewer.value, 'viewer');
    });

    test('fromString trả về đúng role tương ứng', () {
      expect(UserRoleModel.fromString('admin'), UserRoleModel.admin);
      expect(UserRoleModel.fromString('editor'), UserRoleModel.editor);
      expect(UserRoleModel.fromString('viewer'), UserRoleModel.viewer);
    });

    test('fromString trả về viewer nếu role không hợp lệ', () {
      expect(UserRoleModel.fromString('invalid_role'), UserRoleModel.viewer);
    });

    test('Kiểm tra quyền admin', () {
      final role = UserRoleModel.admin;
      expect(role.canEdit, isTrue);
      expect(role.canDelete, isTrue);
      expect(role.canManageUsers, isTrue);
      expect(role.canManageSettings, isTrue);
      expect(role.canViewReports, isTrue);
    });

    test('Kiểm tra quyền editor', () {
      final role = UserRoleModel.editor;
      expect(role.canEdit, isTrue);
      expect(role.canDelete, isFalse);
      expect(role.canManageUsers, isFalse);
      expect(role.canManageSettings, isFalse);
      expect(role.canViewReports, isTrue);
    });

    test('Kiểm tra quyền viewer', () {
      final role = UserRoleModel.viewer;
      expect(role.canEdit, isFalse);
      expect(role.canDelete, isFalse);
      expect(role.canManageUsers, isFalse);
      expect(role.canManageSettings, isFalse);
      expect(role.canViewReports, isTrue);
    });
  });
}
