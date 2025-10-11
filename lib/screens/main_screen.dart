import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_role_model.dart';
import 'simple_home_screen.dart';
import 'products_screen.dart';
import 'categories_screen.dart';
import 'environmental_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'user_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole;

    final screens = [
      const SimpleHomeScreen(),
      const ProductsScreen(),
      const CategoriesScreen(),
      const EnvironmentalScreen(),
      const ReportsScreen(),
    ];

    // Thêm màn hình quản lý user cho admin
    if (userRole == UserRoleModel.admin) {
      screens.add(const UserManagementScreen());
    }

    screens.add(const SettingsScreen());
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF5E81AC),
              unselectedItemColor: const Color(0xFF88C0D0),
              selectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: _buildNavigationItems(authProvider.userRole),
            ),
          ),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(UserRoleModel userRole) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Trang chủ',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2),
        label: 'Sản phẩm',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: 'Danh mục',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Môi trường'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics),
        label: 'Báo cáo',
      ),
    ];

    // Thêm menu quản lý user cho admin
    if (userRole == UserRoleModel.admin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Người dùng',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Cài đặt',
      ),
    );

    return items;
  }
}
