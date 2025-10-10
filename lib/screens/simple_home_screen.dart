import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Hệ thống Quản lý Danh mục',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hệ thống quản lý danh mục điện tử dùng chung',
                    style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
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
                  childAspectRatio: constraints.maxWidth < 600 ? .8 : 1.1,
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
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF5E81AC), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Dữ liệu Môi trường Hiện tại',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E3440),
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
              'Sản phẩm mẫu',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
              ),
            ),
            const SizedBox(height: 16),

            _SampleProductCard(
              name: 'Lúa Jasmine',
              category: 'Cây lương thực',
              price: '25,000 ₫',
              quantity: '1000 kg',
            ),
            const SizedBox(height: 12),
            _SampleProductCard(
              name: 'Cà chua Cherry',
              category: 'Rau củ',
              price: '45,000 ₫',
              quantity: '500 kg',
            ),
            const SizedBox(height: 12),
            _SampleProductCard(
              name: 'Dưa hấu',
              category: 'Trái cây',
              price: '35,000 ₫',
              quantity: '200 quả',
            ),
          ],
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
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF88C0D0),
            ),
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
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF88C0D0),
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
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFFA3BE8C),
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
  final String category;
  final String price;
  final String quantity;

  const _SampleProductCard({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
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
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF5E81AC).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFF5E81AC),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3440),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3BE8C).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA3BE8C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD08770),
                ),
              ),
              Text(
                quantity,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF88C0D0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
