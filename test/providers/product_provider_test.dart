import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProdProductRepository extends Mock implements ProductRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class ProductModelFake extends Fake implements ProductModel {
  @override
  final String id;
  @override
  final String name;

  ProductModelFake({this.id = 'fake-id', this.name = 'fake-product'});

  @override
  ProductModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
    String? description,
    String? categoryId,
    Map<String, dynamic>? environmentalData,
    String? status,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModelFake(id: id ?? this.id, name: name ?? this.name);
  }
}

void main() {
  late ProductProvider productProvider;
  late MockProdProductRepository mockProdProductRepository;
  late MockConnectivityService mockConnectivityService;
  late ConnectivityProvider connectivityProvider;

  final sampleModel = ProductModel(
    id: 'prd_001',
    name: 'Phân bón hữu cơ sinh học',
    description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
    categoryId: 'cat_001',
    price: 150000.0,
    quantity: 50,
    unit: 'kg',
    imageUrl: 'https://example.com/images/product1.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    status: 'active',
  );
  setUpAll(() {
    registerFallbackValue(ProductModelFake());
  });

  setUp(() {
    mockProdProductRepository = MockProdProductRepository();
    mockConnectivityService = MockConnectivityService();

    when(
      () => mockConnectivityService.connectionStatusStream,
    ).thenAnswer((_) => Stream.value(true));
    when(() => mockConnectivityService.isOnline).thenAnswer((_) async => true);

    connectivityProvider = ConnectivityProvider(mockConnectivityService);

    productProvider = ProductProvider(mockProdProductRepository);
  });
  group('ProductProvider', () {
    test('fetchProducts() hoạt động bình thường', () async {
      when(
        () => mockProdProductRepository.syncProducts(
          isOnline: any(named: 'isOnline'),
        ),
      ).thenAnswer((_) async => [sampleModel]);

      await productProvider.fetchProducts(connectivityProvider.isOnline);

      expect(productProvider.products.length, 1);
      expect(productProvider.products.first.name, 'Phân bón hữu cơ sinh học');
      expect(productProvider.error, isEmpty);
    });

    test('fetchProducts() khi lỗi', () async {
      when(
        () => mockProdProductRepository.syncProducts(
          isOnline: any(named: 'isOnline'),
        ),
      ).thenThrow(Exception('Network error'));

      await productProvider.fetchProducts(connectivityProvider.isOnline);

      expect(productProvider.error, contains('Lỗi khi tải'));
    });

    test('addProduct() thêm thành công', () async {
      final sampleModel = ProductModelFake();

      when(
        () => mockProdProductRepository.add(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenAnswer((_) async => {});

      final result = await productProvider.addProduct(true, sampleModel, null);

      expect(result, true);
      expect(productProvider.products.length, 1);
      expect(productProvider.products.first.id, sampleModel.id);
      expect(productProvider.error, '');
    });

    test('addProduct() thất bại', () async {
      when(
        () => mockProdProductRepository.add(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await productProvider.addProduct(
        connectivityProvider.isOnline,
        sampleModel,
        null,
      );

      expect(result, false);
      expect(productProvider.error, contains('Lỗi khi thêm'));
    });

    test('updateProduct() cập nhật thành công', () async {
      productProvider.products.add(sampleModel);

      final updated = sampleModel.copyWith(name: 'Phân bón hữu cơ sinh học 2');

      when(
        () => mockProdProductRepository.update(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenAnswer((_) async => {});

      final result = await productProvider.updateProduct(
        connectivityProvider.isOnline,
        updated,
        '',
        null,
      );

      expect(result, true);
      expect(productProvider.products.first.name, 'Phân bón hữu cơ sinh học 2');
      expect(productProvider.error, isEmpty);
    });

    test('updateProduct() thất bại', () async {
      productProvider.products.add(sampleModel);
      when(
        () => mockProdProductRepository.update(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenThrow(Exception('DB fail'));

      final updated = sampleModel.copyWith(name: 'Lỗi rồi');

      final result = await productProvider.updateProduct(
        connectivityProvider.isOnline,
        updated,
        '',
        null,
      );

      expect(result, false);
      expect(productProvider.error, contains('Lỗi khi cập nhật'));
    });

    test('deleteProduct() xóa thành công', () async {
      productProvider.products.add(sampleModel);

      when(
        () => mockProdProductRepository.delete(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenAnswer((_) async => {});

      final result = await productProvider.deleteProduct(
        connectivityProvider.isOnline,
        'prd_001',
      );

      expect(result, true);
      expect(productProvider.products.isEmpty, true);
    });

    test('deleteProduct() xóa thất bại', () async {
      productProvider.products.add(sampleModel);

      when(
        () => mockProdProductRepository.delete(
          any(),
          isOnline: any(named: 'isOnline'),
        ),
      ).thenThrow(Exception('Error'));

      final result = await productProvider.deleteProduct(
        connectivityProvider.isOnline,
        'prd_001',
      );
      expect(result, false);
      expect(productProvider.error, contains('Lỗi khi xóa'));
    });
  });
}
