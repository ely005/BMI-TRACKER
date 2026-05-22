import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bmi_tracker/core/config/env_config.dart';
import 'package:bmi_tracker/core/errors/exceptions.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Future<dynamic> get(String endpoint, {String? token}) async {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    final http.Response response = await _httpClient.get(
      uri,
      headers: _headers(token),
    );
    return _parseResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    final http.Response response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _parseResponse(response);
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    final http.Response response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _parseResponse(response);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$endpoint');
    final http.Response response = await _httpClient.delete(
      uri,
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );
    return _parseResponse(response);
  }

  Map<String, String> _headers(String? token) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _parseResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String rawBody = response.body;

    dynamic decodedBody;
    if (rawBody.isNotEmpty) {
      try {
        decodedBody = jsonDecode(rawBody);
      } catch (_) {
        decodedBody = rawBody;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    throw ServerException('Request failed ($statusCode)');
  }
}
