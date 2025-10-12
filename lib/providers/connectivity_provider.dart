import 'package:flutter/foundation.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';

/// Provider để quản lý và thông báo trạng thái mạng online/offline
class ConnectivityProvider with ChangeNotifier {
  ConnectivityService _connectivityService;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityProvider(this._connectivityService) {
    // Lắng nghe thay đổi mạng realtime
    _connectivityService.connectionStatusStream.listen((status) {
      _isOnline = status;
      notifyListeners();
    });

    // Kiểm tra mạng lần đầu khi khởi tạo
    _init();
  }
  void update(ConnectivityService connectivityService) {
    _connectivityService = connectivityService;
    notifyListeners();
  }

  Future<void> _init() async {
    _isOnline = await _connectivityService.isOnline;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
