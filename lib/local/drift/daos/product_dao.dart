import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/tables/product_table.dart';
import 'package:enviro_agri_manager/models/product_model.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [ProductTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  // CREATE
  Future<void> insertProduct(ProductModel model) async {
    await into(productTable).insertOnConflictUpdate(
      ProductTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        categoryId: Value(model.categoryId),
        price: Value(model.price),
        quantity: Value(model.quantity),
        unit: Value(model.unit),
        imageUrl: Value(model.imageUrl),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
        status: Value(model.status),
      ),
    );
  }

  // READ
  Future<List<ProductModel>> getAllProducts() async {
    final rows = await (select(
      productTable,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<List<ProductModel>> getUnsyncedProducts() async {
    final rows = await (select(
      productTable,
    )..where((t) => t.isSynced.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> insertOrUpdateProduct(ProductTableCompanion entry) {
    return into(productTable).insertOnConflictUpdate(
      entry.copyWith(updatedAt: Value(DateTime.now()), isSynced: Value(false)),
    );
  }

  Future<void> markAsSynced(List<String> ids) {
    return (update(productTable)..where((t) => t.id.isIn(ids))).write(
      ProductTableCompanion(isSynced: Value(true)),
    );
  }

  // UPDATE
  Future<bool> updateProduct(ProductModel model) async {
    return update(productTable).replace(
      ProductTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        categoryId: Value(model.categoryId),
        price: Value(model.price),
        quantity: Value(model.quantity),
        unit: Value(model.unit),
        imageUrl: Value(model.imageUrl),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
        status: Value(model.status),
      ),
    );
  }

  // DELETE
  Future<int> deleteProduct(String id) async {
    return (delete(productTable)..where((p) => p.id.equals(id))).go();
  }

  // SYNC
  Future<void> syncFromSupabase(List<ProductModel> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        productTable,
        remoteData.map((p) {
          return ProductTableCompanion(
            id: Value(p.id),
            name: Value(p.name),
            description: Value(p.description),
            categoryId: Value(p.categoryId),
            price: Value(p.price),
            quantity: Value(p.quantity),
            unit: Value(p.unit),
            imageUrl: Value(p.imageUrl),
            createdAt: Value(p.createdAt),
            updatedAt: Value(p.updatedAt),
            status: Value(p.status),
          );
        }).toList(),
      );
    });
  }

  Future<void> markProductAsDeleted(String id) async {
    await (update(productTable)..where((t) => t.id.equals(id))).write(
      ProductTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(true),
        pendingDelete: const Value(true),
      ),
    );
  }

  Future<void> restoreProduct(String id) async {
    await (update(productTable)..where((t) => t.id.equals(id))).write(
      ProductTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(false),
        pendingDelete: const Value(false),
      ),
    );
  }

  Future<List<ProductModel>> getDeletedUnsyncedProducts() async {
    final rows =
        await (select(productTable)..where(
              (t) => t.isDeleted.equals(true) & t.isSynced
                ..equals(false),
            ))
            .get();
    return rows.map(_mapToModel).toList();
  }

  ProductModel _mapToModel(ProductTableData row) {
    return ProductModel(
      id: row.id,
      name: row.name,
      description: row.description ?? '',
      categoryId: row.categoryId,
      price: row.price,
      quantity: row.quantity,
      unit: row.unit,
      imageUrl: row.imageUrl ?? '',
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      status: row.status,
    );
  }
}
