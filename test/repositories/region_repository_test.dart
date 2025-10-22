import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/daos/region_dao.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ==== Mock classes ====
class MockAppDatabase extends Mock implements AppDatabase {}

class MockRegionDao extends Mock implements RegionDao {}

class MockRegionService extends Mock implements RegionService {}

class RegionModelFake extends Fake implements RegionModel {}

class RegionTableCompanionFake extends Fake implements RegionTableCompanion {}

void registerAllFakes() {
  registerFallbackValue(RegionModelFake());
  registerFallbackValue(RegionTableCompanionFake());
}

void main() {
  late MockAppDatabase mockDb;
  late MockRegionDao mockDao;
  late MockRegionService mockService;
  late RegionRepository repository;

  final sample = RegionModel(
    id: '1',
    name: 'Đà Lạt',
    description: 'Thành phố hoa',
    parentId: null,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockDb = MockAppDatabase();
    mockDao = MockRegionDao();
    mockService = MockRegionService();

    // Gán DAO vào DB
    when(() => mockDb.regionDao).thenReturn(mockDao);

    repository = RegionRepository(mockDb, mockService);
  });
  setUpAll(registerAllFakes);

  group('RegionRepository', () {
    group('syncRegions()', () {
      test('online: push unsynced + merge remote', () async {
        // Giả lập dữ liệu local chưa sync
        when(
          () => mockDao.getUnsyncedRegions(),
        ).thenAnswer((_) async => [sample]);
        when(
          () => mockService.uploadRegions(any()),
        ).thenAnswer((_) async => {});
        when(() => mockDao.markAsSynced(any())).thenAnswer((_) async => {});
        when(
          () => mockDao.getDeletedUnsyncedRegions(),
        ).thenAnswer((_) async => []);
        when(
          () => mockService.fetchRegions(),
        ).thenAnswer((_) async => [sample]);
        when(() => mockDao.syncFromSupabase(any())).thenAnswer((_) async => {});

        final result = await repository.syncRegions(isOnline: true);

        expect(result, isA<List<RegionModel>>());
        verify(() => mockService.uploadRegions(any())).called(1);
        verify(() => mockDao.syncFromSupabase(any())).called(1);
      });

      test('offline: return local data only', () async {
        when(() => mockDao.getAllRegions()).thenAnswer((_) async => [sample]);

        final result = await repository.syncRegions(isOnline: false);

        expect(result, [sample]);
        verifyNever(() => mockService.fetchRegions());
      });
    });

    group('add()', () {
      test('online success: upload + insert synced', () async {
        when(() => mockService.addRegion(any())).thenAnswer((_) async => {});
        when(() => mockDao.insertRegion(any())).thenAnswer((_) async => {});

        await repository.add(sample, isOnline: true);

        verify(() => mockService.addRegion(sample)).called(1);
        verify(() => mockDao.insertRegion(sample)).called(1);
      });

      test('online failed: insert unsynced', () async {
        when(
          () => mockService.addRegion(any()),
        ).thenThrow(Exception('Network error'));
        when(
          () => mockDao.insertOrUpdateRegion(any()),
        ).thenAnswer((_) async => {});

        expect(
          () async => repository.add(sample, isOnline: true),
          throwsA(isA<Exception>()),
        );

        verify(() => mockDao.insertOrUpdateRegion(any())).called(1);
      });

      test('offline: insert unsynced', () async {
        when(
          () => mockDao.insertOrUpdateRegion(any()),
        ).thenAnswer((_) async => {});

        await repository.add(sample, isOnline: false);

        verify(() => mockDao.insertOrUpdateRegion(any())).called(1);
        verifyNever(() => mockService.addRegion(any()));
      });
    });

    group('update()', () {
      test('online success: update service + dao', () async {
        when(
          () => mockService.updateRegion(any(), false),
        ).thenAnswer((_) async => {});
        when(() => mockDao.updateRegion(any())).thenAnswer((_) async => true);

        await repository.update(sample, false, isOnline: true);

        verify(() => mockService.updateRegion(sample, false)).called(1);
        verify(() => mockDao.updateRegion(sample)).called(1);
      });

      test('offline: insertOrUpdate unsynced', () async {
        when(
          () => mockDao.insertOrUpdateRegion(any()),
        ).thenAnswer((_) async => {});

        await repository.update(sample, false, isOnline: false);

        verify(() => mockDao.insertOrUpdateRegion(any())).called(1);
        verifyNever(() => mockService.updateRegion(any(), false));
      });
    });

    group('delete()', () {
      test('online success: delete both service + dao', () async {
        when(() => mockService.deleteRegion(any())).thenAnswer((_) async => {});
        when(() => mockDao.deleteRegion(any())).thenAnswer((_) async => 0);

        await repository.delete('1', isOnline: true);

        verify(() => mockService.deleteRegion('1')).called(1);
        verify(() => mockDao.deleteRegion('1')).called(1);
      });

      test('offline: mark as deleted', () async {
        when(
          () => mockDao.markRegionAsDeleted(any()),
        ).thenAnswer((_) async => {});

        await repository.delete('1', isOnline: false);

        verify(() => mockDao.markRegionAsDeleted('1')).called(1);
        verifyNever(() => mockService.deleteRegion(any()));
      });
    });
  });
}
