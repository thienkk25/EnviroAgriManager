import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service kiểm tra và lắng nghe trạng thái mạng (online/offline)
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Constructor chính
  ConnectivityService() : _connectivity = Connectivity() {
    _initialize();
  }

  /// Constructor dành riêng cho test
  ConnectivityService.forTest(this._connectivity) {
    _initialize();
  }

  Future<void> _initialize() async {
    final initialStatus = await _checkConnection();
    _connectionStatusController.add(initialStatus);

    _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = _isConnected(results);
      _connectionStatusController.add(isOnline);
    });
  }

  Future<bool> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
  }

  Future<bool> get isOnline async => await _checkConnection();

  void dispose() {
    _connectionStatusController.close();
  }
}
