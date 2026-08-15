import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_request_page.dart';
import '../../features/auth/presentation/pages/forgot_password_reset_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/main/presentation/pages/main_shell_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/service_selection/presentation/pages/service_selection_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/advanced/presentation/cubit/advanced_cubit.dart';
import '../../features/advanced/presentation/cubit/eta_cubit.dart';
import '../../features/trip/presentation/cubit/trip_cubit.dart';
import '../../features/trip/presentation/pages/trip_screen.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/wallet/presentation/pages/wallet_dashboard_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import 'app_routes.dart';

/// Central route table for the application.
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const sessionExpiredMessage =
      'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';

  /// Clears the nav stack and opens login after an expired/revoked session.
  static void goToLoginOnSessionExpired() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: sessionExpiredMessage,
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.splash => MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        ),
      AppRoutes.onboarding => MaterialPageRoute<void>(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        ),
      AppRoutes.login => MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: LoginPage(successMessage: settings.arguments as String?),
          ),
          settings: settings,
        ),
      AppRoutes.register => MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => sl<RegisterCubit>(),
            child: const RegisterPage(),
          ),
          settings: settings,
        ),
      AppRoutes.forgotPassword => MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => sl<ForgotPasswordCubit>(),
            child: const ForgotPasswordRequestPage(),
          ),
          settings: settings,
        ),
      AppRoutes.forgotPasswordReset => MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => sl<ForgotPasswordCubit>(),
            child: ForgotPasswordResetPage(
              email: settings.arguments as String? ?? '',
            ),
          ),
          settings: settings,
        ),
      AppRoutes.serviceSelection => MaterialPageRoute<void>(
          builder: (_) => const ServiceSelectionScreen(),
          settings: settings,
        ),
      AppRoutes.home => MaterialPageRoute<void>(
          builder: (_) => const MainShellPage(),
          settings: settings,
        ),
      AppRoutes.trip => MaterialPageRoute<void>(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<TripCubit>()),
              BlocProvider(create: (_) => sl<EtaCubit>()..load()),
              BlocProvider(create: (_) => sl<AdvancedCubit>()),
            ],
            child: const TripScreen(),
          ),
          settings: settings,
        ),
      AppRoutes.walletTopUp => MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => sl<WalletCubit>(),
            child: const WalletDashboardPage(),
          ),
          settings: settings,
        ),
      AppRoutes.checkout => MaterialPageRoute<void>(
          builder: (_) {
            final args = settings.arguments as Map<String, dynamic>?;
            return CheckoutPage(
              currentBalance: args?['currentBalance'] ?? 1500.0,
              totalAmount: args?['totalAmount'] ?? 450.0,
            );
          },
          settings: settings,
        ),
      _ => MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        ),
    };
  }

  static void goToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  static void goToLogin(BuildContext context, {String? successMessage}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
      arguments: successMessage,
    );
  }

  static void goToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  static void goToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  static void goToForgotPasswordReset(BuildContext context, {required String email}) {
    Navigator.of(context).pushNamed(
      AppRoutes.forgotPasswordReset,
      arguments: email,
    );
  }

  /// Post-auth gateway: Food Delivery vs Request a Ride.
  static void goToServiceSelection(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.serviceSelection,
      (_) => false,
    );
  }

  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (_) => false,
    );
  }

  static void goToTrip(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.trip);
  }
}
