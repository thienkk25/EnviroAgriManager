import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy categories: $e');
    }
  }

  Future<CategoryModel> getCategory(String id) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Danh mục không tồn tại');
      }
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _supabase.from('categories').insert(category.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm danh mục: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _supabase
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật danh mục: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Lỗi xóa danh mục: $e');
    }
  }

  Future<void> uploadCategories(List<CategoryModel> categories) async {
    try {
      final data = categories.map((c) => c.toJson()).toList();
      await _supabase.from('categories').upsert(data);
    } catch (e) {
      throw Exception('Lỗi upload categories: $e');
    }
  }
}
