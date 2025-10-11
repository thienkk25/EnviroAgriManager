import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role_model.dart';

class RoleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy role của 1 user từ bảng profiles + roles
  Future<UserRoleModel> getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('roles(name)')
          .eq('id', userId)
          .maybeSingle();

      if (response == null || response['roles'] == null) {
        return UserRoleModel.viewer; // mặc định viewer
      }

      final roleName = response['roles']['name'] as String;
      return UserRoleModel.fromString(roleName);
    } catch (e) {
      throw Exception('Lỗi lấy role: $e');
    }
  }

  /// Cập nhật role của user (role_id)
  Future<void> setUserRole(String userId, UserRoleModel role) async {
    try {
      // Lấy role_id theo role.name
      final roleRow = await _supabase
          .from('roles')
          .select('id')
          .eq('name', role.value)
          .maybeSingle();

      if (roleRow == null) {
        throw Exception('Role ${role.value} không tồn tại');
      }

      await _supabase
          .from('profiles')
          .update({
            'role_id': roleRow['id'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Lỗi cập nhật role: $e');
    }
  }

  /// Lấy danh sách tất cả users kèm role (chỉ admin mới xem được nhờ policy)
  Future<List<Map<String, dynamic>>> getAllUsersWithRoles() async {
    try {
      final response = await _supabase.rpc('get_users_with_roles');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách users: $e');
    }
  }

  /// Xóa profile (chỉ admin được phép theo policy)
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase.from('profiles').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Lỗi xóa profile: $e');
    }
  }

  /// Kiểm tra hệ thống có admin nào không
  Future<bool> hasAdmin() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, roles(name)')
          .eq('roles.name', 'admin')
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
