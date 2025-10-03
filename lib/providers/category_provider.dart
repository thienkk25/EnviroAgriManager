import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Khởi tạo dữ liệu mẫu
  void initializeSampleData() {
    _categories = [];
    notifyListeners();
  }

  // Lấy danh sách danh mục
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await _categoryService.fetchCategories();
      _categories = data;
      // if (_categories.isEmpty) {
      //   initializeSampleData();
      // }
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
    return _categories
        .where((category) => category.parentId == parentId)
        .toList();
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
