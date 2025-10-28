import 'package:enviro_agri_manager/models/user_role_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      if (userRole != UserRoleModel.viewer) const CategoriesScreen(),
      const EnvironmentalScreen(),
      const ReportsScreen(),
      if (userRole == UserRoleModel.admin) const UserManagementScreen(),
      const SettingsScreen(),
    ];

    return screens;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: const Color(0xFF5E81AC),
              unselectedItemColor: const Color(0xFF88C0D0),
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
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
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        label: _currentIndex == 0 ? 'Trang chủ' : '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2),
        label: _currentIndex == 1 ? 'Sản phẩm' : '',
      ),
      if (userRole != UserRoleModel.viewer)
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: _currentIndex == 2 ? 'Danh mục' : '',
        ),

      BottomNavigationBarItem(
        icon: Icon(Icons.eco),
        label: _currentIndex == 3 ? 'Môi trường' : '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics),
        label: _currentIndex == 4 ? 'Báo cáo' : '',
      ),

      if (userRole == UserRoleModel.admin)
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: _currentIndex == 5 ? 'Người dùng' : '',
        ),

      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: _currentIndex == 6 ? 'Cài đặt' : '',
      ),
    ];

    return items;
  }
}
