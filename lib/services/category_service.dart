import 'package:enviro_agri_manager/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return (response as List).map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy categories: $e');
    }
  }

  Future<Category> getCategory(String id) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Danh mục không tồn tại');
      }
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _supabase.from('categories').insert(category.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm danh mục: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
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
}
