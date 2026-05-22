import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:bmi_tracker/core/errors/exceptions.dart';
import 'package:bmi_tracker/core/storage/local_storage_service.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';
import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';

/// AuthService backed by either the local Flask REST API (port 51266)
/// or Supabase auth when [useSupabase] is true.
class AuthService {
  AuthService({
    required http.Client httpClient,
    required LocalStorageService localStorageService,
    bool useSupabase = false,
  })  : _httpClient = httpClient,
        _localStorageService = localStorageService,
        _useSupabase = useSupabase;

  final http.Client _httpClient;
  final LocalStorageService _localStorageService;
  final bool _useSupabase;

  static const String _baseUrl = 'http://localhost:51266/api';

  Map<String, String> _headers({String? token}) => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Uri _url(String path) => Uri.parse('$_baseUrl$path');

  Future<UserEntity> login(LoginRequest request) async {
    if (_useSupabase) {
      final supabase.AuthResponse response = await supabase.Supabase.instance.client.auth.signInWithPassword(
        email: request.email.trim(),
        password: request.password,
      );

      final supabase.User? user = response.user;
      final supabase.Session? session = response.session;
      final String? token = session?.accessToken;

      if (user == null) {
        throw AuthException('Login failed: No user returned from Supabase');
      }

      final UserEntity userModel = UserEntity(
        id: user.id,
        name: user.userMetadata?['name']?.toString() ?? '',
        email: user.email ?? '',
        token: token,
      );

      if (token != null && token.isNotEmpty) {
        await saveAuthData(userModel);
      }

      return userModel;
    }

    final http.Response response = await _httpClient.post(
      _url('/auth/login'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    return _handleAuthResponse(response);
  }

  Future<UserEntity> signup(SignupRequest request) async {
    if (_useSupabase) {
      final supabase.AuthResponse response = await supabase.Supabase.instance.client.auth.signUp(
        email: request.email.trim(),
        password: request.password,
        data: {'name': request.name.trim()},
      );

      final supabase.User? user = response.user;
      final supabase.Session? session = response.session;
      final String? token = session?.accessToken;

      if (user == null) {
        throw AuthException('Signup failed: No user returned from Supabase');
      }

      final UserEntity userModel = UserEntity(
        id: user.id,
        name: user.userMetadata?['name']?.toString() ?? '',
        email: user.email ?? '',
        token: token,
      );

      if (token != null && token.isNotEmpty) {
        await saveAuthData(userModel);
      }

      return userModel;
    }

    final http.Response response = await _httpClient.post(
      _url('/auth/signup'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    return _handleAuthResponse(response);
  }

  Future<UserEntity?> getCurrentUser() async {
    if (_useSupabase) {
      final supabase.Session? session = supabase.Supabase.instance.client.auth.currentSession;
      final supabase.User? user = supabase.Supabase.instance.client.auth.currentUser;
      if (session == null || user == null) {
        return null;
      }
      return UserEntity(
        id: user.id,
        name: user.userMetadata?['name']?.toString() ?? '',
        email: user.email ?? '',
        token: session.accessToken,
      );
    }

    final String token = await _localStorageService.getString('auth_token') ?? '';
    if (token.isEmpty) return null;

    final http.Response response = await _httpClient.get(
      _url('/auth/me'),
      headers: _headers(token: token),
    );

    if (response.statusCode != 200) {
      await _localStorageService.remove('auth_token');
      return null;
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return UserEntity(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      token: token,
    );
  }

  Future<void> logout() async {
    if (_useSupabase) {
      await supabase.Supabase.instance.client.auth.signOut();
      await _localStorageService.remove('auth_token');
      return;
    }

    final String token = await _localStorageService.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      await _httpClient.post(
        _url('/auth/logout'),
        headers: _headers(token: token),
      );
    }
    await _localStorageService.remove('auth_token');
  }

  Future<void> saveAuthData(UserEntity user) async {
    await _localStorageService.saveString('auth_token', user.token ?? '');
    await _localStorageService.saveString('user_id', user.id);
    await _localStorageService.saveString('user_name', user.name);
    await _localStorageService.saveString('user_email', user.email);
    await _localStorageService.saveBool('is_logged_in', true);
  }

  Future<void> clearAuthData() async {
    await _localStorageService.remove('auth_token');
    await _localStorageService.remove('user_id');
    await _localStorageService.remove('user_name');
    await _localStorageService.remove('user_email');
    await _localStorageService.saveBool('is_logged_in', false);
  }

  Future<bool> isLoggedIn() async {
    if (_useSupabase) {
      final supabase.Session? session = supabase.Supabase.instance.client.auth.currentSession;
      return session != null && session.accessToken.isNotEmpty;
    }

    final token = await _localStorageService.getString('auth_token');
    return (token ?? '').isNotEmpty;
  }

  UserEntity _handleAuthResponse(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(
        'Auth request failed (${response.statusCode}): ${response.body}',
      );
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return UserEntity(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      token: json['token'] as String?,
    );
  }
}
