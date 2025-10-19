import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  test('insert và query ProductTable với Category', () async {
    // Thêm 1 category trước (vì Product có foreign key categoryId)
    await db
        .into(db.categoryTable)
        .insert(CategoryTableCompanion.insert(id: 'c1', name: 'Rau củ quả'));

    // Thêm sản phẩm
    await db
        .into(db.productTable)
        .insert(
          ProductTableCompanion.insert(
            id: 'p1',
            name: 'Cà chua hữu cơ',
            categoryId: 'c1',
            price: const Value(15000.0),
            quantity: const Value(100),
            unit: const Value('kg'),
            imageUrl: const Value('https://example.com/tomato.jpg'),
          ),
        );

    // Query lại để kiểm tra
    final result = await db.select(db.productTable).get();

    expect(result.length, 1);
    final product = result.first;

    expect(product.name, 'Cà chua hữu cơ');
    expect(product.categoryId, 'c1');
    expect(product.price, 15000.0);
    expect(product.quantity, 100);
    expect(product.unit, 'kg');
    expect(product.status, 'active');
  });

  test('xóa Category thì Product liên quan cũng không bị xóa', () async {
    // Thêm Category + Product
    await db
        .into(db.categoryTable)
        .insert(CategoryTableCompanion.insert(id: 'c2', name: 'Trái cây'));
    await db
        .into(db.productTable)
        .insert(
          ProductTableCompanion.insert(
            id: 'p2',
            name: 'Xoài cát',
            categoryId: 'c2',
          ),
        );

    // Xóa Category
    await (db.delete(
      db.categoryTable,
    )..where((tbl) => tbl.id.equals('c2'))).go();

    // Kiểm tra Product bị xóa theo cascade
    final products = await db.select(db.productTable).get();
    expect(products.isEmpty, false);
  });
}
