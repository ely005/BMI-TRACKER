import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';

class CreateBmiUseCase {
  CreateBmiUseCase(this._bmiRepository);

  final BmiRepository _bmiRepository;

  Future<BmiRecordEntity> call(CreateBmiRequest request) {
    return _bmiRepository.createRecord(request);
  }
}
