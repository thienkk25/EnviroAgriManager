import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  test('insert và query CategoryTable', () async {
    await db
        .into(db.categoryTable)
        .insert(
          CategoryTableCompanion.insert(
            id: 'cate1',
            name: 'Phân bón',
            description: const Value('Dành cho cây trồng'),
          ),
        );

    final result = await db.select(db.categoryTable).get();

    expect(result.length, 1);
    expect(result.first.name, 'Phân bón');
    expect(result.first.description, 'Dành cho cây trồng');
  });
}
