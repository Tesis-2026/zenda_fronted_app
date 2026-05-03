import '../../core/models/user.dart';
import '../../core/services/ai_chat_api_service.dart';
import '../../core/services/quiz_api_service.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/badges/badges_screen.dart';
import '../../features/challenges/challenges_screen.dart';
import '../../features/education/education_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/predictions/predictions_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../features/surveys/sus_screen.dart';
import '../../features/surveys/survey_screen.dart';
import '../../features/transactions/transaction_list_screen.dart';
import 'demo_data.dart';
import 'mock_services.dart';

/// All ProviderScope overrides needed to run the app in demo mode.
// ignore: always_declare_return_types
buildDemoOverrides() {
  return [
    // ── Auth ─────────────────────────────────────────────────────────────────
    // Starts unauthenticated so the full sign-in / sign-up workflow is visible.
    authNotifierProvider.overrideWith(
      () => _DemoAuthNotifier(),
    ),

    // ── Accounts + transactions + streak (local providers) ───────────────────
    accountsProvider.overrideWith(
      (ref) async => DemoData.accounts,
    ),
    transactionsProvider.overrideWith(
      (ref) async => DemoData.transactions,
    ),
    transactionListProvider.overrideWith(
      (ref) async => DemoData.apiTransactions,
    ),
    streakStateProvider.overrideWith(
      (ref) async => DemoData.streak,
    ),

    // ── Dashboard summary providers ───────────────────────────────────────────
    daySummaryProvider.overrideWith(
      (ref) async => DemoData.daySummary,
    ),
    weekSummaryProvider.overrideWith(
      (ref) async => DemoData.weekSummary,
    ),
    monthSummaryProvider.overrideWith(
      (ref) async => DemoData.monthSummary,
    ),

    // ── Recommendations ───────────────────────────────────────────────────────
    recommendationsProvider.overrideWith(
      (ref) async => DemoData.recommendations,
    ),

    // ── Feature service providers ─────────────────────────────────────────────
    goalsServiceProvider.overrideWithValue(MockGoalsApiService()),
    budgetServiceProvider.overrideWithValue(MockBudgetApiService()),
    educationServiceProvider.overrideWithValue(MockEducationApiService()),
    challengesServiceProvider.overrideWithValue(MockChallengesApiService()),
    badgesServiceProvider.overrideWithValue(MockBadgesApiService()),
    predictionsServiceProvider.overrideWithValue(MockPredictionsApiService()),
    profileUserServiceProvider.overrideWithValue(MockUserApiService()),
    reportsInsightsServiceProvider.overrideWithValue(MockInsightsApiService()),
    quizServiceProvider.overrideWithValue(MockQuizApiService()),
    aiChatServiceProvider.overrideWithValue(MockAiChatApiService()),
    progressServiceProvider.overrideWithValue(MockProgressApiService()),
    surveysServiceProvider.overrideWithValue(MockSurveysApiService()),
    susSurveyServiceProvider.overrideWithValue(MockSurveysApiService()),
  ];
}

// ── Demo auth notifier ────────────────────────────────────────────────────────
//
// Starts unauthenticated. Any credentials are accepted for login / register.
// State is kept in a static field so it survives ref.invalidate() calls
// (e.g. when profile_setup_screen invalidates the provider after saving).
// When the notifier rebuilds and the stored user has profileCompleted: false,
// it promotes it to true — this is the signal that profile setup just ran.

class _DemoAuthNotifier extends AuthNotifier {
  static AuthState _state = const AuthState.unauthenticated();

  @override
  AuthState build() {
    final s = _state;
    if (s.isAuthenticated && s.user != null && !s.user!.profileCompleted) {
      // profile_setup_screen called ref.invalidate after completing setup —
      // advance the user to profileCompleted: true.
      final updated = User(
        id: s.user!.id,
        name: s.user!.name,
        email: s.user!.email,
        age: s.user!.age,
        university: s.user!.university,
        incomeType: s.user!.incomeType,
        averageMonthlyIncome: s.user!.averageMonthlyIncome,
        financialLiteracyLevel: s.user!.financialLiteracyLevel,
        profileCompleted: true,
        currency: s.user!.currency,
      );
      _state = AuthState.authenticated(updated);
    }
    return _state;
  }

  @override
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));
    _state = AuthState.authenticated(DemoData.user);
    state = _state;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));
    _state = AuthState.authenticated(
      User(
        id: 'demo-user-1',
        name: name,
        email: email,
        profileCompleted: false,
      ),
    );
    state = _state;
  }

  @override
  Future<void> logout() async {
    _state = const AuthState.unauthenticated();
    state = _state;
  }
}
