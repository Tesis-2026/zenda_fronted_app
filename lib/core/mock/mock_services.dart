import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/summary_models.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/badges_api_service.dart';
import '../services/budget_api_service.dart';
import '../services/challenges_api_service.dart';
import '../services/education_api_service.dart';
import '../services/goals_api_service.dart';
import '../services/insights_api_service.dart';
import '../services/predictions_api_service.dart';
import '../services/recommendations_api_service.dart';
import '../services/transaction_api_service.dart';
import '../services/user_api_service.dart';
import 'demo_data.dart';

class MockInsightsApiService extends InsightsApiService {
  @override
  Future<PeriodSummary> getDaySummary({required String date}) async =>
      DemoData.daySummary;

  @override
  Future<PeriodSummary> getWeekSummary({required int year, required int week}) async =>
      DemoData.weekSummary;

  @override
  Future<PeriodSummary> getMonthSummary({required int year, required int month}) async =>
      DemoData.monthSummary;

  @override
  Future<ProgressSummary> getProgress() async => DemoData.progressSummary;

  @override
  Future<List<MonthComparisonEntry>> getComparison({required int months}) async =>
      DemoData.monthComparison;

  @override
  Future<List<int>> downloadPdfReport({required int year, required int month}) async => [];
}

class MockGoalsApiService extends GoalsApiService {
  @override
  Future<List<SavingsGoal>> getAll() async => DemoData.goals;

  @override
  Future<SavingsGoal> create({
    required String name,
    required double targetAmount,
    String? dueDate,
  }) async {
    return SavingsGoal(
      id: 'goal-new-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo-user-1',
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      dueDate: dueDate,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<SavingsGoal> contribute(String id, {required double amount}) async {
    final goal = DemoData.goals.firstWhere(
      (g) => g.id == id,
      orElse: () => DemoData.goals.first,
    );
    return SavingsGoal(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + amount,
      dueDate: goal.dueDate,
      createdAt: goal.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<GoalContribution>> getContributions(String id) async => [];

  @override
  Future<SavingsGoal> complete(String id) async {
    final goal = DemoData.goals.firstWhere(
      (g) => g.id == id,
      orElse: () => DemoData.goals.first,
    );
    return SavingsGoal(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.targetAmount,
      dueDate: goal.dueDate,
      createdAt: goal.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> delete(String id) async {}
}

class MockBudgetApiService extends BudgetApiService {
  @override
  Future<List<Budget>> getAll({int? month, int? year}) async => DemoData.budgets;

  @override
  Future<Budget> create({
    required double amountLimit,
    required int month,
    required int year,
    String? categoryId,
  }) async {
    return Budget(
      id: 'budget-new-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo-user-1',
      categoryId: categoryId,
      amountLimit: amountLimit,
      month: month,
      year: year,
      currentSpent: 0,
      percentageUsed: 0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<Budget> update(String id, {required double amountLimit}) async =>
      DemoData.budgets.firstWhere((b) => b.id == id, orElse: () => DemoData.budgets.first);

  @override
  Future<void> delete(String id) async {}
}

class MockEducationApiService extends EducationApiService {
  @override
  Future<List<EducationTopic>> listTopics() async => DemoData.educationTopics;

  @override
  Future<EducationTopic> getTopic(String id) async {
    return DemoData.educationTopics.firstWhere(
      (t) => t.id == id,
      orElse: () => DemoData.educationTopics.first,
    );
  }

  @override
  Future<void> completeTopic(String id) async {}
}

class MockChallengesApiService extends ChallengesApiService {
  @override
  Future<List<Challenge>> getAll() async => DemoData.challenges;

  @override
  Future<void> accept(String id) async {}

  @override
  Future<void> complete(String id) async {}
}

class MockBadgesApiService extends BadgesApiService {
  @override
  Future<List<ZendaBadge>> getAll() async => DemoData.badges;
}

class MockPredictionsApiService extends PredictionsApiService {
  @override
  Future<PredictionResult> getExpensePrediction() async =>
      DemoData.expensePrediction;
}

class MockRecommendationsApiService extends RecommendationsApiService {
  @override
  Future<List<Recommendation>> getAll() async => DemoData.recommendations;

  @override
  Future<void> submitFeedback(String id, {required bool accepted}) async {}
}

class MockUserApiService extends UserApiService {
  @override
  Future<User> getProfile() async => DemoData.user;

  @override
  Future<User> updateProfile({
    String? fullName,
    int? age,
    String? university,
    IncomeType? incomeType,
    double? averageMonthlyIncome,
    FinancialLiteracyLevel? financialLiteracyLevel,
    bool? profileCompleted,
    String? currency,
  }) async =>
      DemoData.user;
}

class MockTransactionApiService extends TransactionApiService {
  @override
  Future<List<Map<String, dynamic>>> getAll({
    String? type,
    String? from,
    String? to,
    String? categoryId,
  }) async {
    if (type == null) return DemoData.apiTransactions;
    return DemoData.apiTransactions.where((tx) {
      final txType = tx['type'] as String;
      return txType.toUpperCase() == type.toUpperCase();
    }).toList();
  }

  @override
  Future<CreateTransactionResult> create({
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
    String? customCategoryName,
  }) async {
    return (completedChallenges: <String>[], anomalyAlert: null);
  }

  @override
  Future<void> update({
    required String id,
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
  }) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<TransactionCategory?> classify({
    required String description,
    required double amount,
  }) async => null;
}
