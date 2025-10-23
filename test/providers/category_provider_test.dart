import 'package:enviro_agri_manager/models/category_model.dart';
import 'package:enviro_agri_manager/providers/category_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late CategoryProvider provider;
  late MockCategoryRepository mockRepo;
  late MockConnectivityService mockConnectivityService;
  late ConnectivityProvider connectivityProvider;

  final sampleCategory = CategoryModel(
    id: '1',
    name: 'Trái cây',
    description: 'Các loại trái cây',
    parentId: null,
    icon: '',
    color: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(
      CategoryModel(
        id: 'fake',
        name: 'Fake',
        description: 'fake',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        icon: '',
        color: '',
      ),
    );
  });

  setUp(() {
    mockRepo = MockCategoryRepository();
    mockConnectivityService = MockConnectivityService();

    when(
      () => mockConnectivityService.connectionStatusStream,
    ).thenAnswer((_) => Stream.value(true));
    when(() => mockConnectivityService.isOnline).thenAnswer((_) async => true);

    connectivityProvider = ConnectivityProvider(mockConnectivityService);

    provider = CategoryProvider(mockRepo);
  });

  group('CategoryProvider', () {
    test('fetchCategories() hoạt động bình thường', () async {
      when(
        () => mockRepo.syncCategories(isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => [sampleCategory]);

      await provider.fetchCategories(connectivityProvider.isOnline);

      expect(provider.categories.length, 1);
      expect(provider.categories.first.name, 'Trái cây');
      expect(provider.error, isEmpty);
    });

    test('fetchCategories() khi lỗi', () async {
      when(
        () => mockRepo.syncCategories(isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('Network error'));

      await provider.fetchCategories(connectivityProvider.isOnline);

      expect(provider.error, contains('Lỗi khi tải danh sách'));
    });

    test('addCategory() thêm thành công', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.addCategory(
        connectivityProvider.isOnline,
        sampleCategory,
      );

      expect(result, true);
      expect(provider.categories.contains(sampleCategory), true);
      expect(provider.error, isEmpty);
    });

    test('addCategory() thất bại', () async {
      when(
        () => mockRepo.add(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('DB error'));

      final result = await provider.addCategory(
        connectivityProvider.isOnline,
        sampleCategory,
      );

      expect(result, false);
      expect(provider.error, contains('Lỗi khi thêm danh mục'));
    });

    test('updateCategory() cập nhật danh mục thành công', () async {
      provider.categories.add(sampleCategory);

      final updated = sampleCategory.copyWith(name: 'Hoa quả');

      when(
        () => mockRepo.update(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.updateCategory(
        connectivityProvider.isOnline,
        updated,
      );

      expect(result, true);
      expect(provider.categories.first.name, 'Hoa quả');
      expect(provider.error, isEmpty);
    });

    test('updateCategory() thất bại', () async {
      provider.categories.add(sampleCategory);
      when(
        () => mockRepo.update(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('DB fail'));

      final updated = sampleCategory.copyWith(name: 'Lỗi rồi');

      final result = await provider.updateCategory(
        connectivityProvider.isOnline,
        updated,
      );

      expect(result, false);
      expect(provider.error, contains('Lỗi khi cập nhật'));
    });

    test('deleteCategory() xóa danh mục thành công', () async {
      provider.categories.add(sampleCategory);

      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenAnswer((_) async => {});

      final result = await provider.deleteCategory(
        connectivityProvider.isOnline,
        '1',
      );

      expect(result, true);
      expect(provider.categories.isEmpty, true);
    });

    test('deleteCategory() lỗi vì có liên kết', () async {
      provider.categories.add(sampleCategory);

      when(
        () => mockRepo.delete(any(), isOnline: any(named: 'isOnline')),
      ).thenThrow(Exception('Không thể xóa'));

      final result = await provider.deleteCategory(
        connectivityProvider.isOnline,
        '1',
      );

      expect(result, false);
      expect(provider.error, contains('không thể xóa'));
    });

    test('getMainCategories() chỉ trả danh mục gốc', () {
      provider.categories.addAll([
        sampleCategory,
        sampleCategory.copyWith(id: '2', name: 'Táo', parentId: '1'),
      ]);

      final result = provider.getMainCategories();

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('getSubCategories() trả danh mục con', () {
      provider.categories.addAll([
        sampleCategory,
        sampleCategory.copyWith(id: '2', name: 'Chuối', parentId: '1'),
      ]);

      final result = provider.getSubCategories('1');

      expect(result.length, 1);
      expect(result.first.name, 'Chuối');
    });

    test('getCategoryName() trả đúng tên', () {
      provider.categories.add(sampleCategory);
      expect(provider.getCategoryName('1'), 'Trái cây');
    });

    test('searchCategories() tìm đúng', () {
      provider.categories.add(sampleCategory);
      final result = provider.searchCategories('trái');
      expect(result.length, 1);
    });

    test('getCategoryIds() truy ngược cha', () {
      provider.categories.addAll([
        CategoryModel(
          id: '1',
          name: 'Root',
          description: '',
          parentId: null,
          icon: '',
          color: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '2',
          name: 'Con',
          description: '',
          parentId: '1',
          icon: '',
          color: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

      final result = provider.getCategoryIds('2');
      expect(result, ['1', '2']);
    });

    test('getCategoryIdsDown() lấy con đệ quy', () {
      provider.categories.addAll([
        CategoryModel(
          id: '1',
          name: 'Root',
          description: '',
          parentId: null,
          icon: '',
          color: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '2',
          name: 'Con',
          description: '',
          parentId: '1',
          icon: '',
          color: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '3',
          name: 'Cháu',
          description: '',
          parentId: '2',
          icon: '',
          color: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

      final result = provider.getCategoryIdsDown('1');
      expect(result, ['1', '2', '3']);
    });
  });
}
