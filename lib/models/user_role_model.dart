enum UserRoleModel {
  admin('admin', 'Admin', 'Có toàn quyền truy cập hệ thống'),
  editor('editor', 'Quản lý', 'Có thể chỉnh sửa và quản lý dữ liệu'),
  viewer('viewer', 'Người xem', 'Chỉ có thể xem dữ liệu');

  const UserRoleModel(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static UserRoleModel fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRoleModel.admin;
      case 'editor':
        return UserRoleModel.editor;
      case 'viewer':
        return UserRoleModel.viewer;
      default:
        return UserRoleModel.viewer; // Default role
    }
  }

  // Kiểm tra quyền
  bool get canEdit =>
      this == UserRoleModel.admin || this == UserRoleModel.editor;
  bool get canDelete => this == UserRoleModel.admin;
  bool get canManageUsers => this == UserRoleModel.admin;
  bool get canViewReports => true;
  bool get canManageSettings => this == UserRoleModel.admin;
  bool get isEditor => this == UserRoleModel.editor;
  bool get isAdmin => this == UserRoleModel.admin;
}
