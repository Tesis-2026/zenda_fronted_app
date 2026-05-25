import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/summary_models.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/education_api_service.dart';
// merged into education_api_service.dart
import '../services/education_api_service.dart';
import '../services/predictions_api_service.dart';
import '../services/progress_api_service.dart';
import '../services/recommendations_api_service.dart';
import '../services/streak_repository.dart';
// merged into education_api_service.dart

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
      name: 'Efectivo',
      type: AccountType.cash,
      balance: 450.00,
      colorValue: 0xFF34D399,
    ),
    const Account(
      id: 'acc-debit-1',
      name: 'Débito BCP',
      type: AccountType.debit,
      balance: 1280.00,
      colorValue: 0xFF3B82F6,
    ),
    const Account(
      id: 'acc-credit-1',
      name: 'Crédito Visa',
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
      note: 'Café',
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
      note: 'Supermercado',
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
      note: 'Sueldo mensual',
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
      note: 'Proyecto freelance',
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
      note: 'Compras de la semana',
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
      note: 'Recibo de internet',
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
      note: 'Almuerzo con amigos',
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
      note: 'Tutorías part-time',
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
      note: 'Membresía del gimnasio',
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
      note: 'Ropa',
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
      note: 'Pasaje de bus',
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
      note: 'Cine',
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
      note: 'Almuerzo',
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
      note: 'Sueldo de abril (parcial)',
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
      note: 'Consulta médica',
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
      note: 'Venta de libros usados',
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
      note: 'Alquiler de abril',
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
      TopCategoryItem(name: 'Comida', amount: 8.50),
    ],
  );

  // ── Week summary (ISO week 18, 2026) ──────────────────────────────────────

  static final weekSummary = const PeriodSummary(
    totalIncome: 1200.00,
    totalExpense: 20.50,
    netBalance: 1179.50,
    topCategories: [
      TopCategoryItem(name: 'Comida', amount: 8.50),
      TopCategoryItem(name: 'Transporte', amount: 12.00),
    ],
  );

  // ── Month summary (May 2026) ───────────────────────────────────────────────

  static final monthSummary = const PeriodSummary(
    totalIncome: 1200.00,
    totalExpense: 480.80,
    netBalance: 719.20,
    topCategories: [
      TopCategoryItem(name: 'Salud', amount: 120.00),
      TopCategoryItem(name: 'Comida', amount: 116.00),
      TopCategoryItem(name: 'Servicios', amount: 79.00),
      TopCategoryItem(name: 'Compras', amount: 89.90),
      TopCategoryItem(name: 'Entretenimiento', amount: 25.00),
      TopCategoryItem(name: 'Transporte', amount: 12.00),
      TopCategoryItem(name: 'Suscripciones', amount: 37.90),
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
      title: 'Reduce el gasto en comida',
      body: 'Tu presupuesto de comida está al 77% con S/ 116 gastados de S/ 150. Cocina en casa dos veces esta semana para no pasarte.',
      impactScore: 0.85,
      actionLabel: 'Definir presupuesto de comida',
    ),
    Recommendation(
      id: 'rec-2',
      type: 'SAVING',
      title: 'Construye tu fondo de emergencia',
      body: 'No registraste ahorros este mes. Aparta S/ 50 hoy para empezar a construir tu fondo de emergencia.',
      impactScore: 0.90,
      actionLabel: 'Crear meta de fondo de emergencia',
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
      name: 'Fondo de Emergencia',
      targetAmount: 3000.00,
      currentAmount: 850.00,
      dueDate: '2026-12-31',
      createdAt: '2026-01-15T00:00:00Z',
      updatedAt: '2026-04-20T00:00:00Z',
    ),
    const SavingsGoal(
      id: 'goal-2',
      userId: 'demo-user-1',
      name: 'Laptop Nueva',
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
      title: '¿Qué es la regla 50/30/20?',
      content: 'La regla 50/30/20 divide tus ingresos netos en tres bolsillos: 50% para necesidades, 30% para deseos y 20% para ahorro. Las necesidades incluyen alquiler, comida y servicios. Los deseos incluyen comer fuera, suscripciones y entretenimiento. El 20% restante va al ahorro y al pago de deudas.\n\nEste marco te ayuda a construir equilibrio financiero sin necesidad de rastrear cada gasto en detalle.',
      difficulty: 'Principiante',
      category: 'budgeting',
      order: 1,
      isCompleted: true,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-2',
      title: 'Cómo armar un presupuesto realista',
      content: 'Un presupuesto realista parte de conocer tus ingresos reales y tus gastos fijos. Lista primero todo costo recurrente —alquiler, servicios, suscripciones— y luego calcula lo que queda. Asigna un monto fijo al gasto variable (comida, transporte) basándote en los datos del mes anterior.\n\nRevisa tu presupuesto semanalmente el primer mes para detectar desviaciones a tiempo. Cuando te excedas, ajusta los límites por categoría en lugar de abandonar el presupuesto por completo.',
      difficulty: 'Principiante',
      category: 'budgeting',
      order: 2,
      isCompleted: true,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-3',
      title: 'Bases del fondo de emergencia',
      content: 'Un fondo de emergencia equivale a 3 a 6 meses de gastos esenciales guardados en una cuenta líquida. Cubre eventos inesperados —pérdida de empleo, gastos médicos, reparaciones urgentes— sin obligarte a endeudarte.\n\nEmpieza pequeño: S/ 50 al mes son S/ 600 en un año. Mantén el fondo separado de tu cuenta principal para reducir la tentación de gastarlo.',
      difficulty: 'Intermedio',
      category: 'saving',
      order: 3,
      isCompleted: false,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-4',
      title: 'Cómo ahorrar de forma consistente',
      content: 'La constancia gana a los depósitos grandes pero esporádicos. Automatiza una transferencia al ahorro el día de pago —aunque sean S/ 20— antes de tener oportunidad de gastarlo. Este hábito de "págate primero a ti mismo" saca a la fuerza de voluntad de la ecuación.\n\nMide mensualmente tu tasa de ahorro (ahorro ÷ ingreso × 100). Una tasa del 10% es un buen punto de partida para estudiantes universitarios.',
      difficulty: 'Intermedio',
      category: 'saving',
      order: 4,
      isCompleted: false,
      questionCount: 4,
      isLocked: false,
    ),
    EducationTopic(
      id: 'topic-5',
      title: 'Cómo funcionan las tarjetas de crédito',
      content: 'Las tarjetas de crédito cobran intereses solo sobre los saldos no pagados. Pagar el saldo completo del estado de cuenta cada mes no te cuesta nada en intereses y construye tu historial crediticio.\n\nEl pago mínimo te atrapa en un ciclo de deuda —un saldo de S/ 500 pagado en mínimos puede tardar años en cancelarse. Apunta siempre a pagar más que el mínimo, idealmente el saldo completo.',
      difficulty: 'Intermedio',
      category: 'budgeting',
      order: 5,
      isCompleted: false,
      questionCount: 4,
      isLocked: true,
    ),
    EducationTopic(
      id: 'topic-6',
      title: 'Inversión para principiantes',
      content: 'Invertir significa poner el dinero a trabajar para que crezca con el tiempo. Empieza por opciones de bajo riesgo: cuentas de ahorro, depósitos a plazo o bonos del gobierno. Conforme aprendas, considera fondos indexados —reparten el riesgo entre muchas empresas a bajo costo.\n\nEl tiempo en el mercado importa más que el momento exacto. Empezar con S/ 100 al mes a los 22 años supera a S/ 500 al mes a los 35 en el largo plazo.',
      difficulty: 'Avanzado',
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
        difficulty: 'Principiante',
        text: 'En la regla 50/30/20, ¿qué porcentaje va a las necesidades?',
        options: ['30%', '50%', '20%', '40%'],
        correctIndex: 1,
        explanation: 'El 50 en 50/30/20 asigna la mitad de tus ingresos netos a necesidades esenciales como alquiler, comida y servicios.',
      ),
      _QuizEntry(
        id: 't1-q2',
        difficulty: 'Principiante',
        text: '¿Cuál de los siguientes es un "deseo" según la regla 50/30/20?',
        options: ['Alquiler', 'Comida básica', 'Suscripción de streaming', 'Servicios'],
        correctIndex: 2,
        explanation: 'Una suscripción de streaming es discrecional (un deseo): puedes cancelarla sin afectar tus necesidades básicas.',
      ),
      _QuizEntry(
        id: 't1-q3',
        difficulty: 'Principiante',
        text: '¿Qué representa el "20" en 50/30/20?',
        options: ['Entretenimiento', 'Impuestos', 'Ahorro y pago de deudas', 'Vivienda'],
        correctIndex: 2,
        explanation: 'El 20% se reserva para construir ahorros y pagar deudas, lo que te ayuda a crecer tu patrimonio con el tiempo.',
      ),
      _QuizEntry(
        id: 't1-q4',
        difficulty: 'Principiante',
        text: 'Con un ingreso mensual de S/ 2000, ¿cuánto debería ir al ahorro según la regla 50/30/20?',
        options: ['S/ 1000', 'S/ 600', 'S/ 400', 'S/ 200'],
        correctIndex: 2,
        explanation: 'El 20% de S/ 2000 = S/ 400; ese es tu monto objetivo de ahorro mensual bajo la regla 50/30/20.',
      ),
    ],
    'topic-2': [
      _QuizEntry(
        id: 't2-q1',
        difficulty: 'Principiante',
        text: '¿Qué deberías listar primero al armar un presupuesto realista?',
        options: ['Gasto variable', 'Entretenimiento', 'Costos fijos recurrentes', 'Metas de ahorro'],
        correctIndex: 2,
        explanation: 'Los costos fijos como alquiler, servicios y suscripciones son predecibles y deben cubrirse cada mes, por eso anclan tu presupuesto.',
      ),
      _QuizEntry(
        id: 't2-q2',
        difficulty: 'Principiante',
        text: '¿Con qué frecuencia debes revisar tu presupuesto en el primer mes?',
        options: ['Diario', 'Semanal', 'Mensual', 'Trimestral'],
        correctIndex: 1,
        explanation: 'Las revisiones semanales del primer mes te ayudan a detectar excesos a tiempo y ajustar antes de que termine el mes.',
      ),
      _QuizEntry(
        id: 't2-q3',
        difficulty: 'Principiante',
        text: 'Cuando te excedes en una categoría, la mejor respuesta es:',
        options: ['Abandonar el presupuesto', 'Tomar prestado del próximo mes', 'Ajustar el límite de la categoría', 'Ignorarlo'],
        correctIndex: 2,
        explanation: 'Ajustar el límite con datos reales hace que tu presupuesto sea más preciso y sostenible en el tiempo.',
      ),
      _QuizEntry(
        id: 't2-q4',
        difficulty: 'Principiante',
        text: '¿Qué fuente de datos es más útil para asignar el gasto variable?',
        options: ['Los gastos de un amigo', 'Calculadoras en línea', 'Tu gasto real del mes anterior', 'Tu tasa de impuestos'],
        correctIndex: 2,
        explanation: 'Tu propio gasto pasado es la línea base más precisa porque refleja tus hábitos personales y costo de vida.',
      ),
    ],
    'topic-3': [
      _QuizEntry(
        id: 't3-q1',
        difficulty: 'Intermedio',
        text: '¿Cuántos meses de gastos debe cubrir un fondo de emergencia?',
        options: ['1 a 2 meses', '3 a 6 meses', '7 a 9 meses', '1 año'],
        correctIndex: 1,
        explanation: 'De 3 a 6 meses te da suficiente colchón para enfrentar pérdida de empleo o emergencias médicas sin endeudarte.',
      ),
      _QuizEntry(
        id: 't3-q2',
        difficulty: 'Intermedio',
        text: '¿Qué tipo de cuenta es mejor para un fondo de emergencia?',
        options: ['Inversión de largo plazo', 'Acciones de alto riesgo', 'Cuenta de ahorro líquida', 'Depósito a plazo fijo'],
        correctIndex: 2,
        explanation: 'Una cuenta líquida te permite acceder al dinero de inmediato en una emergencia, sin penalidades ni esperas.',
      ),
      _QuizEntry(
        id: 't3-q3',
        difficulty: 'Intermedio',
        text: 'El propósito principal de un fondo de emergencia es:',
        options: ['Invertir en acciones', 'Cubrir costos imprevistos sin endeudarse', 'Pagar las cuentas regulares', 'Financiar viajes de vacaciones'],
        correctIndex: 1,
        explanation: 'Un fondo de emergencia actúa como colchón financiero para que los imprevistos no te empujen a deudas con altos intereses.',
      ),
      _QuizEntry(
        id: 't3-q4',
        difficulty: 'Intermedio',
        text: 'Ahorrando S/ 50 al mes, ¿cuánto te toma llegar a S/ 600?',
        options: ['6 meses', '1 año', '2 años', '18 meses'],
        correctIndex: 1,
        explanation: 'S/ 50 × 12 meses = S/ 600; los depósitos pequeños y constantes se acumulan de forma significativa en un año.',
      ),
    ],
    'topic-4': [
      _QuizEntry(
        id: 't4-q1',
        difficulty: 'Intermedio',
        text: '¿Qué significa "págate primero a ti mismo"?',
        options: ['Gastar en ti antes que en las cuentas', 'Ahorrar antes de gastar', 'Invertir el 50% del ingreso', 'Pagar deudas primero'],
        correctIndex: 1,
        explanation: 'Ahorrar antes de gastar saca la fuerza de voluntad de la ecuación: tu transferencia al ahorro ocurre automáticamente el día de pago.',
      ),
      _QuizEntry(
        id: 't4-q2',
        difficulty: 'Intermedio',
        text: '¿Cuál es el momento ideal para transferir dinero al ahorro?',
        options: ['Fin de mes', 'El día de pago', 'Después de todos los gastos', 'En cualquier momento'],
        correctIndex: 1,
        explanation: 'Transferir el día de pago hace que el ahorro ocurra antes del gasto discrecional, asegurando que siempre apartes algo.',
      ),
      _QuizEntry(
        id: 't4-q3',
        difficulty: 'Intermedio',
        text: 'Una tasa de ahorro inicial sólida para estudiantes universitarios es:',
        options: ['5%', '20%', '10%', '30%'],
        correctIndex: 2,
        explanation: 'Una tasa del 10% es alcanzable con un ingreso estudiantil y construye el hábito de ahorrar sin restringir demasiado el gasto.',
      ),
      _QuizEntry(
        id: 't4-q4',
        difficulty: 'Intermedio',
        text: '¿Cómo se calcula tu tasa de ahorro?',
        options: ['Ahorro × 100', 'Ahorro ÷ gastos × 100', 'Ahorro ÷ ingreso × 100', 'Ahorro ÷ 12'],
        correctIndex: 2,
        explanation: 'Tasa de ahorro = (monto ahorrado ÷ ingreso total) × 100; dividir entre el ingreso muestra qué fracción de tus ganancias conservas.',
      ),
    ],
    'topic-5': [
      _QuizEntry(
        id: 't5-q1',
        difficulty: 'Intermedio',
        text: '¿Cuándo cobran intereses las tarjetas de crédito?',
        options: ['En cada compra', 'Solo en avances de efectivo', 'Sobre saldos no pagados', 'Cada mes sin importar nada'],
        correctIndex: 2,
        explanation: 'Los intereses se cobran solo sobre el saldo que mantengas después de la fecha de pago; pagar el total cada mes implica cero intereses.',
      ),
      _QuizEntry(
        id: 't5-q2',
        difficulty: 'Intermedio',
        text: 'La mejor estrategia de pago de una tarjeta de crédito es:',
        options: ['Pagar el mínimo', 'Pagar el saldo total del estado de cuenta', 'Pagar la mitad del saldo', 'Saltarse un mes'],
        correctIndex: 1,
        explanation: 'Pagar el saldo total elimina los intereses y construye un historial crediticio positivo sin costo extra.',
      ),
      _QuizEntry(
        id: 't5-q3',
        difficulty: 'Intermedio',
        text: 'Pagar solo el mínimo de una tarjeta de crédito resulta en:',
        options: ['Mejor score crediticio', 'Los intereses se detienen', 'Un ciclo de deuda', 'Exoneración de comisiones'],
        correctIndex: 2,
        explanation: 'Los pagos mínimos apenas cubren los intereses, así que el capital casi no baja, atrapándote en un ciclo de deuda lento y caro.',
      ),
      _QuizEntry(
        id: 't5-q4',
        difficulty: 'Intermedio',
        text: 'Pagar el saldo total de la tarjeta de crédito cada mes te da:',
        options: ['Mayor línea de crédito', 'Recompensas en efectivo', 'Cero intereses y mejora tu historial', 'Pagos mínimos más bajos'],
        correctIndex: 2,
        explanation: 'Pagar el total evita los intereses por completo y los pagos a tiempo construyen tu historial crediticio con el tiempo.',
      ),
    ],
    'topic-6': [
      _QuizEntry(
        id: 't6-q1',
        difficulty: 'Avanzado',
        text: '¿Qué inversión es de menor riesgo para un principiante?',
        options: ['Acciones individuales', 'Bonos del gobierno', 'Criptomonedas', 'Materias primas'],
        correctIndex: 1,
        explanation: 'Los bonos del gobierno están respaldados por el Estado y ofrecen rendimientos predecibles, siendo el punto de partida más seguro para nuevos inversores.',
      ),
      _QuizEntry(
        id: 't6-q2',
        difficulty: 'Avanzado',
        text: 'La principal ventaja de los fondos indexados es:',
        options: ['Rendimientos garantizados', 'Riesgo diversificado a bajo costo', 'Sin impuestos sobre las ganancias', 'Acceso exclusivo'],
        correctIndex: 1,
        explanation: 'Los fondos indexados reparten el riesgo entre cientos de empresas automáticamente y cobran comisiones muy bajas comparadas con los fondos activos.',
      ),
      _QuizEntry(
        id: 't6-q3',
        difficulty: 'Avanzado',
        text: '"Tiempo en el mercado" se refiere a:',
        options: ['Operar en el momento correcto', 'Day trading', 'Mantener inversiones a largo plazo', 'Adivinar las caídas del mercado'],
        correctIndex: 2,
        explanation: 'Mantener inversiones a largo plazo deja que el interés compuesto trabaje, lo cual supera consistentemente a intentar adivinar los movimientos del mercado.',
      ),
      _QuizEntry(
        id: 't6-q4',
        difficulty: 'Avanzado',
        text: '¿Por qué empezar a invertir a los 22 años gana frente a empezar a los 35 (aun con menos al mes)?',
        options: ['Aportes más altos', 'Más años de crecimiento compuesto', 'Impuestos más bajos', 'Mayor tolerancia al riesgo'],
        correctIndex: 1,
        explanation: 'Más años de capitalización significan que cada aporte temprano crece exponencialmente por más tiempo, generando un saldo final mucho mayor.',
      ),
    ],
  };

  // ── AI Chat predefined responses ──────────────────────────────────────────

  static const aiChatResponses = <String, String>{
    'budget': 'Según tu gasto de este mes, tu presupuesto de comida está al 77% con S/ 116 gastados de un límite de S/ 150. Cocina en casa 2 o 3 veces esta semana para mantenerte en rumbo. Tu entretenimiento y suscripciones están bien dentro de los límites.',
    'save': 'Has ahorrado S/ 0 este mes hasta ahora. Un gran primer paso es automatizar una transferencia de S/ 100 el día de pago, antes de que puedas gastarlo. Incluso S/ 50 al mes son S/ 600 al año para tu fondo de emergencia.',
    'goal': 'Tu Fondo de Emergencia está al 28% (S/ 850 de S/ 3000). Al ritmo actual, lo alcanzarás en diciembre de 2026. Aportar S/ 200 más al mes te permitiría llegar a la meta 3 meses antes.',
    'invest': 'Para principiantes, recomiendo empezar con una cuenta de ahorro o bonos de bajo riesgo antes de pasar a fondos indexados. El tiempo en el mercado le gana al timing del mercado: incluso S/ 100 al mes a los 22 años se capitaliza significativamente para los 30.',
    'spend': 'Tus principales categorías de gasto este mes: Salud S/ 120, Comida S/ 116, Compras S/ 90, Servicios S/ 79. Salud y comida están cerca de su límite. Te sugiero revisar tu membresía del gimnasio si no la estás usando con regularidad.',
    'debt': 'Paga siempre el saldo total de tu tarjeta de crédito cada mes para evitar intereses. Tu Crédito Visa tiene S/ 1150 disponibles, eso es bueno; mantén la utilización por debajo del 30% para proteger tu score crediticio.',
    'analyze': '¡Tus finanzas se ven saludables este mes! Ingreso: S/ 1200, Gasto: S/ 481, Neto: S/ 719. Estás ahorrando el 60% de tu ingreso, excelente para un estudiante universitario. Tu mayor área de riesgo es el gasto en comida, que se acerca al presupuesto.',
    'default': '¡Excelente pregunta financiera! Según tus patrones de gasto actuales, te recomiendo enfocarte primero en construir tu fondo de emergencia y luego trabajar tus metas de ahorro. ¿Quieres que analice un área específica de tus finanzas?',
  };

  // ── Challenges ─────────────────────────────────────────────────────────────

  static final challenges = <Challenge>[
    const Challenge(
      id: 'challenge-1',
      title: 'Semana sin café',
      description: 'No compres café por 5 días seguidos y ahorra esos S/ 8.50 al día.',
      pointsReward: 75,
      status: 'ACTIVE',
      progressCurrent: 3,
      progressTotal: 5,
      daysLeft: '4',
      badgeReward: 'Ahorrador',
    ),
    const Challenge(
      id: 'challenge-2',
      title: 'Maestro del presupuesto',
      description: 'Mantén todas tus categorías de presupuesto activas en rumbo durante todo el mes.',
      pointsReward: 100,
      status: 'ACTIVE',
      progressCurrent: 2,
      progressTotal: 3,
      daysLeft: '8',
    ),
    const Challenge(
      id: 'challenge-3',
      title: 'Ahorra S/ 100',
      description: 'Transfiere al menos S/ 100 a una meta de ahorro este mes.',
      pointsReward: 50,
      status: 'COMPLETED',
      progressCurrent: 5,
      progressTotal: 5,
      daysLeft: '0',
    ),
    const Challenge(
      id: 'challenge-4',
      title: 'Registra 7 días',
      description: 'Registra al menos una transacción cada día durante 7 días consecutivos.',
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
      name: 'Primer paso',
      description: 'Registraste tu primera transacción.',
      isEarned: true,
      earnedAt: DateTime(2026, 1, 20),
    ),
    ZendaBadge(
      id: 'badge-2',
      name: 'Racha de 7 días',
      description: 'Registraste transacciones durante 7 días consecutivos.',
      isEarned: true,
      earnedAt: DateTime(2026, 2, 14),
    ),
    ZendaBadge(
      id: 'badge-3',
      name: 'Primera encuesta',
      description: 'Completaste tu primera encuesta de alfabetización financiera.',
      isEarned: true,
      earnedAt: DateTime(2026, 3, 5),
    ),
    ZendaBadge(
      id: 'badge-4',
      name: 'Maestro del presupuesto',
      description: 'Mantente debajo de todos tus presupuestos durante un mes entero.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-5',
      name: 'Conquistador de metas',
      description: 'Completa cualquier meta de ahorro antes de su fecha límite.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-6',
      name: 'Inversor inicial',
      description: 'Completa el tema de inversión y su cuestionario.',
      isEarned: false,
    ),
    ZendaBadge(
      id: 'badge-7',
      name: 'Racha de 30 días',
      description: 'Registra transacciones durante 30 días consecutivos.',
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
    level: 'Intermedio',
    xpEarned: 50,
    badgeUnlocked: 'Primera encuesta',
  );

  static final mockPreSurvey = Survey(
    id: 'survey-pre-demo',
    type: 'PRE',
    questions: [
      const SurveyQuestion(
        id: 'sq-1',
        order: 1,
        text: '¿Con qué frecuencia registras tus gastos diarios?',
        options: ['Nunca', 'Rara vez', 'A veces', 'Siempre'],
      ),
      const SurveyQuestion(
        id: 'sq-2',
        order: 2,
        text: '¿Tienes un presupuesto mensual que sigas?',
        options: ['No', 'Lo intento pero suelo fallar', 'La mayor parte del tiempo', 'Sí, estrictamente'],
      ),
      const SurveyQuestion(
        id: 'sq-3',
        order: 3,
        text: '¿Cuánto ahorras de tus ingresos mensuales?',
        options: ['Nada', 'Menos del 10%', 'Entre 10% y 20%', 'Más del 20%'],
      ),
      const SurveyQuestion(
        id: 'sq-4',
        order: 4,
        text: '¿Sabes qué es la regla de presupuesto 50/30/20?',
        options: ['No', 'He escuchado de ella', 'La conozco a grandes rasgos', 'La aplico regularmente'],
      ),
      const SurveyQuestion(
        id: 'sq-5',
        order: 5,
        text: '¿Qué tan confiado te sientes de alcanzar una meta de ahorro?',
        options: ['Nada confiado', 'Algo confiado', 'Bastante confiado', 'Muy confiado'],
      ),
    ],
  );

  // ── AI prediction ──────────────────────────────────────────────────────────

  static final expensePrediction = PredictionResult(
    period: '2026-06',
    predictedTotal: 460.00,
    confidence: PredictionConfidence.medium,
    confidenceInterval: PredictionInterval(lower: 391.00, upper: 529.00),
    narrative:
        'Según tus últimos 3 meses, estimamos tus gastos de junio en S/ 460. Tus costos de comida y transporte se mantienen estables. Reducir una de tus suscripciones podría llevarlo por debajo de S/ 430.',
    projectedBalance: 780.00,
    budgetUsageFraction: 0.73,
    vsLastMonthLabel: '+8% vs abril',
    categories: [
      PredictionCategory(
        name: 'Comida',
        amount: 320.00,
        color: Color(0xFFFEF3C7),
      ),
      PredictionCategory(
        name: 'Transporte',
        amount: 180.00,
        color: Color(0xFFDBEAFE),
      ),
      PredictionCategory(
        name: 'Entretenimiento',
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
        TransactionCategory.comida => 'Comida',
        TransactionCategory.transporte => 'Transporte',
        TransactionCategory.vivienda => 'Vivienda',
        TransactionCategory.servicios => 'Servicios',
        TransactionCategory.salud => 'Salud',
        TransactionCategory.ocio => 'Entretenimiento',
        TransactionCategory.compras => 'Compras',
        TransactionCategory.suscripciones => 'Suscripciones',
        TransactionCategory.antojos => 'Antojos',
        TransactionCategory.ahorro => 'Ahorro',
        _ => 'Otros',
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
