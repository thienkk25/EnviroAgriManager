import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Khởi tạo dữ liệu mẫu
  void initializeSampleData() {
    _products = [];
    notifyListeners();
  }

  // Lấy danh sách sản phẩm
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await _productService.fetchProducts();
      _products = data;
      // if (_products.isEmpty) {
      //   initializeSampleData();
      // }
    } catch (e) {
      _error = 'Lỗi khi tải danh sách sản phẩm: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm sản phẩm mới
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.addProduct(product);
      _products.add(product);
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi thêm sản phẩm: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi cập nhật sản phẩm: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi xóa sản phẩm: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm sản phẩm
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.categoryId.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Lọc sản phẩm theo danh mục
  List<Product> getProductsByCategory(String categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  // Lấy sản phẩm theo ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Thống kê tổng quan
  Map<String, dynamic> getStatistics() {
    final totalProducts = _products.length;
    final activeProducts = _products.where((p) => p.status == 'active').length;
    final totalValue = _products.fold(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );

    // Thống kê theo danh mục
    final categoryStats = <String, int>{};
    for (final product in _products) {
      categoryStats[product.categoryId] =
          (categoryStats[product.categoryId] ?? 0) + 1;
    }

    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'totalValue': totalValue,
    };
  }
}
