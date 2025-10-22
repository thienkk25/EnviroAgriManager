import 'dart:typed_data';
import 'package:enviro_agri_manager/local/drift/daos/environmental_data_dao.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockEnvironmentalDataDao extends Mock implements EnvironmentalDataDao {}

class MockEnvironmentalDataModel extends Mock
    implements EnvironmentalDataModel {}

class MockProductService extends Mock implements EnvironmentalDataService {}

class EnvironmentalDataTableCompanionFake extends Fake
    implements EnvironmentalDataTableCompanion {}

void main() {
  late MockAppDatabase mockDb;
  late MockEnvironmentalDataDao mockDao;
  late MockProductService mockService;
  late EnvironmentalDataRepository repository;

  final sampleProduct = EnvironmentalDataModel(
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
    recordedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(EnvironmentalDataTableCompanionFake());
    registerFallbackValue(MockEnvironmentalDataModel());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockDb = MockAppDatabase();
    mockDao = MockEnvironmentalDataDao();
    mockService = MockProductService();

    // Gắn DAO vào DB
    when(() => mockDb.environmentalDataDao).thenReturn(mockDao);

    repository = EnvironmentalDataRepository(mockDb, mockService);
  });

  group('EnvironmentalDataRepository', () {
    test('syncEnvironmentalData - online, no unsynced data', () async {
      // arrange
      when(
        () => mockDao.getUnsyncedEnvironmentalData(),
      ).thenAnswer((_) async => []);
      when(
        () => mockDao.getDeletedUnsyncedEnvironmentalData(),
      ).thenAnswer((_) async => []);
      when(
        () => mockService.fetchEnvironmentalData(),
      ).thenAnswer((_) async => [sampleProduct]);
      when(() => mockDao.syncFromSupabase(any())).thenAnswer((_) async {});

      // act
      final result = await repository.syncEnvironmentalData(isOnline: true);

      // assert
      expect(result, [sampleProduct]);
      verify(() => mockDao.syncFromSupabase(any())).called(1);
    });

    test('add - online, success', () async {
      // arrange
      when(
        () => mockService.addEnvironmentalData(any()),
      ).thenAnswer((_) async {});
      when(() => mockDao.insertData(any())).thenAnswer((_) async {});

      // act
      await repository.add(sampleProduct, isOnline: true);

      // assert
      verify(() => mockService.addEnvironmentalData(sampleProduct)).called(1);
      verify(() => mockDao.insertData(sampleProduct)).called(1);
    });

    test('add - offline, saves local only', () async {
      when(
        () => mockDao.insertOrUpdateEnvironmentalData(any()),
      ).thenAnswer((_) async {});
      await repository.add(sampleProduct, isOnline: false);

      verify(() => mockDao.insertOrUpdateEnvironmentalData(any())).called(1);
      verifyNever(() => mockService.addEnvironmentalData(any()));
    });

    test('update - online, success', () async {
      when(
        () => mockService.updateEnvironmentalData(any()),
      ).thenAnswer((_) async {});
      when(() => mockDao.updateData(any())).thenAnswer((_) async => true);

      await repository.update(sampleProduct, isOnline: true);

      verify(
        () => mockService.updateEnvironmentalData(sampleProduct),
      ).called(1);
      verify(() => mockDao.updateData(sampleProduct)).called(1);
    });

    test('delete - online, success', () async {
      when(
        () => mockService.deleteEnvironmentalData(any()),
      ).thenAnswer((_) async {});
      when(() => mockDao.deleteData(any())).thenAnswer((_) async => 0);

      await repository.delete('1', isOnline: true);

      verify(() => mockService.deleteEnvironmentalData('1')).called(1);
      verify(() => mockDao.deleteData('1')).called(1);
    });
  });
}
