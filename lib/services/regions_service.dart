import 'dart:convert';

import 'package:enviro_agri_manager/models/region_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RegionModel>> fetchRegions() async {
    try {
      final response = await _supabase.from('regions').select();
      return (response as List)
          .map((item) => RegionModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy regions: $e');
    }
  }

  Future<RegionModel> getRegion(String id) async {
    try {
      final response = await _supabase
          .from('regions')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Region không tồn tại');
      }
      return RegionModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy region: $e');
    }
  }

  Future<void> addRegion(RegionModel region) async {
    try {
      await _supabase.from('regions').insert(region.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm region: $e');
    }
  }

  Future<void> updateRegion(RegionModel region, bool level) async {
    try {
      await _supabase
          .from('regions')
          .update(region.toJson())
          .eq('id', region.id);
      if (level) {
        await _supabase
            .from('regions')
            .update({'parent_id': jsonDecode('null')})
            .eq('id', region.id);
      }
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
