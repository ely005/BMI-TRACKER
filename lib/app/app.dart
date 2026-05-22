import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/app_routes.dart';
import 'package:bmi_tracker/app/theme/app_theme.dart';
import 'package:bmi_tracker/core/config/env_config.dart';
import 'package:bmi_tracker/core/storage/local_storage_service.dart';
import 'package:bmi_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bmi_tracker/features/auth/data/services/auth_service.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bmi_tracker/features/auth/domain/usecases/signup_usecase.dart';
import 'package:bmi_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bmi_tracker/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:bmi_tracker/features/bmi/data/services/mock_bmi_service.dart';
import 'package:bmi_tracker/features/bmi/data/services/supabase_bmi_service.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/create_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/delete_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_record_detail_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_records_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/update_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),
        Provider<AuthService>(
          create: (BuildContext context) => AuthService(
            localStorageService: context.read<LocalStorageService>(),
          ),
        ),
        Provider<AuthRepositoryImpl>(
          create: (BuildContext context) =>
              AuthRepositoryImpl(authService: context.read<AuthService>()),
        ),
        Provider<LoginUseCase>(
          create: (BuildContext context) =>
              LoginUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<SignupUseCase>(
          create: (BuildContext context) =>
              SignupUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<LogoutUseCase>(
          create: (BuildContext context) =>
              LogoutUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider<CheckAuthStatusUseCase>(
          create: (BuildContext context) =>
              CheckAuthStatusUseCase(context.read<AuthRepositoryImpl>()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (BuildContext context) => AuthController(
            loginUseCase: context.read<LoginUseCase>(),
            signupUseCase: context.read<SignupUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
            checkAuthStatusUseCase: context.read<CheckAuthStatusUseCase>(),
          )..checkAuthStatus(),
        ),
        Provider<BmiDataSource>(
          create: (BuildContext context) {
            if (EnvConfig.useMockData) {
              return MockBmiService();
            }
            return SupabaseBmiService();
          },
        ),
        Provider<BmiRepositoryImpl>(
          create: (BuildContext context) =>
              BmiRepositoryImpl(dataSource: context.read<BmiDataSource>()),
        ),
        Provider<GetBmiRecordsUseCase>(
          create: (BuildContext context) =>
              GetBmiRecordsUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<GetBmiRecordDetailUseCase>(
          create: (BuildContext context) =>
              GetBmiRecordDetailUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<CreateBmiUseCase>(
          create: (BuildContext context) =>
              CreateBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<UpdateBmiUseCase>(
          create: (BuildContext context) =>
              UpdateBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        Provider<DeleteBmiUseCase>(
          create: (BuildContext context) =>
              DeleteBmiUseCase(context.read<BmiRepositoryImpl>()),
        ),
        ChangeNotifierProvider<BmiController>(
          create: (BuildContext context) => BmiController(
            getBmiRecordsUseCase: context.read<GetBmiRecordsUseCase>(),
            getBmiRecordDetailUseCase: context
                .read<GetBmiRecordDetailUseCase>(),
            createBmiUseCase: context.read<CreateBmiUseCase>(),
            updateBmiUseCase: context.read<UpdateBmiUseCase>(),
            deleteBmiUseCase: context.read<DeleteBmiUseCase>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: EnvConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
