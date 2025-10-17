import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter/foundation.dart';

class RegionRepository {
  final AppDatabase? _db;
  final RegionService _regionService;

  RegionRepository(this._db, this._regionService);

  Future<List<RegionModel>> syncRegions({required bool isOnline}) async {
    if (kIsWeb) {
      return await _regionService.fetchRegions();
    } else {
      if (isOnline) {
        try {
          final localNewData = await _db!.regionDao.getUnsyncedRegions();

          if (localNewData.isNotEmpty) {
            await _regionService.uploadRegions(localNewData);

            await _db.regionDao.markAsSynced(
              localNewData.map((e) => e.id).toList(),
            );
          }

          final deletedData = await _db.regionDao.getDeletedUnsyncedRegions();
          if (deletedData.isNotEmpty) {
            final futures = deletedData
                .map((e) async => await delete(e.id, isOnline: isOnline))
                .toList();
            await Future.wait(futures);
          }

          final remoteData = await _regionService.fetchRegions();
          await _db.regionDao.syncFromSupabase(remoteData);

          return remoteData;
        } catch (e) {
          return await _db!.regionDao.getAllRegions();
        }
      } else {
        return await _db!.regionDao.getAllRegions();
      }
    }
  }

  Future<void> add(RegionModel region, {required bool isOnline}) async {
    if (kIsWeb) {
      await _regionService.addRegion(region);
    } else {
      if (isOnline) {
        try {
          await _regionService.addRegion(region);
          await _db!.regionDao.insertRegion(region);
        } catch (e) {
          await _db!.regionDao.insertOrUpdateRegion(
            RegionTableCompanion(
              id: Value(region.id),
              name: Value(region.name),
              description: Value(region.description),
              parentId: Value(region.parentId),
              isActive: Value(region.isActive),
              createdAt: Value(region.createdAt),
              updatedAt: Value(region.updatedAt),
              isSynced: Value(false),
            ),
          );
          rethrow;
        }
      } else {
        await _db!.regionDao.insertOrUpdateRegion(
          RegionTableCompanion(
            id: Value(region.id),
            name: Value(region.name),
            description: Value(region.description),
            parentId: Value(region.parentId),
            isActive: Value(region.isActive),
            createdAt: Value(region.createdAt),
            updatedAt: Value(region.updatedAt),
            isSynced: Value(false),
          ),
        );
      }
    }
  }

  Future<void> update(
    RegionModel region,
    bool level, {
    required bool isOnline,
  }) async {
    if (kIsWeb) {
      await _regionService.updateRegion(region, level);
    } else {
      if (isOnline) {
        try {
          await _regionService.updateRegion(region, level);
          await _db!.regionDao.updateRegion(region);
        } catch (e) {
          await _db!.regionDao.insertOrUpdateRegion(
            RegionTableCompanion(
              id: Value(region.id),
              name: Value(region.name),
              description: Value(region.description),
              parentId: Value(region.parentId),
              isActive: Value(region.isActive),
              createdAt: Value(region.createdAt),
              updatedAt: Value(region.updatedAt),
              isSynced: Value(false),
            ),
          );
          rethrow;
        }
      } else {
        await _db!.regionDao.insertOrUpdateRegion(
          RegionTableCompanion(
            id: Value(region.id),
            name: Value(region.name),
            description: Value(region.description),
            parentId: Value(region.parentId),
            isActive: Value(region.isActive),
            createdAt: Value(region.createdAt),
            updatedAt: Value(region.updatedAt),
            isSynced: Value(false),
          ),
        );
      }
    }
  }

  Future<void> delete(String id, {required bool isOnline}) async {
    if (kIsWeb) {
      await _regionService.deleteRegion(id);
    } else {
      if (isOnline) {
        try {
          await _regionService.deleteRegion(id);
          await _db!.regionDao.deleteRegion(id);
        } catch (e) {
          if (e.toString().contains(
                'Không thể xóa vị trí đang có dữ liệu môi trường phụ thuộc',
              ) ||
              e.toString().contains('Không thể')) {
            await _db!.regionDao.restoreRegion(id);
          } else {
            await _db!.regionDao.markRegionAsDeleted(id);
          }
          rethrow;
        }
      } else {
        await _db!.regionDao.markRegionAsDeleted(id);
      }
    }
  }
}
