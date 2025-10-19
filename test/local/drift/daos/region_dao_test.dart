import 'package:enviro_agri_manager/local/drift/daos/region_dao.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;
  late RegionDao dao;

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.regionDao;
  });

  tearDown(() async => await db.close());

  group('RegionDao', () {
    test('Thêm', () async {
      final now = DateTime.now();
      final model = RegionModel(
        id: '1',
        name: 'Đà Lạt',
        description: 'Thành phố hoa',
        parentId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await dao.insertRegion(model);
      final all = await dao.getAllRegions();

      expect(all.isNotEmpty, true);
    });
    test('Cập nhật', () async {
      final now = DateTime.now();
      final model = RegionModel(
        id: '2',
        name: 'Tây Nam',
        description: 'Thành phố hoa',
        parentId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await dao.insertRegion(model);

      final update = RegionModel(
        id: '2',
        name: 'Tây Nguyên',
        description: 'Thành phố hoa',
        parentId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await dao.updateRegion(update);
      final all = await dao.getAllRegions();

      expect(all.first.name, equals('Tây Nguyên'));
    });
    test('Xóa', () async {
      await dao.deleteRegion('1');
      await dao.deleteRegion('2');
      final all = await dao.getAllRegions();

      expect(all.isEmpty, true);
    });
  });
}
