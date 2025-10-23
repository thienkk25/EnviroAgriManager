import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegionRepository extends Mock implements RegionRepository {}

void main() {
  late RegionProvider provider;
  late MockRegionRepository mockRepo;

  final regionRoot = RegionModel(
    id: '1',
    name: 'Hà Nội',
    description: 'Thủ đô',
    parentId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
  );

  final regionChild = RegionModel(
    id: '2',
    name: 'Quận 1',
    description: 'Khu trung tâm',
    parentId: '1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
  );

  final regionGrandChild = RegionModel(
    id: '3',
    name: 'Phường A',
    description: 'Khu phố',
    parentId: '2',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(
      RegionModel(
        id: 'fake',
        name: 'Fake',
        description: 'fake',
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    );
  });

  setUp(() {
    mockRepo = MockRegionRepository();
    provider = RegionProvider(mockRepo);
  });

  group('RegionProvider', () {
    test('addRegion() và getMainRegions() + getSubRegions()', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      await provider.addRegion(true, regionChild);
      await provider.addRegion(true, regionGrandChild);

      final mainRegions = provider.getMainRegions();
      expect(mainRegions.length, 1);
      expect(mainRegions.first.id, '1');

      final subRegions = provider.getSubRegions('1');
      expect(subRegions.length, 1);
      expect(subRegions.first.id, '2');

      final subSubRegions = provider.getSubRegions('2');
      expect(subSubRegions.length, 1);
      expect(subSubRegions.first.id, '3');
    });

    test('getRegionById() trả đúng', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      final region = provider.getRegionById('1');
      expect(region?.name, 'Hà Nội');
    });

    test('searchRegions() tìm đúng theo tên và mô tả', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      await provider.addRegion(true, regionChild);

      final resultByName = provider.searchRegions('Hà');
      expect(resultByName.length, 1);
      expect(resultByName.first.id, '1');

      final resultByDesc = provider.searchRegions('trung tâm');
      expect(resultByDesc.length, 1);
      expect(resultByDesc.first.id, '2');
    });

    test('getRegionIds() truy ngược cha', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      await provider.addRegion(true, regionChild);
      await provider.addRegion(true, regionGrandChild);

      final ids = provider.getRegionIds('3'); // từ Phường A lên Hà Nội
      expect(ids, ['1', '2', '3']);
    });

    test('updateRegion() thành công', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});
      when(
        () => mockRepo.update(any(), true, isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      final updated = regionRoot.copyWith(name: 'Hà Nội Mới');
      final result = await provider.updateRegion(true, updated, true);
      expect(result, true);
      final region = provider.getRegionById('1');
      expect(region?.name, 'Hà Nội Mới');
    });

    test('deleteRegion() thành công', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});
      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      await provider.addRegion(true, regionRoot);
      await provider.addRegion(true, regionChild);

      final result = await provider.deleteRegion(true, '2'); // Xóa Quận 1
      expect(result, true);

      final subRegions = provider.getSubRegions('1');
      expect(subRegions, isEmpty);
    });

    test('deleteRegion() lỗi vì có liên kết', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});
      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('Không thể xóa'));

      await provider.addRegion(true, regionRoot);
      final result = await provider.deleteRegion(true, '1');
      expect(result, false);
      expect(provider.error, contains('không thể xóa'));
    });
  });
}
