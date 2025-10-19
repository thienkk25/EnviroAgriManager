import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/models/region_model.dart';

void main() {
  group('RegionModel', () {
    final now = DateTime.now();

    final region = RegionModel(
      id: '1',
      name: 'Đà Lạt',
      description: 'Thành phố hoa',
      parentId: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    test('Tạo đối tượng RegionModel hợp lệ', () {
      expect(region.id, '1');
      expect(region.name, 'Đà Lạt');
      expect(region.description, 'Thành phố hoa');
      expect(region.parentId, isNull);
      expect(region.isActive, isTrue);
      expect(region.createdAt, isA<DateTime>());
    });

    test('Chuyển đổi sang JSON đúng định dạng', () {
      final json = region.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Đà Lạt');
      expect(json['is_active'], true);
      expect(json['created_at'], isA<String>());
    });

    test('Khởi tạo từ JSON đúng dữ liệu', () {
      final json = {
        'id': '2',
        'name': 'Hà Nội',
        'description': 'Thủ đô',
        'parent_id': null,
        'is_active': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final fromJson = RegionModel.fromJson(json);
      expect(fromJson.id, '2');
      expect(fromJson.name, 'Hà Nội');
      expect(fromJson.isActive, false);
    });

    test('copyWith cập nhật đúng giá trị mới', () {
      final updated = region.copyWith(name: 'Lâm Đồng', isActive: false);
      expect(updated.name, 'Lâm Đồng');
      expect(updated.isActive, false);
      expect(updated.id, region.id); // giữ nguyên id
    });
  });
}
