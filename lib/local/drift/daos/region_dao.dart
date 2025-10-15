import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/local/drift/tables/region_table.dart';
import 'package:enviro_agri_manager/models/region_model.dart';

part 'region_dao.g.dart';

@DriftAccessor(tables: [RegionTable])
class RegionDao extends DatabaseAccessor<AppDatabase> with _$RegionDaoMixin {
  RegionDao(super.db);

  // --- CREATE ---
  Future<void> insertRegion(RegionModel model) async {
    await into(regionTable).insertOnConflictUpdate(
      RegionTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        parentId: Value(model.parentId),
        isActive: Value(model.isActive),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
      ),
    );
  }

  // --- READ ---
  Future<List<RegionModel>> getAllRegions() async {
    final rows = await (select(
      regionTable,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<List<RegionModel>> getUnsyncedRegions() async {
    final rows = await (select(
      regionTable,
    )..where((t) => t.isSynced.equals(false))).get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> insertOrUpdateRegion(RegionTableCompanion entry) {
    return into(
      regionTable,
    ).insertOnConflictUpdate(entry.copyWith(isSynced: Value(false)));
  }

  Future<void> markAsSynced(List<String> ids) {
    return (update(regionTable)..where((t) => t.id.isIn(ids))).write(
      RegionTableCompanion(isSynced: Value(true)),
    );
  }

  // --- UPDATE ---
  Future<bool> updateRegion(RegionModel model) async {
    return update(regionTable).replace(
      RegionTableCompanion(
        id: Value(model.id),
        name: Value(model.name),
        description: Value(model.description),
        parentId: Value(model.parentId),
        isActive: Value(model.isActive),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
      ),
    );
  }

  // --- DELETE ---
  Future<int> deleteRegion(String id) async {
    return (delete(regionTable)..where((r) => r.id.equals(id))).go();
  }

  // --- SYNC (Supabase → Local) ---
  Future<void> syncFromSupabase(List<RegionModel> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        regionTable,
        remoteData.map((r) {
          return RegionTableCompanion(
            id: Value(r.id),
            name: Value(r.name),
            description: Value(r.description),
            parentId: Value(r.parentId),
            isActive: Value(r.isActive),
            createdAt: Value(r.createdAt),
            updatedAt: Value(r.updatedAt),
          );
        }).toList(),
      );
    });
  }

  Future<void> markRegionAsDeleted(String id) async {
    await (update(regionTable)..where((t) => t.id.equals(id))).write(
      RegionTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(true),
        pendingDelete: const Value(true),
      ),
    );
  }

  Future<void> restoreRegion(String id) async {
    await (update(regionTable)..where((t) => t.id.equals(id))).write(
      RegionTableCompanion(
        isSynced: const Value(false),
        isDeleted: const Value(false),
        pendingDelete: const Value(false),
      ),
    );
  }

  Future<List<RegionModel>> getDeletedUnsyncedRegions() async {
    final rows =
        await (select(regionTable)..where(
              (t) => t.isDeleted.equals(true) & t.isSynced
                ..equals(false),
            ))
            .get();
    return rows.map(_mapToModel).toList();
  }

  // --- Helper mapping ---
  RegionModel _mapToModel(RegionTableData row) => RegionModel(
    id: row.id,
    name: row.name,
    description: row.description ?? '',
    parentId: row.parentId,
    isActive: row.isActive,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
