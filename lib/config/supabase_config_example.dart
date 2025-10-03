// File này là ví dụ về cấu hình Supabase
// Copy nội dung này vào supabase_config.dart và thay thế bằng thông tin thực tế

class SupabaseConfig {
  // Thay thế bằng URL thực tế từ Supabase project của bạn
  // Ví dụ: 'https://abcdefghijklmnop.supabase.co'
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  // Thay thế bằng anon key thực tế từ Supabase project của bạn
  // Ví dụ: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // URL redirect cho deep linking (không cần thay đổi)
  static const String redirectUrl =
      'io.supabase.enviroagrimanager://login-callback/';
}
