import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  static const String routeName = '/user-management';

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<Map<String, dynamic>>?> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture = context.read<AuthProvider>().getAllUsersWithRoles();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quản lý người dùng',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          IconButton(onPressed: _refreshUsers, icon: const Icon(Icons.refresh)),
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
                  style: GoogleFonts.inter(color: Colors.red),
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
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshUsers,
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
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: _getRoleColor(role),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Tạo: ${_formatDate(userData['profile_created_at'] as String?)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Cập nhật: ${_formatDate(userData['profile_updated_at'] as String?)}',
                                  style: GoogleFonts.inter(
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
        return AlertDialog(
          title: Text(
            'Cập nhật quyền cho ${userData['email']}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: RadioGroup<UserRoleModel>(
            groupValue: currentRole,
            onChanged: (UserRoleModel? newRole) async {
              if (newRole == null) return;
              Navigator.of(dialogContext).pop(); // đóng dialog
              final authProvider = context.read<AuthProvider>();

              final success = await authProvider.updateUserRole(
                userData['id'],
                newRole,
              );

              if (success && context.mounted) {
                // Dùng context cha (không phải dialogContext)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã cập nhật quyền của ${userData['email']}'),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshUsers();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: UserRoleModel.values.map((role) {
                return ListTile(
                  title: Text(role.displayName),
                  subtitle: Text(role.description),
                  leading: Radio<UserRoleModel>(value: role),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
          ],
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
