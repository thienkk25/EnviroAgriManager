import 'package:enviro_agri_manager/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kiểm tra biến cấu hình có phải loại string không?', () {
    expect(SupabaseConfig.supabaseUrl, isA<String>());
    expect(SupabaseConfig.redirectUrl, isA<String>());
    expect(SupabaseConfig.supabaseAnonKey, isA<String>());
  });
}
