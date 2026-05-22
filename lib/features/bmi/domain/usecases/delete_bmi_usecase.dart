import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';

class DeleteBmiUseCase {
  DeleteBmiUseCase(this._bmiRepository);

  final BmiRepository _bmiRepository;

  Future<void> call(DeleteBmiRequest request) {
    return _bmiRepository.deleteRecord(request);
  }
}
