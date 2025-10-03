import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_role.dart';
import 'role_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final RoleService _roleService = RoleService();

  // Lấy user hiện tại
  User? get currentUser => _supabase.auth.currentUser;

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
      await _supabase.auth.signOut();
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
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } on AuthException catch (error) {
      throw Exception('Lỗi cập nhật mật khẩu: ${error.message}');
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Kiểm tra xem user đã đăng nhập chưa
  bool get isSignedIn => currentUser != null;

  // Lấy session hiện tại
  Session? get currentSession => _supabase.auth.currentSession;

  // Lấy role của user hiện tại
  Future<UserRole> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return UserRole.viewer;

    return await _roleService.getUserRole(user.id);
  }

  // Cập nhật role của user
  Future<void> updateUserRole(String userId, UserRole role) async {
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
