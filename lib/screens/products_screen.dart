import 'package:enviro_agri_manager/models/product.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_based_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quản lý Sản phẩm',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          RoleBasedActionButton(
            permission: 'edit',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductFormScreen(mode: ProductFormMode.add),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: const Color(0xFF5E81AC),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF5E81AC),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    final data = categoryProvider.categories;
                    final categories = [
                      {'id': 'Tất cả', 'name': 'Tất cả'},
                      ...data.map((e) => {'id': e.id, 'name': e.name}),
                    ];

                    return SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              category['id'] == _selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category['name']!),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category['id']!;
                                });
                              },
                              selectedColor: Colors.white,
                              checkmarkColor: const Color(0xFF5E81AC),
                              labelStyle: GoogleFonts.inter(
                                color: isSelected
                                    ? const Color(0xFF5E81AC)
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.error.isNotEmpty) {
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
                          productProvider.error,
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productProvider.fetchProducts(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter products
                List<Product> filteredProducts = productProvider.products;

                // Search filter
                if (_searchController.text.isNotEmpty) {
                  filteredProducts = productProvider.searchProducts(
                    _searchController.text,
                  );
                }

                // Category filter
                if (_selectedCategory != 'Tất cả') {
                  filteredProducts = filteredProducts
                      .where(
                        (product) => product.categoryId == _selectedCategory,
                      )
                      .toList();
                }

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy sản phẩm nào',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
                          style: GoogleFonts.inter(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(
                              mode: ProductFormMode.view,
                              product: product,
                            ),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(
                              mode: ProductFormMode.edit,
                              product: product,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteDialog(context, product);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(mode: ProductFormMode.add),
              ),
            );
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Xác nhận xóa',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?',
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
                    .read<ProductProvider>()
                    .deleteProduct(product.id);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Xóa sản phẩm thành công'
                          : 'Có lỗi xảy ra vui lòng thử lại!',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E81AC).withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF5E81AC),
                              size: 32,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E3440),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF88C0D0),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFA3BE8C,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.unit,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA3BE8C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    product.status,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(product.status),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(product.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions Menu
                    Consumer<AuthProvider>(
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
                  ],
                ),

                const SizedBox(height: 16),

                // Price and Quantity Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá bán',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD08770),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tồn kho',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            '${product.quantity} ${product.unit}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5E81AC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cập nhật',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(product.updatedAt),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E3440),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFFA3BE8C);
      case 'inactive':
        return const Color(0xFFD08770);
      case 'discontinued':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Tạm dừng';
      case 'discontinued':
        return 'Ngừng kinh doanh';
      default:
        return 'Không xác định';
    }
  }
}

enum ProductFormMode { add, edit, view }

class ProductFormScreen extends StatefulWidget {
  final ProductFormMode mode;
  final Product? product;

  const ProductFormScreen({super.key, required this.mode, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;

  String _selectedCategory = '';
  String _imageUrl = 'https://via.placeholder.com/150';
  String _selectedStatus = 'active';

  bool get isView => widget.mode == ProductFormMode.view;
  bool get isEdit => widget.mode == ProductFormMode.edit;
  bool get isAdd => widget.mode == ProductFormMode.add;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _quantityController = TextEditingController(
      text: p != null ? p.quantity.toString() : '',
    );
    _unitController = TextEditingController(text: p?.unit ?? '');
    _selectedCategory = p?.categoryId ?? '';
    _selectedStatus = p?.status ?? 'active';
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: const Color(0xFF88C0D0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF88C0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E81AC)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isAdd
              ? 'Thêm Sản phẩm Mới'
              : isEdit
              ? 'Chỉnh sửa Sản phẩm'
              : 'Chi tiết Sản phẩm',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          if (!isView)
            TextButton(
              onPressed: () {
                if (isAdd) {
                  _addProduct(context);
                } else {
                  _updateProduct(context, widget.product!);
                }
              },

              child: Text(
                'Lưu',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Thông tin sản phẩm ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Thông tin sản phẩm'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Tên sản phẩm *'),
                      readOnly: isView,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration('Mô tả sản phẩm *'),
                      readOnly: isView,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập mô tả'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Giá và Số lượng ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Giá và Số lượng'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Giá bán (₫) *'),
                            readOnly: isView,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập giá bán';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Giá bán không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Số lượng *'),
                            readOnly: isView,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập số lượng';
                              }
                              if (int.tryParse(v) == null) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitController,
                      decoration: _inputDecoration('Đơn vị *'),
                      readOnly: isView,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập đơn vị'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Phân loại ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Phân loại'),
                    const SizedBox(height: 16),
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, child) {
                        final categories = categoryProvider.categories;
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategory.isEmpty
                              ? null
                              : _selectedCategory,
                          decoration: _inputDecoration('Chọn danh mục *'),
                          items: categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: isView
                              ? null
                              : (v) =>
                                    setState(() => _selectedCategory = v ?? ''),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Vui lòng chọn danh mục';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: _inputDecoration('Trạng thái sản phẩm'),
                      items: ['active', 'inactive', 'discontinued']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_getStatusText(s)),
                            ),
                          )
                          .toList(),
                      onChanged: isView
                          ? null
                          : (v) =>
                                setState(() => _selectedStatus = v ?? 'active'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Nút lưu ---
              if (!isView)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isAdd) {
                        _addProduct(context);
                      } else {
                        _updateProduct(context, widget.product!);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E81AC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isAdd ? 'Lưu sản phẩm' : 'Cập nhật sản phẩm',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2E3440),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final Product product = Product(
        id: Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: _selectedStatus,
      );

      final result = await context.read<ProductProvider>().addProduct(product);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã thêm sản phẩm thành công'
                : 'Có lỗi xảy ra khi thêm sản phẩm',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProduct(BuildContext context, Product oldProduct) async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = oldProduct.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        updatedAt: DateTime.now(), // chỉ cập nhật thời gian sửa
        status: _selectedStatus,
      );

      final result = await context.read<ProductProvider>().updateProduct(
        updatedProduct,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã cập nhật sản phẩm thành công'
                : 'Có lỗi xảy ra vui lòng thử lại!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Tạm dừng';
      case 'discontinued':
        return 'Ngừng kinh doanh';
      default:
        return 'Không xác định';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
