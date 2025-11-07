import 'package:enviro_agri_manager/models/message_model.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/services/ai_service.dart';

class AiRepository {
  final AiService _service;
  final CategoryRepository _categoryRepo;
  final RegionRepository _regionRepo;
  final EnvironmentalDataRepository _envRepo;
  final ProductRepository _productRepo;

  AiRepository(
    this._service,
    this._regionRepo,
    this._envRepo,
    this._productRepo,
    this._categoryRepo,
  );

  Stream<Message> getBotReplyStream(String prompt, bool isOnline) async* {
    // Lấy dữ liệu từ các repository
    final categories = await _categoryRepo.syncCategories(isOnline: isOnline);
    final regions = await _regionRepo.syncRegions(isOnline: isOnline);
    final envData = await _envRepo.syncEnvironmentalData(isOnline: isOnline);
    final products = await _productRepo.syncProducts(isOnline: isOnline);

    // Chuyển sang chuỗi để nhúng vào prompt
    final contextData =
        '''
    Dữ liệu danh mục: ${categories.map((r) => r.name).join(", ")}.
    Dữ liệu vùng: ${regions.map((r) => r.name).join(", ")}.
    Dữ liệu môi trường: ${envData.map((p) => p).join(", ")}.
    Dữ liệu sản phẩm: ${products.map((p) => p.name).join(", ")}.
    ''';

    // Gộp dữ liệu với câu hỏi người dùng
    final fullPrompt =
        '''
    Dưới đây là dữ liệu hiện có của trang trại:
    $contextData
    Câu hỏi của người dùng: $prompt
    ''';

    final buffer = StringBuffer();
    await for (final chunk in _service.streamPrompt(fullPrompt)) {
      buffer.write(chunk);
      yield Message(
        sender: 'bot',
        content: buffer.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
}
