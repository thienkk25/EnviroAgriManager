import 'package:enviro_agri_manager/models/region.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter/material.dart';

class RegionProvider with ChangeNotifier {
  final RegionService _regionService = RegionService();
  List<Region> _regions = [];
  bool _isLoading = false;
  String _error = '';

  List<Region> get regions => _regions;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Khởi tạo dữ liệu mẫu
  void initializeSampleData() {
    _regions = [];
    notifyListeners();
  }

  Future<void> fetchRegions() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await _regionService.fetchRegions();
      _regions = data;
      // if (_regions.isEmpty) {
      //   initializeSampleData();
      // }
    } catch (e) {
      _error = 'Lỗi khi tải danh sách: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRegion(Region region) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _regionService.addRegion(region);
      _regions.add(region);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRegion(Region region) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _regionService.updateRegion(region);

      final index = _regions.indexWhere((c) => c.id == region.id);
      if (index != -1) {
        _regions[index] = region;
      }
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRegion(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _regionService.deleteRegion(id);

      _regions.removeWhere((region) => region.id == id);
      _error = '';
      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa danh mục: ${e.toString()}';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Region? getRegionById(String id) {
    try {
      return _regions.firstWhere((region) => region.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy danh mục chính (không có parent) region
  List<Region> getMainRegions() {
    return _regions.where((region) => region.parentId == null).toList();
  }

  // Lấy danh mục con region
  List<Region> getSubRegions(String parentId) {
    return _regions.where((region) => region.parentId == parentId).toList();
  }

  // Tìm kiếm region
  List<Region> searchRegions(String query) {
    if (query.isEmpty) return _regions;

    return _regions.where((region) {
      return region.name.toLowerCase().contains(query.toLowerCase()) ||
          region.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
