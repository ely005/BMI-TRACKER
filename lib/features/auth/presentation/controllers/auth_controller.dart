import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/signup_usecase.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _signupUseCase = signupUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase;

  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  UserEntity? currentUser;
  bool isLoading = false;
  bool isAuthenticated = false;
  String? errorMessage;

  String? get userName => currentUser?.name;

  Future<bool> login(LoginRequest request) async {
    final String? validationError = request.validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    return _runAuthAction(() async {
      currentUser = await _loginUseCase(request);
      isAuthenticated = true;
      return true;
    });
  }

  // NOTE: For direct login after signup, disable email confirmation in Supabase Dashboard.
  // Go to: Supabase Dashboard → Authentication → Providers → Email → Turn OFF "Enable email confirmation"
  // If email confirmation is enabled, the returned session will be null and users will see
  // "Please verify your email before logging in." message.
  Future<bool> signup(SignupRequest request) async {
    final String? validationError = request.validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final UserEntity user = await _signupUseCase(request);
      // If user has a token, they're authenticated immediately
      if (user.token != null && user.token!.isNotEmpty) {
        currentUser = user;
        isAuthenticated = true;
        return true;
      } else {
        // Email verification required - no session yet
        isAuthenticated = false;
        currentUser = null;
        errorMessage =
            'Account created! Please verify your email before logging in.';
        return false;
      }
    } catch (e) {
      isAuthenticated = false;
      currentUser = null;
      errorMessage = _readableError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _logoutUseCase();
      currentUser = null;
      isAuthenticated = false;
    } catch (e) {
      errorMessage = _readableError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      isAuthenticated = await _checkAuthStatusUseCase();
      if (isAuthenticated) {
        currentUser = await _checkAuthStatusUseCase.getCurrentUser();
      } else {
        currentUser = null;
      }
    } catch (e) {
      isAuthenticated = false;
      currentUser = null;
      errorMessage = _readableError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<bool> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      isAuthenticated = false;
      currentUser = null;
      errorMessage = _readableError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _readableError(Object error) {
    if (error is AuthException) {
      // Handle common Supabase auth errors
      switch (error.code) {
        case 'invalid_credentials':
          return 'Invalid email or password.';
        case 'user_not_found':
          return 'No account found with this email.';
        case 'email_taken':
          return 'This email is already registered.';
        case 'weak_password':
          return 'Password is too weak. Please use at least 6 characters.';
        default:
          return error.message.isNotEmpty == true
              ? error.message
              : 'Authentication failed. Please try again.';
      }
    }
    final String message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
