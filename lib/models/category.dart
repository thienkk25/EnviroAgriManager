class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String? parentId; // nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawParent = json['parent_id'];
    final String? parent =
        (rawParent == null || (rawParent is String && rawParent.trim().isEmpty))
        ? null
        : rawParent as String;

    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🌱',
      color: json['color'] ?? '#4CAF50',
      parentId: parent,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };

    return data;
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
