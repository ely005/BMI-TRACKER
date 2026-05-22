import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';

class BmiRepositoryImpl implements BmiRepository {
  BmiRepositoryImpl({required BmiDataSource dataSource})
    : _dataSource = dataSource;

  final BmiDataSource _dataSource;

  @override
  Future<List<BmiRecordEntity>> getRecords() {
    return _dataSource.getRecords();
  }

  @override
  Future<BmiRecordEntity> getRecordDetail(String id) {
    return _dataSource.getRecordDetail(id);
  }

  @override
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request) {
    return _dataSource.createRecord(request);
  }

  @override
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request) {
    return _dataSource.updateRecord(request);
  }

  @override
  Future<void> deleteRecord(DeleteBmiRequest request) {
    return _dataSource.deleteRecord(request);
  }
}
