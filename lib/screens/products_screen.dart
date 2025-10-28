import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/widgets/product_card.dart';
import 'package:enviro_agri_manager/widgets/product_form_screen.dart';
import 'package:enviro_agri_manager/widgets/review_products_page.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ProductFormMode { add, edit, view }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  final ScrollController _scrollController = ScrollController();
  double _dragStart = 0.0;
  double _scrollStart = 0.0;
  bool _isRefreshing = false;
  late AnimationController _rotationController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(
        context.read<ConnectivityProvider>().isOnline,
      );
      context.read<CategoryProvider>().fetchCategories(
        context.read<ConnectivityProvider>().isOnline,
      );
    });
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts(BuildContext context) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _rotationController.forward(from: 0);
    await context.read<ProductProvider>().refreshProducts(
      context.read<ConnectivityProvider>().isOnline,
    );
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quản lý Sản phẩm',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          RoleBasedMenuItem(
            permission: 'edit',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade900,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.pending_actions_rounded, size: 18),
                label: const Text(
                  'Chờ duyệt',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewProductsPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Làm mới',
            icon: RotationTransition(
              turns: _rotationController,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            onPressed: _isRefreshing ? null : () => _refreshProducts(context),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
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
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey[500],
                        ),
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
                      final categories = [
                        {'id': 'Tất cả', 'name': 'Tất cả'},
                        ...categoryProvider.getMainCategories().map(
                          (e) => {'id': e.id, 'name': e.name},
                        ),
                      ];

                      return Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent) {
                            _scrollController.jumpTo(
                              _scrollController.offset + event.scrollDelta.dy,
                            );
                          }
                        },
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            _dragStart = details.globalPosition.dx;
                            _scrollStart = _scrollController.offset;
                          },
                          onHorizontalDragUpdate: (details) {
                            final delta =
                                _dragStart - details.globalPosition.dx;
                            _scrollController.jumpTo(_scrollStart + delta);
                          },
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              controller: _scrollController,
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
                                    labelStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      color: isSelected
                                          ? const Color(0xFF5E81AC)
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: Consumer2<ProductProvider, CategoryProvider>(
                builder: (context, productProvider, categoryProvider, child) {
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
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => productProvider.fetchProducts(
                              context.read<ConnectivityProvider>().isOnline,
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter products
                  List<ProductModel> filteredProducts =
                      productProvider.products;

                  // Search filter
                  if (_searchController.text.isNotEmpty) {
                    filteredProducts = productProvider.searchProducts(
                      _searchController.text,
                    );
                  }

                  // Category filter
                  if (_selectedCategory != 'Tất cả') {
                    final categoriesIds = categoryProvider.getCategoryIdsDown(
                      _selectedCategory,
                    );
                    filteredProducts = filteredProducts
                        .where(
                          (product) =>
                              categoriesIds.contains(product.categoryId),
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
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => productProvider.refreshProducts(
                      context.read<ConnectivityProvider>().isOnline,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          key: Key(product.id),
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductFormScreen(
                                  mode: ProductFormMode.view,
                                  product: product,
                                  isEditProductReview: false,
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
                                  isEditProductReview: false,
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            _showDeleteDialog(context, product);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          heroTag: 'fab_product',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(
                  mode: ProductFormMode.add,
                  isEditProductReview: false,
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Xác nhận xóa',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
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
                final result = await context
                    .read<ProductProvider>()
                    .deleteProduct(
                      context.read<ConnectivityProvider>().isOnline,
                      product.id,
                    );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Xóa sản phẩm thành công'
                          : 'Có lỗi xảy ra vui lòng thử lại!',
                      style: const TextStyle(fontFamily: 'Inter'),
                    ),
                    backgroundColor: result
                        ? const Color(0xFFA3BE8C)
                        : Colors.red,
                  ),
                );
              },
              child: Text(
                'Xóa',
                style: const TextStyle(fontFamily: 'Inter', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
