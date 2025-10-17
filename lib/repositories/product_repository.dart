import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:flutter/foundation.dart';

class ProductRepository {
  final AppDatabase? _db;
  final ProductService _productService;

  ProductRepository(this._db, this._productService);

  Future<List<ProductModel>> syncProducts({required bool isOnline}) async {
    if (kIsWeb) {
      return await _productService.fetchProducts();
    } else {
      if (isOnline) {
        try {
          final localNewData = await _db!.productDao.getUnsyncedProducts();

          if (localNewData.isNotEmpty) {
            await _productService.uploadProducts(localNewData);

            await _db.productDao.markAsSynced(
              localNewData.map((e) => e.id).toList(),
            );
          }

          final deletedData = await _db.productDao.getDeletedUnsyncedProducts();
          if (deletedData.isNotEmpty) {
            for (var product in deletedData) {
              await delete(product.id, isOnline: isOnline);
            }
          }

          final remoteData = await _productService.fetchProducts();
          await _db.productDao.syncFromSupabase(remoteData);

          return remoteData;
        } catch (e) {
          return await _db!.productDao.getAllProducts();
        }
      } else {
        return await _db!.productDao.getAllProducts();
      }
    }
  }

  Future<void> add(ProductModel product, {required bool isOnline}) async {
    if (kIsWeb) {
      await _productService.addProduct(product);
    } else {
      if (isOnline) {
        try {
          await _productService.addProduct(product);
          await _db!.productDao.insertProduct(product);
        } catch (e) {
          await _db!.productDao.insertOrUpdateProduct(
            ProductTableCompanion(
              id: Value(product.id),
              name: Value(product.name),
              description: Value(product.description),
              categoryId: Value(product.categoryId),
              price: Value(product.price),
              quantity: Value(product.quantity),
              unit: Value(product.unit),
              imageUrl: Value(product.imageUrl),
              createdAt: Value(product.createdAt),
              updatedAt: Value(product.updatedAt),
              isSynced: Value(false),
            ),
          );
          rethrow;
        }
      } else {
        await _db!.productDao.insertOrUpdateProduct(
          ProductTableCompanion(
            id: Value(product.id),
            name: Value(product.name),
            description: Value(product.description),
            categoryId: Value(product.categoryId),
            price: Value(product.price),
            quantity: Value(product.quantity),
            unit: Value(product.unit),
            imageUrl: Value(product.imageUrl),
            createdAt: Value(product.createdAt),
            updatedAt: Value(product.updatedAt),
            isSynced: Value(false),
          ),
        );
      }
    }
  }

  Future<void> update(ProductModel product, {required bool isOnline}) async {
    if (kIsWeb) {
      await _productService.updateProduct(product);
    } else {
      if (isOnline) {
        try {
          await _productService.updateProduct(product);
          await _db!.productDao.updateProduct(product);
        } catch (e) {
          await _db!.productDao.insertOrUpdateProduct(
            ProductTableCompanion(
              id: Value(product.id),
              name: Value(product.name),
              description: Value(product.description),
              categoryId: Value(product.categoryId),
              price: Value(product.price),
              quantity: Value(product.quantity),
              unit: Value(product.unit),
              imageUrl: Value(product.imageUrl),
              createdAt: Value(product.createdAt),
              updatedAt: Value(product.updatedAt),
              isSynced: Value(false),
            ),
          );
          rethrow;
        }
      } else {
        await _db!.productDao.insertOrUpdateProduct(
          ProductTableCompanion(
            id: Value(product.id),
            name: Value(product.name),
            description: Value(product.description),
            categoryId: Value(product.categoryId),
            price: Value(product.price),
            quantity: Value(product.quantity),
            unit: Value(product.unit),
            imageUrl: Value(product.imageUrl),
            createdAt: Value(product.createdAt),
            updatedAt: Value(product.updatedAt),
            isSynced: Value(false),
          ),
        );
      }
    }
  }

  Future<void> delete(String id, {required bool isOnline}) async {
    if (kIsWeb) {
      await _productService.deleteProduct(id);
    } else {
      if (isOnline) {
        try {
          await _productService.deleteProduct(id);
          await _db!.productDao.deleteProduct(id);
        } catch (e) {
          await _db!.productDao.markProductAsDeleted(id);
          rethrow;
        }
      } else {
        await _db!.productDao.markProductAsDeleted(id);
      }
    }
  }

  Future<String?> uploadImageFileProducts(Uint8List image) async {
    try {
      return await _productService.uploadImageFileProducts(image);
    } catch (e) {
      rethrow;
    }
  }
}
