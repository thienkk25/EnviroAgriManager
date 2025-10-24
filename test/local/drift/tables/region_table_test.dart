import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(openTestConnection());
  });

  tearDown(() async {
    await db.close();
  });

  test('Thêm và truy vấn RegionTable', () async {
    // Insert dữ liệu
    await db
        .into(db.regionTable)
        .insert(
          RegionTableCompanion.insert(
            id: 'r1',
            name: 'Miền Bắc',
            description: const Value('Khu vực phía Bắc Việt Nam'),
            isActive: const Value(true),
          ),
        );

    // Truy vấn lại
    final regions = await db.select(db.regionTable).get();

    expect(regions.length, 1);
    final region = regions.first;

    expect(region.id, 'r1');
    expect(region.name, 'Miền Bắc');
    expect(region.description, 'Khu vực phía Bắc Việt Nam');
    expect(region.isActive, true);
    expect(region.isDeleted, false);
    expect(region.isSynced, false);
  });

  test('Cập nhật thông tin Region', () async {
    // Thêm region ban đầu
    await db
        .into(db.regionTable)
        .insert(RegionTableCompanion.insert(id: 'r2', name: 'Miền Trung'));

    // Cập nhật lại tên
    await (db.update(db.regionTable)..where((tbl) => tbl.id.equals('r2')))
        .write(const RegionTableCompanion(name: Value('Miền Trung Việt Nam')));

    // Kiểm tra kết quả
    final updated = await (db.select(
      db.regionTable,
    )..where((tbl) => tbl.id.equals('r2'))).getSingle();

    expect(updated.name, 'Miền Trung Việt Nam');
  });

  test('Xóa region', () async {
    await db
        .into(db.regionTable)
        .insert(RegionTableCompanion.insert(id: 'r3', name: 'Miền Nam'));

    await (db.delete(db.regionTable)..where((tbl) => tbl.id.equals('r3'))).go();

    final allRegions = await db.select(db.regionTable).get();
    expect(allRegions.isEmpty, true);
  });
}
