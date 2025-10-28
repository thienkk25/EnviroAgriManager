import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/product_review_model.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/providers/product_review_provider.dart';
import 'package:enviro_agri_manager/screens/products_screen.dart';
import 'package:enviro_agri_manager/widgets/product_form_screen.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? rejected;
  final ProductReviewModel? productReview;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.rejected,
    this.productReview,
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
              spacing: 16,
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
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3440),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF88C0D0),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 16,
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
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFA3BE8C),
                                  ),
                                ),
                              ),
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
                                  style: TextStyle(
                                    fontFamily: 'Inter',
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
                    if (rejected == null)
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final canEdit = authProvider.hasPermission('edit');
                          final canDelete = authProvider.hasPermission(
                            'delete',
                          );

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
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                          ),
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
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
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

                // Price and Quantity Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá bán',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(product.price),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD08770),
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
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            '${product.quantity} ${product.unit}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5E81AC),
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
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF88C0D0),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(product.updatedAt),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2E3440),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (productReview != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: _getStatusColor(productReview!.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Trạng thái: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Chip(
                              label: Text(
                                _getStatusReviewText(productReview!.status),
                              ),
                              backgroundColor: _getStatusColor(
                                productReview!.status,
                              ).withValues(alpha: .15),
                              labelStyle: TextStyle(
                                color: _getStatusColor(productReview!.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.comment_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Lý do: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                productReview!.note?.isNotEmpty == true
                                    ? productReview!.note!
                                    : 'Không có ghi chú',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (rejected != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!rejected!)
                        Consumer<ProductReviewProvider>(
                          builder: (context, productReviewProvider, child) {
                            if (productReviewProvider.isLoading) {
                              return CircularProgressIndicator();
                            }
                            return Column(
                              children: [
                                RoleBasedMenuItem(
                                  permission: 'manage_settings',
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Duyệt'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade600,
                                        ),
                                        onPressed: () async {
                                          await productReviewProvider
                                              .approveOrRejectProductReview(
                                                productReview!.id,
                                                'approve',
                                              );
                                          await productReviewProvider
                                              .fetchProductReviews();
                                          if (!context.mounted) return;
                                          context
                                              .read<ProductProvider>()
                                              .refreshProducts(
                                                context
                                                    .read<
                                                      ConnectivityProvider
                                                    >()
                                                    .isOnline,
                                              );
                                        },
                                      ),
                                      OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Từ chối',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          await productReviewProvider
                                              .approveOrRejectProductReview(
                                                productReview!.id,
                                                'reject',
                                              );
                                          await productReviewProvider
                                              .fetchProductReviews();
                                          if (!context.mounted) return;
                                          context
                                              .read<ProductProvider>()
                                              .refreshProducts(
                                                context
                                                    .read<
                                                      ConnectivityProvider
                                                    >()
                                                    .isOnline,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                RoleBasedMenuItem(
                                  permission: 'isEditor',
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Chỉnh sửa'),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductFormScreen(
                                                  mode: ProductFormMode.edit,
                                                  product:
                                                      ProductModel.fromJson(
                                                        productReview
                                                                ?.changes ??
                                                            {},
                                                      ),
                                                  productReview: productReview,
                                                  isEditProductReview: true,
                                                ),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          await productReviewProvider
                                              .deleteProductReview(
                                                productReview!.id,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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
      case 'active' || 'approved':
        return const Color(0xFFA3BE8C);
      case 'inactive' || 'pending':
        return const Color(0xFFD08770);
      case 'discontinued' || 'rejected':
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

  String _getStatusReviewText(String status) {
    switch (status) {
      case 'approved':
        return 'Đã duyệt';
      case 'pending':
        return 'Đang chờ duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }
}
