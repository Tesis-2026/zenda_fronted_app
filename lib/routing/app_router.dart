import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/onboarding/splash_decider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/profile_setup_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/email_sent_screen.dart';
import '../features/consent/consent_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/transactions/add_transaction_screen.dart';
import '../features/budget/budget_screen.dart';
import '../features/categories/category_management_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/goals/goal_detail_screen.dart';
import '../core/models/savings_goal.dart';
import '../features/reports/reports_screen.dart';
import '../features/predictions/predictions_screen.dart';
import '../features/recommendations/recommendations_screen.dart';
import '../features/education/education_screen.dart';
import '../features/education/topic_detail_screen.dart';
import '../features/education/quiz_screen.dart';
import '../features/challenges/challenges_screen.dart';
import '../features/badges/badges_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/surveys/survey_screen.dart';
import '../features/surveys/survey_comparison_screen.dart';
import '../features/transactions/edit_transaction_screen.dart';
import '../features/notifications/notification_preferences_screen.dart';
import '../features/ai_chat/ai_chat_screen.dart';

// Routes that do not require authentication.
const _publicRoutes = {
  '/',
  '/onboarding',
  '/consent',
  '/auth/forgot-password',
  '/auth/verify-code',
  '/auth/reset-password',
  '/auth/email-sent',
  '/login',
};

// Routes that authenticated users should be redirected away from.
const _authOnlyRoutes = {'/auth/login', '/auth/register'};

// Routes exempt from the profile-setup redirect.
const _profileSetupExempt = {'/profile-setup', '/auth/email-sent', '/dashboard'};

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _sub = ref.listen<AuthState>(authNotifierProvider, (_, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final container = ProviderScope.containerOf(context, listen: false);
      final auth = container.read(authNotifierProvider);

      if (auth.isLoading) return null;

      final loc = state.matchedLocation;

      // Unauthenticated user trying to reach a protected route → login.
      if (!auth.isAuthenticated &&
          !_publicRoutes.contains(loc) &&
          !_authOnlyRoutes.contains(loc)) {
        return '/auth/login';
      }

      // Authenticated user trying to reach login/register → dashboard.
      if (auth.isAuthenticated && _authOnlyRoutes.contains(loc)) {
        return '/dashboard';
      }

      // Authenticated user with incomplete profile → profile setup.
      if (auth.isAuthenticated &&
          !(auth.user?.profileCompleted ?? true) &&
          !_profileSetupExempt.contains(loc) &&
          !_publicRoutes.contains(loc)) {
        return '/profile-setup';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashDecider(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final redirectToRegister =
              state.uri.queryParameters['flow'] == 'register';
          return OnboardingScreen(redirectToRegister: redirectToRegister);
        },
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verify-code',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) {
          final token = state.extra as String?;
          return ResetPasswordScreen(prefillToken: token);
        },
      ),
      GoRoute(
        path: '/auth/email-sent',
        builder: (context, state) => const EmailSentScreen(),
      ),

      // Legacy login route
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/auth/login',
      ),

      // Profile setup (shown after registration when profileCompleted == false)
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Protected routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final goal = state.extra as SavingsGoal;
              return GoalDetailScreen(goal: goal);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/predictions',
        builder: (context, state) => const PredictionsScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: '/education',
        builder: (context, state) => const EducationScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => TopicDetailScreen(
              topicId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'quiz',
                builder: (context, state) => QuizScreen(
                  topicId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/surveys/pre',
        builder: (context, state) => const SurveyScreen(isPre: true),
      ),
      GoRoute(
        path: '/surveys/post',
        builder: (context, state) => const SurveyScreen(isPre: false),
      ),
      GoRoute(
        path: '/surveys/comparison',
        builder: (context, state) => const SurveyComparisonScreen(),
      ),
      GoRoute(
        path: '/edit-transaction',
        builder: (context, state) {
          final tx = state.extra as Map<String, dynamic>;
          return EditTransactionScreen(transaction: tx);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
});
