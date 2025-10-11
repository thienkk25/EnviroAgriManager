import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:enviro_agri_manager/local/drift/daos/category_dao.dart';
import 'package:enviro_agri_manager/local/drift/daos/environmental_data_dao.dart';
import 'package:enviro_agri_manager/local/drift/daos/product_dao.dart';
import 'package:enviro_agri_manager/local/drift/daos/region_dao.dart';
import 'package:enviro_agri_manager/local/drift/tables/category_table.dart';
import 'package:enviro_agri_manager/local/drift/tables/environmental_data_table.dart';
import 'package:enviro_agri_manager/local/drift/tables/product_table.dart';
import 'package:enviro_agri_manager/local/drift/tables/region_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CategoryTable, EnvironmentalDataTable, RegionTable, ProductTable],
  daos: [CategoryDao, EnvironmentalDataDao, RegionDao, ProductDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'app_database',
    native: DriftNativeOptions(shareAcrossIsolates: true),
  );
}
