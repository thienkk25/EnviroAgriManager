import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  late ConnectivityProvider _connectivityProvider;
  late AuthService _authService;
  late SharedPreferences _prefs;
  late AppPreferences _appPrefs;
  User? _user;
  UserRoleModel _userRole = UserRoleModel.viewer;
  bool _isLoading = false;
  bool _isOfflineMode = false;
  String _errorMessage = '';

  User? get user => _user;
  UserRoleModel get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isOfflineMode => _isOfflineMode;
  String get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  AuthProvider(this._connectivityProvider, this._authService) {
    initializeAuth();
  }
  void updateDependencies(
    ConnectivityProvider connectivity,
    AuthService authService,
  ) {
    _connectivityProvider = connectivity;
    _authService = authService;
  }

  /// Khởi tạo auth state
  Future<void> initializeAuth() async {
    _prefs = await SharedPreferences.getInstance();
    _appPrefs = AppPreferences(_prefs);
    _isOfflineMode = _connectivityProvider.isOnline;

    if (!_isOfflineMode) {
      // Offline: load user từ local cache
      final cached = _appPrefs.getCachedUser();
      if (cached['id'] != null) {
        _user = User(
          id: cached['id']!,
          email: cached['email'],
          appMetadata: {},
          userMetadata: {"full_name": "Offline"},
          aud: '',
          createdAt: '',
        );
        _userRole = UserRoleModel.fromString(cached['role']!);
      }
    } else {
      // Online: load từ Supabase
      _user = _authService.currentUser;
      await _loadUserRole();
      if (_user != null) {
        await _appPrefs.setCachedUser(
          id: _user!.id,
          email: _user!.email ?? '',
          role: (await _authService.getCurrentUserRole()).value,
        );
      }

      // Lắng nghe thay đổi trạng thái authentication
      _authService.authStateChanges.listen((data) async {
        _user = data.session?.user;
        await _loadUserRole();
        if (_user != null) {
          await _appPrefs.setCachedUser(
            id: _user!.id,
            email: _user!.email ?? '',
            role: (await _authService.getCurrentUserRole()).value,
          );
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    if (_user != null) {
      try {
        _userRole = await _authService.getCurrentUserRole();
      } catch (_) {
        _userRole = UserRoleModel.viewer;
      }
    } else {
      _userRole = UserRoleModel.viewer;
    }
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

        await _appPrefs.setAccessToken(response.session?.accessToken ?? '');
        await _appPrefs.setCachedUser(
          id: _user!.id,
          email: _user!.email ?? '',
          role: _userRole.value,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      if (!_isOfflineMode) await _authService.signOut();
      await _appPrefs.clearCachedUser();
      _user = null;
      _userRole = UserRoleModel.viewer;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authService.updatePassword(oldPassword, newPassword);
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _authService.updateDisplayName(newName);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      case 'isEditor':
        return _userRole.isEditor;
      case 'isAdmin':
        return _userRole.isAdmin;
      default:
        return false;
    }
  }

  /// Cập nhật role của user được chỉ định
  Future<bool> updateUserRole(String userId, UserRoleModel newRole) async {
    try {
      await _authService.updateUserRole(userId, newRole);

      // Nếu cập nhật chính mình thì đổi local luôn
      if (_user?.id == userId) {
        _userRole = newRole;
        await _appPrefs.setCachedUser(
          id: _user!.id,
          email: _user!.email ?? '',
          role: newRole.value,
        );
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
      _errorMessage = e.toString();
      return null;
    }
  }
}
