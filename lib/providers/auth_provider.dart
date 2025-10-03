import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserRole _userRole = UserRole.viewer;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  /// Khởi tạo auth state
  Future<void> _initializeAuth() async {
    _user = _authService.currentUser;
    await _loadUserRole();
    notifyListeners();

    // Lắng nghe thay đổi trạng thái authentication
    _authService.authStateChanges.listen((data) async {
      _user = data.session?.user;
      await _loadUserRole();
      notifyListeners();
    });
  }

  Future<void> _loadUserRole() async {
    if (_user != null) {
      try {
        _userRole = await _authService.getCurrentUserRole();
      } catch (_) {
        _userRole = UserRole.viewer;
      }
    } else {
      _userRole = UserRole.viewer;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        _user = response.user;
        return true;
      }
      return false;
    } catch (e) {
      // _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadUserRole();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // _setError(e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      // _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signOut();
      _user = null;
      _userRole = UserRole.viewer;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }

  /// Kiểm tra quyền
  bool hasPermission(String permission) {
    switch (permission) {
      case 'edit':
        return _userRole.canEdit;
      case 'delete':
        return _userRole.canDelete;
      case 'manage_users':
        return _userRole.canManageUsers;
      case 'view_reports':
        return _userRole.canViewReports;
      case 'manage_settings':
        return _userRole.canManageSettings;
      default:
        return false;
    }
  }

  /// Cập nhật role của user được chỉ định
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _authService.updateUserRole(userId, newRole);

      // Nếu cập nhật chính mình thì đổi local luôn
      if (_user?.id == userId) {
        _userRole = newRole;
        notifyListeners();
      }

      return true;
    } catch (e) {
      // _setError(e.toString());
      return false;
    }
  }

  /// Lấy danh sách tất cả users với role (chỉ admin)
  Future<List<Map<String, dynamic>>?> getAllUsersWithRoles() async {
    if (!_userRole.canManageUsers) return null;

    try {
      final users = await _authService.getAllUsersWithProfiles();
      return users;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }
}
