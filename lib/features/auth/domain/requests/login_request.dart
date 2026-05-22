import 'package:bmi_tracker/core/validators/auth_validator.dart';

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email.trim(), 'password': password};
  }

  String? validate() {
    final String? emailError = AuthValidator.validateEmail(email);
    if (emailError != null) {
      return emailError;
    }

    final String? passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      return passwordError;
    }

    return null;
  }
}
