import '../models/account.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/summary_models.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/badges_api_service.dart';
import '../services/challenges_api_service.dart';
import '../services/education_api_service.dart';
import '../services/predictions_api_service.dart';
import '../services/recommendations_api_service.dart';
import '../services/streak_repository.dart';

abstract final class DemoData {
  // ── User ───────────────────────────────────────────────────────────────────

  static final user = User(
    id: 'demo-user-1',
    name: 'Paolo Guillen',
    email: 'demo@zenda.app',
    age: 22,
    university: 'PUCP',
    incomeType: IncomeType.partTime,
    averageMonthlyIncome: 2000.0,
    financialLiteracyLevel: FinancialLiteracyLevel.intermediate,
    profileCompleted: true,
    currency: 'PEN',
  );

  // ── Accounts ───────────────────────────────────────────────────────────────

  static final accounts = <Account>[
    const Account(
      id: 'acc-cash-1',
      name: 'Cash',
      type: AccountType.cash,
      balance: 450.00,
      colorValue: 0xFF34D399,
    ),
    const Account(
      id: 'acc-debit-1',
      name: 'BCP Debit',
      type: AccountType.debit,
      balance: 1280.00,
      colorValue: 0xFF3B82F6,
    ),
    const Account(
      id: 'acc-credit-1',
      name: 'Visa Credit',
      type: AccountType.credit,
      creditLimit: 1500.00,
      creditAvailable: 1150.00,
      colorValue: 0xFF7C3AED,
    ),
  ];

  // ── Transactions ───────────────────────────────────────────────────────────

  static final transactions = <TransactionModel>[
    TransactionModel(
      id: 'tx-10',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.expense,
      amount: 8.50,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 5, 2, 9, 15),
      note: 'Coffee',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-9',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 12.00,
      currency: 'PEN',
      category: TransactionCategory.transporte,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 5, 1, 18, 30),
      note: 'Uber',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-8',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.income,
      amount: 1200.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 5, 1, 9, 0),
      note: 'Salary',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-7',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 85.50,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 30, 12, 0),
      note: 'Groceries',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-6',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 79.00,
      currency: 'PEN',
      category: TransactionCategory.servicios,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 30, 10, 0),
      note: 'Internet',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-5',
      userId: 'demo-user-1',
      accountId: 'acc-credit-1',
      kind: TransactionKind.expense,
      amount: 37.90,
      currency: 'PEN',
      category: TransactionCategory.suscripciones,
      bucket: Bucket503020.deseo,
      timestamp: DateTime(2026, 4, 29, 11, 0),
      note: 'Netflix',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-4',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.expense,
      amount: 22.00,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 29, 13, 0),
      note: 'Lunch',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-3',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 120.00,
      currency: 'PEN',
      category: TransactionCategory.salud,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 28, 8, 0),
      note: 'Gym membership',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-2',
      userId: 'demo-user-1',
      accountId: 'acc-credit-1',
      kind: TransactionKind.expense,
      amount: 89.90,
      currency: 'PEN',
      category: TransactionCategory.compras,
      bucket: Bucket503020.deseo,
      timestamp: DateTime(2026, 4, 28, 15, 30),
      note: 'Clothes',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-1',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.expense,
      amount: 25.00,
      currency: 'PEN',
      category: TransactionCategory.ocio,
      bucket: Bucket503020.deseo,
      timestamp: DateTime(2026, 4, 27, 20, 0),
      note: 'Cinema',
      source: TransactionSource.manual,
    ),
  ];

  // ── Streak ─────────────────────────────────────────────────────────────────

  static final streak = StreakState(
    lastActiveDate: DateTime(2026, 5, 2),
    currentDays: 7,
    bestDays: 12,
  );

  // ── Day summary (today = 2026-05-02) ──────────────────────────────────────

  static final daySummary = const PeriodSummary(
    totalIncome: 0.0,
    totalExpense: 8.50,
    netBalance: -8.50,
    topCategories: [
      TopCategoryItem(name: 'food', amount: 8.50),
    ],
  );

  // ── Week summary (ISO week 18, 2026) ──────────────────────────────────────

  static final weekSummary = const PeriodSummary(
    totalIncome: 1200.00,
    totalExpense: 20.50,
    netBalance: 1179.50,
    topCategories: [
      TopCategoryItem(name: 'food', amount: 8.50),
      TopCategoryItem(name: 'transportation', amount: 12.00),
    ],
  );

  // ── Month summary (May 2026) ───────────────────────────────────────────────

  static final monthSummary = const PeriodSummary(
    totalIncome: 1200.00,
    totalExpense: 480.80,
    netBalance: 719.20,
    topCategories: [
      TopCategoryItem(name: 'health', amount: 120.00),
      TopCategoryItem(name: 'food', amount: 116.00),
      TopCategoryItem(name: 'utilities', amount: 79.00),
      TopCategoryItem(name: 'shopping', amount: 89.90),
      TopCategoryItem(name: 'entertainment', amount: 25.00),
      TopCategoryItem(name: 'transportation', amount: 12.00),
      TopCategoryItem(name: 'subscriptions', amount: 37.90),
    ],
    dailyBreakdown: [
      DailyBreakdownItem(date: '2026-04-27', totalIncome: 0, totalExpense: 25.00),
      DailyBreakdownItem(date: '2026-04-28', totalIncome: 0, totalExpense: 209.90),
      DailyBreakdownItem(date: '2026-04-29', totalIncome: 0, totalExpense: 59.90),
      DailyBreakdownItem(date: '2026-04-30', totalIncome: 0, totalExpense: 164.50),
      DailyBreakdownItem(date: '2026-05-01', totalIncome: 1200, totalExpense: 12.00),
      DailyBreakdownItem(date: '2026-05-02', totalIncome: 0, totalExpense: 8.50),
    ],
  );

  // ── Progress (vs previous month) ──────────────────────────────────────────

  static final progressSummary = const ProgressSummary(
    currentIncome: 1200.00,
    currentExpenses: 480.80,
    currentBalance: 719.20,
    previousIncome: 1000.00,
    previousExpenses: 620.50,
    previousBalance: 379.50,
    expensesChangePercent: -22.5,
    savingsChangePercent: 35.0,
    balanceChangePercent: 89.5,
  );

  // ── Month comparison (last 3 months) ──────────────────────────────────────

  static final monthComparison = <MonthComparisonEntry>[
    const MonthComparisonEntry(year: 2026, month: 3, totalIncome: 900.0, totalExpense: 750.0, netBalance: 150.0),
    const MonthComparisonEntry(year: 2026, month: 4, totalIncome: 1000.0, totalExpense: 620.5, netBalance: 379.5),
    const MonthComparisonEntry(year: 2026, month: 5, totalIncome: 1200.0, totalExpense: 480.8, netBalance: 719.2),
  ];

  // ── Recommendations ────────────────────────────────────────────────────────

  static final recommendations = <Recommendation>[
    const Recommendation(
      id: 'rec-1',
      type: 'SPENDING',
      title: 'Reduce food spending',
      body: 'Your food budget is at 77%. Try cooking at home twice this week to stay under budget.',
      impactScore: 0.85,
    ),
    const Recommendation(
      id: 'rec-2',
      type: 'SAVINGS',
      title: 'Build your emergency fund',
      body: 'No savings transactions this month. Set aside S/ 50 today to start your emergency fund.',
      impactScore: 0.90,
    ),
  ];

  // ── Budgets ────────────────────────────────────────────────────────────────

  static final budgets = <Budget>[
    const Budget(
      id: 'budget-1',
      userId: 'demo-user-1',
      categoryId: 'cat-food',
      categoryName: 'food',
      amountLimit: 150.00,
      month: 5,
      year: 2026,
      currentSpent: 116.00,
      percentageUsed: 77.3,
      createdAt: '2026-05-01T00:00:00Z',
      updatedAt: '2026-05-02T09:15:00Z',
    ),
    const Budget(
      id: 'budget-2',
      userId: 'demo-user-1',
      categoryId: 'cat-health',
      categoryName: 'health',
      amountLimit: 150.00,
      month: 5,
      year: 2026,
      currentSpent: 120.00,
      percentageUsed: 80.0,
      createdAt: '2026-05-01T00:00:00Z',
      updatedAt: '2026-04-28T08:00:00Z',
    ),
    const Budget(
      id: 'budget-3',
      userId: 'demo-user-1',
      categoryId: 'cat-entertainment',
      categoryName: 'entertainment',
      amountLimit: 80.00,
      month: 5,
      year: 2026,
      currentSpent: 25.00,
      percentageUsed: 31.3,
      createdAt: '2026-05-01T00:00:00Z',
      updatedAt: '2026-04-27T20:00:00Z',
    ),
  ];

  // ── Goals ──────────────────────────────────────────────────────────────────

  static final goals = <SavingsGoal>[
    const SavingsGoal(
      id: 'goal-1',
      userId: 'demo-user-1',
      name: 'Emergency Fund',
      targetAmount: 3000.00,
      currentAmount: 850.00,
      dueDate: '2026-12-31',
      createdAt: '2026-01-15T00:00:00Z',
      updatedAt: '2026-04-20T00:00:00Z',
    ),
    const SavingsGoal(
      id: 'goal-2',
      userId: 'demo-user-1',
      name: 'New Laptop',
      targetAmount: 2500.00,
      currentAmount: 1200.00,
      dueDate: '2026-08-31',
      createdAt: '2026-02-01T00:00:00Z',
      updatedAt: '2026-04-15T00:00:00Z',
    ),
  ];

  // ── Education topics ───────────────────────────────────────────────────────

  static final educationTopics = <EducationTopic>[
    const EducationTopic(
      id: 'topic-1',
      title: 'What is the 50/30/20 rule?',
      content: 'The 50/30/20 rule divides your after-tax income into three buckets: 50% for needs, 30% for wants, and 20% for savings. Needs include rent, groceries, and utilities. Wants include dining out, subscriptions, and entertainment. The remaining 20% goes toward savings and debt repayment.\n\nThis framework helps you build financial balance without tracking every expense in detail.',
      difficulty: 'beginner',
      category: 'budgeting',
      order: 1,
      isCompleted: true,
    ),
    const EducationTopic(
      id: 'topic-2',
      title: 'How to set a realistic budget',
      content: 'A realistic budget starts by knowing your actual income and fixed expenses. List every recurring cost first—rent, utilities, subscriptions—then calculate what remains. Allocate a fixed amount for variable spending (food, transport) based on last month\'s data.\n\nReview your budget weekly for the first month to catch gaps early. Adjust category limits rather than abandoning the budget entirely when you overspend.',
      difficulty: 'beginner',
      category: 'budgeting',
      order: 2,
      isCompleted: true,
    ),
    const EducationTopic(
      id: 'topic-3',
      title: 'Emergency fund basics',
      content: 'An emergency fund is 3–6 months of essential expenses saved in a liquid account. It covers unexpected events—job loss, medical costs, urgent repairs—without forcing you to take on debt.\n\nStart small: S/ 50 per month builds S/ 600 in a year. Keep the fund separate from your main account to reduce the temptation to spend it.',
      difficulty: 'intermediate',
      category: 'saving',
      order: 3,
      isCompleted: false,
    ),
    const EducationTopic(
      id: 'topic-4',
      title: 'How to save consistently',
      content: 'Consistency beats large infrequent deposits. Automate a transfer to savings on payday—even S/ 20—before you can spend it. This "pay yourself first" habit removes willpower from the equation.\n\nTrack your savings rate (savings ÷ income × 100) monthly. A 10% rate is a solid starting point for university students.',
      difficulty: 'intermediate',
      category: 'saving',
      order: 4,
      isCompleted: false,
    ),
    const EducationTopic(
      id: 'topic-5',
      title: 'Understanding credit cards',
      content: 'Credit cards charge interest only on unpaid balances. Paying the full statement balance every month costs you nothing in interest and builds a credit history.\n\nThe minimum payment traps you in a debt cycle—a S/ 500 balance paid in minimums can take years to clear. Always aim to pay more than the minimum, ideally the full amount.',
      difficulty: 'intermediate',
      category: 'budgeting',
      order: 5,
      isCompleted: false,
    ),
    const EducationTopic(
      id: 'topic-6',
      title: 'Investment for beginners',
      content: 'Investing means putting money to work so it grows over time. Start with low-risk options: savings accounts, CDs, or government bonds. As you learn, consider index funds—they spread risk across many companies at low cost.\n\nTime in the market matters more than timing the market. Starting with S/ 100/month at age 22 outperforms S/ 500/month at age 35 in the long run.',
      difficulty: 'advanced',
      category: 'investing',
      order: 6,
      isCompleted: false,
    ),
  ];

  // ── Challenges ─────────────────────────────────────────────────────────────

  static final challenges = <Challenge>[
    const Challenge(
      id: 'challenge-1',
      title: 'Record 7 consecutive days',
      description: 'Log at least one transaction every day for 7 days in a row.',
      pointsReward: 50,
      status: 'COMPLETED',
    ),
    const Challenge(
      id: 'challenge-2',
      title: 'Stay under food budget for a week',
      description: 'Keep your food spending below your weekly food budget for 7 days.',
      pointsReward: 30,
      status: 'ACTIVE',
    ),
    const Challenge(
      id: 'challenge-3',
      title: 'Save 10% of your income',
      description: 'Allocate at least 10% of this month\'s income to a savings goal.',
      pointsReward: 100,
      status: 'AVAILABLE',
    ),
    const Challenge(
      id: 'challenge-4',
      title: 'No impulse spending for 5 days',
      description: 'Avoid unplanned purchases in the "wants" category for 5 days.',
      pointsReward: 40,
      status: 'AVAILABLE',
    ),
  ];

  // ── Badges ─────────────────────────────────────────────────────────────────

  static final badges = <ZendaBadge>[
    ZendaBadge(
      id: 'badge-1',
      name: 'First Step',
      description: 'Record your first transaction.',
      isEarned: true,
      earnedAt: DateTime(2026, 1, 20),
    ),
    ZendaBadge(
      id: 'badge-2',
      name: '7-Day Streak',
      description: 'Log transactions for 7 consecutive days.',
      isEarned: true,
      earnedAt: DateTime(2026, 5, 2),
    ),
    ZendaBadge(
      id: 'badge-3',
      name: 'Budget Master',
      description: 'Stay under all your budgets for a full month.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-4',
      name: 'Savings Champion',
      description: 'Reach 50% progress on any savings goal.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-5',
      name: 'Education Explorer',
      description: 'Complete all education topics.',
      isEarned: false,
    ),
  ];

  // ── AI prediction ──────────────────────────────────────────────────────────

  static const expensePrediction = PredictionResult(
    period: '2026-06',
    predictedAmount: 460.00,
    confidenceLevel: 0.78,
    narrative: 'Based on your last 3 months, we estimate your June expenses at S/ 460. Your food and transport costs are stable. Reducing subscriptions by one service could bring this below S/ 430.',
  );

  // ── API transaction rows (for TransactionListScreen) ──────────────────────

  static final apiTransactions = transactions
      .map(
        (tx) => <String, dynamic>{
          'id': tx.id,
          'type': tx.kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
          'amount': tx.amount,
          'description': tx.note ?? '',
          'occurredAt': tx.timestamp.toIso8601String(),
          'category': <String, dynamic>{
            'name': _categoryApiName(tx.category),
          },
        },
      )
      .toList();

  static String _categoryApiName(TransactionCategory cat) => switch (cat) {
        TransactionCategory.comida => 'food',
        TransactionCategory.transporte => 'transportation',
        TransactionCategory.vivienda => 'housing',
        TransactionCategory.servicios => 'utilities',
        TransactionCategory.salud => 'health',
        TransactionCategory.ocio => 'entertainment',
        TransactionCategory.compras => 'shopping',
        TransactionCategory.suscripciones => 'subscriptions',
        TransactionCategory.antojos => 'cravings',
        TransactionCategory.ahorro => 'savings',
        _ => 'other',
      };
}
