import 'package:drift/drift.dart';

class CategoryTable extends Table {
  // ID chính (UUID hoặc String)
  TextColumn get id => text()();

  // Tên danh mục
  TextColumn get name => text()();

  // Mô tả (có thể null)
  TextColumn get description => text().nullable()();

  // Biểu tượng
  TextColumn get icon => text().withDefault(const Constant('🌱'))();

  // Màu sắc
  TextColumn get color => text().withDefault(const Constant('#4CAF50'))();

  // ID danh mục cha (nullable)
  TextColumn get parentId => text().nullable()();

  // Thời gian tạo
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Thời gian cập nhật
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Trạng thái hoạt động
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Kiểm tra đồng bộ chưa
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // Kiểm tra xóa
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Khóa chính
  @override
  Set<Column> get primaryKey => {id};
}
