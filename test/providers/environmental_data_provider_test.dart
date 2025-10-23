import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvironmentalDataRepository extends Mock
    implements EnvironmentalDataRepository {}

class MockRegionRepository extends Mock implements RegionRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late EnvironmentalDataProvider provider;
  late RegionProvider regionProvider;
  late MockEnvironmentalDataRepository mockRepo;
  late MockRegionRepository mockRegionRepository;
  late MockConnectivityService mockConnectivityService;
  late ConnectivityProvider connectivityProvider;

  final sampleCategory = EnvironmentalDataModel(
    id: 'env_001',
    regionId: 'reg_001',
    location: 'Cần Thơ',
    temperature: 29.3,
    humidity: 76.5,
    ph: 6.2,
    soilMoisture: 40.1,
    lightIntensity: 800.0,
    co2Level: 380.0,
    nitrogen: 12.0,
    phosphorus: 6.0,
    potassium: 9.5,
    weatherCondition: 'Nắng nhẹ',
    notes: 'Độ ẩm cao buổi sáng',
    recordedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(
      EnvironmentalDataModel(
        id: 'fake',
        location: 'Fake',
        regionId: '',
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepo = MockEnvironmentalDataRepository();
    mockRegionRepository = MockRegionRepository();
    mockConnectivityService = MockConnectivityService();

    when(
      () => mockConnectivityService.connectionStatusStream,
    ).thenAnswer((_) => Stream.value(true));
    when(() => mockConnectivityService.isOnline).thenAnswer((_) async => true);

    connectivityProvider = ConnectivityProvider(mockConnectivityService);

    provider = EnvironmentalDataProvider(mockRepo);
    regionProvider = RegionProvider(mockRegionRepository);
  });

  group('EnvironmentalDataProvider', () {
    test('fetchEnvironmentalData() hoạt động bình thường', () async {
      when(
        () => mockRepo.syncEnvironmentalData(isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => [sampleCategory]);

      await provider.fetchEnvironmentalData(connectivityProvider.isOnline);

      expect(provider.environmentalData.length, 1);
      expect(provider.environmentalData.first.location, 'Cần Thơ');
      expect(provider.error, isEmpty);
    });

    test('fetchEnvironmentalData() khi lỗi', () async {
      when(
        () => mockRepo.syncEnvironmentalData(isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('Network error'));

      await provider.fetchEnvironmentalData(connectivityProvider.isOnline);

      expect(provider.error, contains('Lỗi khi tải'));
    });

    test('addEnvironmentalData() thêm thành công', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.addEnvironmentalData(
        connectivityProvider.isOnline,
        sampleCategory,
      );

      expect(result, true);
      expect(provider.environmentalData.contains(sampleCategory), true);
      expect(provider.error, isEmpty);
    });

    test('addEnvironmentalData() thất bại', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('DB error'));

      final result = await provider.addEnvironmentalData(
        connectivityProvider.isOnline,
        sampleCategory,
      );

      expect(result, false);
      expect(provider.error, contains('Lỗi khi thêm'));
    });

    test('updateEnvironmentalData() cập nhật thành công', () async {
      provider.environmentalData.add(sampleCategory);

      final updated = sampleCategory.copyWith(location: 'Đà Nẵng');

      when(
        () => mockRepo.update(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.updateEnvironmentalData(
        connectivityProvider.isOnline,
        updated,
      );

      expect(result, true);
      expect(provider.environmentalData.first.location, 'Đà Nẵng');
      expect(provider.error, isEmpty);
    });

    test('updateEnvironmentalData() thất bại', () async {
      provider.environmentalData.add(sampleCategory);
      when(
        () => mockRepo.update(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('DB fail'));

      final updated = sampleCategory.copyWith(location: 'Lỗi rồi');

      final result = await provider.updateEnvironmentalData(
        connectivityProvider.isOnline,
        updated,
      );

      expect(result, false);
      expect(provider.error, contains('Lỗi khi cập nhật'));
    });

    test('deleteEnvironmentalData() xóa thành công', () async {
      provider.environmentalData.add(sampleCategory);

      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.deleteEnvironmentalData(
        connectivityProvider.isOnline,
        'env_001',
      );

      expect(result, true);
      expect(provider.environmentalData.isEmpty, true);
    });

    test('deleteEnvironmentalData() xóa thất bại', () async {
      provider.environmentalData.add(sampleCategory);

      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('Error'));

      final result = await provider.deleteEnvironmentalData(
        connectivityProvider.isOnline,
        '1',
      );
      expect(result, false);
      expect(provider.error, contains('Lỗi khi xóa'));
    });

    test('getEnvironmentalDataById() lấy môi trường theo ID', () {
      provider.environmentalData.add(sampleCategory);

      final result = provider.getEnvironmentalDataById('env_001');

      expect(result!.location, 'Cần Thơ');
    });

    group('getEnvironmentalDataByTime', () {
      setUp(() {
        provider.environmentalData.addAll([
          EnvironmentalDataModel(
            id: '1',
            regionId: 'p1',
            recordedAt: DateTime.now(),
            temperature: 30,
            humidity: 60,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '2',
            regionId: 'd1',
            recordedAt: DateTime.now().subtract(const Duration(days: 3)),
            temperature: 31,
            humidity: 62,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '3',
            regionId: 'w1',
            recordedAt: DateTime.now().subtract(const Duration(days: 10)),
            temperature: 29,
            humidity: 65,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '4',
            regionId: 'w1',
            recordedAt: DateTime.now().subtract(const Duration(days: 40)),
            temperature: 28,
            humidity: 70,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]);
      });
      test('lọc theo tuần hiện tại', () {
        final result = provider.getEnvironmentalDataByTime('week');
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        expect(
          result.every(
            (e) =>
                e.recordedAt.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                e.recordedAt.isBefore(endOfWeek.add(const Duration(days: 1))),
          ),
          true,
        );
      });

      test('lọc theo tháng hiện tại', () {
        final result = provider.getEnvironmentalDataByTime('month');
        expect(
          result.every(
            (e) =>
                e.recordedAt.year == DateTime.now().year &&
                e.recordedAt.month == DateTime.now().month,
          ),
          true,
        );
      });

      test('lọc theo quý hiện tại', () {
        final result = provider.getEnvironmentalDataByTime('quarter');
        final now = DateTime.now();
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        expect(
          result.every((e) {
            final dataQuarter = ((e.recordedAt.month - 1) ~/ 3) + 1;
            return e.recordedAt.year == now.year &&
                dataQuarter == currentQuarter;
          }),
          true,
        );
      });

      test('lọc theo năm hiện tại', () {
        final result = provider.getEnvironmentalDataByTime('year');
        expect(
          result.every((e) => e.recordedAt.year == DateTime.now().year),
          true,
        );
      });
    });
    group('getFilteredData', () {
      List<RegionModel> sampleRegions = [
        {
          "id": "p1",
          "name": "Trung du và miền núi Bắc Bộ",
          "description": "Vùng đồi núi, phát triển cây ăn quả và chăn nuôi",
          "parent_id": null,
          "is_active": true,
          "created_at": "2025-10-17 21:36:23+00",
          "updated_at": "2025-10-18 02:28:55.82842+00",
        },
        {
          "id": "d1",
          "name": "Bắc Trung Bộ",
          "description":
              "Vùng có khí hậu khắc nghiệt, nổi bật với cây công nghiệp và chăn nuôi",
          "parent_id": null,
          "is_active": true,
          "created_at": "2025-10-18 04:36:23+00",
          "updated_at": "2025-10-18 05:11:27.891452+00",
        },
        {
          "id": "w1",
          "name": "Đông Nam Bộ",
          "description": "Vùng công nghiệp và cây công nghiệp lâu năm",
          "parent_id": null,
          "is_active": true,
          "created_at": "2025-10-17 21:36:23+00",
          "updated_at": "2025-10-18 02:28:55.82842+00",
        },
      ].map((e) => RegionModel.fromJson(e)).toList();
      setUp(() {
        provider.environmentalData.addAll([
          EnvironmentalDataModel(
            id: '1',
            regionId: 'p1',
            recordedAt: DateTime.now(),
            temperature: 30,
            humidity: 60,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '2',
            regionId: 'd1',
            recordedAt: DateTime.now().subtract(const Duration(days: 3)),
            temperature: 31,
            humidity: 62,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '3',
            regionId: 'w1',
            recordedAt: DateTime.now().subtract(const Duration(days: 10)),
            temperature: 29,
            humidity: 65,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          EnvironmentalDataModel(
            id: '4',
            regionId: 'w1',
            recordedAt: DateTime.now().subtract(const Duration(days: 40)),
            temperature: 28,
            humidity: 70,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]);

        regionProvider.regions.addAll(sampleRegions);
      });
      test('lọc theo province', () {
        final result = provider.getFilteredData(
          'p1',
          null,
          null,
          'Hôm nay',
          sampleRegions,
        );
        expect(
          result.every((e) => ['p1', 'd1', 'w1'].contains(e.regionId)),
          true,
        );
      });

      test('lọc theo district', () {
        final result = provider.getFilteredData(
          null,
          'd1',
          null,
          '7 ngày trước',
          sampleRegions,
        );
        expect(result.every((e) => ['d1', 'w1'].contains(e.regionId)), true);
      });

      test('lọc theo ward', () {
        final result = provider.getFilteredData(
          null,
          null,
          'w1',
          '30 ngày trước',
          sampleRegions,
        );
        expect(result.every((e) => e.regionId == 'w1'), true);
      });

      test('lọc theo thời gian - Hôm nay', () {
        final result = provider.getFilteredData(
          null,
          null,
          null,
          'Hôm nay',
          sampleRegions,
        );
        expect(
          result.every(
            (e) =>
                e.recordedAt.year == DateTime.now().year &&
                e.recordedAt.month == DateTime.now().month &&
                e.recordedAt.day == DateTime.now().day,
          ),
          true,
        );
      });

      test('lọc theo thời gian - 7 ngày trước', () {
        final result = provider.getFilteredData(
          null,
          null,
          null,
          '7 ngày trước',
          sampleRegions,
        );
        expect(
          result.every(
            (e) => e.recordedAt.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          ),
          true,
        );
      });

      test('lọc theo thời gian - 30 ngày trước', () {
        final result = provider.getFilteredData(
          null,
          null,
          null,
          '30 ngày trước',
          sampleRegions,
        );
        expect(
          result.every(
            (e) => e.recordedAt.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          ),
          true,
        );
      });
    });
  });
}
