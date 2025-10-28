import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/screens/region_manager_screen.dart';
import 'package:enviro_agri_manager/widgets/environmental_data_card.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum EnvironmentalDialogMode { add, edit, view }

class EnvironmentalScreen extends StatefulWidget {
  const EnvironmentalScreen({super.key});

  @override
  State<EnvironmentalScreen> createState() => _EnvironmentalScreenState();
}

class _EnvironmentalScreenState extends State<EnvironmentalScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnvironmentalDataProvider>().fetchEnvironmentalData(
        context.read<ConnectivityProvider>().isOnline,
      );
      context.read<RegionProvider>().fetchRegions(
        context.read<ConnectivityProvider>().isOnline,
      );
    });

    super.initState();
  }

  String _selectedTimeRange = 'Tất cả';

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Giám sát Môi trường',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5E81AC),
        elevation: 0,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Row(
              children: [
                const Icon(Icons.location_on),
                Text(
                  "Các địa điểm hoạt động",
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                ),
              ],
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegionManagerScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Filters Section
            Container(
              color: const Color(0xFF5E81AC),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runAlignment: WrapAlignment.spaceBetween,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      Text(
                        'Vị trí: ',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Consumer<RegionProvider>(
                        builder: (context, regionProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ==== Tỉnh ====
                              DropdownButton<String>(
                                value: _selectedProvince,
                                dropdownColor: Color(0xFF5E81AC),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'Tất cả',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ...(regionProvider.getMainRegions()..sort(
                                        (a, b) => a.name.compareTo(b.name),
                                      ))
                                      .map((province) {
                                        return DropdownMenuItem(
                                          value: province.id,
                                          child: Text(province.name),
                                        );
                                      }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProvince = value;
                                    _selectedDistrict = null;
                                    _selectedWard = null;
                                  });
                                },
                              ),

                              // ==== Xã ====
                              ?_selectedProvince == null
                                  ? null
                                  : DropdownButton<String>(
                                      value: _selectedDistrict,
                                      dropdownColor: Color(0xFF5E81AC),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                      ),
                                      items: _selectedProvince == null
                                          ? null
                                          : [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text(
                                                  'Tất cả',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              ...(regionProvider.getSubRegions(
                                                    _selectedProvince!,
                                                  )..sort(
                                                    (a, b) => a.name.compareTo(
                                                      b.name,
                                                    ),
                                                  ))
                                                  .map((district) {
                                                    return DropdownMenuItem(
                                                      value: district.id,
                                                      child: Text(
                                                        district.name,
                                                      ),
                                                    );
                                                  }),
                                            ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDistrict = value;
                                          _selectedWard = null;
                                        });
                                      },
                                    ),

                              ?_selectedDistrict == null
                                  ? null
                                  : DropdownButton<String>(
                                      value: _selectedWard,
                                      dropdownColor: Color(0xFF5E81AC),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                      ),
                                      items: _selectedDistrict == null
                                          ? null
                                          : [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text(
                                                  'Tất cả',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              ...(regionProvider.getSubRegions(
                                                    _selectedDistrict!,
                                                  )..sort(
                                                    (a, b) => a.name.compareTo(
                                                      b.name,
                                                    ),
                                                  ))
                                                  .map((ward) {
                                                    return DropdownMenuItem(
                                                      value: ward.id,
                                                      child: Text(ward.name),
                                                    );
                                                  }),
                                            ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWard = value;
                                        });
                                      },
                                    ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      const Icon(Icons.schedule, color: Colors.white),
                      DropdownButton<String>(
                        value: _selectedTimeRange,
                        dropdownColor: Color(0xFF5E81AC),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Tất cả',
                            child: Text(
                              'Tất cả',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Hôm nay',
                            child: Text(
                              'Hôm nay',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '7 ngày',
                            child: Text(
                              '7 ngày trước',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '30 ngày',
                            child: Text(
                              '30 ngày trước',
                              style: TextStyle(color: Colors.white),
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
            Expanded(
              child: Consumer<EnvironmentalDataProvider>(
                builder: (context, environmentalDataProvider, child) {
                  if (environmentalDataProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (environmentalDataProvider.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            environmentalDataProvider.error,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => environmentalDataProvider
                                .fetchEnvironmentalData(
                                  context.read<ConnectivityProvider>().isOnline,
                                ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  List<EnvironmentalDataModel> filteredEnvimentalData =
                      environmentalDataProvider.getFilteredData(
                        _selectedProvince,
                        _selectedDistrict,
                        _selectedWard,
                        _selectedTimeRange,
                        context.read<RegionProvider>().regions,
                      )..sort((a, b) => a.location!.compareTo(b.location!));
                  if (filteredEnvimentalData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có môi trường nào',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thử thay đổi vị trí hoặc thời gian gần đây',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        environmentalDataProvider.refreshEnvironmentalData(
                          context.read<ConnectivityProvider>().isOnline,
                        ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredEnvimentalData.length,
                      itemBuilder: (context, index) {
                        return EnvironmentalDataCard(
                          key: Key(filteredEnvimentalData[index].id),
                          environmentalData: filteredEnvimentalData[index],
                          onTap: () => _showDataDialog(
                            context: context,
                            mode: EnvironmentalDialogMode.view,
                            environmentalData: filteredEnvimentalData[index],
                          ),
                          onEdit: () => _showDataDialog(
                            context: context,
                            mode: EnvironmentalDialogMode.edit,
                            environmentalData: filteredEnvimentalData[index],
                          ),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Xác nhận xóa',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Bạn có chắc chắn muốn xóa dữ liệu môi trường này?',
                                  style: const TextStyle(fontFamily: 'Inter'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Hủy',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final result = await context
                                          .read<EnvironmentalDataProvider>()
                                          .deleteEnvironmentalData(
                                            context
                                                .read<ConnectivityProvider>()
                                                .isOnline,
                                            filteredEnvimentalData[index].id,
                                          );

                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();

                                      if (result) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã xóa dữ liệu môi trường thành công',
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            backgroundColor: const Color(
                                              0xFFA3BE8C,
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Lỗi khi xóa dữ liệu môi trường',
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      'Xóa',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          heroTag: 'fab_envir',
          onPressed: () {
            _showDataDialog(
              context: context,
              mode: EnvironmentalDialogMode.add,
            );
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showDataDialog({
    required BuildContext context,
    required EnvironmentalDialogMode mode,
    EnvironmentalDataModel? environmentalData,
  }) {
    final formKey = GlobalKey<FormState>();
    final temperatureController = TextEditingController(
      text: environmentalData?.temperature.toString() ?? '',
    );
    final humidityController = TextEditingController(
      text: environmentalData?.humidity.toString() ?? '',
    );
    final phController = TextEditingController(
      text: environmentalData?.ph.toString() ?? '',
    );
    final soilMoistureController = TextEditingController(
      text: environmentalData?.soilMoisture.toString() ?? '',
    );
    final lightIntensityController = TextEditingController(
      text: environmentalData?.lightIntensity.toString() ?? '',
    );
    final co2LevelController = TextEditingController(
      text: environmentalData?.co2Level.toString() ?? '',
    );
    final nitrogenController = TextEditingController(
      text: environmentalData?.nitrogen.toString() ?? '',
    );
    final phosphorusController = TextEditingController(
      text: environmentalData?.phosphorus.toString() ?? '',
    );
    final potassiumController = TextEditingController(
      text: environmentalData?.potassium.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: environmentalData?.notes ?? '',
    );
    final locationController = TextEditingController(
      text: environmentalData?.location ?? '',
    );

    final isView = mode == EnvironmentalDialogMode.view;
    String selectedWeather = 'Nắng';
    String? selectedProvince;
    String? selectedDistrict;
    String? selectedWard;
    if (!(mode == EnvironmentalDialogMode.add)) {
      final getRegionIds = context.read<RegionProvider>().getRegionIds(
        environmentalData!.regionId,
      );
      selectedProvince = getRegionIds.isNotEmpty ? getRegionIds[0] : null;
      selectedDistrict = getRegionIds.length > 1 ? getRegionIds[1] : null;
      selectedWard = getRegionIds.length > 2 ? getRegionIds[2] : null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                mode == EnvironmentalDialogMode.add
                    ? 'Thêm dữ liệu môi trường'
                    : mode == EnvironmentalDialogMode.edit
                    ? 'Chỉnh sửa dữ liệu môi trường'
                    : 'Xem dữ liệu môi trường',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      SizedBox(height: 8),
                      Consumer<RegionProvider>(
                        builder: (context, regionProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              // ==== Tỉnh ====
                              DropdownButtonFormField<String>(
                                initialValue: selectedProvince,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Địa điểm',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: regionProvider.getMainRegions().map((
                                  province,
                                ) {
                                  return DropdownMenuItem(
                                    value: province.id,
                                    child: Text(province.name),
                                  );
                                }).toList(),
                                onChanged: isView
                                    ? null
                                    : (value) {
                                        setState(() {
                                          selectedProvince = value;
                                          selectedDistrict = null;
                                          selectedWard = null;
                                        });
                                      },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Vui lòng nhập vị trí'
                                    : null,
                              ),

                              // ==== Xã ====
                              ?selectedProvince == null
                                  ? null
                                  : DropdownButtonFormField<String>(
                                      initialValue: selectedDistrict,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: '---',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      items: selectedProvince == null
                                          ? null
                                          : regionProvider
                                                .getSubRegions(
                                                  selectedProvince!,
                                                )
                                                .map((district) {
                                                  return DropdownMenuItem(
                                                    value: district.id,
                                                    child: Text(district.name),
                                                  );
                                                })
                                                .toList(),
                                      onChanged: isView
                                          ? null
                                          : (value) {
                                              setState(() {
                                                selectedDistrict = value;
                                                selectedWard = null;
                                              });
                                            },
                                    ),

                              ?selectedDistrict == null
                                  ? null
                                  : DropdownButtonFormField<String>(
                                      initialValue: selectedWard,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: '---',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      items: selectedDistrict == null
                                          ? null
                                          : regionProvider
                                                .getSubRegions(
                                                  selectedDistrict!,
                                                )
                                                .map((ward) {
                                                  return DropdownMenuItem(
                                                    value: ward.id,
                                                    child: Text(ward.name),
                                                  );
                                                })
                                                .toList(),
                                      onChanged: isView
                                          ? null
                                          : (value) {
                                              setState(() {
                                                selectedWard = value;
                                              });
                                            },
                                    ),
                            ],
                          );
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: temperatureController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nhiệt độ (°C)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập nhiệt độ'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: humidityController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Độ ẩm (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập độ ẩm'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: phController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Độ pH',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập độ pH'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: soilMoistureController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Độ ẩm đất (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập độ ẩm đất'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: lightIntensityController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cường độ ánh sáng (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập cường độ ánh sáng'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: co2LevelController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CO2 (ppm)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập mức CO2'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nitrogenController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nitơ (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập nitơ'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: phosphorusController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Phốt pho (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập phốt pho'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: potassiumController,
                              enabled: !isView,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Kali (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập kali'
                                  : null,
                            ),
                          ),
                        ],
                      ),
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
                              onChanged: isView
                                  ? null
                                  : (value) => setState(() {
                                      selectedWeather = value!;
                                    }),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: locationController,
                        enabled: !isView,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Mô tả vị trí',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: notesController,
                        enabled: !isView,
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                !isView
                    ? ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (mode == EnvironmentalDialogMode.add) {
                              final newEnvironmentalData =
                                  EnvironmentalDataModel(
                                    id: Uuid().v4(),
                                    temperature: double.parse(
                                      temperatureController.text,
                                    ),
                                    humidity: double.parse(
                                      humidityController.text,
                                    ),
                                    ph: double.parse(phController.text),
                                    soilMoisture: double.parse(
                                      soilMoistureController.text,
                                    ),
                                    lightIntensity: double.parse(
                                      lightIntensityController.text,
                                    ),
                                    co2Level: double.parse(
                                      co2LevelController.text,
                                    ),
                                    nitrogen: double.parse(
                                      nitrogenController.text,
                                    ),
                                    phosphorus: double.parse(
                                      phosphorusController.text,
                                    ),
                                    potassium: double.parse(
                                      potassiumController.text,
                                    ),
                                    location: locationController.text,
                                    weatherCondition: selectedWeather,
                                    notes: notesController.text,
                                    recordedAt: DateTime.now(),
                                    regionId:
                                        selectedWard ??
                                        selectedDistrict ??
                                        selectedProvince ??
                                        '',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                              final result = await context
                                  .read<EnvironmentalDataProvider>()
                                  .addEnvironmentalData(
                                    context
                                        .read<ConnectivityProvider>()
                                        .isOnline,
                                    newEnvironmentalData,
                                  );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã thêm dữ liệu môi trường thành công',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFA3BE8C),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Lỗi khi thêm dữ liệu môi trường',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              final newEnvironmentalData = environmentalData!
                                  .copyWith(
                                    temperature: double.parse(
                                      temperatureController.text,
                                    ),
                                    humidity: double.parse(
                                      humidityController.text,
                                    ),
                                    ph: double.parse(phController.text),
                                    soilMoisture: double.parse(
                                      soilMoistureController.text,
                                    ),
                                    lightIntensity: double.parse(
                                      lightIntensityController.text,
                                    ),
                                    co2Level: double.parse(
                                      co2LevelController.text,
                                    ),
                                    nitrogen: double.parse(
                                      nitrogenController.text,
                                    ),
                                    phosphorus: double.parse(
                                      phosphorusController.text,
                                    ),
                                    potassium: double.parse(
                                      potassiumController.text,
                                    ),
                                    location: locationController.text,
                                    weatherCondition: selectedWeather,
                                    notes: notesController.text,
                                    regionId:
                                        selectedWard ??
                                        selectedDistrict ??
                                        selectedProvince ??
                                        environmentalData.regionId,
                                    recordedAt: environmentalData.recordedAt,
                                    updatedAt: DateTime.now(),
                                  );
                              final result = await context
                                  .read<EnvironmentalDataProvider>()
                                  .updateEnvironmentalData(
                                    context
                                        .read<ConnectivityProvider>()
                                        .isOnline,
                                    newEnvironmentalData,
                                  );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã cập nhật dữ liệu môi trường thành công',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFA3BE8C),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Lỗi khi cập nhật dữ liệu môi trường',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E81AC),
                        ),
                        child: Text(
                          mode == EnvironmentalDialogMode.edit ? 'Lưu' : 'Thêm',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            );
          },
        );
      },
    );
  }
}
