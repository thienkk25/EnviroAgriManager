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

// Conditional import
import 'database_stub.dart'
    if (dart.library.io) 'package:drift/native.dart'
    hide DriftNativeOptions;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CategoryTable, EnvironmentalDataTable, RegionTable, ProductTable],
  daos: [CategoryDao, EnvironmentalDataDao, RegionDao, ProductDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Dùng cho unit test - nhận QueryExecutor trực tiếp
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'app_database', native: DriftNativeOptions());
}

// Helper method để tạo database cho testing (không cần Flutter binding)
QueryExecutor openTestConnection() {
  if (_isWeb) {
    // Trên web, sử dụng in-memory database không cần binding
    return driftDatabase(name: 'test_db', native: null);
  } else {
    // Trên native, sử dụng NativeDatabase.memory() trực tiếp
    return NativeDatabase.memory();
  }
}

bool get _isWeb => identical(0, 0.0);
