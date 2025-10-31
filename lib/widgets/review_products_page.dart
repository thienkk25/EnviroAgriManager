import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_review_provider.dart';
import 'package:enviro_agri_manager/screens/products_screen.dart';
import 'package:enviro_agri_manager/widgets/product_card.dart';
import 'package:enviro_agri_manager/widgets/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewProductsPage extends StatefulWidget {
  const ReviewProductsPage({super.key});

  @override
  State<ReviewProductsPage> createState() => _ReviewProductsPageState();
}

class _ReviewProductsPageState extends State<ReviewProductsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _rotationController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductReviewProvider>().fetchProductReviews();
    });

    _tabController = TabController(length: 3, vsync: this);
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProductReviews(BuildContext context) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _rotationController.forward(from: 0);
    await context.read<ProductReviewProvider>().fetchProductReviews();
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    if (!isOnline) {
      return const Scaffold(
        body: Center(child: Text('Chức năng này cần online')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt sản phẩm'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: RotationTransition(
              turns: _rotationController,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            onPressed: _isRefreshing
                ? null
                : () => _refreshProductReviews(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đang chờ'),
            Tab(text: 'Từ chối'),
            Tab(text: 'Đã phê duyệt'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer<ProductReviewProvider>(
          builder: (context, productReviewProvider, child) {
            if (productReviewProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productReviewProvider.error.isNotEmpty) {
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
                      productReviewProvider.error,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // ElevatedButton(
                    //   onPressed: () => productReviewProvider.fetchProductReviews(
                    //     context.read<ConnectivityProvider>().isOnline,
                    //   ),
                    //   child: const Text('Thử lại'),
                    // ),
                  ],
                ),
              );
            }
            if (productReviewProvider.productReviews.isEmpty) {
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
                      'Chưa có dữ liệu nào',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            final pendingProductReviews = productReviewProvider
                .pendingProductReviews();
            final rejectedProductReviews = productReviewProvider
                .rejectedProductReviews();
            final approvedProductReviews = productReviewProvider
                .approvedProductReviews();

            return TabBarView(
              controller: _tabController,
              children: [
                pendingProductReviews.isEmpty
                    ? Center(child: Text('Không có dữ liệu'))
                    : ListView.builder(
                        itemCount: pendingProductReviews.length,
                        itemBuilder: (_, i) => ProductCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreen(
                                mode: ProductFormMode.view,
                                product: ProductModel.fromJson(
                                  pendingProductReviews[i].changes!,
                                ),
                                productReview: pendingProductReviews[i],
                                isEditProductReview: true,
                              ),
                            ),
                          ),
                          product: ProductModel.fromJson(
                            pendingProductReviews[i].changes!,
                          ),
                          rejected: false,
                          productReview: pendingProductReviews[i],
                        ),
                      ),
                rejectedProductReviews.isEmpty
                    ? Center(child: Text('Không có dữ liệu'))
                    : ListView.builder(
                        itemCount: rejectedProductReviews.length,
                        itemBuilder: (_, i) => ProductCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreen(
                                mode: ProductFormMode.view,
                                product: ProductModel.fromJson(
                                  rejectedProductReviews[i].changes!,
                                ),
                                productReview: rejectedProductReviews[i],
                                isEditProductReview: true,
                              ),
                            ),
                          ),
                          product: ProductModel.fromJson(
                            rejectedProductReviews[i].changes!,
                          ),
                          rejected: true,
                          productReview: rejectedProductReviews[i],
                        ),
                      ),
                approvedProductReviews.isEmpty
                    ? Center(child: Text('Không có dữ liệu'))
                    : ListView.builder(
                        itemCount: approvedProductReviews.length,
                        itemBuilder: (_, i) => ProductCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreen(
                                mode: ProductFormMode.view,
                                product: ProductModel.fromJson(
                                  approvedProductReviews[i].changes!,
                                ),
                                productReview: approvedProductReviews[i],
                                isEditProductReview: true,
                              ),
                            ),
                          ),
                          product: ProductModel.fromJson(
                            approvedProductReviews[i].changes!,
                          ),
                          rejected: true,
                          productReview: approvedProductReviews[i],
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
