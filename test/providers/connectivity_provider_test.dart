import 'dart:async';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late ConnectivityProvider provider;
  late MockConnectivityService mockService;
  late StreamController<bool> controller;

  setUp(() {
    mockService = MockConnectivityService();
    controller = StreamController<bool>.broadcast();

    // Mock stream và future ban đầu
    when(
      () => mockService.connectionStatusStream,
    ).thenAnswer((_) => controller.stream);
    when(() => mockService.isOnline).thenAnswer((_) async => true);

    provider = ConnectivityProvider(mockService);
  });

  tearDown(() {
    controller.close();
  });

  group('ConnectivityProvider', () {
    test('khởi tạo mặc định isOnline = true', () async {
      expect(provider.isOnline, true);
    });

    test('updateService() cập nhật service mới', () {
      final newService = MockConnectivityService();
      provider.updateService(newService);
    });

    test('lắng nghe stream thay đổi và notifyListeners', () async {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      // Gửi sự kiện "offline"
      controller.add(false);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(provider.isOnline, false);
      expect(notified, true);

      // Gửi sự kiện "online" lại
      notified = false;
      controller.add(true);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(provider.isOnline, true);
      expect(notified, true);
    });

    test('dispose() gọi dispose() trong service', () {
      when(() => mockService.dispose()).thenAnswer((_) {});

      provider.dispose();

      verify(() => mockService.dispose()).called(1);
    });
  });
}
