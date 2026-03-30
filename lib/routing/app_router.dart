import 'package:go_router/go_router.dart';
import '../features/onboarding/splash_decider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/auth_gate.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/add_transaction_screen.dart';
import '../features/categories/category_management_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashDecider(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final redirectToRegister = state.uri.queryParameters['flow'] == 'register';
          return OnboardingScreen(redirectToRegister: redirectToRegister);
        },
      ),

      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const AuthGate(child: LoginScreen()),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const AuthGate(child: RegisterScreen()),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Legacy login route (redirect to /auth/login)
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/auth/login',
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
    ],
  );
}
