import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/tables/category_table.dart';
import 'package:enviro_agri_manager/models/category_model.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [CategoryTable])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // --- CREATE ---
  Future<void> insertCategory(CategoryModel model) async {
    await into(categoryTable).insertOnConflictUpdate(
      CategoryTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        icon: Value(model.icon),
        color: Value(model.color),
        parentId: Value(model.parentId),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
        isActive: Value(model.isActive),
      ),
    );
  }

  // --- READ ---
  Future<List<CategoryModel>> getAllCategories() async {
    final rows = await (select(
      categoryTable,
    )..where((t) => t.deletedAt.isNull())).get();
    return rows.map(_mapToModel).toList();
  }

  // Lấy danh mục chưa đồng bộ sang model
  Future<List<CategoryModel>> getUnsyncedCategoriesAsModels() async {
    final rows = await (select(
      categoryTable,
    )..where((t) => t.isSynced.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  // Thêm / Cập nhật danh mục và đánh dấu chưa sync
  Future<void> insertOrUpdateCategory(CategoryTableCompanion entry) {
    return into(
      categoryTable,
    ).insertOnConflictUpdate(entry.copyWith(isSynced: Value(false)));
  }

  // Đánh dấu danh mục đã sync
  Future<void> markAsSynced(List<String> ids) {
    return (update(categoryTable)..where((t) => t.id.isIn(ids))).write(
      CategoryTableCompanion(isSynced: Value(true)),
    );
  }

  // --- UPDATE ---
  Future<bool> updateCategory(CategoryModel model) async {
    return update(categoryTable).replace(
      CategoryTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        icon: Value(model.icon),
        color: Value(model.color),
        parentId: Value(model.parentId),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
        isActive: Value(model.isActive),
      ),
    );
  }

  // --- DELETE ---
  Future<int> deleteCategory(String id) async {
    return (delete(categoryTable)..where((c) => c.id.equals(id))).go();
  }

  // --- SYNC (ví dụ khi nhận data từ Supabase) ---
  Future<void> syncFromSupabase(List<CategoryModel> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        categoryTable,
        remoteData.map((e) {
          return CategoryTableCompanion(
            id: Value(e.id),
            name: Value(e.name),
            description: Value(e.description),
            icon: Value(e.icon),
            color: Value(e.color),
            parentId: Value(e.parentId),
            createdAt: Value(e.createdAt),
            updatedAt: Value(e.updatedAt),
            isActive: Value(e.isActive),
          );
        }).toList(),
      );
    });
  }

  Future<void> softDeleteCategory(String id) async {
    await (update(categoryTable)..where((t) => t.id.equals(id))).write(
      CategoryTableCompanion(
        deletedAt: Value(DateTime.now()),
        isSynced: Value(false), // Đánh dấu chưa sync
      ),
    );
  }

  // Lấy categories đã xóa chưa sync
  Future<List<CategoryModel>> getDeletedUnsyncedCategories() async {
    final rows =
        await (select(categoryTable)..where(
              (t) => t.deletedAt.isNotNull() & t.isSynced
                ..equals(false),
            ))
            .get();
    return rows.map(_mapToModel).toList();
  }

  // --- Helper ---
  CategoryModel _mapToModel(CategoryTableData row) {
    return CategoryModel(
      id: row.id,
      name: row.name,
      description: row.description ?? '',
      icon: row.icon,
      color: row.color,
      parentId: row.parentId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isActive: row.isActive,
    );
  }
}
