class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive', 'discontinued'
  final Map<String, dynamic> environmentalData; // Dữ liệu môi trường

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.environmentalData = const {},
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      environmentalData: json['environmentalData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'environmentalData': environmentalData,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? quantity,
    String? unit,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Map<String, dynamic>? environmentalData,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      environmentalData: environmentalData ?? this.environmentalData,
    );
  }
}
