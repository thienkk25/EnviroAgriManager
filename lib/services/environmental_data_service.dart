import 'package:enviro_agri_manager/models/environmental_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnvironmentalDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<EnvironmentalData>> fetchEnvironmentalData() async {
    try {
      final response = await _supabase.from('environmental_data').select();
      return (response as List)
          .map((item) => EnvironmentalData.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy environmental_data: $e');
    }
  }

  Future<EnvironmentalData> getEnvironmentalData(String id) async {
    try {
      final response = await _supabase
          .from('environmental_data')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Dữ liệu môi trường không tồn tại');
      }
      return EnvironmentalData.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu môi trường: $e');
    }
  }

  Future<void> addEnvironmentalData(EnvironmentalData environmentalData) async {
    try {
      final response = await _supabase
          .from('environmental_data')
          .insert(environmentalData.toJson());
      if (response == null) {
        throw Exception('Thêm dữ liệu môi trường thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi thêm dữ liệu môi trường: $e');
    }
  }

  Future<void> updateEnvironmentalData(
    EnvironmentalData environmentalData,
  ) async {
    try {
      final response = await _supabase
          .from('environmental_data')
          .update(environmentalData.toJson())
          .eq('id', environmentalData.id);
      if ((response as List).isEmpty) {
        throw Exception('Cập nhật dữ liệu môi trường thất bại!');
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật dữ liệu môi trường: $e');
    }
  }

  Future<void> deleteEnvironmentalData(String id) async {
    try {
      final response = await _supabase
          .from('environmental_data')
          .delete()
          .eq('id', id);
      if ((response as List).isEmpty) {
        throw Exception('Xóa dữ liệu môi trường thất bại!');
      }
    } catch (e) {
      throw Exception('Lỗi xóa dữ liệu môi trường: $e');
    }
  }
}
