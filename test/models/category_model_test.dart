import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    final now = DateTime.now();

    final mockJson = {
      'id': '123',
      'name': 'Cây trồng',
      'description': 'Danh mục các loại cây trồng',
      'icon': '🌾',
      'color': '#4CAF50',
      'parent_id': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_active': true,
    };

    test('fromJson() chuyển JSON sang model chính xác', () {
      final model = CategoryModel.fromJson(mockJson);

      expect(model, isA<CategoryModel>());
      expect(model.id, '123');
      expect(model.name, 'Cây trồng');
      expect(model.description, 'Danh mục các loại cây trồng');
      expect(model.icon, '🌾');
      expect(model.color, '#4CAF50');
      expect(model.parentId, isNull);
      expect(model.isActive, isTrue);
      expect(model.createdAt, isA<DateTime>());
      expect(model.updatedAt, isA<DateTime>());
    });

    test('fromJson() xử lý parent_id là chuỗi rỗng', () {
      final json = {...mockJson, 'parent_id': ''};
      final model = CategoryModel.fromJson(json);
      expect(model.parentId, isNull);
    });

    test('toJson() chuyển model sang JSON chính xác', () {
      final model = CategoryModel(
        id: '123',
        name: 'Cây trồng',
        description: 'Danh mục các loại cây trồng',
        icon: '🌾',
        color: '#4CAF50',
        parentId: null,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Cây trồng');
      expect(json['icon'], '🌾');
      expect(json['color'], '#4CAF50');
      expect(json['parent_id'], isNull);
      expect(json['is_active'], isTrue);
    });

    test('copyWith() tạo bản sao chính xác', () {
      final model = CategoryModel.fromJson(mockJson);
      final copy = model.copyWith(name: 'Cây công nghiệp', isActive: false);

      expect(copy.id, model.id);
      expect(copy.name, 'Cây công nghiệp');
      expect(copy.isActive, isFalse);
      expect(copy.createdAt, model.createdAt);
    });

    test('isActive mặc định là true khi không truyền vào', () {
      final model = CategoryModel(
        id: '1',
        name: 'Thực phẩm',
        description: 'Mô tả',
        icon: '🥦',
        color: '#00FF00',
        createdAt: now,
        updatedAt: now,
      );

      expect(model.isActive, isTrue);
    });
  });
}
