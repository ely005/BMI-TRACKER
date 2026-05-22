import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';

class LoginUseCase {
  LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call(LoginRequest request) {
    return _authRepository.login(request);
  }
}
