import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  static const String routeName = '/user-management';

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _isRefresh = false;
  late AnimationController _rotationController;
  late Future<List<Map<String, dynamic>>?> _usersFuture;
  @override
  void initState() {
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _usersFuture = context.read<AuthProvider>().getAllUsersWithRoles();

    super.initState();
  }

  Future<void> _refreshUsers(BuildContext context) async {
    if (_isRefresh) return;
    setState(() {
      _isRefresh = true;
    });
    _rotationController.forward(from: 0);
    _usersFuture = context.read<AuthProvider>().getAllUsersWithRoles();
    await _usersFuture;
    await Future.delayed(Duration(milliseconds: 700));
    setState(() {
      _isRefresh = false;
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    if (!isOnline) {
      return const Scaffold(
        body: Center(child: Text('Chức năng này cần online')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quản lý người dùng',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          IconButton(
            icon: RotationTransition(
              turns: _rotationController,
              child: Icon(Icons.refresh, color: Colors.white),
            ),
            onPressed: _isRefresh ? null : () => _refreshUsers(context),
          ),
        ],
      ),
      body: RoleBasedWidget(
        permission: 'manage_users',
        adminChild: FutureBuilder<List<Map<String, dynamic>>?>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.red,
                  ),
                ),
              );
            }

            final users = snapshot.data ?? [];
            final user = context.read<AuthProvider>().user?.id;
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có người dùng nào',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _refreshUsers(context),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = Map<String, dynamic>.from(users[index]);
                  final role = UserRoleModel.fromString(
                    userData['role_name'] as String? ?? 'viewer',
                  );
                  final fullName =
                      userData['full_name'] as String? ?? 'Chưa cập nhật';
                  final email = userData['email'] as String? ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(
                          role,
                        ).withValues(alpha: .1),
                        child: Icon(
                          _getRoleIcon(role),
                          color: _getRoleColor(role),
                        ),
                      ),
                      title: Text(
                        user == userData['id'] ? "Tôi" : fullName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(email),
                          Row(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(
                                    role,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  role.displayName,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: _getRoleColor(role),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Tạo: ${_formatDate(userData['profile_created_at'] as String?)}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Cập nhật: ${_formatDate(userData['profile_updated_at'] as String?)}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => _showRoleDialog(context, userData),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Cập nhật quyền',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        fallbackChild: const NoPermissionWidget(
          message: 'Chỉ quản trị viên mới có thể truy cập tính năng này',
          icon: Icons.admin_panel_settings,
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, Map<String, dynamic> userData) {
    final currentRole = UserRoleModel.fromString(
      userData['role_name'] as String? ?? 'viewer',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cập nhật quyền cho\n${userData['email']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // List quyền
                Column(
                  children: UserRoleModel.values.map((role) {
                    final isSelected = role == currentRole;
                    final roleIcon = _getRoleIcon(role);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent.withValues(alpha: .1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          final authProvider = context.read<AuthProvider>();

                          final success = await authProvider.updateUserRole(
                            userData['id'],
                            role,
                          );

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green.shade600,
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Đã cập nhật quyền ${role.displayName} cho ${userData['email']}',
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            _refreshUsers(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          leading: Icon(roleIcon, color: Colors.blueAccent),
                          title: Text(
                            role.displayName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey.shade800,
                            ),
                          ),
                          subtitle: Text(
                            role.description,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.blueAccent,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    label: const Text(
                      'Hủy',
                      style: TextStyle(fontFamily: 'Inter', color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRoleModel role) {
    switch (role) {
      case UserRoleModel.admin:
        return Colors.red;
      case UserRoleModel.editor:
        return Colors.orange;
      case UserRoleModel.viewer:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(UserRoleModel role) {
    switch (role) {
      case UserRoleModel.admin:
        return Icons.admin_panel_settings;
      case UserRoleModel.editor:
        return Icons.edit;
      case UserRoleModel.viewer:
        return Icons.visibility;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknows';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Unknows';
    }
  }
}
