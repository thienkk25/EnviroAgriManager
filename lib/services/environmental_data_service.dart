import 'package:enviro_agri_manager/models/environmental_data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnvironmentalDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<EnvironmentalDataModel>> fetchEnvironmentalData() async {
    try {
      final response = await _supabase.from('environmental_data').select();
      return (response as List)
          .map((item) => EnvironmentalDataModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy environmental_data: $e');
    }
  }

  Future<EnvironmentalDataModel> getEnvironmentalData(String id) async {
    try {
      final response = await _supabase
          .from('environmental_data')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        throw Exception('Dữ liệu môi trường không tồn tại');
      }
      return EnvironmentalDataModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu môi trường: $e');
    }
  }

  Future<void> addEnvironmentalData(
    EnvironmentalDataModel environmentalData,
  ) async {
    try {
      await _supabase
          .from('environmental_data')
          .insert(environmentalData.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm dữ liệu môi trường: $e');
    }
  }

  Future<void> updateEnvironmentalData(
    EnvironmentalDataModel environmentalData,
  ) async {
    try {
      await _supabase
          .from('environmental_data')
          .update(environmentalData.toJson())
          .eq('id', environmentalData.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật dữ liệu môi trường: $e');
    }
  }

  Future<void> deleteEnvironmentalData(String id) async {
    try {
      await _supabase.from('environmental_data').delete().eq('id', id);
    } catch (e) {
      throw Exception('Lỗi xóa dữ liệu môi trường: $e');
    }
  }

  Future<void> uploadEnvironmentalData(
    List<EnvironmentalDataModel> environmentalData,
  ) async {
    try {
      final data = environmentalData.map((c) => c.toJson()).toList();
      await _supabase.from('environmental_data').upsert(data);
    } catch (e) {
      throw Exception('Lỗi upload environmental_data: $e');
    }
  }
}
