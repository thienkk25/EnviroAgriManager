import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';

void main() {
  group('EnvironmentalDataModel', () {
    final now = DateTime.parse('2025-10-19T08:00:00Z');

    final mockJson = {
      'id': 'env_001',
      'region_id': 'reg_001',
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
      'recorded_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson() - chuyển đổi đúng từ JSON sang model', () {
      final data = EnvironmentalDataModel.fromJson(mockJson);

      expect(data.id, 'env_001');
      expect(data.regionId, 'reg_001');
      expect(data.location, 'Cần Thơ');
      expect(data.temperature, 29.3);
      expect(data.humidity, 76.5);
      expect(data.ph, 6.2);
      expect(data.soilMoisture, 40.1);
      expect(data.lightIntensity, 800.0);
      expect(data.co2Level, 380.0);
      expect(data.nitrogen, 12.0);
      expect(data.phosphorus, 6.0);
      expect(data.potassium, 9.5);
      expect(data.weatherCondition, 'Nắng nhẹ');
      expect(data.notes, 'Độ ẩm cao buổi sáng');
      expect(data.recordedAt, isA<DateTime>());
      expect(data.createdAt, isA<DateTime>());
      expect(data.updatedAt, isA<DateTime>());
    });

    test('toJson() - trả về JSON đúng', () {
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

      final json = model.toJson();

      expect(json['id'], 'env_001');
      expect(json['region_id'], 'reg_001');
      expect(json['location'], 'Cần Thơ');
      expect(json['temperature'], 29.3);
      expect(json['humidity'], 76.5);
      expect(json['ph'], 6.2);
      expect(json['soil_moisture'], 40.1);
      expect(json['light_intensity'], 800.0);
      expect(json['co2_level'], 380.0);
      expect(json['nitrogen'], 12.0);
      expect(json['phosphorus'], 6.0);
      expect(json['potassium'], 9.5);
      expect(json['weather_condition'], 'Nắng nhẹ');
      expect(json['notes'], 'Độ ẩm cao buổi sáng');
      expect(json['recorded_at'], now.toIso8601String());
      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('copyWith() - tạo bản sao đúng với thay đổi mới', () {
      final model = EnvironmentalDataModel.fromJson(mockJson);
      final updated = model.copyWith(
        temperature: 31.2,
        humidity: 70.0,
        weatherCondition: 'Nhiều mây',
      );

      expect(updated.temperature, 31.2);
      expect(updated.humidity, 70.0);
      expect(updated.weatherCondition, 'Nhiều mây');
      expect(updated.id, model.id);
      expect(updated.regionId, model.regionId);
    });
  });
}
