import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/tables/region_table.dart';

class EnvironmentalDataTable extends Table {
  // ID chính (UUID hoặc String)
  TextColumn get id => text()();

  // Liên kết đến Region (foreign key)
  TextColumn get regionId =>
      text().references(RegionTable, #id, onDelete: KeyAction.cascade)();

  // Vị trí cụ thể (nếu có)
  TextColumn get location => text().nullable()();

  // Các chỉ số cảm biến (nullable)
  RealColumn get temperature => real().nullable()();
  RealColumn get humidity => real().nullable()();
  RealColumn get ph => real().nullable()();
  RealColumn get soilMoisture => real().nullable()();
  RealColumn get lightIntensity => real().nullable()();
  RealColumn get co2Level => real().nullable()();
  RealColumn get nitrogen => real().nullable()();
  RealColumn get phosphorus => real().nullable()();
  RealColumn get potassium => real().nullable()();

  // Thông tin thêm
  TextColumn get weatherCondition => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Thời gian ghi nhận dữ liệu
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  // Thời gian tạo & cập nhật
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Đồng bộ
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingDelete =>
      boolean().withDefault(const Constant(false))();

  // Khóa chính
  @override
  Set<Column> get primaryKey => {id};
}
