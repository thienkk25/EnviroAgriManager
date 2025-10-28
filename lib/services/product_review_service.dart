import 'package:enviro_agri_manager/models/product_review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductReviewModel>> fetchProductReviews() async {
    try {
      final response = await _supabase.from('product_reviews').select();
      return (response as List)
          .map((item) => ProductReviewModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProductReview(ProductReviewModel productReviewModel) async {
    try {
      await _supabase
          .from('product_reviews')
          .insert(productReviewModel.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductReview(
    ProductReviewModel productReviewModel,
  ) async {
    try {
      await _supabase
          .from('product_reviews')
          .update(productReviewModel.toJson())
          .eq('id', productReviewModel.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProductReview(String id) async {
    try {
      await _supabase.from('product_reviews').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveOrRejectProductReview(
    String reviewId,
    String action,
  ) async {
    try {
      await _supabase.rpc(
        'approve_or_reject_review',
        params: {'p_review_id': reviewId, 'p_action': action},
      );
    } catch (e) {
      rethrow;
    }
  }
}
