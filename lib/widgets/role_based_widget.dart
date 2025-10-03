import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_role.dart';

class RoleBasedWidget extends StatelessWidget {
  final Widget adminChild;
  final Widget? editorChild;
  final Widget? viewerChild;
  final Widget? fallbackChild;
  final String? permission;

  const RoleBasedWidget({
    super.key,
    required this.adminChild,
    this.editorChild,
    this.viewerChild,
    this.fallbackChild,
    this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        // Nếu có permission được chỉ định, kiểm tra quyền
        if (permission != null && !authProvider.hasPermission(permission!)) {
          return fallbackChild ?? const SizedBox.shrink();
        }

        // Hiển thị widget theo role
        switch (userRole) {
          case UserRole.admin:
            return adminChild;
          case UserRole.editor:
            return editorChild ?? adminChild;
          case UserRole.viewer:
            return viewerChild ?? editorChild ?? adminChild;
        }
      },
    );
  }
}

// Widget cho các nút hành động theo role
class RoleBasedActionButton extends StatelessWidget {
  final String permission;
  final Widget child;
  final VoidCallback? onPressed;
  final Widget? fallbackChild;

  const RoleBasedActionButton({
    super.key,
    required this.permission,
    required this.child,
    this.onPressed,
    this.fallbackChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.hasPermission(permission)) {
          return fallbackChild ?? const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}

// Widget cho menu items theo role
class RoleBasedMenuItem extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallbackChild;

  const RoleBasedMenuItem({
    super.key,
    required this.permission,
    required this.child,
    this.fallbackChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.hasPermission(permission)) {
          return fallbackChild ?? const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}

// Widget hiển thị thông báo không có quyền
class NoPermissionWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const NoPermissionWidget({
    super.key,
    this.message = 'Bạn không có quyền truy cập tính năng này',
    this.icon = Icons.lock,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng liên hệ quản trị viên để được cấp quyền',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
