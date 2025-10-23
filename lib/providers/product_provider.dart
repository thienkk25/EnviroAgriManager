import 'dart:typed_data';

import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  ProductRepository _productRepository;

  ProductProvider(this._productRepository);
  void update(ProductRepository repo) {
    _productRepository = repo;
    notifyListeners();
  }

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Lấy danh sách sản phẩm
  Future<void> fetchProducts(bool isOnline) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _products = await _productRepository.syncProducts(isOnline: isOnline);
    } catch (e) {
      _error = 'Lỗi khi tải danh sách sản phẩm: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts(bool isOnline) async {
    try {
      _products = await _productRepository.syncProducts(isOnline: isOnline);

      _error = '';
    } catch (e) {
      _error = 'Lỗi khi tải danh sách: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // Thêm sản phẩm mới
  Future<bool> addProduct(
    bool isOnline,
    ProductModel product,
    Uint8List? image,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = product.copyWith(
        imageUrl: image == null
            ? ''
            : await _productRepository.uploadImageFileProducts(image),
      );
      await _productRepository.add(data, isOnline: isOnline);
      _products.add(data);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm sản phẩm: ${e.toString()}';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật sản phẩm
  Future<bool> updateProduct(
    bool isOnline,
    ProductModel product,
    String paths,
    Uint8List? image,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = product.copyWith(
        imageUrl: image == null
            ? product.imageUrl
            : await _productRepository.uploadImageFileProducts(image),
      );
      if (image != null) {
        await _productRepository.deleteImageFileProducts([paths]);
      }
      await _productRepository.update(data, isOnline: isOnline);
      final index = _products.indexWhere((p) => p.id == data.id);
      if (index != -1) {
        _products[index] = data;
      }
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật sản phẩm: ${e.toString()}';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa sản phẩm
  Future<bool> deleteProduct(bool isOnline, String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productRepository.delete(productId, isOnline: isOnline);
      _products.removeWhere((product) => product.id == productId);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa sản phẩm: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm sản phẩm
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.categoryId.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Lấy sản phẩm theo ID
  ProductModel? getProductById(String id) {
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

    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'totalValue': totalValue,
    };
  }

  String formatMonth(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  String formatWeek(DateTime date) {
    // ISO 8601 week number calculation
    // Tuần 1 là tuần có ngày thứ 5 đầu tiên của năm

    // Tìm ngày thứ 5 đầu tiên của năm
    final jan4 = DateTime(date.year, 1, 4);

    // Tìm ngày thứ 2 của tuần chứa ngày 4/1
    final weekStart = jan4.subtract(Duration(days: jan4.weekday - 1));

    // Tính số tuần
    final weekNumber = ((date.difference(weekStart).inDays) / 7).floor() + 1;

    // Xử lý trường hợp tuần cuối năm trước
    if (weekNumber < 1) {
      return formatWeek(DateTime(date.year - 1, 12, 31));
    }

    // Xử lý trường hợp tuần đầu năm sau
    if (weekNumber > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      final lastWeekStart = dec31.subtract(Duration(days: dec31.weekday - 1));
      if (date.isAfter(lastWeekStart.add(Duration(days: 7)))) {
        return '${date.year + 1}-W01';
      }
    }

    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  // Procuct theo category
  Map<String, double> getTrendByCategory(
    List<CategoryModel> categories,
    String type,
  ) {
    final Map<String, double> result = {};

    for (var p in _products.where((p) => p.status == 'active')) {
      String key;
      final categoryName = categories
          .firstWhere((category) => category.id == p.categoryId)
          .name;

      switch (type) {
        case 'week':
          key = '$categoryName (${formatWeek(p.updatedAt)})';
          break;

        case 'month':
          key = '$categoryName (${formatMonth(p.updatedAt)})';
          break;

        case 'quarter':
          final quarter = ((p.updatedAt.month - 1) ~/ 3) + 1;
          key = '$categoryName (Q$quarter-${p.updatedAt.year})';
          break;

        case 'year':
        default:
          key = '$categoryName (${p.updatedAt.year})';
          break;
      }

      result[key] = (result[key] ?? 0) + p.quantity;
    }

    // Sắp xếp theo quantity giảm dần
    final sortedEntries = result.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return {for (var e in sortedEntries) e.key: e.value};
  }

  // Get category distribution data from products
  Map<String, double> getCategoryDistributionData(
    List<CategoryModel> categories,
    String type,
  ) {
    final Map<String, double> categoryMap = {};

    for (var product in _products.where((p) => p.status == 'active')) {
      String key;
      final categoryId = product.categoryId;

      final categoryName = categories
          .firstWhere((category) => category.id == categoryId)
          .name;

      switch (type) {
        case 'week':
          key = '$categoryName (${formatWeek(product.updatedAt)})';
          break;

        case 'month':
          key = '$categoryName (${formatMonth(product.updatedAt)})';
          break;

        case 'quarter':
          final quarter = ((product.updatedAt.month - 1) ~/ 3) + 1;
          key = '$categoryName (Q$quarter-${product.updatedAt.year})';
          break;

        case 'year':
        default:
          key = '$categoryName (${product.updatedAt.year})';
          break;
      }

      // Sum by quantity or by inventory value
      final value = product.quantity.toDouble();
      // Alternative: Use inventory value
      // final value = product.quantity * product.price;

      categoryMap[key] = (categoryMap[key] ?? 0) + value;
    }

    return categoryMap;
  }
}
