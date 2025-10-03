class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String parentId; // Để hỗ trợ danh mục con
  final List<String> subCategories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.parentId = '',
    this.subCategories = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🌱',
      color: json['color'] ?? '#4CAF50',
      parentId: json['parentId'] ?? '',
      subCategories: List<String>.from(json['subCategories'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'parentId': parentId,
      'subCategories': subCategories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? parentId,
    List<String>? subCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      subCategories: subCategories ?? this.subCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
