import 'package:enviro_agri_manager/local/drift/daos/category_dao.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;
  late CategoryDao dao;

  setUp(() {
    db = AppDatabase.forTesting(openTestConnection());
    dao = db.categoryDao;
  });

  tearDown(() async => await db.close());

  group('CategoryDao', () {
    test('Thêm danh mục', () async {
      final model = CategoryModel(
        id: '123',
        name: 'Cây trồng',
        description: 'Danh mục các loại cây trồng',
        icon: '🌾',
        color: '#4CAF50',
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      await dao.insertCategory(model);
      final all = await dao.getAllCategories();

      expect(all.isNotEmpty, true);
    });
    test('Cập nhật danh mục', () async {
      final model = CategoryModel(
        id: '999',
        name: 'Cây trồng',
        description: 'Danh mục các loại cây trồng',
        icon: '🌾',
        color: '#4CAF50',
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      await dao.insertCategory(model);

      final update = CategoryModel(
        id: '999',
        name: 'Cây trồng 1',
        description: 'Danh mục các loại cây trồng 1',
        icon: '🌾',
        color: '#4CAF50',
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      await dao.updateCategory(update);
      final all = await dao.getAllCategories();

      expect(all.first.name, equals('Cây trồng 1'));
    });
    test('Xóa danh mục', () async {
      await dao.deleteCategory('123');
      await dao.deleteCategory('999');
      final all = await dao.getAllCategories();

      expect(all.isEmpty, true);
    });
  });
}
