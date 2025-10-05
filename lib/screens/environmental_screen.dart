import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EnvironmentalScreen extends StatefulWidget {
  const EnvironmentalScreen({super.key});

  @override
  State<EnvironmentalScreen> createState() => _EnvironmentalScreenState();
}

class _EnvironmentalScreenState extends State<EnvironmentalScreen> {
  final List<Map<String, dynamic>> _environmentalData = [
    {
      'id': '1',
      'productId': '1',
      'temperature': 28.5,
      'humidity': 75.0,
      'ph': 6.5,
      'soilMoisture': 65.0,
      'lightIntensity': 85.0,
      'co2Level': 400.0,
      'nitrogen': 45.0,
      'phosphorus': 25.0,
      'potassium': 30.0,
      'weatherCondition': 'Nắng',
      'location': 'Khu A',
      'recordedAt': DateTime.now().subtract(const Duration(hours: 2)),
      'notes': 'Điều kiện môi trường tốt',
    },
    {
      'id': '2',
      'productId': '2',
      'temperature': 25.0,
      'humidity': 70.0,
      'ph': 6.0,
      'soilMoisture': 60.0,
      'lightIntensity': 80.0,
      'co2Level': 380.0,
      'nitrogen': 40.0,
      'phosphorus': 20.0,
      'potassium': 25.0,
      'weatherCondition': 'Mây',
      'location': 'Khu B',
      'recordedAt': DateTime.now().subtract(const Duration(hours: 4)),
      'notes': 'Nhiệt độ hơi thấp',
    },
    {
      'id': '3',
      'productId': '3',
      'temperature': 30.0,
      'humidity': 65.0,
      'ph': 6.8,
      'soilMoisture': 70.0,
      'lightIntensity': 90.0,
      'co2Level': 420.0,
      'nitrogen': 50.0,
      'phosphorus': 30.0,
      'potassium': 35.0,
      'weatherCondition': 'Nắng',
      'location': 'Khu C',
      'recordedAt': DateTime.now().subtract(const Duration(hours: 1)),
      'notes': 'Điều kiện tối ưu',
    },
  ];

  String _selectedLocation = 'Tất cả';
  String _selectedTimeRange = 'Hôm nay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Giám sát Môi trường',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDataDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            color: const Color(0xFF5E81AC),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location Filter
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Vị trí: ',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedLocation,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.inter(color: Colors.white),
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Tất cả',
                            child: Text(
                              'Tất cả',
                              style: TextStyle(color: Color(0xFF5E81AC)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Khu A',
                            child: Text(
                              'Khu A',
                              style: TextStyle(color: Color(0xFF5E81AC)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Khu B',
                            child: Text(
                              'Khu B',
                              style: TextStyle(color: Color(0xFF5E81AC)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Khu C',
                            child: Text(
                              'Khu C',
                              style: TextStyle(color: Color(0xFF5E81AC)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.schedule, color: Colors.white),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedTimeRange,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.inter(color: Colors.white),
                      underline: Container(),
                      items: const [
                        DropdownMenuItem(
                          value: 'Hôm nay',
                          child: Text(
                            'Hôm nay',
                            style: TextStyle(color: Color(0xFF5E81AC)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '7 ngày',
                          child: Text(
                            '7 ngày',
                            style: TextStyle(color: Color(0xFF5E81AC)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '30 ngày',
                          child: Text(
                            '30 ngày',
                            style: TextStyle(color: Color(0xFF5E81AC)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeRange = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Environmental Data List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getFilteredData().length,
              itemBuilder: (context, index) {
                final data = _getFilteredData()[index];
                return EnvironmentalDataCard(data: data);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          onPressed: () {
            _showAddDataDialog();
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredData() {
    List<Map<String, dynamic>> filteredData = _environmentalData;

    if (_selectedLocation != 'Tất cả') {
      filteredData = filteredData
          .where((data) => data['location'] == _selectedLocation)
          .toList();
    }

    // Filter by time range (simplified)
    final now = DateTime.now();
    if (_selectedTimeRange == 'Hôm nay') {
      filteredData = filteredData
          .where((data) => data['recordedAt'].day == now.day)
          .toList();
    }

    return filteredData;
  }

  void _showAddDataDialog() {
    final temperatureController = TextEditingController();
    final humidityController = TextEditingController();
    final phController = TextEditingController();
    final soilMoistureController = TextEditingController();
    final lightIntensityController = TextEditingController();
    final co2LevelController = TextEditingController();
    final nitrogenController = TextEditingController();
    final phosphorusController = TextEditingController();
    final potassiumController = TextEditingController();
    final notesController = TextEditingController();

    String selectedLocation = 'Khu A';
    String selectedWeather = 'Nắng';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Thêm dữ liệu môi trường',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: temperatureController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Nhiệt độ (°C)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: humidityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Độ ẩm (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Độ pH',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: soilMoistureController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Độ ẩm đất (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: lightIntensityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cường độ ánh sáng (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: co2LevelController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'CO2 (ppm)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nitrogenController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Nitơ (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: phosphorusController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Phốt pho (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: potassiumController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Kali (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedLocation,
                            decoration: InputDecoration(
                              labelText: 'Vị trí',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Khu A',
                                child: Text('Khu A'),
                              ),
                              DropdownMenuItem(
                                value: 'Khu B',
                                child: Text('Khu B'),
                              ),
                              DropdownMenuItem(
                                value: 'Khu C',
                                child: Text('Khu C'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedWeather,
                            decoration: InputDecoration(
                              labelText: 'Thời tiết',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Nắng',
                                child: Text('Nắng'),
                              ),
                              DropdownMenuItem(
                                value: 'Mây',
                                child: Text('Mây'),
                              ),
                              DropdownMenuItem(
                                value: 'Mưa',
                                child: Text('Mưa'),
                              ),
                              DropdownMenuItem(
                                value: 'Âm u',
                                child: Text('Âm u'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedWeather = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add data logic here
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm dữ liệu môi trường thành công',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: const Color(0xFFA3BE8C),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E81AC),
                  ),
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class EnvironmentalDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const EnvironmentalDataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF5E81AC),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['location'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E3440),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3BE8C).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['weatherCondition'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA3BE8C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Environmental Metrics
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.thermostat,
                  label: 'Nhiệt độ',
                  value: '${data['temperature']}°C',
                  color: const Color(0xFF5E81AC),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.water_drop,
                  label: 'Độ ẩm',
                  value: '${data['humidity']}%',
                  color: const Color(0xFF88C0D0),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.science,
                  label: 'Độ pH',
                  value: '${data['ph']}',
                  color: const Color(0xFFD08770),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.water,
                  label: 'Độ ẩm đất',
                  value: '${data['soilMoisture']}%',
                  color: const Color(0xFFA3BE8C),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.wb_sunny,
                  label: 'Ánh sáng',
                  value: '${data['lightIntensity']}%',
                  color: const Color(0xFFB48EAD),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.cloud,
                  label: 'CO2',
                  value: '${data['co2Level']} ppm',
                  color: const Color(0xFF88C0D0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nutrients
          Text(
            'Dinh dưỡng đất',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.eco,
                  label: 'N',
                  value: '${data['nitrogen']}%',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.eco,
                  label: 'P',
                  value: '${data['phosphorus']}%',
                  color: const Color(0xFF2196F3),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.eco,
                  label: 'K',
                  value: '${data['potassium']}%',
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notes and Time
          if (data['notes'].isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, color: Color(0xFF88C0D0), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['notes'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF2E3440),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ghi nhận: ${DateFormat('dd/MM/yyyy HH:mm').format(data['recordedAt'])}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF88C0D0),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      // Edit logic
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    onPressed: () {
                      // Delete logic
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3440),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF88C0D0),
            ),
          ),
        ],
      ),
    );
  }
}
