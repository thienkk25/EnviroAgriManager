import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnvironmentalDataProvider with ChangeNotifier {
  EnvironmentalDataRepository? _environmentalDataRepository;

  List<EnvironmentalDataModel> _environmentalData = [];
  bool _isLoading = false;
  String _error = '';

  List<EnvironmentalDataModel> get environmentalData => _environmentalData;
  bool get isLoading => _isLoading;
  String get error => _error;

  EnvironmentalDataProvider(this._environmentalDataRepository);
  void update(EnvironmentalDataRepository repo) {
    _environmentalDataRepository = repo;
    notifyListeners();
  }

  // Lấy danh sách môi trường
  Future<void> fetchEnvironmentalData(BuildContext context) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      _environmentalData = await _environmentalDataRepository!
          .syncEnvironmentalData(isOnline: isOnline);
      _error = '';
    } catch (e) {
      _error = 'Lỗi khi tải danh sách danh mục: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEnvironmentalData(BuildContext context) async {
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      _environmentalData = await _environmentalDataRepository!
          .syncEnvironmentalData(isOnline: isOnline);

      _error = '';
    } catch (e) {
      _error = 'Lỗi khi tải danh sách danh mục: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // Thêm môi trường mới
  Future<bool> addEnvironmentalData(
    BuildContext context,
    EnvironmentalDataModel environmentalData,
  ) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _environmentalDataRepository!.add(
        environmentalData,
        isOnline: isOnline,
      );
      _environmentalData.add(environmentalData);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm danh mục: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật môi trường
  Future<bool> updateEnvironmentalData(
    BuildContext context,
    EnvironmentalDataModel environmentalData,
  ) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _environmentalDataRepository!.update(
        environmentalData,
        isOnline: isOnline,
      );

      final index = _environmentalData.indexWhere(
        (c) => c.id == environmentalData.id,
      );
      if (index != -1) {
        _environmentalData[index] = environmentalData;
      }
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật danh mục: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa môi trường
  Future<bool> deleteEnvironmentalData(BuildContext context, String id) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _environmentalDataRepository!.delete(id, isOnline: isOnline);

      _environmentalData.removeWhere(
        (environmentalData) => environmentalData.id == id,
      );
      _error = '';
      return true;
    } catch (e) {
      if (e.toString().contains('Không thể xóa')) {
        _error = 'Danh mục này có sản phẩm liên quan, không thể xóa!';
      } else {
        _error = 'Lỗi khi xóa danh mục: ${e.toString()}';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy môi trường theo ID
  EnvironmentalDataModel? getEnvironmentalDataById(String id) {
    try {
      return _environmentalData.firstWhere(
        (environmentalData) => environmentalData.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Lọc dữ liệu
  List<EnvironmentalDataModel> getFilteredData(
    String? selectedProvince,
    String? selectedDistrict,
    String? selectedWard,
    String selectedTimeRange,
    List<RegionModel> regions,
  ) {
    List<EnvironmentalDataModel> filteredData = _environmentalData;

    // Hàm đệ quy lấy tất cả id con
    Set<String> getAllChildIds(String parentId) {
      final children = regions.where((r) => r.parentId == parentId).toList();
      final result = <String>{parentId};
      for (var child in children) {
        result.addAll(getAllChildIds(child.id));
      }
      return result;
    }

    Set<String> filterIds = {};

    if (selectedWard != null) {
      filterIds = getAllChildIds(selectedWard);
    } else if (selectedDistrict != null) {
      filterIds = getAllChildIds(selectedDistrict);
    } else if (selectedProvince != null) {
      filterIds = getAllChildIds(selectedProvince);
    }

    if (filterIds.isNotEmpty) {
      filteredData = filteredData
          .where((e) => filterIds.contains(e.regionId))
          .toList();
    }

    // Lọc theo thời gian
    final now = DateTime.now();
    if (selectedTimeRange == 'Hôm nay') {
      filteredData = filteredData
          .where(
            (e) =>
                e.recordedAt.year == now.year &&
                e.recordedAt.month == now.month &&
                e.recordedAt.day == now.day,
          )
          .toList();
    } else if (selectedTimeRange == '7 ngày trước') {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      filteredData = filteredData
          .where((e) => e.recordedAt.isAfter(sevenDaysAgo))
          .toList();
    } else if (selectedTimeRange == '30 ngày trước') {
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      filteredData = filteredData
          .where((e) => e.recordedAt.isAfter(thirtyDaysAgo))
          .toList();
    }

    return filteredData;
  }

  // Lấy dữ liệu lọc theo time
  List<EnvironmentalDataModel> getEnvironmentalDataByTime(String type) {
    final now = DateTime.now();

    return _environmentalData.where((data) {
      final recordedDate = data.recordedAt;

      switch (type) {
        case 'week':
          // Lọc dữ liệu trong tuần hiện tại
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return recordedDate.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              recordedDate.isBefore(endOfWeek.add(const Duration(days: 1)));

        case 'month':
          // Lọc dữ liệu trong tháng hiện tại
          return recordedDate.year == now.year &&
              recordedDate.month == now.month;

        case 'quarter':
          // Lọc dữ liệu trong quý hiện tại
          final currentQuarter = ((now.month - 1) ~/ 3) + 1;
          final dataQuarter = ((recordedDate.month - 1) ~/ 3) + 1;
          return recordedDate.year == now.year && dataQuarter == currentQuarter;

        case 'year':
        default:
          // Lọc dữ liệu trong năm hiện tại
          return recordedDate.year == now.year;
      }
    }).toList();
  }
}
