import 'package:drift/drift.dart';
import 'package:enviro_agri_manager/local/drift/tables/category_table.dart';

class ProductTable extends Table {
  // Khóa chính
  TextColumn get id => text()();

  // Tên sản phẩm
  TextColumn get name => text()();

  // Mô tả sản phẩm (có thể null)
  TextColumn get description => text().nullable()();

  // Liên kết đến danh mục (foreign key)
  TextColumn get categoryId =>
      text().references(CategoryTable, #id, onDelete: KeyAction.cascade)();

  // Giá
  RealColumn get price => real().withDefault(const Constant(0.0))();

  // Số lượng
  IntColumn get quantity => integer().withDefault(const Constant(0))();

  // Đơn vị (vd: kg, lít, cây)
  TextColumn get unit => text().withDefault(const Constant(''))();

  // Ảnh sản phẩm (có thể null)
  TextColumn get imageUrl => text().nullable()();

  // Trạng thái (vd: active, inactive, sold_out)
  TextColumn get status => text().withDefault(const Constant('active'))();

  // Thời gian tạo và cập nhật
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Đồng bộ
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Khóa chính
  @override
  Set<Column> get primaryKey => {id};
}
