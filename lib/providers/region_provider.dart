import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegionProvider with ChangeNotifier {
  RegionRepository? _regionRepository;
  RegionProvider(this._regionRepository);
  void update(RegionRepository repo) {
    _regionRepository = repo;
    notifyListeners();
  }

  List<RegionModel> _regions = [];
  bool _isLoading = false;
  String _error = '';

  List<RegionModel> get regions => _regions;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchRegions(BuildContext context) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      _regions = await _regionRepository!.syncRegions(isOnline: isOnline);
    } catch (e) {
      _error = 'Lỗi khi tải danh sách: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRegion(BuildContext context, RegionModel region) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _regionRepository!.add(region, isOnline: isOnline);
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

  Future<bool> updateRegion(
    BuildContext context,
    RegionModel region,
    bool level,
  ) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _regionRepository!.update(region, level, isOnline: isOnline);

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

  Future<bool> deleteRegion(BuildContext context, String id) async {
    _isLoading = true;
    notifyListeners();
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    try {
      await _regionRepository!.delete(id, isOnline: isOnline);

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

  RegionModel? getRegionById(String id) {
    try {
      return _regions.firstWhere((region) => region.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy danh mục chính (không có parent) region
  List<RegionModel> getMainRegions() {
    return _regions.where((region) => region.parentId == null).toList();
  }

  // Lấy danh mục con region
  List<RegionModel> getSubRegions(String parentId) {
    return _regions.where((region) => region.parentId == parentId).toList();
  }

  // Tìm kiếm region
  List<RegionModel> searchRegions(String query) {
    if (query.isEmpty) return _regions;

    return _regions.where((region) {
      return region.name.toLowerCase().contains(query.toLowerCase()) ||
          region.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<String> getRegionIds(String regionId) {
    final region = _regions.firstWhere((r) => r.id == regionId);
    if (region.parentId == null) {
      // Đây là province (cấp cao nhất)
      return [region.id];
    } else {
      // Gọi đệ quy lên trên và thêm tên hiện tại
      return [...getRegionIds(region.parentId!), region.id];
    }
  }
}
