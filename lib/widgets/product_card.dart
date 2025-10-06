import 'package:enviro_agri_manager/models/product.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E81AC).withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF5E81AC),
                              size: 32,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E3440),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF88C0D0),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFA3BE8C,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.unit,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA3BE8C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    product.status,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(product.status),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(product.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions Menu
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final canEdit = authProvider.hasPermission('edit');
                        final canDelete = authProvider.hasPermission('delete');

                        if (!canEdit && !canDelete) {
                          return const SizedBox.shrink();
                        }

                        return PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                onEdit?.call();
                                break;
                              case 'delete':
                                onDelete?.call();
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            final items = <PopupMenuItem<String>>[];

                            if (canEdit) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Color(0xFF5E81AC),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Chỉnh sửa',
                                        style: GoogleFonts.inter(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (canDelete) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Xóa',
                                        style: GoogleFonts.inter(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return items;
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price and Quantity Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá bán',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD08770),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tồn kho',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            '${product.quantity} ${product.unit}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5E81AC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cập nhật',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(product.updatedAt),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E3440),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFFA3BE8C);
      case 'inactive':
        return const Color(0xFFD08770);
      case 'discontinued':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Tạm dừng';
      case 'discontinued':
        return 'Ngừng kinh doanh';
      default:
        return 'Không xác định';
    }
  }
}
