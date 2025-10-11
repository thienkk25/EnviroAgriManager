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
    final rows = await select(regionTable).get();
    return rows.map(_mapToModel).toList();
  }

  Future<RegionModel?> getRegionById(String id) async {
    final row = await (select(
      regionTable,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<List<RegionModel>> getSubRegions(String? parentId) async {
    final rows = await (select(
      regionTable,
    )..where((r) => r.parentId.equals(parentId!))).get();
    return rows.map(_mapToModel).toList();
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
  Future<void> syncFromSupabase(List<Map<String, dynamic>> remoteData) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        regionTable,
        remoteData.map((data) {
          return RegionTableCompanion(
            id: Value(data['id']),
            name: Value(data['name']),
            description: Value(data['description']),
            parentId: Value(data['parent_id']),
            isActive: Value(data['is_active'] ?? true),
            createdAt: Value(DateTime.parse(data['created_at'])),
            updatedAt: Value(DateTime.parse(data['updated_at'])),
          );
        }).toList(),
      );
    });
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
