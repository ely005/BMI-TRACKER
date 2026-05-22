import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';

class SignupUseCase {
  SignupUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call(SignupRequest request) {
    return _authRepository.signup(request);
  }
}
