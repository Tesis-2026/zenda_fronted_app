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
  Future<PeriodSummary> getWeekSummary({
    required int year,
    required int week,
  }) async => DemoData.weekSummary;

  @override
  Future<PeriodSummary> getMonthSummary({
    required int year,
    required int month,
  }) async => DemoData.monthSummary;

  @override
  Future<ProgressSummary> getProgress() async => DemoData.progressSummary;

  @override
  Future<List<MonthComparisonEntry>> getComparison({
    required int months,
  }) async => DemoData.monthComparison;

  @override
  Future<List<int>> downloadPdfReport({
    required int fromYear,
    required int fromMonth,
    required int toYear,
    required int toMonth,
  }) async => [];
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
  Future<SavingsGoal> update(
    String id, {
    String? name,
    double? targetAmount,
    String? dueDate,
  }) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx == -1) return _goals.first;
    final g = _goals[idx];
    final updated = SavingsGoal(
      id: g.id,
      userId: g.userId,
      name: name ?? g.name,
      targetAmount: targetAmount ?? g.targetAmount,
      currentAmount: g.currentAmount,
      dueDate: dueDate ?? g.dueDate,
      createdAt: g.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _goals[idx] = updated;
    return updated;
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
    final idx = _goals.indexWhere((g) => g.id == id);
    final goal = idx != -1 ? _goals[idx] : _goals.first;
    final completed = SavingsGoal(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.targetAmount,
      dueDate: goal.dueDate,
      completedAt: DateTime.now().toIso8601String(),
      isCompleted: true,
      createdAt: goal.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    if (idx != -1) _goals[idx] = completed;
    return completed;
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
    String? name,
  }) async {
    final budget = Budget(
      id: 'budget-new-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo-user-1',
      categoryId: categoryId,
      name: name,
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
  Future<Budget> update(String id, {double? amountLimit, String? name}) async {
    final idx = _budgets.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = _budgets[idx];
      final newLimit = amountLimit ?? b.amountLimit;
      final updated = Budget(
        id: b.id,
        userId: b.userId,
        categoryId: b.categoryId,
        name: name ?? b.name,
        categoryName: b.categoryName,
        amountLimit: newLimit,
        month: b.month,
        year: b.year,
        currentSpent: b.currentSpent,
        percentageUsed: (b.currentSpent / newLimit * 100).clamp(0, 100),
        createdAt: b.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
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
  Future<PersonalizedQuizResult> getPersonalizedQuiz({
    String language = 'es',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const PersonalizedQuizResult(
      attemptsRemainingToday: 3,
      questions: [
        PersonalizedQuizQuestion(
          id: 'pq-1',
          difficulty: 'Intermedio',
          text:
              'Tu gasto en comida este mes es S/ 116 de un presupuesto de S/ 150 (77%). ¿Qué acción es más efectiva para los 8 días que quedan?',
          options: [
            'Cocinar en casa 3 veces esta semana',
            'Cambiar a un supermercado más barato',
            'Eliminar por completo las comidas en restaurantes',
            'Registrar cada compra de comida a diario',
          ],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-2',
          difficulty: 'Principiante',
          text:
              'Tu meta de Fondo de Emergencia está al 28% (S/ 850 de S/ 3 000). Al ritmo actual la alcanzarás en diciembre. ¿Qué te llevaría a alcanzarla 3 meses antes?',
          options: [
            'Aportar S/ 50 extra al mes',
            'Aportar S/ 150 extra al mes',
            'Aportar S/ 200 extra al mes',
            'No hacer nada — el ritmo actual está bien',
          ],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-3',
          difficulty: 'Intermedio',
          text:
              'Tienes una tarjeta de crédito Visa con S/ 1 150 disponibles. Tu tasa de utilización actual es de aproximadamente 23%. ¿Cuál es la utilización máxima recomendada para proteger tu score crediticio?',
          options: ['10%', '30%', '50%', '70%'],
        ),
        PersonalizedQuizQuestion(
          id: 'pq-4',
          difficulty: 'Principiante',
          text:
              'Mirando tu presupuesto de mayo: ingreso S/ 1 200, gastos S/ 481, neto S/ 719. ¿Qué porcentaje de tu ingreso estás ahorrando?',
          options: ['30%', '40%', '50%', '60%'],
        ),
      ],
    );
  }

  @override
  Future<PersonalizedLearningPath> getPersonalizedLearningPath({
    String language = 'es',
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final topics = DemoData.educationTopics;
    final steps = <LearningPathStep>[
      if (topics.isNotEmpty)
        LearningPathStep(
          id: 'topic_${topics[0].id}',
          kind: 'topic',
          topicId: topics[0].id,
          title: topics[0].title,
          reason: 'Empieza por ordenar tus gastos y prioridades mensuales.',
          focus: 'Presupuesto y control de gastos.',
          difficulty: topics[0].difficulty,
          status: topics[0].isCompleted
              ? 'completed'
              : topics[0].isRead
              ? 'read'
              : 'pending',
          order: 1,
          estimatedMinutes: 8,
          quizMode: 'app_topic_quiz',
        ),
      const LearningPathStep(
        id: 'personalized_quiz_2',
        kind: 'personalized_quiz',
        title: 'Quiz personalizado con IA',
        reason: 'Practica con preguntas adaptadas a tus habitos.',
        focus: 'Ingresos, gastos y metas reales.',
        difficulty: 'INTERMEDIATE',
        status: 'pending',
        order: 2,
        estimatedMinutes: 6,
        quizMode: 'ai_personalized_quiz',
      ),
      if (topics.length > 1)
        LearningPathStep(
          id: 'topic_${topics[1].id}',
          kind: 'topic',
          topicId: topics[1].id,
          title: topics[1].title,
          reason: 'Refuerza habitos para ahorrar con constancia.',
          focus: 'Metas y fondo de emergencia.',
          difficulty: topics[1].difficulty,
          status: topics[1].isCompleted
              ? 'completed'
              : topics[1].isRead
              ? 'read'
              : 'pending',
          order: 3,
          estimatedMinutes: 7,
          quizMode: 'app_topic_quiz',
        ),
    ];

    return PersonalizedLearningPath(
      generatedAt: DateTime.now(),
      source: 'fallback',
      summary: 'Ruta demo con temas del app y un quiz personalizado.',
      steps: steps,
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
  }) async => DemoData.user;
}

class MockQuizApiService extends QuizApiService {
  @override
  Future<List<QuizQuestion>> getQuiz(String topicId, String language) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final entries = DemoData.quizData[topicId] ?? DemoData.quizData['topic-1']!;
    return entries
        .map(
          (e) => QuizQuestion(
            id: e.id,
            difficulty: e.difficulty,
            text: e.text,
            options: List<String>.from(e.options),
            explanation: e.explanation,
          ),
        )
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
      feedback.add(
        QuizFeedback(
          questionId: entry.id,
          correct: isCorrect,
          correctAnswer: correctAnswer,
        ),
      );
    }
    final total = entries.length;
    final score = total > 0 ? ((correct / total) * 100).round() : 0;
    return QuizResult(
      score: score,
      correctCount: correct,
      totalCount: total,
      level: score >= 80
          ? 'Avanzado'
          : score >= 50
          ? 'Intermedio'
          : 'Principiante',
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
        level: 'Avanzado',
        improvement: 13.0,
        xpEarned: 75,
        badgeUnlocked: 'Maestro del presupuesto',
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
          text: 'Creo que me gustaría usar esta aplicación con frecuencia.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-2',
          order: 2,
          text: 'Encontré la aplicación innecesariamente compleja.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-3',
          order: 3,
          text: 'Me pareció que la aplicación era fácil de usar.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-4',
          order: 4,
          text:
              'Necesitaría el apoyo de una persona técnica para poder usar esta aplicación.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-5',
          order: 5,
          text:
              'Encontré que las distintas funciones de la aplicación estaban bien integradas.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-6',
          order: 6,
          text: 'Pensé que había demasiada inconsistencia en esta aplicación.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-7',
          order: 7,
          text:
              'Imagino que la mayoría de las personas aprenderían a usar esta aplicación rápidamente.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-8',
          order: 8,
          text: 'Encontré la aplicación muy engorrosa de usar.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-9',
          order: 9,
          text: 'Me sentí muy seguro usando la aplicación.',
          options: ['1', '2', '3', '4', '5'],
        ),
        const SurveyQuestion(
          id: 'sus-10',
          order: 10,
          text:
              'Necesité aprender muchas cosas antes de poder usar esta aplicación.',
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
  // In-memory transcript so the demo behaves like the real backend:
  // history persists across sends within the same app run, and is
  // wiped on closeActive().
  final List<ChatMessage> _history = [];

  @override
  Future<ActiveConversation> getActive() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ActiveConversation(
      conversationId: _history.isEmpty ? null : 'mock-conversation',
      messages: List.unmodifiable(_history),
    );
  }

  @override
  Future<ChatReply> sendMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _history.add(ChatMessage(role: 'user', content: message));
    final reply = _respond(message.toLowerCase());
    _history.add(ChatMessage(role: 'assistant', content: reply));
    return ChatReply(conversationId: 'mock-conversation', reply: reply);
  }

  @override
  Future<void> closeActive() async {
    _history.clear();
  }

  String _respond(String input) {
    if (input.contains('budget') || input.contains('presupuesto')) {
      return DemoData.aiChatResponses['budget']!;
    }
    if (input.contains('sav') ||
        input.contains('ahorro') ||
        input.contains('save')) {
      return DemoData.aiChatResponses['save']!;
    }
    if (input.contains('goal') || input.contains('meta')) {
      return DemoData.aiChatResponses['goal']!;
    }
    if (input.contains('invest') || input.contains('invert')) {
      return DemoData.aiChatResponses['invest']!;
    }
    if (input.contains('spend') ||
        input.contains('gast') ||
        input.contains('expense')) {
      return DemoData.aiChatResponses['spend']!;
    }
    if (input.contains('debt') ||
        input.contains('credit') ||
        input.contains('card') ||
        input.contains('deuda')) {
      return DemoData.aiChatResponses['debt']!;
    }
    if (input.contains('analiz') ||
        input.contains('analys') ||
        input.contains('overview') ||
        input.contains('summary')) {
      return DemoData.aiChatResponses['analyze']!;
    }
    return DemoData.aiChatResponses['default']!;
  }
}

class MockTransactionApiService extends TransactionApiService {
  // Mutable in-memory copy so demo deletions actually stick across refreshes
  // (the soft-delete is simulated by removing the row from this list).
  static final List<Map<String, dynamic>> _txs = [
    for (final tx in DemoData.apiTransactions) Map<String, dynamic>.from(tx),
  ];

  @override
  Future<List<Map<String, dynamic>>> getAll({
    String? type,
    String? from,
    String? to,
    String? categoryId,
    String? accountId,
  }) async {
    if (type == null) return List.unmodifiable(_txs);
    return _txs.where((tx) {
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
    String? budgetId,
    String? accountId,
    String? description,
    String? customCategoryName,
    String? aiSuggestedCategoryName,
    double? aiConfidence,
    String? idempotencyKey,
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
    String? accountId,
  }) async {}

  @override
  Future<void> deleteTransaction(String id) async {
    _txs.removeWhere((tx) => tx['id'] == id);
  }

  @override
  Future<ClassifyResult?> classify({
    required String description,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final d = description.toLowerCase();
    final category = _matchCategory(d);
    if (category == null) return null;
    return (
      category: category,
      categoryName: categoryToApiName(category),
      confidence: 0.85,
    );
  }

  TransactionCategory? _matchCategory(String d) {
    if (d.contains('food') ||
        d.contains('lunch') ||
        d.contains('dinner') ||
        d.contains('breakfast') ||
        d.contains('groceries') ||
        d.contains('supermarket') ||
        d.contains('restaurant') ||
        d.contains('cafe') ||
        d.contains('comida')) {
      return TransactionCategory.comida;
    }
    if (d.contains('uber') ||
        d.contains('taxi') ||
        d.contains('bus') ||
        d.contains('transport') ||
        d.contains('metro') ||
        d.contains('ride')) {
      return TransactionCategory.transporte;
    }
    if (d.contains('rent') ||
        d.contains('housing') ||
        d.contains('alquiler') ||
        d.contains('apartment') ||
        d.contains('flat')) {
      return TransactionCategory.vivienda;
    }
    if (d.contains('internet') ||
        d.contains('electricity') ||
        d.contains('water') ||
        d.contains('bill') ||
        d.contains('utility') ||
        d.contains('phone')) {
      return TransactionCategory.servicios;
    }
    if (d.contains('doctor') ||
        d.contains('gym') ||
        d.contains('pharmacy') ||
        d.contains('health') ||
        d.contains('medicine') ||
        d.contains('hospital')) {
      return TransactionCategory.salud;
    }
    if (d.contains('cinema') ||
        d.contains('movie') ||
        d.contains('concert') ||
        d.contains('entertainment') ||
        d.contains('bar') ||
        d.contains('club')) {
      return TransactionCategory.ocio;
    }
    if (d.contains('clothes') ||
        d.contains('shopping') ||
        d.contains('amazon') ||
        d.contains('store') ||
        d.contains('mall')) {
      return TransactionCategory.compras;
    }
    if (d.contains('netflix') ||
        d.contains('spotify') ||
        d.contains('subscription') ||
        d.contains('prime') ||
        d.contains('hbo') ||
        d.contains('disney')) {
      return TransactionCategory.suscripciones;
    }
    if (d.contains('coffee') ||
        d.contains('snack') ||
        d.contains('dessert') ||
        d.contains('candy') ||
        d.contains('ice cream')) {
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
    CategoryModel(
      id: 'cat-food',
      name: 'Comida',
      type: CategoryType.system,
      icon: 'food',
    ),
    CategoryModel(
      id: 'cat-transport',
      name: 'Transporte',
      type: CategoryType.system,
      icon: 'transport',
    ),
    CategoryModel(
      id: 'cat-housing',
      name: 'Vivienda',
      type: CategoryType.system,
      icon: 'housing',
    ),
    CategoryModel(
      id: 'cat-utilities',
      name: 'Servicios',
      type: CategoryType.system,
      icon: 'utilities',
    ),
    CategoryModel(
      id: 'cat-health',
      name: 'Salud',
      type: CategoryType.system,
      icon: 'health',
    ),
    CategoryModel(
      id: 'cat-entertainment',
      name: 'Entretenimiento',
      type: CategoryType.system,
      icon: 'entertainment',
    ),
    CategoryModel(
      id: 'cat-shopping',
      name: 'Compras',
      type: CategoryType.system,
      icon: 'shopping',
    ),
    CategoryModel(
      id: 'cat-subscriptions',
      name: 'Suscripciones',
      type: CategoryType.system,
      icon: 'subscriptions',
    ),
    CategoryModel(
      id: 'cat-savings',
      name: 'Ahorro',
      type: CategoryType.system,
      icon: 'savings',
    ),
    CategoryModel(
      id: 'cat-other',
      name: 'Otros',
      type: CategoryType.system,
      icon: 'other',
    ),
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
      _custom[idx] = CategoryModel(
        id: id,
        name: name,
        type: CategoryType.custom,
      );
      return _custom[idx];
    }
    return CategoryModel(id: id, name: name, type: CategoryType.custom);
  }

  @override
  Future<void> delete(String id) async =>
      _custom.removeWhere((c) => c.id == id);
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
