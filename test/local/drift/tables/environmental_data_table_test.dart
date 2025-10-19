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

  test('insert và query EnvironmentalDataTable với Region', () async {
    // Tạo 1 region trước vì EnvironmentalData cần regionId
    await db
        .into(db.regionTable)
        .insert(RegionTableCompanion.insert(id: 'r1', name: 'Đà Lạt'));

    // Thêm bản ghi môi trường
    await db
        .into(db.environmentalDataTable)
        .insert(
          EnvironmentalDataTableCompanion.insert(
            id: 'e1',
            regionId: 'r1', // liên kết với region ở trên
            temperature: const Value(25.5),
            humidity: const Value(80.0),
            notes: const Value('Nhiệt độ ổn định'),
          ),
        );

    // Query lại
    final result = await db.select(db.environmentalDataTable).get();

    expect(result.length, 1);
    final record = result.first;

    expect(record.regionId, 'r1');
    expect(record.temperature, 25.5);
    expect(record.humidity, 80.0);
    expect(record.notes, 'Nhiệt độ ổn định');
  });

  test(
    'foreign key Region bị xóa thì EnvironmentalData không bị xóa khi có dữ liệu phụ thuộc',
    () async {
      // Tạo region + data
      await db
          .into(db.regionTable)
          .insert(RegionTableCompanion.insert(id: 'r2', name: 'Bảo Lộc'));
      await db
          .into(db.environmentalDataTable)
          .insert(
            EnvironmentalDataTableCompanion.insert(id: 'e2', regionId: 'r2'),
          );

      // Xóa region
      await (db.delete(
        db.regionTable,
      )..where((tbl) => tbl.id.equals('r2'))).go();

      final remaining = await db.select(db.environmentalDataTable).get();
      expect(remaining.isEmpty, false);
    },
  );
}
