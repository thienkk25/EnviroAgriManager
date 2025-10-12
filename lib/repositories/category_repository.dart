import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/services/category_service.dart';

class CategoryRepository {
  final AppDatabase _db;
  final CategoryService _categoryService;

  CategoryRepository(this._db, this._categoryService);

  Future<List<CategoryModel>> syncCategories({required bool isOnline}) async {
    if (isOnline) {
      try {
        // Lấy dữ liệu local chưa sync (dưới dạng Model)
        final localNewData = await _db.categoryDao
            .getUnsyncedCategoriesAsModels();

        // Push dữ liệu local lên server
        if (localNewData.isNotEmpty) {
          await _categoryService.uploadCategories(localNewData);

          // Đánh dấu đã sync
          await _db.categoryDao.markAsSynced(
            localNewData.map((e) => e.id).toList(),
          );
        }

        // Push các item đã xóa
        final deletedData = await _db.categoryDao
            .getDeletedUnsyncedCategories();
        if (deletedData.isNotEmpty) {
          // Xóa trên server
          for (var category in deletedData) {
            await _categoryService.deleteCategory(category.id);
          }

          // Xóa thật khỏi local DB sau khi đã sync
          for (var category in deletedData) {
            await _db.categoryDao.deleteCategory(category.id);
          }
        }

        // Lấy dữ liệu server
        final remoteData = await _categoryService.fetchCategories();
        // Merge dữ liệu server về local
        await _db.categoryDao.syncFromSupabase(remoteData);

        return remoteData;
      } catch (e) {
        return await _db.categoryDao.getAllCategories();
      }
    } else {
      // Offline: chỉ lấy dữ liệu local
      return await _db.categoryDao.getAllCategories();
    }
  }

  Future<void> add(CategoryModel category, {required bool isOnline}) async {
    if (isOnline) {
      try {
        await _categoryService.addCategory(category);
        // Online thành công → insert với isSynced = true
        await _db.categoryDao.insertCategory(category);
      } catch (e) {
        // Online thất bại → insert với isSynced = false để sync sau
        await _db.categoryDao.insertOrUpdateCategory(
          CategoryTableCompanion(
            id: Value(category.id),
            name: Value(category.name),
            description: Value(category.description),
            icon: Value(category.icon),
            color: Value(category.color),
            parentId: Value(category.parentId),
            createdAt: Value(category.createdAt),
            updatedAt: Value(category.updatedAt),
            isActive: Value(category.isActive),
            isSynced: Value(false), // ✅ Đánh dấu chưa sync
          ),
        );
        rethrow;
      }
    } else {
      // Offline → insert với isSynced = false
      await _db.categoryDao.insertOrUpdateCategory(
        CategoryTableCompanion(
          id: Value(category.id),
          name: Value(category.name),
          description: Value(category.description),
          icon: Value(category.icon),
          color: Value(category.color),
          parentId: Value(category.parentId),
          createdAt: Value(category.createdAt),
          updatedAt: Value(category.updatedAt),
          isActive: Value(category.isActive),
          isSynced: Value(false), // ✅ Đánh dấu chưa sync
        ),
      );
    }
  }

  Future<void> update(CategoryModel category, {required bool isOnline}) async {
    if (isOnline) {
      try {
        await _categoryService.updateCategory(category);
        await _db.categoryDao.updateCategory(category);
      } catch (e) {
        // Nếu update online thất bại, đánh dấu chưa sync
        await _db.categoryDao.insertOrUpdateCategory(
          CategoryTableCompanion(
            id: Value(category.id),
            name: Value(category.name),
            description: Value(category.description),
            icon: Value(category.icon),
            color: Value(category.color),
            parentId: Value(category.parentId),
            createdAt: Value(category.createdAt),
            updatedAt: Value(category.updatedAt),
            isActive: Value(category.isActive),
            isSynced: Value(false),
          ),
        );
        rethrow;
      }
    } else {
      // Offline → update với isSynced = false
      await _db.categoryDao.insertOrUpdateCategory(
        CategoryTableCompanion(
          id: Value(category.id),
          name: Value(category.name),
          description: Value(category.description),
          icon: Value(category.icon),
          color: Value(category.color),
          parentId: Value(category.parentId),
          createdAt: Value(category.createdAt),
          updatedAt: Value(category.updatedAt),
          isActive: Value(category.isActive),
          isSynced: Value(false),
        ),
      );
    }
  }

  Future<void> delete(String id, {required bool isOnline}) async {
    if (isOnline) {
      try {
        // Online: xóa trên server và xóa thật local
        await _categoryService.deleteCategory(id);
        await _db.categoryDao.deleteCategory(id);
      } catch (e) {
        // Lỗi → soft delete để sync sau
        await _db.categoryDao.softDeleteCategory(id);
        rethrow;
      }
    } else {
      // Offline: soft delete
      await _db.categoryDao.softDeleteCategory(id);
    }
  }
}
