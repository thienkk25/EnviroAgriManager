import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late ProductService productService;

  setUpAll(() async {
    mockHttpClient = MockSupabaseHttpClient();
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      anonKey: 'fake-key',
      httpClient: mockHttpClient,
    );
    mockSupabase = Supabase.instance.client;
  });
  setUp(() {
    Supabase.instance.client = mockSupabase;
    productService = ProductService();
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('productService', () {
    test('fetchProducts', () async {
      await mockSupabase.from('products').insert([
        {
          'id': 'prd_001',
          'name': 'Phân bón hữu cơ sinh học',
          'description': 'Phân bón giúp cải thiện độ phì nhiêu của đất',
          'category_id': 'cat_001',
          'price': 150000.0,
          'quantity': 50,
          'unit': 'kg',
          'image_url': 'https://example.com/images/product1.jpg',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'status': 'active',
        },
        {
          'id': 'prd_002',
          'name': 'Phân bón hữu cơ sinh học',
          'description': 'Phân bón giúp cải thiện độ phì nhiêu của đất',
          'category_id': 'cat_002',
          'price': 150000.0,
          'quantity': 50,
          'unit': 'kg',
          'image_url': 'https://example.com/images/product1.jpg',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'status': 'active',
        },
      ]);

      final result = await productService.fetchProducts();

      expect(result.length, 2);
      expect(result.first.name, 'Phân bón hữu cơ sinh học');
      expect(result.last.categoryId, 'cat_002');
    });

    test('addProduct', () async {
      final model = ProductModel(
        id: '3',
        name: 'Test 3',
        description: '',
        categoryId: '',
        price: 1,
        quantity: 1,
        unit: '',
        imageUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: '',
      );

      await productService.addProduct(model);

      final result = await mockSupabase.from('products').select();

      expect(result.length, 1);
      expect(result.first['name'], 'Test 3');
    });
    test('getProduct', () async {
      final model = ProductModel(
        id: '4',
        name: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        categoryId: '',
        price: 1,
        quantity: 1,
        unit: '',
        imageUrl: '',
        status: '',
      );

      await productService.addProduct(model);

      final result = await productService.getProduct('4');

      expect(result.id, '4');
      expect(result.name, 'Test 4');
    });
    test('updateProduct', () async {
      final model = ProductModel(
        id: '4',
        name: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        categoryId: '',
        price: 1,
        quantity: 1,
        unit: '',
        imageUrl: '',
        status: '',
      );

      await productService.addProduct(model);

      final updateCategory = model.copyWith(name: 'Test update 4');

      await productService.updateProduct(updateCategory);

      final result = await productService.getProduct(model.id);

      expect(result.id, '4');
      expect(result.name, 'Test update 4');
    });
    test('deleteProduct', () async {
      final model = ProductModel(
        id: '5',
        name: 'Test 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        categoryId: '',
        price: 1,
        quantity: 1,
        unit: '',
        imageUrl: '',
        status: '',
      );

      await productService.addProduct(model);

      await productService.deleteProduct(model.id);

      await expectLater(
        () => productService.getProduct(model.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
