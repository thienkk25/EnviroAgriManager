import 'dart:typed_data';

import 'package:enviro_agri_manager/local/prefs/app_preferences.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/product_review_model.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/repositories/product_review_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProductReviewProvider with ChangeNotifier {
  ProductReviewRepository _productReviewRepository;
  ProductRepository _productRepository;
  late SharedPreferences _prefs;
  late AppPreferences _appPrefs;

  ProductReviewProvider(
    this._productReviewRepository,
    this._productRepository,
  ) {
    init();
  }
  void update(
    ProductReviewRepository productReviewRepository,
    ProductRepository productRepository,
  ) {
    _productReviewRepository = productReviewRepository;
    _productRepository = productRepository;
    notifyListeners();
  }

  List<ProductReviewModel> _productReviews = [];
  bool _isLoading = false;
  String _error = '';

  List<ProductReviewModel> get productReviews => _productReviews;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _appPrefs = AppPreferences(_prefs);
  }

  Future<void> fetchProductReviews() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _productReviews = await _productReviewRepository.fetchProductReviews();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProductReview(
    ProductModel product,
    Uint8List? image,
    String note,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = product.copyWith(
        imageUrl: image == null
            ? product.imageUrl
            : await _productRepository.uploadImageFileProducts(image),
      );

      final productReviewModel = ProductReviewModel(
        id: Uuid().v4(),
        productId: data.id.isNotEmpty ? data.id : null,
        editedBy: _appPrefs.getCachedUser()['id'],
        changes: data.toJson(),
        note: note,
        createdAt: DateTime.now(),
      );

      await _productReviewRepository.addProductReview(productReviewModel);
      _productReviews.add(productReviewModel);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProductReview(
    bool isOnline,
    ProductModel product,
    Uint8List? image,
    String note,
    ProductReviewModel productReviewModel,
  ) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final dataProduct = product.copyWith(
        imageUrl: image == null
            ? product.imageUrl
            : await _productRepository.uploadImageFileProducts(image),
      );

      final dataProductReview = productReviewModel.copyWith(
        productId: dataProduct.id.isNotEmpty ? dataProduct.id : null,
        changes: dataProduct.toJson(),
        note: note,
      );

      await _productReviewRepository.updateProductReview(dataProductReview);

      final index = _productReviews.indexWhere(
        (p) => p.id == dataProductReview.id,
      );
      if (index != -1) {
        _productReviews[index] = dataProductReview;
      }
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProductReview(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _productReviewRepository.deleteProductReview(id);
      _productReviews.removeWhere((element) => element.id == id);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveOrRejectProductReview(
    String reviewId,
    String action,
  ) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _productReviewRepository.approveOrRejectProductReview(
        reviewId,
        action,
      );

      final index = _productReviews.indexWhere((p) => p.id == reviewId);
      if (index != -1) {
        _productReviews[index] = _productReviews[index].copyWith(
          status: action,
        );
      }

      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductReviewModel> pendingProductReviews() {
    return _productReviews
        .where((element) => element.status == 'pending')
        .toList();
  }

  List<ProductReviewModel> rejectedProductReviews() {
    return _productReviews
        .where((element) => element.status == 'rejected')
        .toList();
  }

  List<ProductReviewModel> approvedProductReviews() {
    return _productReviews
        .where((element) => element.status == 'approved')
        .toList();
  }
}
