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
    final rows = await select(categoryTable).get();
    return rows.map(_mapToModel).toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final row = await (select(
      categoryTable,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<List<CategoryModel>> getSubCategories(String? parentId) async {
    final rows = await (select(
      categoryTable,
    )..where((c) => c.parentId.equals(parentId!))).get();
    return rows.map(_mapToModel).toList();
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
  Future<void> syncFromSupabase(List<Map<String, dynamic>> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        categoryTable,
        remoteData.map((data) {
          return CategoryTableCompanion(
            id: Value(data['id']),
            name: Value(data['name']),
            description: Value(data['description']),
            icon: Value(data['icon']),
            color: Value(data['color']),
            parentId: Value(data['parent_id']),
            createdAt: Value(DateTime.parse(data['created_at'])),
            updatedAt: Value(DateTime.parse(data['updated_at'])),
            isActive: Value(data['is_active'] ?? true),
          );
        }).toList(),
      );
    });
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
