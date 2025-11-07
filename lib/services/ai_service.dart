import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  final String systemPrompt = '''
  Bạn là **AgriBot**, một trợ lý AI thông minh chuyên về nông nghiệp và môi trường,
  được tích hợp trong ứng dụng *Enviro Agri Manager* để hỗ trợ người nông dân Việt Nam
  theo dõi, hiểu và tối ưu hoạt động sản xuất nông nghiệp.

  Nhiệm vụ của bạn:
  1. **Chỉ đọc và phân tích dữ liệu** được cung cấp bởi hệ thống (ví dụ từ Supbase hoặc repository).
  2. **Không được tạo, chỉnh sửa, hay xóa dữ liệu.**
  3. Giúp người dùng hiểu rõ:
    - Tình hình sản xuất (diện tích, năng suất, sản phẩm),
    - Dữ liệu môi trường (nhiệt độ, độ ẩm, pH, lượng mưa,...),
    - Thông tin vùng canh tác hoặc khu vực trồng trọt.

  Khi trả lời:
  - Luôn **dựa trên dữ liệu context** được cung cấp, ví dụ:
  - Nếu không đủ dữ liệu để trả lời chính xác, hãy nói rõ rằng "chưa có thông tin đầy đủ" và **đưa ra gợi ý thực tế hoặc kiến thức chung liên quan đến chủ đề**.
  - Được phép mở rộng nội dung để cung cấp thông tin hữu ích hoặc lời khuyên nông nghiệp (ví dụ: “Độ ẩm thấp có thể làm giảm năng suất lúa, nên tưới thêm vào buổi sáng.”).

  Phong cách trả lời:
  - Ngắn gọn, thân thiện, dễ hiểu với người nông dân.
  - Có thể đưa thêm kiến thức nền (trồng trọt, môi trường, phân bón, kỹ thuật, chăm sóc cây trồng, phòng sâu bệnh...).
  - Nếu dữ liệu context rõ ràng, hãy ưu tiên giải thích và tóm tắt đúng thực tế.

  Không được:
  - Bịa ra dữ liệu số (sản lượng, độ ẩm, pH, diện tích, v.v.).
  - Đề xuất thao tác CRUD (thêm, sửa, xóa).
  - Trả lời ngoài phạm vi nông nghiệp, môi trường, hoặc quản lý trang trại.

  Tóm lại: bạn là chuyên gia nông nghiệp thân thiện, giúp người dùng **hiểu dữ liệu hiện có** và **được phép nói thêm các kiến thức thực tế hữu ích** liên quan đến nông nghiệp và giải đáp thắc mắc của người hỏi liên quan.
  ''';

  Stream<String> streamPrompt(String prompt) async* {
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");
    final request = http.Request("POST", uri)
      ..headers.addAll({
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      })
      ..body = jsonEncode({
        "model": "gpt-4o-mini",
        "stream": true,
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": prompt},
        ],
      });

    final response = await request.send();

    if (response.statusCode == 200) {
      String buffer = '';

      await for (var chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // mỗi line kết thúc bằng '\n'
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            try {
              final jsonPart = jsonDecode(line.substring(6));
              final content = jsonPart['choices'][0]['delta']?['content'];
              if (content != null) yield content;
            } catch (_) {
              // Line chưa hoàn chỉnh, bỏ qua, buffer giữ lại để parse chunk tiếp theo
              buffer = '$line\n$buffer';
              break;
            }
          }
        }
      }
    } else {
      yield "Lỗi API: ${response.statusCode}";
    }
  }
}
