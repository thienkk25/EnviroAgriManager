import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryProvider with ChangeNotifier {
  CategoryRepository? _categoryRepository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  CategoryProvider(this._categoryRepository);
  void update(CategoryRepository repo) {
    _categoryRepository = repo;
    notifyListeners();
  }

  // Lấy danh sách danh mục
  Future<void> fetchCategories(BuildContext context) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      _categories = await _categoryRepository!.syncCategories(
        isOnline: isOnline,
      );
    } catch (e) {
      _error = 'Lỗi khi tải danh sách danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Làm mới danh sách danh mục
  Future<void> refreshCategories(BuildContext context) async {
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      _categories = await _categoryRepository!.syncCategories(
        isOnline: isOnline,
      );

      _error = '';
    } catch (e) {
      _error = 'Lỗi khi tải danh sách danh mục: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // Thêm danh mục mới
  Future<bool> addCategory(BuildContext context, CategoryModel category) async {
    _isLoading = true;
    notifyListeners();

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _categoryRepository!.add(category, isOnline: isOnline);
      _categories.add(category);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm danh mục: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật danh mục
  Future<bool> updateCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    _isLoading = true;
    notifyListeners();

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _categoryRepository!.update(category, isOnline: isOnline);

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
      }
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật danh mục: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa danh mục
  Future<bool> deleteCategory(BuildContext context, String id) async {
    _isLoading = true;
    notifyListeners();

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _categoryRepository!.delete(id, isOnline: isOnline);

      _categories.removeWhere((category) => category.id == id);
      _error = '';
      return true;
    } catch (e) {
      if (e.toString().contains('Không thể xóa')) {
        _error = 'Danh mục này có sản phẩm liên quan, không thể xóa!';
      } else {
        _error = 'Lỗi khi xóa danh mục: ${e.toString()}';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh mục chính (không có parent)
  List<CategoryModel> getMainCategories() {
    return _categories.where((category) => category.parentId == null).toList();
  }

  // Lấy danh mục con
  List<CategoryModel> getSubCategories(String parentId) {
    return _categories
        .where((category) => category.parentId == parentId)
        .toList();
  }

  // Lấy name của danh mục theo id
  String getCategoryName(String categoryId) {
    return _categories.firstWhere((category) => category.id == categoryId).name;
  }

  // Tìm kiếm danh mục
  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<String> getCategoryIds(String categoryId) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    if (category.parentId == null) {
      // Đây là danh mục gốc
      return [category.id];
    } else {
      // Gọi đệ quy lên trên và thêm id hiện tại
      return [...getCategoryIds(category.parentId!), category.id];
    }
  }
}
