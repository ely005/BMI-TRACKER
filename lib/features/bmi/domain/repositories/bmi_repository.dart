import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';

abstract class BmiRepository {
  Future<List<BmiRecordEntity>> getRecords();
  Future<BmiRecordEntity> getRecordDetail(String id);
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request);
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request);
  Future<void> deleteRecord(DeleteBmiRequest request);
}
