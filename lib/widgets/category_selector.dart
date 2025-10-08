import 'package:enviro_agri_manager/models/category.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorySelector extends StatefulWidget {
  final bool isView;
  final bool isAdd;
  final String? selectedCategoryId;
  final Function(String value) onChanged;

  const CategorySelector({
    super.key,
    required this.isView,
    required this.isAdd,
    this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> selectedIds = [];

  @override
  void initState() {
    super.initState();
    final categoryProvider = context.read<CategoryProvider>();

    if (!widget.isAdd && widget.selectedCategoryId != null) {
      selectedIds = categoryProvider.getCategoryIds(widget.selectedCategoryId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final mainCategories = categoryProvider.getMainCategories();

        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: _buildRecursiveDropdowns(
            categoryProvider,
            mainCategories,
            0,
          ),
        );
      },
    );
  }

  List<Widget> _buildRecursiveDropdowns(
    CategoryProvider provider,
    List<Category> categories,
    int level,
  ) {
    if (categories.isEmpty) return [];
    if (widget.isView && selectedIds.length == level) {
      return [];
    }

    final selectedId = selectedIds.length > level ? selectedIds[level] : '';

    final dropdown = DropdownButtonFormField<String>(
      initialValue: selectedId.isEmpty ? null : selectedId,
      decoration: InputDecoration(
        labelText: 'Danh mục cấp ${level + 1} *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: [
        ?level > 0
            ? DropdownMenuItem(value: null, child: Text('Không chọn'))
            : null,
        ...categories.map(
          (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
        ),
      ],
      onChanged: widget.isView
          ? null
          : (value) {
              setState(() {
                // Cập nhật giá trị ở cấp hiện tại
                if (selectedIds.length > level) {
                  selectedIds[level] = value ?? '';
                  // Xóa các cấp sau nếu có
                  selectedIds = selectedIds.sublist(0, level + 1);
                } else {
                  selectedIds.add(value ?? '');
                }
                if (selectedIds.last == '' && level > 0) {
                  widget.onChanged(selectedIds[level - 1]);
                } else {
                  widget.onChanged(selectedIds.last);
                }
              });
            },

      validator: (v) {
        if (!(level == 0)) return null;
        return (v == null || v.isEmpty)
            ? 'Vui lòng chọn danh mục cấp ${level + 1}'
            : null;
      },
    );

    // Nếu có danh mục con, thêm dropdown tiếp theo
    final nextLevel = selectedId.isEmpty
        ? <Widget>[]
        : _buildRecursiveDropdowns(
            provider,
            provider.getSubCategories(selectedId),
            level + 1,
          );

    return [dropdown, ...nextLevel];
  }
}
