import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class DriftNativeOptions {
  const DriftNativeOptions();
}

class NativeDatabase {
  static QueryExecutor memory() {
    // Trên web, fallback về database thông thường
    return driftDatabase(name: 'memory_test_db', native: null);
  }
}
