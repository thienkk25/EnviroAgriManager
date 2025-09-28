import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Khởi tạo dữ liệu mẫu
  void initializeSampleData() {
    _products = [
      Product(
        id: '1',
        name: 'Lúa Jasmine',
        description: 'Giống lúa thơm chất lượng cao',
        category: 'Cây lương thực',
        price: 25000,
        quantity: 1000,
        unit: 'kg',
        imageUrl: 'https://via.placeholder.com/150',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        status: 'active',
        environmentalData: {
          'temperature': 28.5,
          'humidity': 75.0,
          'ph': 6.5,
        },
      ),
      Product(
        id: '2',
        name: 'Cà chua Cherry',
        description: 'Cà chua bi ngọt, giòn',
        category: 'Rau củ',
        price: 45000,
        quantity: 500,
        unit: 'kg',
        imageUrl: 'https://via.placeholder.com/150',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        status: 'active',
        environmentalData: {
          'temperature': 25.0,
          'humidity': 70.0,
          'ph': 6.0,
        },
      ),
      Product(
        id: '3',
        name: 'Dưa hấu',
        description: 'Dưa hấu ngọt, mọng nước',
        category: 'Trái cây',
        price: 35000,
        quantity: 200,
        unit: 'quả',
        imageUrl: 'https://via.placeholder.com/150',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
        status: 'active',
        environmentalData: {
          'temperature': 30.0,
          'humidity': 65.0,
          'ph': 6.8,
        },
      ),
    ];
    notifyListeners();
  }

  // Lấy danh sách sản phẩm
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      // Trong thực tế, đây sẽ là API call
      // final response = await http.get(Uri.parse('your-api-url/products'));
      
      if (_products.isEmpty) {
        initializeSampleData();
      }
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
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
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
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
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
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
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
             product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Lọc sản phẩm theo danh mục
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
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
    final totalValue = _products.fold(0.0, (sum, product) => sum + (product.price * product.quantity));
    
    // Thống kê theo danh mục
    final categoryStats = <String, int>{};
    for (final product in _products) {
      categoryStats[product.category] = (categoryStats[product.category] ?? 0) + 1;
    }

    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'totalValue': totalValue,
      'categoryStats': categoryStats,
    };
  }
}
