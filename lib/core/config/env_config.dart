import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get appName => dotenv.env['APP_NAME'] ?? 'BMI Tracker';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get supabaseUrl {
    final String? url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL is not configured in .env');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final String? key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not configured in .env');
    }
    return key;
  }

  static bool get useMockData =>
      dotenv.env['USE_MOCK_DATA']?.toLowerCase() == 'true';
}
