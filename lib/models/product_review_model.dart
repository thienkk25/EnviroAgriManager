import 'dart:convert';

class ProductReviewModel {
  final String id;
  final String? productId;
  final String? editedBy;
  final String? reviewedBy;
  final String status; // pending | approved | rejected
  final Map<String, dynamic>? changes; // JSONB field
  final String? note;
  final DateTime? createdAt;
  final DateTime? reviewedAt;

  const ProductReviewModel({
    required this.id,
    this.productId,
    this.editedBy,
    this.reviewedBy,
    this.status = 'pending',
    this.changes,
    this.note,
    this.createdAt,
    this.reviewedAt,
  });

  /// Convert JSON từ Supabase thành model
  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String?,
      editedBy: json['edited_by'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      status: json['status'] ?? 'pending',
      changes: json['changes'] != null
          ? (json['changes'] is String
                ? jsonDecode(json['changes'])
                : Map<String, dynamic>.from(json['changes']))
          : null,
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
    );
  }

  /// Chuyển ngược model thành JSON để gửi lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'edited_by': editedBy,
      'reviewed_by': reviewedBy,
      'status': status,
      'changes': changes,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  /// Tạo bản sao với dữ liệu mới
  ProductReviewModel copyWith({
    String? id,
    String? productId,
    String? editedBy,
    String? reviewedBy,
    String? status,
    Map<String, dynamic>? changes,
    String? note,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return ProductReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      editedBy: editedBy ?? this.editedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      status: status ?? this.status,
      changes: changes ?? this.changes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
