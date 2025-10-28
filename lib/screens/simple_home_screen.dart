import 'package:enviro_agri_manager/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Hệ thống Quản lý Danh mục',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E81AC), Color(0xFF88C0D0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nông nghiệp & Môi trường',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống quản lý danh mục điện tử dùng chung',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Features Grid
              Text(
                'Tính năng chính',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth < 600 ? .75 : 1.1,
                    children: [
                      _FeatureCard(
                        icon: Icons.inventory_2,
                        title: 'Quản lý Sản phẩm',
                        description: 'Thêm, sửa, xóa sản phẩm nông nghiệp',
                        color: const Color(0xFF5E81AC),
                      ),
                      _FeatureCard(
                        icon: Icons.category,
                        title: 'Quản lý Danh mục',
                        description: 'Phân loại sản phẩm theo loại',
                        color: const Color(0xFFA3BE8C),
                      ),
                      _FeatureCard(
                        icon: Icons.eco,
                        title: 'Giám sát Môi trường',
                        description: 'Theo dõi dữ liệu môi trường',
                        color: const Color(0xFF88C0D0),
                      ),
                      _FeatureCard(
                        icon: Icons.analytics,
                        title: 'Báo cáo Thống kê',
                        description: 'Biểu đồ và thống kê chi tiết',
                        color: const Color(0xFFD08770),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Environmental Data
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.eco,
                          color: Color(0xFF5E81AC),
                          size: 24,
                        ),
                        Expanded(
                          child: Text(
                            'Dữ liệu Môi trường Hiện tại',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3440),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _EnvironmentalMetric(
                            icon: Icons.thermostat,
                            label: 'Nhiệt độ',
                            value: '28°C',
                            status: 'Bình thường',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _EnvironmentalMetric(
                            icon: Icons.water_drop,
                            label: 'Độ ẩm',
                            value: '75%',
                            status: 'Tốt',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _EnvironmentalMetric(
                            icon: Icons.water,
                            label: 'Độ ẩm đất',
                            value: '65%',
                            status: 'Tốt',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _EnvironmentalMetric(
                            icon: Icons.science,
                            label: 'Độ pH',
                            value: '6.5',
                            status: 'Tối ưu',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sample Products
              Text(
                'Sản phẩm gần đây',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3440),
                ),
              ),
              const SizedBox(height: 16),

              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final now = DateTime.now();
                  final startOfDay = DateTime(now.year, now.month, now.day);

                  final products = productProvider.products
                      .where(
                        (value) =>
                            (value.updatedAt.isBefore(
                                  startOfDay.add(Duration(days: 1)),
                                ) ||
                                value.updatedAt.isAtSameMomentAs(
                                  startOfDay.add(Duration(days: 1)),
                                )) &&
                            (value.updatedAt.isAfter(
                                  startOfDay.copyWith(day: startOfDay.day - 3),
                                ) ||
                                value.updatedAt.isAtSameMomentAs(
                                  startOfDay.copyWith(day: startOfDay.day - 3),
                                )),
                      )
                      .toList();

                  if (products.isEmpty) {
                    return _SampleProductCard(
                      name: "Không có sản phẩm",
                      description: "Chưa có sản phẩm thay đổi gần đây",
                      price: '',
                      quantity: '',
                      imageUrl: '',
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _SampleProductCard(
                        name: products[index].name,
                        description: products[index].description,
                        price:
                            "Giá: ${products[index].price.toStringAsFixed(0)} đ",
                        quantity:
                            "Số lượng: ${products[index].quantity.toString()}",
                        imageUrl: products[index].imageUrl,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3440),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF88C0D0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EnvironmentalMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;

  const _EnvironmentalMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5E81AC).withValues(alpha: .05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5E81AC), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF88C0D0),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFA3BE8C).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFFA3BE8C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String quantity;
  final String imageUrl;

  const _SampleProductCard({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        spacing: 16,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: imageUrl != ''
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF5E81AC),
                          size: 60,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF5E81AC),
                      size: 60,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3440),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD08770),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  quantity,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF88C0D0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
