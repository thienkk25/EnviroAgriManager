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
    final rows = await select(productTable).get();
    return rows.map(_mapToModel).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final row = await (select(
      productTable,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
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
  Future<void> syncFromSupabase(List<Map<String, dynamic>> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        productTable,
        remoteData.map((data) {
          return ProductTableCompanion(
            id: Value(data['id']),
            name: Value(data['name']),
            description: Value(data['description']),
            categoryId: Value(data['category_id']),
            price: Value((data['price'] ?? 0).toDouble()),
            quantity: Value(data['quantity'] ?? 0),
            unit: Value(data['unit'] ?? ''),
            imageUrl: Value(data['image_url'] ?? ''),
            createdAt: Value(DateTime.parse(data['created_at'])),
            updatedAt: Value(DateTime.parse(data['updated_at'])),
            status: Value(data['status'] ?? 'active'),
          );
        }).toList(),
      );
    });
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
