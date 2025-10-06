// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Region {
  final String id;
  final String name;
  final String description;
  final String? parentId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  Region({
    required this.id,
    required this.name,
    required this.description,
    this.parentId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Region copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Region.fromJson(String source) =>
      Region.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Region(id: $id, name: $name, description: $description, parentId: $parentId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Region other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.parentId == parentId &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        parentId.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
