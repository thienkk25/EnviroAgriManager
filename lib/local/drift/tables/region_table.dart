import 'package:drift/drift.dart';

class RegionTable extends Table {
  // Khóa chính
  TextColumn get id => text()();

  // Tên vùng hoặc khu vực
  TextColumn get name => text()();

  // Mô tả
  TextColumn get description => text().nullable()();

  // ID vùng cha (nullable, cho phép phân cấp)
  TextColumn get parentId => text().nullable()();

  // Trạng thái hoạt động
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Thời gian tạo và cập nhật
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Đặt khóa chính
  @override
  Set<Column> get primaryKey => {id};
}
