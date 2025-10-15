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
    final rows = await (select(
      environmentalDataTable,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<List<EnvironmentalDataModel>> getUnsyncedEnvironmentalData() async {
    final rows = await (select(
      environmentalDataTable,
    )..where((t) => t.isSynced.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> insertOrUpdateEnvironmentalData(
    EnvironmentalDataTableCompanion entry,
  ) {
    return into(
      environmentalDataTable,
    ).insertOnConflictUpdate(entry.copyWith(isSynced: Value(false)));
  }

  Future<void> markAsSynced(List<String> ids) {
    return (update(environmentalDataTable)..where((t) => t.id.isIn(ids))).write(
      EnvironmentalDataTableCompanion(isSynced: Value(true)),
    );
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

  Future<void> syncFromSupabase(List<EnvironmentalDataModel> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        environmentalDataTable,
        remoteData.map((data) {
          return EnvironmentalDataTableCompanion(
            id: Value(data.id),
            regionId: Value(data.regionId),
            location: Value(data.location),
            temperature: Value(data.temperature),
            humidity: Value(data.humidity),
            ph: Value(data.ph),
            soilMoisture: Value(data.soilMoisture),
            lightIntensity: Value(data.lightIntensity),
            co2Level: Value(data.co2Level),
            nitrogen: Value(data.nitrogen),
            phosphorus: Value(data.phosphorus),
            potassium: Value(data.potassium),
            weatherCondition: Value(data.weatherCondition),
            notes: Value(data.notes),
            recordedAt: Value(data.recordedAt),
            createdAt: Value(data.createdAt),
            updatedAt: Value(data.updatedAt),
          );
        }).toList(),
      );
    });
  }

  Future<void> markEnvironmentDataAsDeleted(String id) async {
    await (update(environmentalDataTable)..where((t) => t.id.equals(id))).write(
      EnvironmentalDataTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(true),
        pendingDelete: const Value(true),
      ),
    );
  }

  Future<void> restoreEnvironmentData(String id) async {
    await (update(environmentalDataTable)..where((t) => t.id.equals(id))).write(
      EnvironmentalDataTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(false),
        pendingDelete: const Value(false),
      ),
    );
  }

  Future<List<EnvironmentalDataModel>>
  getDeletedUnsyncedEnvironmentalData() async {
    final rows =
        await (select(environmentalDataTable)..where(
              (t) => t.isDeleted.equals(true) & t.isSynced
                ..equals(false),
            ))
            .get();
    return rows.map(_mapToModel).toList();
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
