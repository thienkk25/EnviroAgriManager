import 'package:enviro_agri_manager/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _supabase.from('products').select();
      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy products: $e');
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Sản phẩm không tồn tại');
      }
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm sản phẩm: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật sản phẩm: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Lỗi xóa sản phẩm: $e');
    }
  }
}
