import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/services/role_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final RoleService _roleService = RoleService();

  // Lấy user hiện tại
  User? get currentUser => _supabase.auth.currentUser;

  // Kiểm tra xem user đã đăng nhập chưa
  bool get isSignedIn => currentUser != null;

  // Lấy session hiện tại
  Session? get currentSession => _supabase.auth.currentSession;

  // Stream để theo dõi trạng thái authentication
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Đăng ký tài khoản mới
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response;
    } on AuthException catch (error) {
      throw Exception('Lỗi đăng ký: ${error.message}');
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Đăng nhập
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (error) {
      throw Exception('Lỗi đăng nhập: ${error.message}');
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
    } catch (error) {
      throw Exception('Lỗi đăng xuất: $error');
    }
  }

  // Quên mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: SupabaseConfig.redirectUrl,
      );
    } on AuthException catch (error) {
      throw Exception('Lỗi gửi email đặt lại mật khẩu: ${error.message}');
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Cập nhật mật khẩu
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final email = _supabase.auth.currentUser?.email;

      if (email == null) throw Exception('Không tìm thấy email người dùng');

      final loginResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (loginResponse.user == null) {
        throw Exception('Mật khẩu cũ không đúng');
      }
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (error) {
      throw Exception('Lỗi cập nhật mật khẩu: ${error.message}');
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Cập nhật tên hiển thị của người dùng (displayName)
  Future<void> updateDisplayName(String newName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Cập nhật thông tin user trong Supabase Auth
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );

      if (response.user == null) {
        throw Exception('Cập nhật thất bại');
      }
      await _supabase
          .from('profiles')
          .update({'full_name': newName})
          .eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Lấy role của user hiện tại
  Future<UserRoleModel> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return UserRoleModel.viewer;

    return await _roleService.getUserRole(user.id);
  }

  // Cập nhật role của user
  Future<void> updateUserRole(String userId, UserRoleModel role) async {
    try {
      await _roleService.setUserRole(userId, role);
    } catch (error) {
      throw Exception('Lỗi cập nhật role: $error');
    }
  }

  // Lấy danh sách tất cả users + profile + role (chỉ admin)
  Future<List<Map<String, dynamic>>> getAllUsersWithProfiles() async {
    try {
      return await _roleService.getAllUsersWithRoles();
    } catch (error) {
      throw Exception('Lỗi lấy danh sách users: $error');
    }
  }
}
