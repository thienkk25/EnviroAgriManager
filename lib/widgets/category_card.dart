import 'package:enviro_agri_manager/models/category.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(category.color.replaceFirst('#', '0xFF')),
                          ).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E3440),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.read<CategoryProvider>().getSubCategories(category.id.toString()).length} loại',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88C0D0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? const Color(0xFFA3BE8C).withValues(alpha: .1)
                              : const Color(0xFFD08770).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.isActive ? 'Hoạt động' : 'Tạm dừng',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: category.isActive
                                ? const Color(0xFFA3BE8C)
                                : const Color(0xFFD08770),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: MediaQuery.sizeOf(context).width < 600 ? -10 : 0,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final canEdit = authProvider.hasPermission('edit');
                      final canDelete = authProvider.hasPermission('delete');

                      if (!canEdit && !canDelete) {
                        return const SizedBox.shrink();
                      }

                      return PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          final items = <PopupMenuItem<String>>[];

                          if (canEdit) {
                            items.add(
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Color(0xFF5E81AC),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chỉnh sửa',
                                      style: GoogleFonts.inter(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (canDelete) {
                            items.add(
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Xóa',
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return items;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
