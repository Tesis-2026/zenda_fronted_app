import '../models/budget.dart';
import '../models/category.dart';
import '../models/quiz_models.dart';
import '../models/savings_goal.dart';
import '../models/summary_models.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/category_api_service.dart';
import '../services/education_api_service.dart';
import '../services/budget_api_service.dart';
import '../services/goals_api_service.dart';
import '../services/insights_api_service.dart';
import '../services/predictions_api_service.dart';
import '../services/progress_api_service.dart';
import '../services/quiz_api_service.dart';
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
  static final _goals = List<SavingsGoal>.from(DemoData.goals);

  @override
  Future<List<SavingsGoal>> getAll() async => List.unmodifiable(_goals);

  @override
  Future<SavingsGoal> create({
    required String name,
    required double targetAmount,
    String? dueDate,
  }) async {
    final goal = SavingsGoal(
      id: 'goal-new-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo-user-1',
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      dueDate: dueDate,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _goals.add(goal);
    return goal;
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
  Future<void> delete(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }
}

class MockBudgetApiService extends BudgetApiService {
  static final _budgets = List<Budget>.from(DemoData.budgets);

  @override
  Future<List<Budget>> getAll({int? month, int? year}) async =>
      List.unmodifiable(_budgets);

  @override
  Future<Budget> create({
    required double amountLimit,
    required int month,
    required int year,
    String? categoryId,
  }) async {
    final budget = Budget(
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
    _budgets.add(budget);
    return budget;
  }

  @override
  Future<Budget> update(String id, {required double amountLimit}) async {
    final idx = _budgets.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = _budgets[idx];
      final updated = Budget(
        id: b.id, userId: b.userId, categoryId: b.categoryId,
        categoryName: b.categoryName, amountLimit: amountLimit,
        month: b.month, year: b.year, currentSpent: b.currentSpent,
        percentageUsed: (b.currentSpent / amountLimit * 100).clamp(0, 100),
        createdAt: b.createdAt, updatedAt: DateTime.now().toIso8601String(),
      );
      _budgets[idx] = updated;
      return updated;
    }
    return _budgets.first;
  }

  @override
  Future<void> delete(String id) async {
    _budgets.removeWhere((b) => b.id == id);
  }
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

  @override
  Future<PersonalizedQuizResult> getPersonalizedQuiz({String language = 'es'}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const PersonalizedQuizResult(
      attemptsRemainingToday: 3,
      questions: [
        PersonalizedQuizQuestion(
          id: 'pq-1',
          difficulty: 'INTERMEDIATE',
          text: 'Your food spending this month is S/ 116 out of a S/ 150 budget (77%). Which action is most effective for the remaining 8 days?',
          options: [
            'Cook at home 3 times this week',
            'Switch to a cheaper supermarket',
            'Cut out all restaurant meals',
            'Track every food purchase daily',
          ],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-2',
          difficulty: 'BEGINNER',
          text: 'Your Emergency Fund goal is at 28% (S/ 850 of S/ 3,000). At your current pace you\'ll reach it in December. What would get you there 3 months earlier?',
          options: [
            'Add S/ 50 extra per month',
            'Add S/ 150 extra per month',
            'Add S/ 200 extra per month',
            'Do nothing — the current pace is fine',
          ],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-3',
          difficulty: 'INTERMEDIATE',
          text: 'You have a Visa Credit card with S/ 1,150 available. Your current utilization rate is about 23%. What is the recommended maximum utilization to protect your credit score?',
          options: ['10%', '30%', '50%', '70%'],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-4',
          difficulty: 'BEGINNER',
          text: 'Looking at your May budget: income S/ 1,200, expenses S/ 481, net S/ 719. What percentage of your income are you saving?',
          options: ['30%', '40%', '50%', '60%'],
        ),
      ],
    );
  }
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

class MockQuizApiService extends QuizApiService {
  @override
  Future<List<QuizQuestion>> getQuiz(String topicId, String language) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final entries = DemoData.quizData[topicId] ?? DemoData.quizData['topic-1']!;
    return entries
        .map((e) => QuizQuestion(
              id: e.id,
              difficulty: e.difficulty,
              text: e.text,
              options: List<String>.from(e.options),
              explanation: e.explanation,
            ))
        .toList();
  }

  @override
  Future<QuizResult> submitQuiz(
    String topicId,
    Map<String, String> answers,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final entries = DemoData.quizData[topicId] ?? DemoData.quizData['topic-1']!;
    int correct = 0;
    final feedback = <QuizFeedback>[];
    for (final entry in entries) {
      final given = answers[entry.id];
      final correctAnswer = entry.options[entry.correctIndex];
      final isCorrect = given == correctAnswer;
      if (isCorrect) correct++;
      feedback.add(QuizFeedback(
        questionId: entry.id,
        correct: isCorrect,
        correctAnswer: correctAnswer,
      ));
    }
    final total = entries.length;
    final score = total > 0 ? ((correct / total) * 100).round() : 0;
    return QuizResult(
      score: score,
      correctCount: correct,
      totalCount: total,
      level: score >= 80 ? 'advanced' : score >= 50 ? 'intermediate' : 'beginner',
      feedback: feedback,
    );
  }
}

class MockProgressApiService extends ProgressApiService {
  @override
  Future<FinancialProgress> getProgress() async => DemoData.financialProgress;
}

class MockSurveysApiService extends SurveysApiService {
  @override
  Future<Survey> getPreSurvey() async => DemoData.mockPreSurvey;

  @override
  Future<Survey> getPostSurvey() async => DemoData.mockPreSurvey;

  @override
  Future<SurveyResult> submitPre(Map<String, String> answers) async =>
      DemoData.mockSurveyResult;

  @override
  Future<SurveyResult> submitPost(Map<String, String> answers) async =>
      const SurveyResult(
        score: 85.0,
        level: 'advanced',
        improvement: 13.0,
        xpEarned: 75,
        badgeUnlocked: 'Budget Master',
      );

  @override
  Future<Survey> getSusSurvey() async {
    return Survey(
      id: 'survey-sus-demo',
      type: 'SUS',
      questions: [
        const SurveyQuestion(
          id: 'sus-1',
          order: 1,
          text: 'I think that I would like to use this app frequently.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-2',
          order: 2,
          text: 'I found the app unnecessarily complex.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-3',
          order: 3,
          text: 'I thought the app was easy to use.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-4',
          order: 4,
          text: 'I would need the support of a technical person to use this app.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-5',
          order: 5,
          text: 'I found the various functions in this app well integrated.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-6',
          order: 6,
          text: 'I thought there was too much inconsistency in this app.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-7',
          order: 7,
          text: 'I imagine that most people would learn to use this app quickly.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-8',
          order: 8,
          text: 'I found the app very cumbersome to use.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-9',
          order: 9,
          text: 'I felt very confident using the app.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-10',
          order: 10,
          text: 'I needed to learn a lot of things before I could use this app.',
          options: ['1', '2', '3', '4', '5'],
        ),
      ],
    );
  }

  @override
  Future<SusResult> submitSus(Map<String, String> answers) async =>
      const SusResult(susScore: 82, grade: 'B');

  @override
  Future<SurveyComparison> getComparison() async => const SurveyComparison(
        preScore: 72.0,
        postScore: 85.0,
        improvementPercentage: 18.1,
      );
}

class MockAiChatApiService extends AiChatApiService {
  @override
  Future<String> sendMessage(List<ChatMessage> messages) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final last = messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => messages.last,
    );
    return _respond(last.content.toLowerCase());
  }

  String _respond(String input) {
    if (input.contains('budget') || input.contains('presupuesto')) {
      return DemoData.aiChatResponses['budget']!;
    }
    if (input.contains('sav') || input.contains('ahorro') || input.contains('save')) {
      return DemoData.aiChatResponses['save']!;
    }
    if (input.contains('goal') || input.contains('meta')) {
      return DemoData.aiChatResponses['goal']!;
    }
    if (input.contains('invest') || input.contains('invert')) {
      return DemoData.aiChatResponses['invest']!;
    }
    if (input.contains('spend') || input.contains('gast') || input.contains('expense')) {
      return DemoData.aiChatResponses['spend']!;
    }
    if (input.contains('debt') || input.contains('credit') || input.contains('card') || input.contains('deuda')) {
      return DemoData.aiChatResponses['debt']!;
    }
    if (input.contains('analiz') || input.contains('analys') || input.contains('overview') || input.contains('summary')) {
      return DemoData.aiChatResponses['analyze']!;
    }
    return DemoData.aiChatResponses['default']!;
  }
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final d = description.toLowerCase();
    if (d.contains('food') || d.contains('lunch') || d.contains('dinner') ||
        d.contains('breakfast') || d.contains('groceries') ||
        d.contains('supermarket') || d.contains('restaurant') ||
        d.contains('cafe') || d.contains('comida')) {
      return TransactionCategory.comida;
    }
    if (d.contains('uber') || d.contains('taxi') || d.contains('bus') ||
        d.contains('transport') || d.contains('metro') || d.contains('ride')) {
      return TransactionCategory.transporte;
    }
    if (d.contains('rent') || d.contains('housing') || d.contains('alquiler') ||
        d.contains('apartment') || d.contains('flat')) {
      return TransactionCategory.vivienda;
    }
    if (d.contains('internet') || d.contains('electricity') ||
        d.contains('water') || d.contains('bill') ||
        d.contains('utility') || d.contains('phone')) {
      return TransactionCategory.servicios;
    }
    if (d.contains('doctor') || d.contains('gym') || d.contains('pharmacy') ||
        d.contains('health') || d.contains('medicine') ||
        d.contains('hospital')) {
      return TransactionCategory.salud;
    }
    if (d.contains('cinema') || d.contains('movie') || d.contains('concert') ||
        d.contains('entertainment') || d.contains('bar') ||
        d.contains('club')) {
      return TransactionCategory.ocio;
    }
    if (d.contains('clothes') || d.contains('shopping') ||
        d.contains('amazon') || d.contains('store') || d.contains('mall')) {
      return TransactionCategory.compras;
    }
    if (d.contains('netflix') || d.contains('spotify') ||
        d.contains('subscription') || d.contains('prime') ||
        d.contains('hbo') || d.contains('disney')) {
      return TransactionCategory.suscripciones;
    }
    if (d.contains('coffee') || d.contains('snack') || d.contains('dessert') ||
        d.contains('candy') || d.contains('ice cream')) {
      return TransactionCategory.antojos;
    }
    if (d.contains('saving') || d.contains('ahorro') || d.contains('invest')) {
      return TransactionCategory.ahorro;
    }
    return null;
  }
}

class MockCategoryApiService extends CategoryApiService {
  static final _custom = <CategoryModel>[];

  static const _system = <CategoryModel>[
    CategoryModel(id: 'cat-food', name: 'Food', type: CategoryType.system),
    CategoryModel(id: 'cat-transport', name: 'Transportation', type: CategoryType.system),
    CategoryModel(id: 'cat-housing', name: 'Housing', type: CategoryType.system),
    CategoryModel(id: 'cat-utilities', name: 'Utilities', type: CategoryType.system),
    CategoryModel(id: 'cat-health', name: 'Health', type: CategoryType.system),
    CategoryModel(id: 'cat-entertainment', name: 'Entertainment', type: CategoryType.system),
    CategoryModel(id: 'cat-shopping', name: 'Shopping', type: CategoryType.system),
    CategoryModel(id: 'cat-subscriptions', name: 'Subscriptions', type: CategoryType.system),
    CategoryModel(id: 'cat-savings', name: 'Savings', type: CategoryType.system),
    CategoryModel(id: 'cat-other', name: 'Other', type: CategoryType.system),
  ];

  @override
  Future<List<CategoryModel>> getAll() async => [..._system, ..._custom];

  @override
  Future<CategoryModel> create(String name) async {
    final cat = CategoryModel(
      id: 'cat-custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: CategoryType.custom,
    );
    _custom.add(cat);
    return cat;
  }

  @override
  Future<CategoryModel> rename(String id, String name) async {
    final idx = _custom.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _custom[idx] = CategoryModel(id: id, name: name, type: CategoryType.custom);
      return _custom[idx];
    }
    return CategoryModel(id: id, name: name, type: CategoryType.custom);
  }

  @override
  Future<void> delete(String id) async => _custom.removeWhere((c) => c.id == id);
}

class MockNotificationsApiService extends NotificationsApiService {
  static final _prefs = <NotificationPreference>[
    const NotificationPreference(type: 'BUDGET_ALERT', enabled: true),
    const NotificationPreference(type: 'BADGE_EARNED', enabled: true),
    const NotificationPreference(type: 'ANOMALY_ALERT', enabled: true),
    const NotificationPreference(type: 'PREDICTION_READY', enabled: false),
    const NotificationPreference(type: 'CHALLENGE_REMINDER', enabled: true),
    const NotificationPreference(type: 'DAILY_REMINDER', enabled: false),
  ];

  @override
  Future<List<NotificationPreference>> getPreferences() async =>
      List.unmodifiable(_prefs);

  @override
  Future<void> updatePreference(String type, {required bool enabled}) async {
    final idx = _prefs.indexWhere((p) => p.type == type);
    if (idx != -1) {
      _prefs[idx] = NotificationPreference(type: type, enabled: enabled);
    }
  }
}
