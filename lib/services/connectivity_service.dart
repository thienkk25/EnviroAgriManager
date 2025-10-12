import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service kiểm tra và lắng nghe trạng thái mạng (online/offline)
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  // Stream phát trạng thái online/offline
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  // Hàm khởi tạo
  ConnectivityService() {
    _initialize();
  }

  /// Khởi tạo: kiểm tra mạng ban đầu + lắng nghe thay đổi
  Future<void> _initialize() async {
    final initialStatus = await _checkConnection();
    _connectionStatusController.add(initialStatus);

    // Lắng nghe thay đổi kết nối
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = _isConnected(results);
      _connectionStatusController.add(isOnline);
    });
  }

  /// Kiểm tra mạng hiện tại
  Future<bool> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Xử lý logic xác định online/offline
  bool _isConnected(List<ConnectivityResult> results) {
    // Có thể dùng WiFi, mobile, ethernet, VPN đều là "online"
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }

  /// Lấy trạng thái hiện tại (dành cho gọi 1 lần)
  Future<bool> get isOnline async => await _checkConnection();

  /// Hủy StreamController khi không dùng nữa
  void dispose() {
    _connectionStatusController.close();
  }
}
