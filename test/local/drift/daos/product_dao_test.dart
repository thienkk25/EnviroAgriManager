import 'package:enviro_agri_manager/local/drift/daos/product_dao.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;
  late ProductDao dao;

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.productDao;
  });

  tearDown(() async => await db.close());

  group('ProductDao', () {
    test('Thêm', () async {
      final now = DateTime.now();
      final model = ProductModel(
        id: 'prd_001',
        name: 'Phân bón hữu cơ sinh học',
        description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
        categoryId: 'cat_001',
        price: 150000.0,
        quantity: 50,
        unit: 'kg',
        imageUrl: 'https://example.com/images/product1.jpg',
        createdAt: now,
        updatedAt: now,
        status: 'active',
      );

      await dao.insertProduct(model);
      final all = await dao.getAllProducts();

      expect(all.isNotEmpty, true);
    });
    test('Cập nhật', () async {
      final now = DateTime.now();
      final model = ProductModel(
        id: 'prd_002',
        name: 'Phân bón hữu cơ sinh học',
        description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
        categoryId: 'cat_001',
        price: 150000.0,
        quantity: 50,
        unit: 'kg',
        imageUrl: 'https://example.com/images/product2.jpg',
        createdAt: now,
        updatedAt: now,
        status: 'active',
      );

      await dao.insertProduct(model);

      final update = ProductModel(
        id: 'prd_002',
        name: 'Phân bón vi sinh vật',
        description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
        categoryId: 'cat_002',
        price: 150000.0,
        quantity: 50,
        unit: 'kg',
        imageUrl: 'https://example.com/images/product2.jpg',
        createdAt: now,
        updatedAt: now,
        status: 'active',
      );

      await dao.updateProduct(update);
      final all = await dao.getAllProducts();

      expect(all.first.name, equals('Phân bón vi sinh vật'));
      expect(all.first.categoryId, equals('cat_002'));
    });
    test('Xóa', () async {
      await dao.deleteProduct('env_001');
      await dao.deleteProduct('env_002');
      final all = await dao.getAllProducts();

      expect(all.isEmpty, true);
    });
  });
}
