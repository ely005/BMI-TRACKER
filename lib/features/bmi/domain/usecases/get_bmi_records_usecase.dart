import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';

class GetBmiRecordsUseCase {
  GetBmiRecordsUseCase(this._bmiRepository);

  final BmiRepository _bmiRepository;

  Future<List<BmiRecordEntity>> call() {
    return _bmiRepository.getRecords();
  }
}
