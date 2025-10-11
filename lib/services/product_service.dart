import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _supabase.from('products').select();
      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy products: $e');
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Sản phẩm không tồn tại');
      }
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm: $e');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm sản phẩm: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
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
