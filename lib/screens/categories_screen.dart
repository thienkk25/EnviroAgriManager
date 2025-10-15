import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/config/app_constants.dart';
import 'package:enviro_agri_manager/widgets/category_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum CategoryDialogMode { add, edit, view }

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(startFirst: true);
  }
}

class CategoryScreen extends StatelessWidget {
  final String? parentId;
  final String? title;
  final bool startFirst;

  const CategoryScreen({
    super.key,
    this.parentId,
    this.title,
    required this.startFirst,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    List<CategoryModel> subCategories;
    if (startFirst) {
      subCategories = categoryProvider.getMainCategories();
    } else {
      subCategories = categoryProvider.getSubCategories(parentId!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          title ?? 'Quản lý Danh mục',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<CategoryProvider>().refreshCategories(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<CategoryProvider>().refreshCategories(context),
        child: subCategories.isEmpty
            ? const Center(child: Text('Không có danh mục'))
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (categoryProvider.error.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              categoryProvider.error,
                              style: GoogleFonts.inter(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  categoryProvider.fetchCategories(context),
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth < 600
                                    ? 2
                                    : 4,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: constraints.maxWidth < 600
                                    ? .7
                                    : 1.1,
                              ),
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final category = subCategories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () {
                                // Đệ quy gọi lại chính CategoryScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryScreen(
                                      parentId: category.id,
                                      title: category.name,
                                      startFirst: false,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                _showCategoryDialog(
                                  context,
                                  mode: CategoryDialogMode.view,
                                  category: category,
                                );
                              },
                              onEdit: () {
                                _showCategoryDialog(
                                  context,
                                  mode: CategoryDialogMode.edit,
                                  category: category,
                                );
                              },
                              onDelete: () {
                                _showDeleteDialog(context, category);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          heroTag: 'fab_category',
          onPressed: () {
            _showCategoryDialog(context, mode: CategoryDialogMode.add);
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context, {
    required CategoryDialogMode mode,
    CategoryModel? category, // null nếu thêm mới
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    String selectedIcon = category?.icon ?? '🌱';
    String selectedColor = category?.color ?? '#4CAF50';

    final isView = mode == CategoryDialogMode.view;
    bool selectedIsActive = category?.isActive ?? true;
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
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      const SizedBox(),
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
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập tên danh mục'
                            : null,
                      ),
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
                      Text(
                        'Chọn icon:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryIcons.map((icon) {
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
                                    ? const Color(
                                        0xFF5E81AC,
                                      ).withValues(alpha: .1)
                                    : Colors.grey.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(8),
                                border: selectedIcon == icon
                                    ? Border.all(
                                        color: const Color(0xFF5E81AC),
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
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
                      Text(
                        'Chọn màu:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryColors.map((color) {
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
                                        width: 5,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      DropdownButtonFormField<bool>(
                        initialValue: selectedIsActive,
                        decoration: InputDecoration(
                          labelText: 'Trạng thái danh mục',
                          labelStyle: GoogleFonts.inter(
                            color: const Color(0xFF88C0D0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              "Hoạt động",
                              style: GoogleFonts.inter(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text("Tạm dừng", style: GoogleFonts.inter()),
                          ),
                        ],
                        onChanged: isView
                            ? null
                            : (v) =>
                                  setState(() => selectedIsActive = v ?? true),
                      ),
                      const SizedBox(),
                    ],
                  ),
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
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (mode == CategoryDialogMode.add) {
                          final CategoryModel newCategory = CategoryModel(
                            id: Uuid().v4(),
                            name: nameController.text,
                            description: descriptionController.text,
                            icon: selectedIcon,
                            color: selectedColor,
                            isActive: selectedIsActive,
                            parentId: startFirst ? null : parentId,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          final result = await context
                              .read<CategoryProvider>()
                              .addCategory(context, newCategory);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result
                                    ? 'Đã thêm danh mục thành công'
                                    : 'Có lỗi vui lòng thử lại!',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: result
                                  ? const Color(0xFFA3BE8C)
                                  : Colors.red,
                            ),
                          );
                        } else {
                          final CategoryModel updateCategory = category!
                              .copyWith(
                                name: nameController.text,
                                description: descriptionController.text,
                                icon: selectedIcon,
                                color: selectedColor,
                                isActive: selectedIsActive,
                                updatedAt: DateTime.now(),
                              );
                          final result = await context
                              .read<CategoryProvider>()
                              .updateCategory(context, updateCategory);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result
                                    ? 'Đã cập danh mục thành công'
                                    : 'Có lỗi vui lòng thử lại!',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: result
                                  ? const Color(0xFFA3BE8C)
                                  : Colors.red,
                            ),
                          );
                        }
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

  void _showDeleteDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Xác nhận xóa',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa danh mục "${category.name}"? Tất cả danh mục con sẽ bị xóa (Nếu có).',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                final result = await context
                    .read<CategoryProvider>()
                    .deleteCategory(context, category.id);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Đã xóa danh mục "${category.name}" thành công'
                          : 'Có lỗi vui lòng thử lại!',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: result
                        ? const Color(0xFFA3BE8C)
                        : Colors.red,
                  ),
                );
              },
              child: Text('Xóa', style: GoogleFonts.inter(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
