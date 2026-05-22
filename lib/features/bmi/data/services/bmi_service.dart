import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';

// Deprecated: Use SupabaseBmiService instead. This HTTP-based service
// is kept for backward compatibility but is no longer the default.
// The app now uses Supabase directly for BMI operations.
class BmiService implements BmiDataSource {
  BmiService({
    required ApiClient apiClient,
    required LocalStorageService localStorageService,
  }) : _apiClient = apiClient,
       _localStorageService = localStorageService;

  final ApiClient _apiClient;
  final LocalStorageService _localStorageService;

  @override
  Future<List<BmiRecordEntity>> getRecords() async {
    final dynamic response = await _apiClient.get(
      ApiConstants.bmiRecordsEndpoint,
      token: await _token,
    );
    final List<dynamic> recordsJson = _extractList(response);
    return recordsJson
        .map((dynamic item) => BmiRecordModel.fromJson(_extractObject(item)))
        .toList();
  }

  @override
  Future<BmiRecordEntity> getRecordDetail(String id) async {
    final dynamic response = await _apiClient.get(
      '${ApiConstants.bmiRecordsEndpoint}/$id',
      token: await _token,
    );
    return BmiRecordModel.fromJson(_extractObject(response));
  }

  @override
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request) async {
    final dynamic response = await _apiClient.post(
      ApiConstants.bmiRecordsEndpoint,
      body: request.toJson(),
      token: await _token,
    );
    return BmiRecordModel.fromJson(_extractObject(response));
  }

  @override
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request) async {
    final dynamic response = await _apiClient.put(
      '${ApiConstants.bmiRecordsEndpoint}/${request.id}',
      body: request.toJson(),
      token: await _token,
    );
    return BmiRecordModel.fromJson(_extractObject(response));
  }

  @override
  Future<void> deleteRecord(DeleteBmiRequest request) async {
    await _apiClient.delete(
      '${ApiConstants.bmiRecordsEndpoint}/${request.id}',
      token: await _token,
    );
  }

  Future<String> get _token async {
    return await _localStorageService.getString(StorageKeys.authToken) ?? '';
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }
    if (response is Map<String, dynamic>) {
      final dynamic data = response['data'];
      if (data is List<dynamic>) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        return <dynamic>[data];
      }
      final dynamic record = response['record'];
      if (record is Map<String, dynamic>) {
        return <dynamic>[record];
      }
      final dynamic bmiRecord = response['bmi_record'];
      if (bmiRecord is Map<String, dynamic>) {
        return <dynamic>[bmiRecord];
      }
      return <dynamic>[response];
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractObject(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      final dynamic record = response['record'];
      if (record is Map<String, dynamic>) {
        return record;
      }
      final dynamic bmiRecord = response['bmi_record'];
      if (bmiRecord is Map<String, dynamic>) {
        return bmiRecord;
      }
      return response;
    }
    return <String, dynamic>{};
  }
}
