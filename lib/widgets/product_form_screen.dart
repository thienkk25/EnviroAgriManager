import 'dart:typed_data';

import 'package:enviro_agri_manager/models/product_model.dart';
import 'package:enviro_agri_manager/models/product_review_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:enviro_agri_manager/providers/product_review_provider.dart';
import 'package:enviro_agri_manager/screens/products_screen.dart';
import 'package:enviro_agri_manager/widgets/category_selector.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductFormMode mode;
  final ProductModel? product;
  final ProductReviewModel? productReview;
  final bool isEditProductReview;

  const ProductFormScreen({
    super.key,
    required this.mode,
    this.product,
    this.productReview,
    required this.isEditProductReview,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _notesController;
  Uint8List? _selectedImage;

  String _selectedCategory = '';
  String _imageUrl = '';
  String _selectedStatus = 'active';

  bool get isView => widget.mode == ProductFormMode.view;
  bool get isEdit => widget.mode == ProductFormMode.edit;
  bool get isAdd => widget.mode == ProductFormMode.add;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _quantityController = TextEditingController(
      text: p != null ? p.quantity.toString() : '',
    );
    _unitController = TextEditingController(text: p?.unit ?? '');

    _selectedCategory = p?.categoryId ?? '';

    _selectedStatus = p?.status ?? 'active';
    _imageUrl = p?.imageUrl ?? '';

    _notesController = TextEditingController(
      text: widget.productReview?.note ?? '',
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF88C0D0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF88C0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E81AC)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  String getPathImages(String url) {
    final reg = RegExp(r'product-images/([^?#]+)');
    final m = reg.firstMatch(url);
    if (m != null) {
      final captured = m.group(1);
      final decoded = Uri.decodeFull(captured!);
      return decoded;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isAdd
              ? 'Thêm Sản phẩm mới'
              : isEdit
              ? 'Chỉnh sửa Sản phẩm'
              : 'Chi tiết Sản phẩm',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          if (!isView)
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                RoleBasedMenuItem(
                  permission: 'isAdmin',
                  child: TextButton(
                    onPressed: () {
                      if (isAdd) {
                        _addProduct(context);
                      } else {
                        _updateProduct(context, widget.product!);
                      }
                    },

                    child: Text(
                      isAdd ? 'Thêm' : 'Sửa',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                RoleBasedMenuItem(
                  permission: 'isEditor',
                  child: TextButton(
                    onPressed: () {
                      if (widget.isEditProductReview) {
                        _updateProductReview(
                          context,
                          widget.product!,
                          widget.productReview!,
                        );
                      } else {
                        _addProductReview(context, widget.product);
                      }
                    },

                    child: Text(
                      isAdd ? 'Thêm' : 'Sửa',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              // --- Thông tin sản phẩm ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Thông tin sản phẩm'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Tên sản phẩm *'),
                      readOnly: isView,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration('Mô tả sản phẩm *'),
                      readOnly: isView,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập mô tả'
                          : null,
                    ),
                  ],
                ),
              ),

              // --- Chọn file ảnh ---
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _sectionTitle('Ảnh sản phẩm'),
                    // --- Nút chọn ảnh ---
                    if (!isView)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh từ thư viện'),
                      ),

                    // --- Hiển thị ảnh đã chọn ---
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Image.network(
                            _imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF5E81AC),
                                size: 180,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- Giá và Số lượng ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Giá và Số lượng'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Giá bán (₫) *'),
                            readOnly: isView,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập giá bán';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Giá bán không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Số lượng *'),
                            readOnly: isView,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập số lượng';
                              }
                              if (int.tryParse(v) == null) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitController,
                      decoration: _inputDecoration('Đơn vị *'),
                      readOnly: isView,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập đơn vị'
                          : null,
                    ),
                  ],
                ),
              ),

              // --- Phân loại ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _sectionTitle('Phân loại'),
                    CategorySelector(
                      isView: isView,
                      isAdd: isAdd,
                      selectedCategoryId: _selectedCategory,
                      onChanged: (value) => setState(() {
                        _selectedCategory = value;
                      }),
                    ),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: _inputDecoration('Trạng thái sản phẩm'),
                      items: ['active', 'inactive', 'discontinued']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_getStatusText(s)),
                            ),
                          )
                          .toList(),
                      onChanged: isView
                          ? null
                          : (v) =>
                                setState(() => _selectedStatus = v ?? 'active'),
                    ),
                  ],
                ),
              ),

              if (widget.isEditProductReview || !isView)
                RoleBasedMenuItem(
                  permission: 'isEditor',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        _sectionTitle('Lý do'),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: _inputDecoration('Lý do yêu cầu *'),
                          readOnly: isView,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Vui lòng nhập lý do'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

              // --- Nút lưu ---
              if (!isView)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoleBasedMenuItem(
                      permission: 'isAdmin',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isAdd) {
                              _addProduct(context);
                            } else {
                              _updateProduct(context, widget.product!);
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E81AC),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isAdd ? 'Thêm sản phẩm' : 'Cập nhật sản phẩm',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    RoleBasedMenuItem(
                      permission: 'isEditor',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.isEditProductReview) {
                              _updateProductReview(
                                context,
                                widget.product!,
                                widget.productReview!,
                              );
                            } else {
                              _addProductReview(context, widget.product);
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E81AC),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isAdd
                                ? 'Gửi yêu cầu thêm sản phẩm'
                                : 'Gửi yêu cầu cập nhật sản phẩm',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E3440),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final ProductModel product = ProductModel(
        id: Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: _selectedStatus,
      );

      final result = await context.read<ProductProvider>().addProduct(
        context.read<ConnectivityProvider>().isOnline,
        product,
        _selectedImage,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã thêm sản phẩm thành công'
                : 'Có lỗi xảy ra khi thêm sản phẩm',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProduct(
    BuildContext context,
    ProductModel oldProduct,
  ) async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = oldProduct.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        updatedAt: DateTime.now(), // chỉ cập nhật thời gian sửa
        status: _selectedStatus,
      );

      final result = await context.read<ProductProvider>().updateProduct(
        context.read<ConnectivityProvider>().isOnline,
        updatedProduct,
        getPathImages(_imageUrl),
        _selectedImage,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã cập nhật sản phẩm thành công'
                : 'Có lỗi xảy ra vui lòng thử lại!',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
    }
  }

  Future<void> _addProductReview(
    BuildContext context,
    ProductModel? model,
  ) async {
    if (_formKey.currentState!.validate()) {
      final ProductModel product = ProductModel(
        id: model?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: _selectedStatus,
      );

      final result = await context
          .read<ProductReviewProvider>()
          .addProductReview(product, _selectedImage, _notesController.text);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã gửi yêu cầu thành công'
                : 'Có lỗi xảy ra khi gửi yêu cầu!',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProductReview(
    BuildContext context,
    ProductModel product,
    ProductReviewModel productReview,
  ) async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = product.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        imageUrl: _imageUrl,
        updatedAt: DateTime.now(), // chỉ cập nhật thời gian sửa
        status: _selectedStatus,
      );

      final result = await context
          .read<ProductReviewProvider>()
          .updateProductReview(
            context.read<ConnectivityProvider>().isOnline,
            updatedProduct,
            _selectedImage,
            _notesController.text,
            productReview,
          );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Đã gửi yêu cầu thành công'
                : 'Có lỗi xảy ra vui lòng thử lại!',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: result ? const Color(0xFFA3BE8C) : Colors.red,
        ),
      );
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
