import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';

class GetBmiRecordDetailUseCase {
  GetBmiRecordDetailUseCase(this._bmiRepository);

  final BmiRepository _bmiRepository;

  Future<BmiRecordEntity> call(String id) {
    return _bmiRepository.getRecordDetail(id);
  }
}
