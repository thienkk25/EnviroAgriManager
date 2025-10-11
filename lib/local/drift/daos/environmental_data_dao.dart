import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/tables/environmental_data_table.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';

part 'environmental_data_dao.g.dart';

@DriftAccessor(tables: [EnvironmentalDataTable])
class EnvironmentalDataDao extends DatabaseAccessor<AppDatabase>
    with _$EnvironmentalDataDaoMixin {
  EnvironmentalDataDao(super.db);

  Future<void> insertData(EnvironmentalDataModel model) async {
    await into(environmentalDataTable).insertOnConflictUpdate(
      EnvironmentalDataTableCompanion(
        id: Value(model.id),
        regionId: Value(model.regionId),
        location: Value(model.location),
        temperature: Value(model.temperature),
        humidity: Value(model.humidity),
        ph: Value(model.ph),
        soilMoisture: Value(model.soilMoisture),
        lightIntensity: Value(model.lightIntensity),
        co2Level: Value(model.co2Level),
        nitrogen: Value(model.nitrogen),
        phosphorus: Value(model.phosphorus),
        potassium: Value(model.potassium),
        weatherCondition: Value(model.weatherCondition),
        notes: Value(model.notes),
        recordedAt: Value(model.recordedAt),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
      ),
    );
  }

  Future<List<EnvironmentalDataModel>> getAll() async {
    final rows = await select(environmentalDataTable).get();
    return rows.map(_mapToModel).toList();
  }

  Future<EnvironmentalDataModel?> getById(String id) async {
    final row = await (select(
      environmentalDataTable,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<bool> updateData(EnvironmentalDataModel model) async {
    return update(environmentalDataTable).replace(
      EnvironmentalDataTableCompanion(
        id: Value(model.id),
        regionId: Value(model.regionId),
        location: Value(model.location),
        temperature: Value(model.temperature),
        humidity: Value(model.humidity),
        ph: Value(model.ph),
        soilMoisture: Value(model.soilMoisture),
        lightIntensity: Value(model.lightIntensity),
        co2Level: Value(model.co2Level),
        nitrogen: Value(model.nitrogen),
        phosphorus: Value(model.phosphorus),
        potassium: Value(model.potassium),
        weatherCondition: Value(model.weatherCondition),
        notes: Value(model.notes),
        recordedAt: Value(model.recordedAt),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
      ),
    );
  }

  Future<int> deleteData(String id) async {
    return (delete(environmentalDataTable)..where((e) => e.id.equals(id))).go();
  }

  Future<void> syncFromSupabase(List<Map<String, dynamic>> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        environmentalDataTable,
        remoteData.map((data) {
          return EnvironmentalDataTableCompanion(
            id: Value(data['id']),
            regionId: Value(data['region_id']),
            location: Value(data['location']),
            temperature: Value((data['temperature'] ?? 0).toDouble()),
            humidity: Value((data['humidity'] ?? 0).toDouble()),
            ph: Value((data['ph'] ?? 0).toDouble()),
            soilMoisture: Value((data['soil_moisture'] ?? 0).toDouble()),
            lightIntensity: Value((data['light_intensity'] ?? 0).toDouble()),
            co2Level: Value((data['co2_level'] ?? 0).toDouble()),
            nitrogen: Value((data['nitrogen'] ?? 0).toDouble()),
            phosphorus: Value((data['phosphorus'] ?? 0).toDouble()),
            potassium: Value((data['potassium'] ?? 0).toDouble()),
            weatherCondition: Value(data['weather_condition']),
            notes: Value(data['notes']),
            recordedAt: Value(DateTime.parse(data['recorded_at'])),
            createdAt: Value(DateTime.parse(data['created_at'])),
            updatedAt: Value(DateTime.parse(data['updated_at'])),
          );
        }).toList(),
      );
    });
  }

  EnvironmentalDataModel _mapToModel(EnvironmentalDataTableData row) =>
      EnvironmentalDataModel(
        id: row.id,
        regionId: row.regionId,
        location: row.location,
        temperature: row.temperature,
        humidity: row.humidity,
        ph: row.ph,
        soilMoisture: row.soilMoisture,
        lightIntensity: row.lightIntensity,
        co2Level: row.co2Level,
        nitrogen: row.nitrogen,
        phosphorus: row.phosphorus,
        potassium: row.potassium,
        weatherCondition: row.weatherCondition,
        notes: row.notes,
        recordedAt: row.recordedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
