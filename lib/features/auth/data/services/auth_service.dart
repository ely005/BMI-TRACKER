import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bmi_tracker/core/constants/storage_keys.dart';
import 'package:bmi_tracker/core/storage/local_storage_service.dart';
import 'package:bmi_tracker/features/auth/data/models/user_model.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';

class AuthService {
  AuthService({required LocalStorageService localStorageService})
    : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;

  Future<UserModel> login(LoginRequest request) async {
    final AuthResponse response = await Supabase.instance.client.auth
        .signInWithPassword(
          email: request.email.trim(),
          password: request.password,
        );

    final User? user = response.user;
    final String? token = response.session?.accessToken;

    if (user == null) {
      throw AuthException('Login failed: No user returned from Supabase');
    }

    final UserModel userModel = UserModel.fromSupabaseUser(user, token: token);
    await saveAuthData(userModel);
    return userModel;
  }

  // NOTE: For direct signup without email verification, disable email confirmation in Supabase Dashboard.
  // Go to: Supabase Dashboard → Authentication → Providers → Email → Turn OFF "Enable email confirmation"
  // If email confirmation is enabled, users will need to verify their email before logging in.
  Future<UserModel> signup(SignupRequest request) async {
    final AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: request.email.trim(),
      password: request.password,
      data: {'name': request.name.trim()},
    );

    final User? user = response.user;
    final Session? session = response.session;
    final String? token = session?.accessToken;

    if (user == null) {
      throw AuthException('Signup failed: No user returned from Supabase');
    }

    // If email confirmation is enabled, session may be null.
    // For direct confirmation and immediate login, disable email confirmation in Supabase.
    final UserModel userModel = UserModel.fromSupabaseUser(user, token: token);
    if (session != null && token != null && token.isNotEmpty) {
      await saveAuthData(userModel);
    }

    return userModel;
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore signOut failures and clear local auth state anyway.
    }

    await clearAuthData();
  }

  Future<void> saveAuthData(UserModel user) async {
    await _localStorageService.saveString(StorageKeys.userId, user.id);
    await _localStorageService.saveString(StorageKeys.userName, user.name);
    await _localStorageService.saveString(StorageKeys.userEmail, user.email);
    if ((user.token ?? '').isNotEmpty) {
      await _localStorageService.saveString(StorageKeys.authToken, user.token!);
    }
    await _localStorageService.saveBool(StorageKeys.isLoggedIn, true);
  }

  Future<void> clearAuthData() async {
    await _localStorageService.remove(StorageKeys.authToken);
    await _localStorageService.remove(StorageKeys.userId);
    await _localStorageService.remove(StorageKeys.userName);
    await _localStorageService.remove(StorageKeys.userEmail);
    await _localStorageService.saveBool(StorageKeys.isLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      return true;
    }
    return await _localStorageService.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    final User? user = Supabase.instance.client.auth.currentUser;
    final Session? session = Supabase.instance.client.auth.currentSession;

    if (user == null || session == null) {
      return null;
    }

    return UserModel.fromSupabaseUser(user, token: session.accessToken);
  }
}
