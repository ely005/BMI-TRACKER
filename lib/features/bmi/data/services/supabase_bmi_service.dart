import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/features/bmi/data/models/bmi_record_model.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBmiService implements BmiDataSource {
  SupabaseBmiService();

  static const double _maxHeightCm = 999.99;
  static const double _maxWeightKg = 999.99;

  final SupabaseClient _client = Supabase.instance.client;

  void _validateRequest(CreateBmiRequest request) {
    if (request.heightCm <= 0 || request.heightCm > _maxHeightCm) {
      throw Exception('Height must be between 0 and $_maxHeightCm cm.');
    }
    if (request.weightKg <= 0 || request.weightKg > _maxWeightKg) {
      throw Exception('Weight must be between 0 and $_maxWeightKg kg.');
    }
    if (request.bmiValue <= 0 || request.bmiValue > 99.99) {
      throw Exception('BMI must be 99.99 or less for record storage.');
    }
  }

  @override
  Future<List<BmiRecordEntity>> getRecords() async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('bmi_records')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => BmiRecordModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<BmiRecordEntity> getRecordDetail(String id) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('bmi_records')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Record not found');
    }

    return BmiRecordModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request) async {
    _validateRequest(request);

    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final data = {
      'user_id': userId,
      'height_cm': request.heightCm,
      'weight_kg': request.weightKg,
      'bmi_value': request.bmiValue,
      'category': request.category,
      'notes': request.notes?.trim().isEmpty == true ? null : request.notes?.trim(),
      'created_at': now,
      'updated_at': now,
    };

    final response = await _client.from('bmi_records').insert(data).select().single();

    return BmiRecordModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request) async {
    if (request.heightCm <= 0 || request.heightCm > _maxHeightCm) {
      throw Exception('Height must be between 0 and $_maxHeightCm cm.');
    }
    if (request.weightKg <= 0 || request.weightKg > _maxWeightKg) {
      throw Exception('Weight must be between 0 and $_maxWeightKg kg.');
    }
    if (request.bmiValue <= 0 || request.bmiValue > 99.99) {
      throw Exception('BMI must be 99.99 or less for record storage.');
    }

    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final data = {
      'height_cm': request.heightCm,
      'weight_kg': request.weightKg,
      'bmi_value': request.bmiValue,
      'category': request.category,
      'notes': request.notes?.trim().isEmpty == true ? null : request.notes?.trim(),
      'updated_at': now,
    };

    final response = await _client
        .from('bmi_records')
        .update(data)
        .eq('id', request.id)
        .eq('user_id', userId)
        .select()
        .single();

    return BmiRecordModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> deleteRecord(DeleteBmiRequest request) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from('bmi_records')
        .delete()
        .eq('id', request.id)
        .eq('user_id', userId);
  }
}
