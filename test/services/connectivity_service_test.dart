import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService connectivityService;

  setUp(() {
    mockConnectivity = MockConnectivity();
  });

  tearDown(() {
    connectivityService.dispose();
  });

  group('ConnectivityService', () {
    test('should emit initial connection status as online', () async {
      // Giả lập mạng đang có kết nối WiFi
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Mock stream thay đổi mạng rỗng (vì không cần test thay đổi ở đây)
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream.empty());

      // Inject mockConnectivity vào service (sửa tạm constructor để nhận vào mock)
      connectivityService = ConnectivityService.forTest(mockConnectivity);

      // Lấy giá trị đầu tiên từ stream
      final isOnline = await connectivityService.connectionStatusStream.first;

      expect(isOnline, isTrue);
    });

    test('should emit false when connectivity is none', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream.empty());

      connectivityService = ConnectivityService.forTest(mockConnectivity);

      final isOnline = await connectivityService.connectionStatusStream.first;
      expect(isOnline, isFalse);
    });

    test('should emit updates when connectivity changes', () async {
      final controller = StreamController<List<ConnectivityResult>>();

      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => controller.stream);

      connectivityService = ConnectivityService.forTest(mockConnectivity);

      final emitted = <bool>[];
      final sub = connectivityService.connectionStatusStream.listen(
        emitted.add,
      );

      // Giả lập chuyển từ offline -> online -> offline
      controller.add([ConnectivityResult.none]);
      controller.add([ConnectivityResult.mobile]);
      controller.add([ConnectivityResult.none]);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(emitted, [false, false, true, false]);

      await sub.cancel();
      await controller.close();
    });
  });
}
