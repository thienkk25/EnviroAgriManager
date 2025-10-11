class ProductModel {
  final String id;
  final String name;
  final String description;
  final String categoryId; // tham chiếu sang bảng categories
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive', 'discontinued'

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// Parse từ JSON (snake_case -> camelCase)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? '', // map đúng DB
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      unit: json['unit'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  /// Convert về JSON để insert/update Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  /// Copy object để dễ update
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    double? price,
    int? quantity,
    String? unit,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Map<String, dynamic>? environmentalData,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
