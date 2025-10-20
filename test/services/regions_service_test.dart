import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late RegionService regionService;

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
    regionService = RegionService();
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('regionService', () {
    test('fetchRegions', () async {
      await mockSupabase.from('regions').insert([
        {
          'id': '1',
          'name': 'Hà Nội',
          'description': 'Thủ đô',
          'parent_id': null,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'name': 'Cầ Thơ',
          'description': '',
          'parent_id': null,
          'is_active': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      final result = await regionService.fetchRegions();

      expect(result.length, 2);
      expect(result.first.name, 'Hà Nội');
      expect(result.last.isActive, false);
    });

    test('addRegion', () async {
      final model = RegionModel(
        id: '3',
        name: 'Test 3',
        description: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      await regionService.addRegion(model);

      final result = await mockSupabase.from('regions').select();

      expect(result.length, 1);
      expect(result.first['name'], 'Test 3');
    });
    test('getRegion', () async {
      final model = RegionModel(
        id: '4',
        name: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        isActive: true,
      );

      await regionService.addRegion(model);

      final result = await regionService.getRegion('4');

      expect(result.id, '4');
      expect(result.name, 'Test 4');
    });
    test('updateRegion', () async {
      final model = RegionModel(
        id: '4',
        name: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        isActive: true,
      );

      await regionService.addRegion(model);

      final updateCategory = model.copyWith(name: 'Test update 4');

      await regionService.updateRegion(updateCategory, false);

      final result = await regionService.getRegion(model.id);

      expect(result.id, '4');
      expect(result.name, 'Test update 4');
    });
    test('deleteRegion', () async {
      final model = RegionModel(
        id: '5',
        name: 'Test 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
        isActive: true,
      );

      await regionService.addRegion(model);

      await regionService.deleteRegion(model.id);

      await expectLater(
        () => regionService.getRegion(model.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
