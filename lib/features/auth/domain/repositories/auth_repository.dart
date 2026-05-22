import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';

abstract class AuthRepository {
  Future<UserEntity> login(LoginRequest request);
  Future<UserEntity> signup(SignupRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
}
