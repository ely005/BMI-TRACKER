import 'package:bmi_tracker/features/auth/data/services/auth_service.dart';
import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  @override
  Future<UserEntity> login(LoginRequest request) {
    return _authService.login(request);
  }

  @override
  Future<UserEntity> signup(SignupRequest request) {
    return _authService.signup(request);
  }

  @override
  Future<void> logout() {
    return _authService.logout();
  }

  @override
  Future<bool> isLoggedIn() {
    return _authService.isLoggedIn();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _authService.getCurrentUser();
  }
}
