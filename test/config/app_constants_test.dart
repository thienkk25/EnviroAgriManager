import 'package:enviro_agri_manager/config/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kiểm tra có constans?', () {
    expect(categoryIcons.isNotEmpty, true);
    expect(categoryColors.isNotEmpty, true);
  });
}
