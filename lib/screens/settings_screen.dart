import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _notificationsEnabled = true;
  late bool _darkModeEnabled;
  late int _selectedSync;
  // bool _temperatureAlert = true;
  // bool _humidityAlert = true;
  // bool _phAlert = true;
  // String _selectedLanguage = 'Tiếng Việt';
  // String _selectedUpdateFrequency = 'Cập nhật mỗi 30 phút';
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        context.read<SettingsProvider>().scheduleAutoSyncData(() async {
          await Future.wait([
            context.read<ProductProvider>().refreshProducts(
              context.read<ConnectivityProvider>().isOnline,
            ),
            context.read<CategoryProvider>().refreshCategories(
              context.read<ConnectivityProvider>().isOnline,
            ),
            context.read<EnvironmentalDataProvider>().refreshEnvironmentalData(
              context.read<ConnectivityProvider>().isOnline,
            ),
            context.read<RegionProvider>().refreshRegions(
              context.read<ConnectivityProvider>().isOnline,
            ),
          ]);
        }, context.read<SettingsProvider>().secondSync);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _darkModeEnabled =
        context.read<SettingsProvider>().themeMode == ThemeMode.dark;
    _selectedSync = context.read<SettingsProvider>().secondSync;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Section
              _buildProfileSection(),
              const SizedBox(height: 24),

              // System Settings
              _buildSystemSettings(),
              const SizedBox(height: 24),

              // HACK
              // // Environmental Settings
              // _buildEnvironmentalSettings(),
              // const SizedBox(height: 24),

              // About Section
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userRole = authProvider.userRole;
        final displayName = user?.userMetadata?['full_name'] ?? 'Người dùng';
        final email = user?.email ?? 'email@example.com';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF5E81AC).withValues(alpha: .1),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF5E81AC),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF88C0D0),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(userRole).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userRole.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getRoleColor(userRole),
                  ),
                ),
              ),

              // HACK
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {
              //     _showEditProfileDialog();
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF5E81AC),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text(
              //     'Chỉnh sửa thông tin',
              //     style: const TextStyle(fontFamily: 'Inter',
              //       color: Colors.white,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt hệ thống',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 16),
          // HACK
          // _buildSettingItem(
          //   icon: Icons.notifications,
          //   title: 'Thông báo',
          //   subtitle: 'Nhận thông báo về cập nhật hệ thống',
          //   trailing: Switch(
          //     value: _notificationsEnabled,
          //     onChanged: (value) {
          //       setState(() {
          //         _notificationsEnabled = value;
          //       });
          //     },
          //     activeThumbColor: const Color(0xFF5E81AC),
          //   ),
          // ),
          // const Divider(),
          // _buildSettingItem(
          //   icon: Icons.language,
          //   title: 'Ngôn ngữ',
          //   subtitle: _selectedLanguage,
          //   trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
          //   onTap: () {
          //     _showLanguageDialog();
          //   },
          // ),
          // const Divider(),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Chế độ tối',
            subtitle: 'Giao diện tối cho mắt',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (_) => context.read<SettingsProvider>().toggleTheme(),
              activeThumbColor: const Color(0xFF5E81AC),
            ),
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.sync,
            title: 'Đồng bộ dữ liệu',
            subtitle:
                'Tự động đồng bộ mỗi ${(_selectedSync / 60).toInt()} phút',
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
            onTap: () {
              _showSyncDialog();
            },
          ),
        ],
      ),
    );
  }

  // HACK
  // Widget _buildEnvironmentalSettings() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: .05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Cài đặt môi trường',
  //           style: const TextStyle(fontFamily: 'Inter',
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: const Color(0xFF2E3440),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         _buildSettingItem(
  //           icon: Icons.thermostat,
  //           title: 'Cảnh báo nhiệt độ',
  //           subtitle: 'Cảnh báo khi nhiệt độ vượt ngưỡng',
  //           trailing: Switch(
  //             value: _temperatureAlert,
  //             onChanged: (value) {
  //               setState(() {
  //                 _temperatureAlert = value;
  //               });
  //             },
  //             activeThumbColor: const Color(0xFF5E81AC),
  //           ),
  //         ),
  //         const Divider(),
  //         _buildSettingItem(
  //           icon: Icons.water_drop,
  //           title: 'Cảnh báo độ ẩm',
  //           subtitle: 'Cảnh báo khi độ ẩm thấp',
  //           trailing: Switch(
  //             value: _humidityAlert,
  //             onChanged: (value) {
  //               setState(() {
  //                 _humidityAlert = value;
  //               });
  //             },
  //             activeThumbColor: const Color(0xFF5E81AC),
  //           ),
  //         ),
  //         const Divider(),
  //         _buildSettingItem(
  //           icon: Icons.science,
  //           title: 'Giám sát độ pH',
  //           subtitle: 'Theo dõi độ pH của đất',
  //           trailing: Switch(
  //             value: _phAlert,
  //             onChanged: (value) {
  //               setState(() {
  //                 _phAlert = value;
  //               });
  //             },
  //             activeThumbColor: const Color(0xFF5E81AC),
  //           ),
  //         ),
  //         const Divider(),
  //         _buildSettingItem(
  //           icon: Icons.schedule,
  //           title: 'Tần suất cập nhật',
  //           subtitle: _selectedUpdateFrequency,
  //           trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
  //           onTap: () {
  //             _showUpdateFrequencyDialog();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin ứng dụng',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Phiên bản',
            subtitle: 'v1.0.0',
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
            onTap: () {
              _showVersionDialog();
            },
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Trợ giúp',
            subtitle: 'Hướng dẫn sử dụng',
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
            onTap: () {
              _showHelpDialog();
            },
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Chính sách bảo mật',
            subtitle: 'Quyền riêng tư và bảo mật',
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
            onTap: () {
              _showPrivacyDialog();
            },
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            subtitle: 'Thoát khỏi hệ thống',
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF88C0D0)),
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF5E81AC).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF5E81AC), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2E3440),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF88C0D0),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // HACK
  // void _showEditProfileDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Chỉnh sửa thông tin',
  //           style: const TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.w600),
  //         ),
  //         content: const Text(
  //           'Tính năng này sẽ được phát triển trong phiên bản tiếp theo.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text(
  //               'Đóng',
  //               style: const TextStyle(fontFamily: 'Inter',color: const Color(0xFF5E81AC)),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showLanguageDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Chọn ngôn ngữ',
  //           style: const TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.w600),
  //         ),
  //         content: RadioGroup<String>(
  //           groupValue: _selectedLanguage,
  //           onChanged: (value) {
  //             setState(() {
  //               _selectedLanguage = value!;
  //             });
  //             Navigator.of(context).pop();
  //           },
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                 title: const Text('Tiếng Việt'),
  //                 leading: const Radio(
  //                   value: 'Tiếng Việt',
  //                   activeColor: Color(0xFF5E81AC),
  //                 ),
  //               ),
  //               ListTile(
  //                 title: const Text('English'),
  //                 leading: const Radio(
  //                   value: 'English',
  //                   activeColor: Color(0xFF5E81AC),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Đồng bộ dữ liệu',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: RadioGroup<int>(
            groupValue: _selectedSync,
            onChanged: (value) {
              setState(() {
                _selectedSync = value!;
              });
              if (!kIsWeb) {
                context.read<SettingsProvider>().scheduleAutoSyncData(() async {
                  await Future.wait([
                    context.read<ProductProvider>().refreshProducts(
                      context.read<ConnectivityProvider>().isOnline,
                    ),
                    context.read<CategoryProvider>().refreshCategories(
                      context.read<ConnectivityProvider>().isOnline,
                    ),
                    context
                        .read<EnvironmentalDataProvider>()
                        .refreshEnvironmentalData(
                          context.read<ConnectivityProvider>().isOnline,
                        ),
                    context.read<RegionProvider>().refreshRegions(
                      context.read<ConnectivityProvider>().isOnline,
                    ),
                  ]);
                }, _selectedSync);
              }
              Navigator.of(context).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Tự động đồng bộ mỗi 5 phút'),
                  leading: const Radio(
                    value: 5 * 60,
                    activeColor: Color(0xFF5E81AC),
                  ),
                ),
                ListTile(
                  title: const Text('Tự động đồng bộ mỗi 15 phút'),
                  leading: const Radio(
                    value: 15 * 60,
                    activeColor: Color(0xFF5E81AC),
                  ),
                ),
                ListTile(
                  title: const Text('Tự động đồng bộ mỗi 30 phút'),
                  leading: const Radio(
                    value: 30 * 60,
                    activeColor: Color(0xFF5E81AC),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showUpdateFrequencyDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Tần suất cập nhật',
  //           style: const TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.w600),
  //         ),
  //         content: RadioGroup<String>(
  //           groupValue: _selectedUpdateFrequency,
  //           onChanged: (value) {
  //             setState(() {
  //               _selectedUpdateFrequency = value!;
  //             });
  //             Navigator.of(context).pop();
  //           },
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                 title: const Text('Cập nhật mỗi 15 phút'),
  //                 leading: Radio<String>(
  //                   value: 'Cập nhật mỗi 15 phút',
  //                   activeColor: const Color(0xFF5E81AC),
  //                 ),
  //               ),
  //               ListTile(
  //                 title: const Text('Cập nhật mỗi 30 phút'),
  //                 leading: Radio<String>(
  //                   value: 'Cập nhật mỗi 30 phút',
  //                   activeColor: const Color(0xFF5E81AC),
  //                 ),
  //               ),
  //               ListTile(
  //                 title: const Text('Cập nhật mỗi 1 giờ'),
  //                 leading: Radio<String>(
  //                   value: 'Cập nhật mỗi 1 giờ',
  //                   activeColor: const Color(0xFF5E81AC),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Thông tin phiên bản',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phiên bản: v1.0.0',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              Text(
                'Ngày phát hành: 2025',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              Text(
                'Nhà phát triển: Thien Nguyen',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF5E81AC),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Trợ giúp',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Tài liệu hướng dẫn sẽ được cập nhật trong phiên bản tiếp theo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF5E81AC),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chính sách bảo mật',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Chính sách bảo mật sẽ được cập nhật trong phiên bản tiếp theo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF5E81AC),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Đăng xuất',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.signOut();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã đăng xuất thành công',
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: const Color(0xFFA3BE8C),
                    ),
                  );
                }
              },
              child: Text(
                'Đăng xuất',
                style: const TextStyle(fontFamily: 'Inter', color: Colors.red),
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
}
