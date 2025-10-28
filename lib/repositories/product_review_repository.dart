import 'package:enviro_agri_manager/models/product_review_model.dart';
import 'package:enviro_agri_manager/services/product_review_service.dart';

class ProductReviewRepository {
  final ProductReviewService _productReviewService;

  ProductReviewRepository(this._productReviewService);

  Future<List<ProductReviewModel>> fetchProductReviews() async {
    try {
      final response = await _productReviewService.fetchProductReviews();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProductReview(ProductReviewModel productReviewModel) async {
    try {
      await _productReviewService.addProductReview(productReviewModel);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductReview(
    ProductReviewModel productReviewModel,
  ) async {
    try {
      await _productReviewService.updateProductReview(productReviewModel);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProductReview(String id) async {
    try {
      await _productReviewService.deleteProductReview(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveOrRejectProductReview(
    String reviewId,
    String action,
  ) async {
    try {
      if (action != 'approve' && action != 'reject') {
        throw Exception('Invalid action');
      }
      await _productReviewService.approveOrRejectProductReview(
        reviewId,
        action,
      );
    } catch (e) {
      rethrow;
    }
  }
}
