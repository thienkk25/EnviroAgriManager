import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/daos/category_dao.dart';
import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ==== Mock classes ====
class MockAppDatabase extends Mock implements AppDatabase {}

class MockCategoryDao extends Mock implements CategoryDao {}

class MockCategoryService extends Mock implements CategoryService {}

class CategoryModelFake extends Fake implements CategoryModel {}

class ProductModelFake extends Fake implements ProductModel {}

class CategoryTableCompanionFake extends Fake
    implements CategoryTableCompanion {}

void registerAllFakes() {
  registerFallbackValue(CategoryModelFake());
  registerFallbackValue(ProductModelFake());
  registerFallbackValue(CategoryTableCompanionFake());
}

void main() {
  late MockAppDatabase mockDb;
  late MockCategoryDao mockDao;
  late MockCategoryService mockService;
  late CategoryRepository repository;

  final sampleCategory = CategoryModel(
    id: '1',
    name: 'Rau củ',
    description: 'Danh mục thực phẩm xanh',
    icon: 'leaf',
    color: '#00FF00',
    parentId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
  );

  setUp(() {
    mockDb = MockAppDatabase();
    mockDao = MockCategoryDao();
    mockService = MockCategoryService();

    // Gán DAO vào DB
    when(() => mockDb.categoryDao).thenReturn(mockDao);

    repository = CategoryRepository(mockDb, mockService);
  });
  setUpAll(registerAllFakes);

  group('CategoryRepository', () {
    group('syncCategories()', () {
      test(
        'pushLocalChangesWithConflictCheck - push and delete with conflict',
        () async {
          final unsynced = [
            CategoryModel(
              id: '1',
              name: 'Local',
              updatedAt: DateTime(2025, 11, 8),
              description: '',
              icon: '',
              color: '',
              createdAt: DateTime.now(),
            ),
          ];
          final deleted = [
            CategoryModel(
              id: '2',
              name: 'Deleted',
              updatedAt: DateTime(2025, 11, 7),
              description: '',
              icon: '',
              color: '',
              createdAt: DateTime.now(),
            ),
          ];
          final serverCategory = CategoryModel(
            id: '1',
            name: 'Server',
            updatedAt: DateTime(2025, 11, 7),
            description: '',
            icon: '',
            color: '',
            createdAt: DateTime.now(),
          );
          final serverDeletedCategory = CategoryModel(
            id: '2',
            name: 'ServerDeleted',
            updatedAt: DateTime(2025, 11, 6),
            description: '',
            icon: '',
            color: '',
            createdAt: DateTime.now(),
          );

          // Mock DAO
          when(
            () => mockDao.getUnsyncedCategories(),
          ).thenAnswer((_) async => unsynced);
          when(
            () => mockDao.getDeletedUnsyncedCategories(),
          ).thenAnswer((_) async => deleted);
          when(() => mockDao.markAsSynced(any())).thenAnswer((_) async {});
          when(
            () => mockDao.getCategoryById('2'),
          ).thenAnswer((_) async => deleted[0]);
          when(() => mockDao.restoreCategory(any())).thenAnswer((_) async {});

          // Mock service
          when(
            () => mockService.getCategory('1'),
          ).thenAnswer((_) async => serverCategory);
          when(
            () => mockService.updateCategory(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockService.getCategory('2'),
          ).thenAnswer((_) async => serverDeletedCategory);
          when(() => mockService.deleteCategory('2')).thenAnswer((_) async {});

          await repository.pushLocalChangesWithConflictCheck();

          // Verify push local category
          verify(() => mockService.updateCategory(unsynced[0])).called(1);
          verify(() => mockDao.markAsSynced(['1'])).called(1);

          // Verify delete category
          verify(() => mockService.deleteCategory('2')).called(1);
          verify(() => mockDao.markAsSynced(['2'])).called(1);
        },
      );

      test('offline: return local data only', () async {
        when(
          () => mockDao.getAllCategories(),
        ).thenAnswer((_) async => [sampleCategory]);

        final result = await repository.syncCategories(isOnline: false);

        expect(result, [sampleCategory]);
        verifyNever(() => mockService.fetchCategories());
      });
    });

    group('add()', () {
      test('online success: upload + insert synced', () async {
        when(() => mockService.addCategory(any())).thenAnswer((_) async => {});
        when(() => mockDao.insertCategory(any())).thenAnswer((_) async => {});

        await repository.add(sampleCategory, isOnline: true);

        verify(() => mockService.addCategory(sampleCategory)).called(1);
        verify(() => mockDao.insertCategory(sampleCategory)).called(1);
      });

      test('online failed: insert unsynced', () async {
        when(
          () => mockService.addCategory(any()),
        ).thenThrow(Exception('Network error'));
        when(
          () => mockDao.insertOrUpdateCategory(any()),
        ).thenAnswer((_) async => {});

        expect(
          () async => repository.add(sampleCategory, isOnline: true),
          throwsA(isA<Exception>()),
        );

        verify(() => mockDao.insertOrUpdateCategory(any())).called(1);
      });

      test('offline: insert unsynced', () async {
        when(
          () => mockDao.insertOrUpdateCategory(any()),
        ).thenAnswer((_) async => {});

        await repository.add(sampleCategory, isOnline: false);

        verify(() => mockDao.insertOrUpdateCategory(any())).called(1);
        verifyNever(() => mockService.addCategory(any()));
      });
    });

    group('update()', () {
      test('online success: update service + dao', () async {
        when(
          () => mockService.updateCategory(any()),
        ).thenAnswer((_) async => {});
        when(() => mockDao.updateCategory(any())).thenAnswer((_) async => true);

        await repository.update(sampleCategory, isOnline: true);

        verify(() => mockService.updateCategory(sampleCategory)).called(1);
        verify(() => mockDao.updateCategory(sampleCategory)).called(1);
      });

      test('offline: insertOrUpdate unsynced', () async {
        when(
          () => mockDao.insertOrUpdateCategory(any()),
        ).thenAnswer((_) async => {});

        await repository.update(sampleCategory, isOnline: false);

        verify(() => mockDao.insertOrUpdateCategory(any())).called(1);
        verifyNever(() => mockService.updateCategory(any()));
      });
    });

    group('delete()', () {
      test('online success: delete both service + dao', () async {
        when(
          () => mockService.deleteCategory(any()),
        ).thenAnswer((_) async => {});
        when(() => mockDao.deleteCategory(any())).thenAnswer((_) async => 0);

        await repository.delete('1', isOnline: true);

        verify(() => mockService.deleteCategory('1')).called(1);
        verify(() => mockDao.deleteCategory('1')).called(1);
      });

      test('offline: mark as deleted', () async {
        when(
          () => mockDao.markCategoryAsDeleted(any()),
        ).thenAnswer((_) async => {});

        await repository.delete('1', isOnline: false);

        verify(() => mockDao.markCategoryAsDeleted('1')).called(1);
        verifyNever(() => mockService.deleteCategory(any()));
      });
    });
  });
}
