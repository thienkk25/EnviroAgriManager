import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/models/category_model.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late CategoryService categoryService;

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
    categoryService = CategoryService();
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('CategoryService', () {
    test('fetchCategories', () async {
      await mockSupabase.from('categories').insert([
        {
          'id': '2',
          'name': 'Cây trồng',
          'description': 'Danh mục các loại cây trồng',
          'icon': '🌾',
          'color': '#4CAF50',
          'parent_id': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_active': true,
        },
        {
          'id': '2',
          'name': 'Động vật',
          'description': 'Danh mục động vật',
          'icon': '',
          'color': '#4CAF50',
          'parent_id': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_active': true,
        },
      ]);

      final result = await categoryService.fetchCategories();

      expect(result.length, 2);
      expect(result.first.name, 'Cây trồng');
      expect(result.last.description, 'Danh mục động vật');
    });

    test('addCategory', () async {
      final newCategory = CategoryModel(
        id: '3',
        name: 'Thủy sản',
        description: 'Danh mục thủy sản',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await categoryService.addCategory(newCategory);

      final result = await mockSupabase.from('categories').select();

      expect(result.length, 1);
      expect(result.first['name'], 'Thủy sản');
    });
    test('getCategory', () async {
      final newCategory = CategoryModel(
        id: '4',
        name: 'Test 4',
        description: '',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await categoryService.addCategory(newCategory);

      final result = await categoryService.getCategory('4');

      expect(result.id, '4');
      expect(result.name, 'Test 4');
    });
    test('updateCategory', () async {
      final newCategory = CategoryModel(
        id: '4',
        name: 'Test 4',
        description: '',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await categoryService.addCategory(newCategory);

      final updateCategory = newCategory.copyWith(name: 'Test update 4');

      await categoryService.updateCategory(updateCategory);

      final result = await categoryService.getCategory(newCategory.id);

      expect(result.id, '4');
      expect(result.name, 'Test update 4');
    });
    test('deleteCategory', () async {
      final newCategory = CategoryModel(
        id: '4',
        name: 'Test 4',
        description: '',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await categoryService.addCategory(newCategory);

      await categoryService.deleteCategory(newCategory.id);

      await expectLater(
        () => categoryService.getCategory(newCategory.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
