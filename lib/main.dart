import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bmi_tracker/app/app.dart';
import 'package:bmi_tracker/core/config/env_config.dart' as envs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep bootstrapping even if .env is absent (uses defaults).
  }

  await Supabase.initialize(
    url: envs.EnvConfig.supabaseUrl,
    anonKey: envs.EnvConfig.supabaseAnonKey,
  );

  // Local mode: Flask REST API on http://localhost:51266
  // Supabase auth is enabled for the current app build.

  debugPrint('── BMI Tracker local mode ──────────────────────');
  debugPrint('  API base     : ${envs.EnvConfig.apiBaseUrl}');
  debugPrint('  Use mock data: ${envs.EnvConfig.useMockData}');
  debugPrint('  Supabase URL : ${envs.EnvConfig.supabaseUrl}');
  debugPrint('─────────────────────────────────────────────────');

  runApp(const App());
}
