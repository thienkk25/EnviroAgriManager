import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting();
  });

  tearDown(() async {
    await database.close();
  });

  test('Database khởi tạo đúng schema version', () {
    expect(database.schemaVersion, 1);
  });
}
