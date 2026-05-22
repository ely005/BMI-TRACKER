import 'package:bmi_tracker/core/validators/auth_validator.dart';

class SignupRequest {
  const SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  String? validate() {
    final String? nameError = AuthValidator.validateName(name);
    if (nameError != null) {
      return nameError;
    }

    final String? emailError = AuthValidator.validateEmail(email);
    if (emailError != null) {
      return emailError;
    }

    final String? passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      return passwordError;
    }

    if (passwordConfirmation.trim().isEmpty) {
      return 'Password confirmation is required';
    }

    if (password != passwordConfirmation) {
      return 'Password confirmation does not match';
    }

    return null;
  }
}
