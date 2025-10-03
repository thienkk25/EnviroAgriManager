import 'package:enviro_agri_manager/models/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/category_provider.dart';

enum CategoryDialogMode { add, edit, view }

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quản lý Danh mục',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCategoryDialog(
                context,
                mode: CategoryDialogMode.add,
                onSave: (category) {
                  // gọi provider/service để thêm
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    categoryProvider.error,
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => categoryProvider.fetchCategories(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final categories = categoryProvider.getMainCategories();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có danh mục nào',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm danh mục đầu tiên để bắt đầu',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(category: category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCategoryDialog(
            context,
            mode: CategoryDialogMode.add,
            onSave: (category) {
              // gọi provider/service để thêm
            },
          );
        },
        backgroundColor: const Color(0xFF5E81AC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void _showCategoryDialog(
  BuildContext context, {
  required CategoryDialogMode mode,
  Category? category, // null nếu thêm mới
  required Function(Category) onSave,
}) {
  final nameController = TextEditingController(text: category?.name ?? '');
  final descriptionController = TextEditingController(
    text: category?.description ?? '',
  );
  String selectedIcon = category?.icon ?? '🌱';
  String selectedColor = category?.color ?? '#4CAF50';

  final icons = ['🌱', '🌾', '🥬', '🍎', '🌳', '🐟', '🐄', '🌿', '🌽', '🥕'];
  final colors = [
    '#4CAF50',
    '#FF9800',
    '#2196F3',
    '#9C27B0',
    '#795548',
    '#607D8B',
    '#E91E63',
    '#FF5722',
    '#00BCD4',
    '#8BC34A',
  ];

  final isView = mode == CategoryDialogMode.view;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              mode == CategoryDialogMode.add
                  ? 'Thêm danh mục mới'
                  : mode == CategoryDialogMode.edit
                  ? 'Chỉnh sửa danh mục'
                  : 'Chi tiết danh mục',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    enabled: !isView,
                    decoration: InputDecoration(
                      labelText: 'Tên danh mục',
                      labelStyle: GoogleFonts.inter(
                        color: const Color(0xFF88C0D0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    enabled: !isView,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      labelStyle: GoogleFonts.inter(
                        color: const Color(0xFF88C0D0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn icon:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((icon) {
                      return GestureDetector(
                        onTap: isView
                            ? null
                            : () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedIcon == icon
                                ? const Color(0xFF5E81AC).withValues(alpha: .1)
                                : Colors.grey.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(8),
                            border: selectedIcon == icon
                                ? Border.all(
                                    color: const Color(0xFF5E81AC),
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  )
                                : null,
                          ),
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn màu:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: isView
                            ? null
                            : () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: selectedColor == color
                                ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Đóng',
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
              ),
              if (!isView)
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final Category newCategory = Category(
                        id: Uuid().v4(),
                        name: nameController.text,
                        description: descriptionController.text,
                        icon: selectedIcon,
                        color: selectedColor,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      // onSave(newCategory);
                      context.read<CategoryProvider>().addCategory(newCategory);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            mode == CategoryDialogMode.add
                                ? 'Đã thêm danh mục thành công'
                                : 'Đã cập nhật danh mục thành công',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: const Color(0xFFA3BE8C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E81AC),
                  ),
                  child: Text(
                    mode == CategoryDialogMode.add ? 'Thêm' : 'Cập nhật',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

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
          onTap: () {
            _showCategoryDialog(
              context,
              mode: CategoryDialogMode.view,
              category: category,
              onSave: (_) {}, // không dùng
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  '${category.subCategories.length} loại',
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
        ),
      ),
    );
  }
}
