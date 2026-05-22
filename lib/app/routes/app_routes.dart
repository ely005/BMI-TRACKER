import 'package:go_router/go_router.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:bmi_tracker/features/auth/presentation/pages/signup_page.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/presentation/pages/bmi_dashboard_page.dart';
import 'package:bmi_tracker/features/bmi/presentation/pages/bmi_detail_page.dart';
import 'package:bmi_tracker/features/bmi/presentation/pages/bmi_form_page.dart';
import 'package:bmi_tracker/features/bmi/presentation/pages/bmi_history_page.dart';
import 'package:bmi_tracker/features/splash/presentation/pages/splash_page.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const BmiDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.bmiForm,
        builder: (context, state) {
          final Object? extra = state.extra;
          final BmiRecordEntity? record = extra is BmiRecordEntity
              ? extra
              : null;
          return BmiFormPage(
            initialHeight: record?.heightCm,
            initialWeight: record?.weightKg,
            initialNotes: record?.notes,
          );
        },
      ),
      GoRoute(
        path: RouteNames.bmiDetail,
        builder: (context, state) {
          final Object? extra = state.extra;
          final String? recordId = extra is String ? extra : null;
          return BmiDetailPage(recordId: recordId);
        },
      ),
      GoRoute(
        path: RouteNames.bmiHistory,
        builder: (context, state) => const BmiHistoryPage(),
      ),
    ],
  );
}
