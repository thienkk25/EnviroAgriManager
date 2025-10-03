enum UserRole {
  admin('admin', 'Admin', 'Có toàn quyền truy cập hệ thống'),
  editor('editor', 'Quản lý', 'Có thể chỉnh sửa và quản lý dữ liệu'),
  viewer('viewer', 'Người xem', 'Chỉ có thể xem dữ liệu');

  const UserRole(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'editor':
        return UserRole.editor;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer; // Default role
    }
  }

  // Kiểm tra quyền
  bool get canEdit => this == UserRole.admin || this == UserRole.editor;
  bool get canDelete => this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
  bool get canViewReports => true; // Tất cả role đều có thể xem báo cáo
  bool get canManageSettings => this == UserRole.admin;
}
