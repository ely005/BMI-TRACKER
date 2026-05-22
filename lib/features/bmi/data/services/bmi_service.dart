import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bmi_tracker/core/storage/local_storage_service.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/data/models/bmi_record_model.dart';

/// BMI service backed by the local Flask REST API at http://localhost:51266/api.
///
/// Registers as `BmiDataSource` in `app.dart` when running locally
/// (replaces the deprecated Supabase-based BmiService).
class LocalBmiService implements BmiDataSource {
  LocalBmiService({required LocalStorageService localStorageService, http.Client? httpClient})
      : _localStorageService = localStorageService,
        _httpClient = httpClient ?? http.Client();

  final LocalStorageService _localStorageService;
  final http.Client _httpClient;

  static const String _baseUrl = 'http://localhost:51266/api';

  static Uri _u(String path) => Uri.parse('$_baseUrl$path');
  static Map<String, String> _headers({String? token}) => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<String> get _token async =>
      await _localStorageService.getString('auth_token') ?? '';

  BmiRecordModel _fromJson(Map<String, dynamic> json) =>
      BmiRecordModel.fromJson(json);

  @override
  Future<List<BmiRecordEntity>> getRecords() async {
    final resp = await _httpClient.get(
      _u('/bmi-records'),
      headers: _headers(token: await _token),
    );
    return _extractList(resp);
  }

  @override
  Future<BmiRecordEntity> getRecordDetail(String id) async {
    final resp = await _httpClient.get(
      _u('/bmi-records/$id'),
      headers: _headers(token: await _token),
    );
    if (resp.statusCode != 200) {
      throw Exception('Record not found (${resp.statusCode})');
    }
    return _fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  @override
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request) async {
    final body = <String, dynamic>{
      'height_cm': request.heightCm,
      'weight_kg': request.weightKg,
      'bmi_value': request.bmiValue,
      'category': request.category,
      if (request.notes != null && request.notes!.isNotEmpty)
        'notes': request.notes!.trim(),
    };
    final resp = await _httpClient.post(
      _u('/bmi-records'),
      headers: _headers(token: await _token),
      body: jsonEncode(body),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to create record (${resp.statusCode}): ${resp.body}');
    }
    return _fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  @override
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request) async {
    final body = <String, dynamic>{
      'height_cm': request.heightCm,
      'weight_kg': request.weightKg,
      'bmi_value': request.bmiValue,
      'category': request.category,
      if (request.notes != null) 'notes': request.notes,
    };
    final resp = await _httpClient.patch(
      _u('/bmi-records/${request.id}'),
      headers: _headers(token: await _token),
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to update record (${resp.statusCode}): ${resp.body}',
      );
    }
    return _fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteRecord(DeleteBmiRequest request) async {
    final resp = await _httpClient.delete(
      _u('/bmi-records/${request.id}'),
      headers: _headers(token: await _token),
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Failed to delete record (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  List<BmiRecordEntity> _extractList(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected list response shape.');
    }
    final list = decoded.cast<Map<String, dynamic>>();
    return list.map((e) => _fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
