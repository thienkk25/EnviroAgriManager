import 'package:flutter_test/flutter_test.dart';
import 'package:enviro_agri_manager/models/product_model.dart';

void main() {
  group('ProductModel', () {
    final now = DateTime.parse('2025-10-19T08:00:00Z');

    final mockJson = {
      'id': 'prd_001',
      'name': 'Phân bón hữu cơ sinh học',
      'description': 'Phân bón giúp cải thiện độ phì nhiêu của đất',
      'category_id': 'cat_001',
      'price': 150000.0,
      'quantity': 50,
      'unit': 'kg',
      'image_url': 'https://example.com/images/product1.jpg',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'status': 'active',
    };

    test('fromJson() - parse JSON đúng sang model', () {
      final product = ProductModel.fromJson(mockJson);

      expect(product.id, 'prd_001');
      expect(product.name, 'Phân bón hữu cơ sinh học');
      expect(
        product.description,
        'Phân bón giúp cải thiện độ phì nhiêu của đất',
      );
      expect(product.categoryId, 'cat_001');
      expect(product.price, 150000.0);
      expect(product.quantity, 50);
      expect(product.unit, 'kg');
      expect(product.imageUrl, 'https://example.com/images/product1.jpg');
      expect(product.createdAt, isA<DateTime>());
      expect(product.updatedAt, isA<DateTime>());
      expect(product.status, 'active');
    });

    test('toJson() - chuyển ngược về JSON đúng', () {
      final product = ProductModel(
        id: 'prd_001',
        name: 'Phân bón hữu cơ sinh học',
        description: 'Phân bón giúp cải thiện độ phì nhiêu của đất',
        categoryId: 'cat_001',
        price: 150000.0,
        quantity: 50,
        unit: 'kg',
        imageUrl: 'https://example.com/images/product1.jpg',
        createdAt: now,
        updatedAt: now,
        status: 'active',
      );

      final json = product.toJson();

      expect(json['id'], 'prd_001');
      expect(json['name'], 'Phân bón hữu cơ sinh học');
      expect(
        json['description'],
        'Phân bón giúp cải thiện độ phì nhiêu của đất',
      );
      expect(json['category_id'], 'cat_001');
      expect(json['price'], 150000.0);
      expect(json['quantity'], 50);
      expect(json['unit'], 'kg');
      expect(json['image_url'], 'https://example.com/images/product1.jpg');
      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
      expect(json['status'], 'active');
    });

    test('copyWith() - tạo bản sao mới với giá trị cập nhật', () {
      final product = ProductModel.fromJson(mockJson);

      final updated = product.copyWith(
        price: 180000.0,
        quantity: 40,
        status: 'inactive',
      );

      expect(updated.price, 180000.0);
      expect(updated.quantity, 40);
      expect(updated.status, 'inactive');

      // giữ nguyên các giá trị cũ
      expect(updated.id, product.id);
      expect(updated.name, product.name);
      expect(updated.categoryId, product.categoryId);
    });
  });
}
