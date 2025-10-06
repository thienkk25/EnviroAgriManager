import 'package:enviro_agri_manager/models/region.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Region>> fetchRegions() async {
    try {
      final response = await _supabase.from('regions').select();
      return (response as List).map((item) => Region.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy regions: $e');
    }
  }

  Future<Region> getRegion(String id) async {
    try {
      final response = await _supabase
          .from('regions')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Region không tồn tại');
      }
      return Region.fromMap(response);
    } catch (e) {
      throw Exception('Lỗi lấy region: $e');
    }
  }

  Future<void> addRegion(Region region) async {
    try {
      await _supabase.from('regions').insert(region.toMap());
    } catch (e) {
      throw Exception('Lỗi thêm region: $e');
    }
  }

  Future<void> updateRegion(Region region) async {
    try {
      await _supabase
          .from('regions')
          .update(region.toMap())
          .eq('id', region.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật regions: $e');
    }
  }

  Future<void> deleteRegion(String id) async {
    try {
      await _supabase.from('regions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Lỗi xóa region: $e');
    }
  }
}
