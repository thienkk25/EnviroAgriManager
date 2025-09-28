import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Khởi tạo dữ liệu mẫu
  void initializeSampleData() {
    _categories = [
      Category(
        id: '1',
        name: 'Cây lương thực',
        description: 'Các loại cây trồng chính như lúa, ngô, khoai tây',
        icon: '🌾',
        color: '#FFC107',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Lúa', 'Ngô', 'Khoai tây', 'Sắn'],
      ),
      Category(
        id: '2',
        name: 'Rau củ',
        description: 'Các loại rau xanh và củ quả',
        icon: '🥬',
        color: '#4CAF50',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Rau xanh', 'Củ quả', 'Đậu', 'Cà chua'],
      ),
      Category(
        id: '3',
        name: 'Trái cây',
        description: 'Các loại trái cây tươi',
        icon: '🍎',
        color: '#FF5722',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Trái cây nhiệt đới', 'Trái cây ôn đới', 'Quả hạch'],
      ),
      Category(
        id: '4',
        name: 'Cây công nghiệp',
        description: 'Các loại cây trồng phục vụ công nghiệp',
        icon: '🌳',
        color: '#795548',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Cà phê', 'Cao su', 'Điều', 'Tiêu'],
      ),
      Category(
        id: '5',
        name: 'Thủy sản',
        description: 'Các sản phẩm từ thủy sản',
        icon: '🐟',
        color: '#2196F3',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Cá nước ngọt', 'Cá nước mặn', 'Tôm', 'Cua'],
      ),
      Category(
        id: '6',
        name: 'Chăn nuôi',
        description: 'Các sản phẩm từ chăn nuôi',
        icon: '🐄',
        color: '#9C27B0',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        isActive: true,
        subCategories: ['Gia súc', 'Gia cầm', 'Sữa', 'Trứng'],
      ),
    ];
    notifyListeners();
  }

  // Lấy danh sách danh mục
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (_categories.isEmpty) {
        initializeSampleData();
      }
    } catch (e) {
      _error = 'Lỗi khi tải danh sách danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm danh mục mới
  Future<void> addCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
      _categories.add(category);
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi thêm danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
      }
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi cập nhật danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));
      
      _categories.removeWhere((category) => category.id == categoryId);
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi xóa danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh mục theo ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy danh mục chính (không có parent)
  List<Category> getMainCategories() {
    return _categories.where((category) => category.parentId.isEmpty).toList();
  }

  // Lấy danh mục con
  List<Category> getSubCategories(String parentId) {
    return _categories.where((category) => category.parentId == parentId).toList();
  }

  // Tìm kiếm danh mục
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
             category.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
