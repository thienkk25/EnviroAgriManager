import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';
  Map<String, double> _trendData = {};
  List<EnvironmentalDataModel> _environmentalData = [];
  String _selectedEnvMetric =
      'temperature'; // temperature, humidity, ph, light_intensity

  @override
  void initState() {
    super.initState();
  }

  void refreshData() {
    setState(() {
      context.read<ProductProvider>().fetchProducts(context);
      context.read<EnvironmentalDataProvider>().fetchEnvironmentalData(context);
      _trendData = context.read<ProductProvider>().getTrendByCategory(
        context,
        _selectedPeriod,
      );
      _environmentalData = context
          .read<EnvironmentalDataProvider>()
          .getEnvironmentalDataByTime(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    _trendData = context.read<ProductProvider>().getTrendByCategory(
      context,
      _selectedPeriod,
    );
    _environmentalData = context
        .read<EnvironmentalDataProvider>()
        .environmentalData;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Báo cáo & Thống kê',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'week',
                child: Text('Tuần này'),
              ),
              const PopupMenuItem<String>(
                value: 'month',
                child: Text('Tháng này'),
              ),
              const PopupMenuItem<String>(
                value: 'quarter',
                child: Text('Quý này'),
              ),
              const PopupMenuItem<String>(
                value: 'year',
                child: Text('Năm này'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 26,
          children: [
            // Period Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF5E81AC)),
                  const SizedBox(width: 12),
                  Text(
                    'Kỳ báo cáo: ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E3440),
                    ),
                  ),
                  Text(
                    _toSelectedPeriodToString(_selectedPeriod),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5E81AC),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF5E81AC)),
                    onPressed: refreshData,
                  ),
                ],
              ),
            ),

            // Overview Cards
            _buildOverviewCards(),

            // Products Chart
            _buildProductsChart(_trendData),

            // Category Distribution
            _buildCategoryDistribution(),

            // Environmental Data Chart
            _buildEnvironmentalChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final stats = productProvider.getStatistics();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan',
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
                  childAspectRatio: constraints.maxWidth < 600 ? .8 : 1.5,
                  children: [
                    _OverviewCard(
                      title: 'Tổng sản phẩm',
                      value: '${stats['totalProducts']}',
                      icon: Icons.inventory_2,
                      color: const Color(0xFF5E81AC),
                    ),
                    _OverviewCard(
                      title: 'Sản phẩm hoạt động',
                      value: '${stats['activeProducts']}',
                      icon: Icons.check_circle,
                      color: const Color(0xFFA3BE8C),
                    ),
                    _OverviewCard(
                      title: 'Giá trị tổng',
                      value:
                          '${(stats['totalValue'] / 1000000).toStringAsFixed(1)}M ₫',
                      icon: Icons.attach_money,
                      color: const Color(0xFFD08770),
                    ),
                    _OverviewCard(
                      title: 'Danh mục cha và con',
                      value:
                          '${context.watch<CategoryProvider>().categories.length}',
                      icon: Icons.category,
                      color: const Color(0xFFB48EAD),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsChart(Map<String, double> trendData) {
    // Handle empty data
    if (trendData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xu hướng sản phẩm theo danh mục',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final keys = trendData.keys.toList();
    final values = trendData.values.toList();

    // Calculate maxY with proper handling
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 100.0 : (maxValue * 1.2).ceilToDouble();

    // Calculate interval for Y axis
    final yInterval = _calculateYInterval(maxY);

    final spots = List.generate(
      trendData.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xu hướng sản phẩm theo danh mục',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                minX: 0,
                maxX: (trendData.length - 1).toDouble(),
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= keys.length) {
                          return const SizedBox();
                        }

                        // Hiển thị tên category
                        String label = keys[index];

                        // Rút ngắn tên nếu quá dài
                        if (label.length > 10) {
                          label = '${label.substring(0, 8)}...';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Transform.rotate(
                            angle: -0.5, // Rotate 45 degrees
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF4C566A),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _formatYAxisValue(value),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF4C566A),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF5E81AC),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF5E81AC),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5E81AC).withValues(alpha: 0.3),
                          const Color(0xFF5E81AC).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        return LineTooltipItem(
                          '${keys[index]}\n${spot.y.toInt()}',
                          GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.all(8),
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    // Get category data from your products
    final categoryData = context
        .read<ProductProvider>()
        .getCategoryDistributionData(context, _selectedPeriod);

    if (categoryData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân bố theo danh mục',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final total = categoryData.values.reduce((a, b) => a + b);
    final sections = _createPieChartSections(categoryData, total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bố theo danh mục',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Add touch feedback if needed
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(flex: 2, child: _buildLegend(categoryData, total)),
            ],
          ),
        ],
      ),
    );
  }

  // Create pie chart sections with colors
  List<PieChartSectionData> _createPieChartSections(
    Map<String, double> data,
    double total,
  ) {
    final colors = [
      const Color(0xFF5E81AC),
      const Color(0xFFA3BE8C),
      const Color(0xFFD08770),
      const Color(0xFFB48EAD),
      const Color(0xFF88C0D0),
      const Color(0xFFEBCB8B),
      const Color(0xFFBF616A),
      const Color(0xFF8FBCBB),
    ];

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: categoryEntry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  // Build legend widget
  Widget _buildLegend(Map<String, double> data, double total) {
    final colors = [
      const Color(0xFF5E81AC),
      const Color(0xFFA3BE8C),
      const Color(0xFFD08770),
      const Color(0xFFB48EAD),
      const Color(0xFF88C0D0),
      const Color(0xFFEBCB8B),
      const Color(0xFFBF616A),
      const Color(0xFF8FBCBB),
    ];

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final categoryEntry = entry.value;
        final percentage = (categoryEntry.value / total * 100);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryEntry.key,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2E3440),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% (${categoryEntry.value.toInt()})',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF4C566A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper function to calculate Y axis interval
  double _calculateYInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    return 500;
  }

  // Helper function to format Y axis values
  String _formatYAxisValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  // Helper function
  String _toSelectedPeriodToString(String type) {
    switch (type) {
      case 'week':
        return "Tuần này";
      case 'month':
        return "Tháng này";
      case 'quarter':
        return "Quý này";
      case 'year':
        return "Năm này";
      default:
        return "";
    }
  }

  // Get environmental statistics
  Map<String, double> getEnvironmentalStats() {
    if (_environmentalData.isEmpty) return {};

    switch (_selectedEnvMetric) {
      case 'temperature':
        return _calculateStats('temperature', 'Nhiệt độ (°C)');
      case 'humidity':
        return _calculateStats('humidity', 'Độ ẩm (%)');
      case 'ph':
        return _calculateStats('ph', 'Độ pH');
      case 'light_intensity':
        return _calculateStats('light_intensity', 'Ánh sáng (lux)');
      case 'soil_moisture':
        return _calculateStats('soil_moisture', 'Độ ẩm đất (%)');
      case 'co2_level':
        return _calculateStats('co2_level', 'CO2 (ppm)');
      case 'nitrogen':
        return _calculateStats('nitrogen', 'Nitơ (mg/kg)');
      case 'phosphorus':
        return _calculateStats('phosphorus', 'Lân (mg/kg)');
      case 'potassium':
        return _calculateStats('potassium', 'Kali (mg/kg)');
      default:
        return {};
    }
  }

  Map<String, double> _calculateStats(String field, String label) {
    final Map<String, double> result = {};

    for (var data in _environmentalData) {
      final location = data.location;
      double? value = 0;

      switch (field) {
        case 'temperature':
          value = data.temperature;
          break;
        case 'humidity':
          value = data.humidity;
          break;
        case 'ph':
          value = data.ph;
          break;
        case 'light_intensity':
          value = data.lightIntensity;
          break;
        case 'soil_moisture':
          value = data.soilMoisture;
          break;
        case 'co2_level':
          value = data.co2Level;
          break;
        case 'nitrogen':
          value = data.nitrogen;
          break;
        case 'phosphorus':
          value = data.phosphorus;
          break;
        case 'potassium':
          value = data.potassium;
          break;
      }

      // Lấy tên ngắn cho location
      final shortLocation = _getShortLocation(location!);
      result[shortLocation] = value!;
    }

    return result;
  }

  String _getShortLocation(String location) {
    // Rút ngắn tên location
    if (location.contains('Nông trại')) {
      return location.replaceAll('Nông trại ', 'NT ');
    } else if (location.contains('Xã ')) {
      return location.replaceAll('Xã ', '');
    } else if (location.length > 15) {
      return '${location.substring(0, 12)}...';
    }
    return location;
  }

  Widget _buildEnvironmentalChart() {
    final statsData = getEnvironmentalStats();

    if (statsData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dữ liệu môi trường',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3440),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dữ liệu môi trường',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3440),
                  ),
                ),
              ),
              _buildMetricDropdown(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 280, child: _buildBarChart(statsData)),
          const SizedBox(height: 16),
          _buildEnvStats(statsData),
        ],
      ),
    );
  }

  // Dropdown chọn metric
  Widget _buildMetricDropdown() {
    final metrics = {
      'temperature': 'Nhiệt độ',
      'humidity': 'Độ ẩm',
      'ph': 'Độ pH',
      'light_intensity': 'Ánh sáng',
      'soil_moisture': 'Độ ẩm đất',
      'co2_level': 'CO2',
      'nitrogen': 'Nitơ',
      'phosphorus': 'Lân',
      'potassium': 'Kali',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5E81AC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedEnvMetric,
        underline: const SizedBox(),
        isDense: true,
        items: metrics.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF2E3440),
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedEnvMetric = value;
            });
          }
        },
      ),
    );
  }

  // Bar chart
  Widget _buildBarChart(Map<String, double> data) {
    final entries = data.entries.toList();
    final maxValue = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue * 1.2).ceilToDouble();

    // Colors for bars
    final colors = [
      const Color(0xFF5E81AC),
      const Color(0xFFA3BE8C),
      const Color(0xFFD08770),
      const Color(0xFFB48EAD),
      const Color(0xFF88C0D0),
      const Color(0xFFEBCB8B),
      const Color(0xFFBF616A),
      const Color(0xFF8FBCBB),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final location = entries[group.x.toInt()].key;
              final value = entries[group.x.toInt()].value;
              return BarTooltipItem(
                '$location\n${value.toStringAsFixed(1)}',
                GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      entries[index].key,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF4C566A),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(maxY),
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF4C566A),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            left: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(maxY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.value,
                color: colors[index % colors.length],
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 10000) return 2000;
    return 5000;
  }

  // Stats summary
  Widget _buildEnvStats(Map<String, double> data) {
    if (data.isEmpty) return const SizedBox();

    final values = data.values.toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('TB', avg.toStringAsFixed(1), const Color(0xFF5E81AC)),
          _buildStatItem(
            'Max',
            max.toStringAsFixed(1),
            const Color(0xFFA3BE8C),
          ),
          _buildStatItem(
            'Min',
            min.toStringAsFixed(1),
            const Color(0xFFD08770),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF4C566A),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E3440),
            ),
          ),
          Text(
            title,
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
