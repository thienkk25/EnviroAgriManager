import 'package:enviro_agri_manager/local/drift/daos/environmental_data_dao.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

void main() {
  late AppDatabase db;
  late EnvironmentalDataDao dao;

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.environmentalDataDao;
  });

  tearDown(() async => await db.close());

  group('EnvironmentalDataDao', () {
    test('Thêm', () async {
      final now = DateTime.now();
      final model = EnvironmentalDataModel(
        id: 'env_001',
        regionId: 'reg_001',
        location: 'Cần Thơ',
        temperature: 29.3,
        humidity: 76.5,
        ph: 6.2,
        soilMoisture: 40.1,
        lightIntensity: 800.0,
        co2Level: 380.0,
        nitrogen: 12.0,
        phosphorus: 6.0,
        potassium: 9.5,
        weatherCondition: 'Nắng nhẹ',
        notes: 'Độ ẩm cao buổi sáng',
        recordedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await dao.insertData(model);
      final all = await dao.getAll();

      expect(all.isNotEmpty, true);
    });
    test('Cập nhật', () async {
      final now = DateTime.now();
      final model = EnvironmentalDataModel(
        id: 'env_002',
        regionId: 'reg_001',
        location: 'Cần Thơ 1111',
        temperature: 29.3,
        humidity: 76.5,
        ph: 6.2,
        soilMoisture: 40.1,
        lightIntensity: 800.0,
        co2Level: 380.0,
        nitrogen: 12.0,
        phosphorus: 6.0,
        potassium: 9.5,
        weatherCondition: 'Nắng nhẹ',
        notes: 'Độ ẩm cao buổi sáng',
        recordedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await dao.insertData(model);

      final update = EnvironmentalDataModel(
        id: 'env_002',
        regionId: 'reg_001',
        location: 'Hà Nội',
        temperature: 29.3,
        humidity: 76.5,
        ph: 6.2,
        soilMoisture: 40.1,
        lightIntensity: 800.0,
        co2Level: 380.0,
        nitrogen: 12.0,
        phosphorus: 6.0,
        potassium: 9.5,
        weatherCondition: 'Nắng nhẹ',
        notes: 'Độ ẩm cao buổi sáng',
        recordedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await dao.updateData(update);
      final all = await dao.getAll();

      expect(all.first.location, equals('Hà Nội'));
    });
    test('Xóa', () async {
      await dao.deleteData('env_001');
      await dao.deleteData('env_002');
      final all = await dao.getAll();

      expect(all.isEmpty, true);
    });
  });
}
