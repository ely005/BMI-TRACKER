import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';

class UpdateBmiUseCase {
  UpdateBmiUseCase(this._bmiRepository);

  final BmiRepository _bmiRepository;

  Future<BmiRecordEntity> call(UpdateBmiRequest request) {
    return _bmiRepository.updateRecord(request);
  }
}
