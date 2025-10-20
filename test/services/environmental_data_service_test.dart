import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late EnvironmentalDataService environmentalDataService;

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
    environmentalDataService = EnvironmentalDataService();
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('environmentalDataService', () {
    test('fetchCategories', () async {
      await mockSupabase.from('environmental_data').insert([
        {
          'id': '1',
          'region_id': '1',
          'location': 'Cần Thơ',
          'temperature': 29.3,
          'humidity': 76.5,
          'ph': 6.2,
          'soil_moisture': 40.1,
          'light_intensity': 800.0,
          'co2_level': 380.0,
          'nitrogen': 12.0,
          'phosphorus': 6.0,
          'potassium': 9.5,
          'weather_condition': 'Nắng nhẹ',
          'notes': 'Độ ẩm cao buổi sáng',
          'recorded_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'region_id': '2',
          'location': 'Hà Nội',
          'temperature': 29.3,
          'humidity': 76.5,
          'ph': 6.2,
          'soil_moisture': 40.1,
          'light_intensity': 800.0,
          'co2_level': 380.0,
          'nitrogen': 12.0,
          'phosphorus': 6.0,
          'potassium': 9.5,
          'weather_condition': 'Nắng nhẹ',
          'notes': 'Độ ẩm cao buổi sáng',
          'recorded_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      final result = await environmentalDataService.fetchEnvironmentalData();

      expect(result.length, 2);
      expect(result.first.location, 'Cần Thơ');
      expect(result.last.temperature, 29.3);
    });

    test('addEnvironmentalData', () async {
      final model = EnvironmentalDataModel(
        id: '3',
        location: 'Test 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        regionId: '',
        recordedAt: DateTime.now(),
      );

      await environmentalDataService.addEnvironmentalData(model);

      final result = await mockSupabase.from('environmental_data').select();

      expect(result.length, 1);
      expect(result.first['location'], 'Test 3');
    });
    test('getEnvironmentalData', () async {
      final model = EnvironmentalDataModel(
        id: '4',
        location: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        regionId: '',
        recordedAt: DateTime.now(),
      );

      await environmentalDataService.addEnvironmentalData(model);

      final result = await environmentalDataService.getEnvironmentalData('4');

      expect(result.id, '4');
      expect(result.location, 'Test 4');
    });
    test('updateEnvironmentalData', () async {
      final model = EnvironmentalDataModel(
        id: '4',
        location: 'Test 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        regionId: '',
        recordedAt: DateTime.now(),
      );

      await environmentalDataService.addEnvironmentalData(model);

      final updateCategory = model.copyWith(location: 'Test update 4');

      await environmentalDataService.updateEnvironmentalData(updateCategory);

      final result = await environmentalDataService.getEnvironmentalData(
        model.id,
      );

      expect(result.id, '4');
      expect(result.location, 'Test update 4');
    });
    test('deleteEnvironmentalData', () async {
      final model = EnvironmentalDataModel(
        id: '5',
        location: 'Test 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        regionId: '',
        recordedAt: DateTime.now(),
      );

      await environmentalDataService.addEnvironmentalData(model);

      await environmentalDataService.deleteEnvironmentalData(model.id);

      await expectLater(
        () => environmentalDataService.getEnvironmentalData(model.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
