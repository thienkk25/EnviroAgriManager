import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';

class EnvironmentalDataRepository {
  final AppDatabase _db;
  final EnvironmentalDataService _environmentalDataService;

  EnvironmentalDataRepository(this._db, this._environmentalDataService);

  Future<List<EnvironmentalDataModel>> syncEnvironmentalData({
    required bool isOnline,
  }) async {
    if (isOnline) {
      try {
        final localNewData = await _db.environmentalDataDao
            .getUnsyncedEnvironmentalData();

        if (localNewData.isNotEmpty) {
          await _environmentalDataService.uploadEnvironmentalData(localNewData);

          await _db.environmentalDataDao.markAsSynced(
            localNewData.map((e) => e.id).toList(),
          );
        }

        final deletedData = await _db.environmentalDataDao
            .getDeletedUnsyncedEnvironmentalData();
        if (deletedData.isNotEmpty) {
          for (var environmentalData in deletedData) {
            await delete(environmentalData.id, isOnline: isOnline);
          }
        }

        final remoteData = await _environmentalDataService
            .fetchEnvironmentalData();
        await _db.environmentalDataDao.syncFromSupabase(remoteData);

        return remoteData;
      } catch (e) {
        return await _db.environmentalDataDao.getAll();
      }
    } else {
      return await _db.environmentalDataDao.getAll();
    }
  }

  Future<void> add(
    EnvironmentalDataModel environmentalData, {
    required bool isOnline,
  }) async {
    if (isOnline) {
      try {
        await _environmentalDataService.addEnvironmentalData(environmentalData);
        await _db.environmentalDataDao.insertData(environmentalData);
      } catch (e) {
        await _db.environmentalDataDao.insertOrUpdateEnvironmentalData(
          EnvironmentalDataTableCompanion(
            id: Value(environmentalData.id),
            regionId: Value(environmentalData.regionId),
            location: Value(environmentalData.location),
            temperature: Value(environmentalData.temperature),
            humidity: Value(environmentalData.humidity),
            ph: Value(environmentalData.ph),
            soilMoisture: Value(environmentalData.soilMoisture),
            lightIntensity: Value(environmentalData.lightIntensity),
            co2Level: Value(environmentalData.co2Level),
            nitrogen: Value(environmentalData.nitrogen),
            phosphorus: Value(environmentalData.phosphorus),
            potassium: Value(environmentalData.potassium),
            weatherCondition: Value(environmentalData.weatherCondition),
            notes: Value(environmentalData.notes),
            recordedAt: Value(environmentalData.recordedAt),
            createdAt: Value(environmentalData.createdAt),
            updatedAt: Value(environmentalData.updatedAt),
            isSynced: Value(false),
          ),
        );
        rethrow;
      }
    } else {
      await _db.environmentalDataDao.insertOrUpdateEnvironmentalData(
        EnvironmentalDataTableCompanion(
          id: Value(environmentalData.id),
          regionId: Value(environmentalData.regionId),
          location: Value(environmentalData.location),
          temperature: Value(environmentalData.temperature),
          humidity: Value(environmentalData.humidity),
          ph: Value(environmentalData.ph),
          soilMoisture: Value(environmentalData.soilMoisture),
          lightIntensity: Value(environmentalData.lightIntensity),
          co2Level: Value(environmentalData.co2Level),
          nitrogen: Value(environmentalData.nitrogen),
          phosphorus: Value(environmentalData.phosphorus),
          potassium: Value(environmentalData.potassium),
          weatherCondition: Value(environmentalData.weatherCondition),
          notes: Value(environmentalData.notes),
          recordedAt: Value(environmentalData.recordedAt),
          createdAt: Value(environmentalData.createdAt),
          updatedAt: Value(environmentalData.updatedAt),
          isSynced: Value(false),
        ),
      );
    }
  }

  Future<void> update(
    EnvironmentalDataModel environmentalData, {
    required bool isOnline,
  }) async {
    if (isOnline) {
      try {
        await _environmentalDataService.updateEnvironmentalData(
          environmentalData,
        );
        await _db.environmentalDataDao.updateData(environmentalData);
      } catch (e) {
        await _db.environmentalDataDao.insertOrUpdateEnvironmentalData(
          EnvironmentalDataTableCompanion(
            id: Value(environmentalData.id),
            regionId: Value(environmentalData.regionId),
            location: Value(environmentalData.location),
            temperature: Value(environmentalData.temperature),
            humidity: Value(environmentalData.humidity),
            ph: Value(environmentalData.ph),
            soilMoisture: Value(environmentalData.soilMoisture),
            lightIntensity: Value(environmentalData.lightIntensity),
            co2Level: Value(environmentalData.co2Level),
            nitrogen: Value(environmentalData.nitrogen),
            phosphorus: Value(environmentalData.phosphorus),
            potassium: Value(environmentalData.potassium),
            weatherCondition: Value(environmentalData.weatherCondition),
            notes: Value(environmentalData.notes),
            recordedAt: Value(environmentalData.recordedAt),
            createdAt: Value(environmentalData.createdAt),
            updatedAt: Value(environmentalData.updatedAt),
            isSynced: Value(false),
          ),
        );
        rethrow;
      }
    } else {
      await _db.environmentalDataDao.insertOrUpdateEnvironmentalData(
        EnvironmentalDataTableCompanion(
          id: Value(environmentalData.id),
          regionId: Value(environmentalData.regionId),
          location: Value(environmentalData.location),
          temperature: Value(environmentalData.temperature),
          humidity: Value(environmentalData.humidity),
          ph: Value(environmentalData.ph),
          soilMoisture: Value(environmentalData.soilMoisture),
          lightIntensity: Value(environmentalData.lightIntensity),
          co2Level: Value(environmentalData.co2Level),
          nitrogen: Value(environmentalData.nitrogen),
          phosphorus: Value(environmentalData.phosphorus),
          potassium: Value(environmentalData.potassium),
          weatherCondition: Value(environmentalData.weatherCondition),
          notes: Value(environmentalData.notes),
          recordedAt: Value(environmentalData.recordedAt),
          createdAt: Value(environmentalData.createdAt),
          updatedAt: Value(environmentalData.updatedAt),
          isSynced: Value(false),
        ),
      );
    }
  }

  Future<void> delete(String id, {required bool isOnline}) async {
    if (isOnline) {
      try {
        await _environmentalDataService.deleteEnvironmentalData(id);
        await _db.environmentalDataDao.deleteData(id);
      } catch (e) {
        await _db.environmentalDataDao.markEnvironmentDataAsDeleted(id);
        rethrow;
      }
    } else {
      await _db.environmentalDataDao.markEnvironmentDataAsDeleted(id);
    }
  }
}
