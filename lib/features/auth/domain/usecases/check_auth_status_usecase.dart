import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<bool> call() {
    return _authRepository.isLoggedIn();
  }

  Future<UserEntity?> getCurrentUser() {
    return _authRepository.getCurrentUser();
  }
}
