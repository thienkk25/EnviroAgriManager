import 'dart:typed_data';
import 'package:enviro_agri_manager/local/drift/daos/product_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockProductDao extends Mock implements ProductDao {}

class MockProductModel extends Mock implements ProductModel {}

class MockProductService extends Mock implements ProductService {}

class ProductTableCompanionFake extends Fake implements ProductTableCompanion {}

void main() {
  late MockAppDatabase mockDb;
  late MockProductDao mockDao;
  late MockProductService mockService;
  late ProductRepository repository;

  final sampleProduct = ProductModel(
    id: '1',
    name: 'Test Product',
    description: 'Description',
    categoryId: 'cat1',
    price: 100,
    quantity: 2,
    unit: 'kg',
    imageUrl: 'url',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    status: 'active',
  );

  setUpAll(() {
    registerFallbackValue(ProductTableCompanionFake());
    registerFallbackValue(MockProductModel());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockDb = MockAppDatabase();
    mockDao = MockProductDao();
    mockService = MockProductService();

    // Gắn DAO vào DB
    when(() => mockDb.productDao).thenReturn(mockDao);

    repository = ProductRepository(mockDb, mockService);
  });

  group('ProductRepository', () {
    test('syncProducts - online, no unsynced data', () async {
      // arrange
      when(() => mockDao.getUnsyncedProducts()).thenAnswer((_) async => []);
      when(
        () => mockDao.getDeletedUnsyncedProducts(),
      ).thenAnswer((_) async => []);
      when(
        () => mockService.fetchProducts(),
      ).thenAnswer((_) async => [sampleProduct]);
      when(() => mockDao.syncFromSupabase(any())).thenAnswer((_) async {});

      // act
      final result = await repository.syncProducts(isOnline: true);

      // assert
      expect(result, [sampleProduct]);
      verify(() => mockDao.syncFromSupabase(any())).called(1);
    });

    test('add - online, success', () async {
      // arrange
      when(() => mockService.addProduct(any())).thenAnswer((_) async {});
      when(() => mockDao.insertProduct(any())).thenAnswer((_) async {});

      // act
      await repository.add(sampleProduct, isOnline: true);

      // assert
      verify(() => mockService.addProduct(sampleProduct)).called(1);
      verify(() => mockDao.insertProduct(sampleProduct)).called(1);
    });

    test('add - offline, saves local only', () async {
      when(() => mockDao.insertOrUpdateProduct(any())).thenAnswer((_) async {});
      await repository.add(sampleProduct, isOnline: false);

      verify(() => mockDao.insertOrUpdateProduct(any())).called(1);
      verifyNever(() => mockService.addProduct(any()));
    });

    test('update - online, success', () async {
      when(() => mockService.updateProduct(any())).thenAnswer((_) async {});
      when(() => mockDao.updateProduct(any())).thenAnswer((_) async => true);

      await repository.update(sampleProduct, isOnline: true);

      verify(() => mockService.updateProduct(sampleProduct)).called(1);
      verify(() => mockDao.updateProduct(sampleProduct)).called(1);
    });

    test('delete - online, success', () async {
      when(() => mockService.deleteProduct(any())).thenAnswer((_) async {});
      when(() => mockDao.deleteProduct(any())).thenAnswer((_) async => 0);

      await repository.delete('1', isOnline: true);

      verify(() => mockService.deleteProduct('1')).called(1);
      verify(() => mockDao.deleteProduct('1')).called(1);
    });

    test('uploadImageFileProducts - success', () async {
      final mockBytes = Uint8List(5);
      when(
        () => mockService.uploadImageFileProducts(any()),
      ).thenAnswer((_) async => 'url');

      final result = await repository.uploadImageFileProducts(mockBytes);

      expect(result, 'url');
      verify(() => mockService.uploadImageFileProducts(mockBytes)).called(1);
    });

    test('deleteImageFileProducts - success', () async {
      when(
        () => mockService.deleteImageFileProducts(any()),
      ).thenAnswer((_) async {});

      await repository.deleteImageFileProducts(['path1']);

      verify(() => mockService.deleteImageFileProducts(['path1'])).called(1);
    });
  });
}
