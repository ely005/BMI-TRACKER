import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/core/network/api_client.dart';
import 'package:bmi_tracker/core/storage/local_storage_service.dart';
import 'package:bmi_tracker/features/auth/data/services/auth_service.dart';
import 'package:bmi_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/signup_usecase.dart';
import 'package:bmi_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bmi_tracker/features/bmi/data/services/bmi_service.dart';
import 'package:bmi_tracker/features/bmi/data/services/supabase_bmi_service.dart';
import 'package:bmi_tracker/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/create_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/delete_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_record_detail_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_records_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/update_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';
import 'package:bmi_tracker/app/routes/app_routes.dart';
import 'package:bmi_tracker/app/theme/app_theme.dart';
import 'package:bmi_tracker/core/config/env_config.dart' as envs;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Core ──────────────────────────────────────────────────
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<ApiClient>(
          create: (context) => ApiClient(
            httpClient: context.read<http.Client>(),
          ),
        ),

        // ── Auth ──────────────────────────────────────────────────
        Provider<AuthService>(
          create: (context) => AuthService(
            httpClient: context.read<http.Client>(),
            localStorageService: context.read<LocalStorageService>(),
            useSupabase: true,
          ),
        ),
        Provider<AuthRepositoryImpl>(
          create: (context) =>
              AuthRepositoryImpl(authService: context.read<AuthService>()),
        ),
        Provider<LoginUseCase>(
          create: (context) =>
              LoginUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<SignupUseCase>(
          create: (context) =>
              SignupUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<LogoutUseCase>(
          create: (context) =>
              LogoutUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<CheckAuthStatusUseCase>(
          create: (context) =>
              CheckAuthStatusUseCase(context.read<AuthRepositoryImpl>()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            loginUseCase: context.read<LoginUseCase>(),
            signupUseCase: context.read<SignupUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
            checkAuthStatusUseCase: context.read<CheckAuthStatusUseCase>(),
          )..checkAuthStatus(),
        ),

        // ── BMI data source ───────────────────────────────────────
        Provider<BmiDataSource>(
          create: (context) => envs.EnvConfig.useMockData
              ? LocalBmiService(
                  localStorageService: context.read<LocalStorageService>(),
                  httpClient: context.read<http.Client>(),
                )
              : SupabaseBmiService(),
        ),
        Provider<BmiRepositoryImpl>(
          create: (context) =>
              BmiRepositoryImpl(
                dataSource: context.read<BmiDataSource>(),
              ),
        ),
        Provider<GetBmiRecordsUseCase>(
          create: (context) =>
              GetBmiRecordsUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<GetBmiRecordDetailUseCase>(
          create: (context) =>
              GetBmiRecordDetailUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<CreateBmiUseCase>(
          create: (context) =>
              CreateBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<UpdateBmiUseCase>(
          create: (context) =>
              UpdateBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<DeleteBmiUseCase>(
          create: (context) =>
              DeleteBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        ChangeNotifierProvider<BmiController>(
          create: (context) => BmiController(
            getBmiRecordsUseCase: context.read<GetBmiRecordsUseCase>(),
            getBmiRecordDetailUseCase:
                context.read<GetBmiRecordDetailUseCase>(),
            createBmiUseCase: context.read<CreateBmiUseCase>(),
            updateBmiUseCase: context.read<UpdateBmiUseCase>(),
            deleteBmiUseCase: context.read<DeleteBmiUseCase>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: envs.EnvConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
