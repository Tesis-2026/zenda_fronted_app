import 'package:flutter/material.dart';

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
import '../services/progress_api_service.dart';
import '../services/recommendations_api_service.dart';
import '../services/streak_repository.dart';
import '../services/surveys_api_service.dart';

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
      id: 'tx-20',
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
      id: 'tx-19',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 45.00,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 5, 2, 13, 0),
      note: 'Supermarket',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-18',
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
      id: 'tx-17',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.income,
      amount: 1200.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 5, 1, 9, 0),
      note: 'Monthly salary',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-16',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.income,
      amount: 350.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 4, 30, 15, 0),
      note: 'Freelance project',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-15',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 85.50,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 30, 12, 0),
      note: 'Weekly groceries',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-14',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 79.00,
      currency: 'PEN',
      category: TransactionCategory.servicios,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 30, 10, 0),
      note: 'Internet bill',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-13',
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
      id: 'tx-12',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.expense,
      amount: 22.00,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 29, 13, 0),
      note: 'Lunch with friends',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-11',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.income,
      amount: 200.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 4, 29, 8, 0),
      note: 'Part-time tutoring',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-10',
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
      id: 'tx-9',
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
      id: 'tx-8',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 15.00,
      currency: 'PEN',
      category: TransactionCategory.transporte,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 28, 7, 30),
      note: 'Bus pass',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-7',
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
    TransactionModel(
      id: 'tx-6',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 18.50,
      currency: 'PEN',
      category: TransactionCategory.comida,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 27, 12, 30),
      note: 'Lunch',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-5',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.income,
      amount: 1000.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 4, 25, 9, 0),
      note: 'April salary (partial)',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-4',
      userId: 'demo-user-1',
      accountId: 'acc-credit-1',
      kind: TransactionKind.expense,
      amount: 12.90,
      currency: 'PEN',
      category: TransactionCategory.suscripciones,
      bucket: Bucket503020.deseo,
      timestamp: DateTime(2026, 4, 24, 9, 0),
      note: 'Spotify',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-3',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 55.00,
      currency: 'PEN',
      category: TransactionCategory.salud,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 22, 10, 0),
      note: 'Doctor visit',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-2',
      userId: 'demo-user-1',
      accountId: 'acc-cash-1',
      kind: TransactionKind.income,
      amount: 150.00,
      currency: 'PEN',
      category: TransactionCategory.otros,
      bucket: Bucket503020.ahorro,
      timestamp: DateTime(2026, 4, 20, 16, 0),
      note: 'Sold old books',
      source: TransactionSource.manual,
    ),
    TransactionModel(
      id: 'tx-1',
      userId: 'demo-user-1',
      accountId: 'acc-debit-1',
      kind: TransactionKind.expense,
      amount: 280.00,
      currency: 'PEN',
      category: TransactionCategory.vivienda,
      bucket: Bucket503020.necesidad,
      timestamp: DateTime(2026, 4, 1, 8, 0),
      note: 'April rent',
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

  static const recommendations = <Recommendation>[
    Recommendation(
      id: 'rec-1',
      type: 'BUDGET',
      title: 'Reduce food spending',
      body: 'Your food budget is at 77% with S/ 116 spent of S/ 150. Try cooking at home twice this week to stay under budget.',
      impactScore: 0.85,
      actionLabel: 'Set food budget',
    ),
    Recommendation(
      id: 'rec-2',
      type: 'SAVING',
      title: 'Build your emergency fund',
      body: 'No savings transactions this month. Set aside S/ 50 today to start building your emergency fund.',
      impactScore: 0.90,
      actionLabel: 'Create emergency fund goal',
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

  static const educationTopics = <EducationTopic>[
    EducationTopic(
      id: 'topic-1',
      title: 'What is the 50/30/20 rule?',
      content: 'The 50/30/20 rule divides your after-tax income into three buckets: 50% for needs, 30% for wants, and 20% for savings. Needs include rent, groceries, and utilities. Wants include dining out, subscriptions, and entertainment. The remaining 20% goes toward savings and debt repayment.\n\nThis framework helps you build financial balance without tracking every expense in detail.',
      difficulty: 'beginner',
      category: 'budgeting',
      order: 1,
      isCompleted: true,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-2',
      title: 'How to set a realistic budget',
      content: 'A realistic budget starts by knowing your actual income and fixed expenses. List every recurring cost first—rent, utilities, subscriptions—then calculate what remains. Allocate a fixed amount for variable spending (food, transport) based on last month\'s data.\n\nReview your budget weekly for the first month to catch gaps early. Adjust category limits rather than abandoning the budget entirely when you overspend.',
      difficulty: 'beginner',
      category: 'budgeting',
      order: 2,
      isCompleted: true,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-3',
      title: 'Emergency fund basics',
      content: 'An emergency fund is 3–6 months of essential expenses saved in a liquid account. It covers unexpected events—job loss, medical costs, urgent repairs—without forcing you to take on debt.\n\nStart small: S/ 50 per month builds S/ 600 in a year. Keep the fund separate from your main account to reduce the temptation to spend it.',
      difficulty: 'intermediate',
      category: 'saving',
      order: 3,
      isCompleted: false,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-4',
      title: 'How to save consistently',
      content: 'Consistency beats large infrequent deposits. Automate a transfer to savings on payday—even S/ 20—before you can spend it. This "pay yourself first" habit removes willpower from the equation.\n\nTrack your savings rate (savings ÷ income × 100) monthly. A 10% rate is a solid starting point for university students.',
      difficulty: 'intermediate',
      category: 'saving',
      order: 4,
      isCompleted: false,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-5',
      title: 'Understanding credit cards',
      content: 'Credit cards charge interest only on unpaid balances. Paying the full statement balance every month costs you nothing in interest and builds a credit history.\n\nThe minimum payment traps you in a debt cycle—a S/ 500 balance paid in minimums can take years to clear. Always aim to pay more than the minimum, ideally the full amount.',
      difficulty: 'intermediate',
      category: 'budgeting',
      order: 5,
      isCompleted: false,
      questionCount: 4,
      isLocked: true,
    ),
    EducationTopic(
      id: 'topic-6',
      title: 'Investment for beginners',
      content: 'Investing means putting money to work so it grows over time. Start with low-risk options: savings accounts, CDs, or government bonds. As you learn, consider index funds—they spread risk across many companies at low cost.\n\nTime in the market matters more than timing the market. Starting with S/ 100/month at age 22 outperforms S/ 500/month at age 35 in the long run.',
      difficulty: 'advanced',
      category: 'investing',
      order: 6,
      isCompleted: false,
      questionCount: 4,
      isLocked: true,
    ),
  ];

  // ── Quiz questions (per topic) ────────────────────────────────────────────
  // Each entry: (question, options list, correctIndex)

  static const quizData = <String, List<_QuizEntry>>{
    'topic-1': [
      _QuizEntry(
        id: 't1-q1',
        difficulty: 'BEGINNER',
        text: 'In the 50/30/20 rule, what percentage goes to needs?',
        options: ['30%', '50%', '20%', '40%'],
        correctIndex: 1,
        explanation: 'The 50 in 50/30/20 allocates half your after-tax income to essential needs like rent, food, and utilities.',
      ),
      _QuizEntry(
        id: 't1-q2',
        difficulty: 'BEGINNER',
        text: 'Which of the following is a "want" in the 50/30/20 rule?',
        options: ['Rent', 'Groceries', 'Streaming subscription', 'Utilities'],
        correctIndex: 2,
        explanation: 'A streaming subscription is discretionary (a want) — you could cancel it without affecting your basic living needs.',
      ),
      _QuizEntry(
        id: 't1-q3',
        difficulty: 'BEGINNER',
        text: 'What does the "20" in 50/30/20 represent?',
        options: ['Entertainment', 'Taxes', 'Savings and debt repayment', 'Housing'],
        correctIndex: 2,
        explanation: 'The 20% bucket is reserved for building savings and paying down debt, helping you grow your net worth over time.',
      ),
      _QuizEntry(
        id: 't1-q4',
        difficulty: 'BEGINNER',
        text: 'With a monthly income of S/ 2000, how much should go to savings using the 50/30/20 rule?',
        options: ['S/ 1000', 'S/ 600', 'S/ 400', 'S/ 200'],
        correctIndex: 2,
        explanation: '20% of S/ 2000 = S/ 400; this is your target monthly savings amount under the 50/30/20 framework.',
      ),
    ],
    'topic-2': [
      _QuizEntry(
        id: 't2-q1',
        difficulty: 'BEGINNER',
        text: 'What should you list first when building a realistic budget?',
        options: ['Variable spending', 'Entertainment', 'Fixed recurring costs', 'Savings goals'],
        correctIndex: 2,
        explanation: 'Fixed costs like rent, utilities, and subscriptions are predictable and must be covered every month, so they anchor your budget.',
      ),
      _QuizEntry(
        id: 't2-q2',
        difficulty: 'BEGINNER',
        text: 'How often should you review your budget in the first month?',
        options: ['Daily', 'Weekly', 'Monthly', 'Quarterly'],
        correctIndex: 1,
        explanation: 'Weekly reviews in the first month help you catch overspending early and adjust before the month ends.',
      ),
      _QuizEntry(
        id: 't2-q3',
        difficulty: 'BEGINNER',
        text: 'When you overspend in a category, the best response is to:',
        options: ['Abandon the budget', 'Borrow from next month', 'Adjust the category limit', 'Ignore it'],
        correctIndex: 2,
        explanation: 'Adjusting the limit based on real spending data makes your budget more accurate and sustainable over time.',
      ),
      _QuizEntry(
        id: 't2-q4',
        difficulty: 'BEGINNER',
        text: 'Which data source is most useful for allocating variable spending?',
        options: ["A friend's expenses", 'Online calculators', "Last month's actual spending", 'Your income tax rate'],
        correctIndex: 2,
        explanation: "Your own past spending is the most accurate baseline because it reflects your personal habits and cost of living.",
      ),
    ],
    'topic-3': [
      _QuizEntry(
        id: 't3-q1',
        difficulty: 'INTERMEDIATE',
        text: 'How many months of expenses should an emergency fund cover?',
        options: ['1–2 months', '3–6 months', '7–9 months', '1 year'],
        correctIndex: 1,
        explanation: '3–6 months provides enough runway to handle job loss or medical emergencies without going into debt.',
      ),
      _QuizEntry(
        id: 't3-q2',
        difficulty: 'INTERMEDIATE',
        text: 'What type of account is best for an emergency fund?',
        options: ['Long-term investment', 'High-risk stocks', 'Liquid savings account', 'Fixed-term deposit'],
        correctIndex: 2,
        explanation: 'A liquid account lets you access the money immediately in an emergency without penalties or waiting periods.',
      ),
      _QuizEntry(
        id: 't3-q3',
        difficulty: 'INTERMEDIATE',
        text: 'The main purpose of an emergency fund is:',
        options: ['Invest in stocks', 'Cover unexpected costs without debt', 'Pay regular bills', 'Fund vacation travel'],
        correctIndex: 1,
        explanation: 'An emergency fund acts as a financial buffer so unexpected events do not force you into high-interest debt.',
      ),
      _QuizEntry(
        id: 't3-q4',
        difficulty: 'INTERMEDIATE',
        text: 'Saving S/ 50/month, how long does it take to reach S/ 600?',
        options: ['6 months', '1 year', '2 years', '18 months'],
        correctIndex: 1,
        explanation: 'S/ 50 × 12 months = S/ 600; consistent small deposits accumulate meaningfully over a full year.',
      ),
    ],
    'topic-4': [
      _QuizEntry(
        id: 't4-q1',
        difficulty: 'INTERMEDIATE',
        text: 'What does "pay yourself first" mean?',
        options: ['Spend on yourself before bills', 'Save before spending', 'Invest 50% of income', 'Pay debts first'],
        correctIndex: 1,
        explanation: 'Saving before spending removes willpower from the equation — your savings transfer happens automatically on payday.',
      ),
      _QuizEntry(
        id: 't4-q2',
        difficulty: 'INTERMEDIATE',
        text: 'When is the ideal time to transfer money to savings?',
        options: ['End of month', 'On payday', 'After all expenses', 'Randomly'],
        correctIndex: 1,
        explanation: 'Transferring on payday means savings happen before discretionary spending, ensuring you always set aside something.',
      ),
      _QuizEntry(
        id: 't4-q3',
        difficulty: 'INTERMEDIATE',
        text: 'A solid starting savings rate for university students is:',
        options: ['5%', '20%', '10%', '30%'],
        correctIndex: 2,
        explanation: 'A 10% rate is achievable on a student income and builds the habit of saving consistently without over-restricting spending.',
      ),
      _QuizEntry(
        id: 't4-q4',
        difficulty: 'INTERMEDIATE',
        text: 'How do you calculate your savings rate?',
        options: ['Savings × 100', 'Savings ÷ expenses × 100', 'Savings ÷ income × 100', 'Savings ÷ 12'],
        correctIndex: 2,
        explanation: 'Savings rate = (amount saved ÷ total income) × 100; dividing by income shows what fraction of earnings you keep.',
      ),
    ],
    'topic-5': [
      _QuizEntry(
        id: 't5-q1',
        difficulty: 'INTERMEDIATE',
        text: 'When do credit cards charge interest?',
        options: ['On every purchase', 'Only on cash advances', 'On unpaid balances', 'Every month regardless'],
        correctIndex: 2,
        explanation: 'Interest is charged only on the balance you carry past the due date; paying in full every month means zero interest cost.',
      ),
      _QuizEntry(
        id: 't5-q2',
        difficulty: 'INTERMEDIATE',
        text: 'The best credit card payment strategy is:',
        options: ['Pay the minimum', 'Pay the full statement balance', 'Pay half the balance', 'Skip one month'],
        correctIndex: 1,
        explanation: 'Paying the full statement balance eliminates interest charges and builds a positive credit history at no extra cost.',
      ),
      _QuizEntry(
        id: 't5-q3',
        difficulty: 'INTERMEDIATE',
        text: 'Paying only the minimum on a credit card results in:',
        options: ['Better credit score', 'Interest stops', 'A debt cycle', 'Fee waivers'],
        correctIndex: 2,
        explanation: 'Minimum payments barely cover interest, so the principal barely shrinks, trapping you in a slow and expensive debt cycle.',
      ),
      _QuizEntry(
        id: 't5-q4',
        difficulty: 'INTERMEDIATE',
        text: 'Paying the full credit card balance each month gives you:',
        options: ['Higher credit limit', 'Cash rewards', 'Zero interest and builds credit', 'Lower minimums'],
        correctIndex: 2,
        explanation: 'Full payment avoids interest entirely while on-time payments build your credit score over time.',
      ),
    ],
    'topic-6': [
      _QuizEntry(
        id: 't6-q1',
        difficulty: 'ADVANCED',
        text: 'Which investment is lowest risk for a beginner?',
        options: ['Individual stocks', 'Government bonds', 'Cryptocurrency', 'Commodities'],
        correctIndex: 1,
        explanation: 'Government bonds are backed by the state and offer predictable returns, making them the safest starting point for new investors.',
      ),
      _QuizEntry(
        id: 't6-q2',
        difficulty: 'ADVANCED',
        text: 'The main advantage of index funds is:',
        options: ['Guaranteed returns', 'Diversified risk at low cost', 'No taxes on gains', 'Exclusive access'],
        correctIndex: 1,
        explanation: 'Index funds spread risk across hundreds of companies automatically and charge very low fees compared to active funds.',
      ),
      _QuizEntry(
        id: 't6-q3',
        difficulty: 'ADVANCED',
        text: '"Time in the market" refers to:',
        options: ['Trading at the right time', 'Day trading', 'Holding investments long-term', 'Timing market dips'],
        correctIndex: 2,
        explanation: 'Holding investments long-term allows compound growth to work, which consistently outperforms trying to time market movements.',
      ),
      _QuizEntry(
        id: 't6-q4',
        difficulty: 'ADVANCED',
        text: 'Why does starting to invest at age 22 beat starting at 35 (even with less per month)?',
        options: ['Higher contributions', 'More years of compound growth', 'Lower taxes', 'Higher risk tolerance'],
        correctIndex: 1,
        explanation: 'More years of compounding means each early contribution grows exponentially longer, creating a much larger final balance.',
      ),
    ],
  };

  // ── AI Chat predefined responses ──────────────────────────────────────────

  static const aiChatResponses = <String, String>{
    'budget': 'Based on your spending this month, your food budget is at 77% with S/ 116 spent of S/ 150 limit. Try cooking at home 2–3 times this week to stay on track. Your entertainment and subscriptions are well within limits.',
    'save': 'You\'ve saved S/ 0 this month so far. A great first step is automating a S/ 100 transfer on payday — before you can spend it. Even S/ 50/month builds S/ 600 in a year for your emergency fund.',
    'goal': 'Your Emergency Fund is at 28% (S/ 850 of S/ 3000). At your current pace, you\'ll reach it by December 2026. Contributing S/ 200 more per month would let you hit the goal 3 months earlier.',
    'invest': 'For beginners, I recommend starting with a savings account or low-risk bonds before moving to index funds. Time in the market beats timing the market — even S/ 100/month at age 22 compounds significantly by 30.',
    'spend': 'Your top spending categories this month: Health S/ 120, Food S/ 116, Shopping S/ 90, Utilities S/ 79. Health and food are near their limits. I\'d suggest reviewing your gym membership if you\'re not using it regularly.',
    'debt': 'Always pay your credit card full balance monthly to avoid interest charges. Your Visa Credit has S/ 1150 available — that\'s good, keep utilization below 30% to protect your credit score.',
    'analyze': 'Your finances look healthy this month! Income: S/ 1200, Expenses: S/ 481, Net: S/ 719. You\'re saving 60% of income — excellent for a university student. Your top risk area is food spending, which is approaching budget.',
    'default': 'That\'s a great financial question! Based on your current spending patterns, I\'d recommend focusing on building your emergency fund first, then tackling your savings goals. Would you like me to analyze a specific area of your finances?',
  };

  // ── Challenges ─────────────────────────────────────────────────────────────

  static final challenges = <Challenge>[
    const Challenge(
      id: 'challenge-1',
      title: 'No-Coffee Week',
      description: 'Skip coffee purchases for 5 days in a row and save that S/ 8.50/day.',
      pointsReward: 75,
      status: 'ACTIVE',
      progressCurrent: 3,
      progressTotal: 5,
      daysLeft: '4',
      badgeReward: 'Saver',
    ),
    const Challenge(
      id: 'challenge-2',
      title: 'Budget Master',
      description: 'Keep all active budget categories on track for the full month.',
      pointsReward: 100,
      status: 'ACTIVE',
      progressCurrent: 2,
      progressTotal: 3,
      daysLeft: '8',
    ),
    const Challenge(
      id: 'challenge-3',
      title: 'Save S/ 100',
      description: 'Transfer at least S/ 100 to a savings goal this month.',
      pointsReward: 50,
      status: 'COMPLETED',
      progressCurrent: 5,
      progressTotal: 5,
      daysLeft: '0',
    ),
    const Challenge(
      id: 'challenge-4',
      title: 'Track 7 Days',
      description: 'Log at least one transaction every day for 7 consecutive days.',
      pointsReward: 60,
      status: 'AVAILABLE',
      progressCurrent: 0,
      progressTotal: 7,
      daysLeft: '14',
    ),
  ];

  // ── Badges ─────────────────────────────────────────────────────────────────

  static final badges = <ZendaBadge>[
    ZendaBadge(
      id: 'badge-1',
      name: 'First Step',
      description: 'Recorded your first transaction.',
      isEarned: true,
      earnedAt: DateTime(2026, 1, 20),
    ),
    ZendaBadge(
      id: 'badge-2',
      name: '7-Day Streak',
      description: 'Logged transactions for 7 consecutive days.',
      isEarned: true,
      earnedAt: DateTime(2026, 2, 14),
    ),
    ZendaBadge(
      id: 'badge-3',
      name: 'First Survey',
      description: 'Completed your first financial literacy survey.',
      isEarned: true,
      earnedAt: DateTime(2026, 3, 5),
    ),
    ZendaBadge(
      id: 'badge-4',
      name: 'Budget Master',
      description: 'Stay under all your budgets for a full month.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-5',
      name: 'Goal Crusher',
      description: 'Complete any savings goal before its due date.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-6',
      name: 'Investment Starter',
      description: 'Complete the investing topic and quiz.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-7',
      name: '30-Day Streak',
      description: 'Log transactions for 30 consecutive days.',
      isEarned: false,
    ),
  ];

  // ── Financial progress (for ProgressScreen) ──────────────────────────────

  // May 2026 vs April 2026
  static const financialProgress = FinancialProgress(
    currentMonth: MonthFinancials(
      income: 1200.0,
      expenses: 480.8,
      balance: 719.2,
      savings: 300.0,
    ),
    previousMonth: MonthFinancials(
      income: 1000.0,
      expenses: 620.5,
      balance: 379.5,
      savings: 220.0,
    ),
    expensesChangePercent: -22.5,
    savingsChangePercent: 36.4,
    balanceChangePercent: 89.5,
  );

  // ── Survey result (mock for demo mode) ───────────────────────────────────

  static const mockSurveyResult = SurveyResult(
    score: 72.0,
    level: 'intermediate',
    xpEarned: 50,
    badgeUnlocked: 'First Survey',
  );

  static final mockPreSurvey = Survey(
    id: 'survey-pre-demo',
    type: 'PRE',
    questions: [
      const SurveyQuestion(
        id: 'sq-1',
        order: 1,
        text: 'How often do you track your daily expenses?',
        options: ['Never', 'Rarely', 'Sometimes', 'Always'],
      ),
      const SurveyQuestion(
        id: 'sq-2',
        order: 2,
        text: 'Do you have a monthly budget you follow?',
        options: ['No', 'I try but often fail', 'Most of the time', 'Yes, strictly'],
      ),
      const SurveyQuestion(
        id: 'sq-3',
        order: 3,
        text: 'How much do you save from your monthly income?',
        options: ['Nothing', 'Less than 10%', '10–20%', 'More than 20%'],
      ),
      const SurveyQuestion(
        id: 'sq-4',
        order: 4,
        text: 'Do you know what the 50/30/20 budgeting rule is?',
        options: ['No', "I've heard of it", 'I know it roughly', 'I apply it regularly'],
      ),
      const SurveyQuestion(
        id: 'sq-5',
        order: 5,
        text: 'How confident are you in your ability to reach a savings goal?',
        options: ['Not at all', 'Slightly confident', 'Fairly confident', 'Very confident'],
      ),
    ],
  );

  // ── AI prediction ──────────────────────────────────────────────────────────

  static final expensePrediction = PredictionResult(
    period: '2026-06',
    predictedAmount: 460.00,
    confidenceLevel: 0.78,
    narrative: 'Based on your last 3 months, we estimate your June expenses at S/ 460. Your food and transport costs are stable. Reducing subscriptions by one service could bring this below S/ 430.',
    projectedBalance: 780.00,
    budgetUsageFraction: 0.73,
    vsLastMonthLabel: '+8% vs April',
    topCategories: [
      PredictionCategory(
        name: 'Food',
        amount: 320.00,
        color: Color(0xFFFEF3C7),
      ),
      PredictionCategory(
        name: 'Transport',
        amount: 180.00,
        color: Color(0xFFDBEAFE),
      ),
      PredictionCategory(
        name: 'Entertainment',
        amount: 95.00,
        color: Color(0xFFFEE2E2),
      ),
    ],
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

// Helper to hold quiz question data for demo mode.
class _QuizEntry {
  final String id;
  final String difficulty;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const _QuizEntry({
    required this.id,
    required this.difficulty,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}
