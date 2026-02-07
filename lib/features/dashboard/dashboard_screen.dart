import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_controller.dart';
import 'dashboard_providers.dart';
import 'widgets/summary_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/account_card.dart';
import 'widgets/budget_pie_chart.dart';
import 'widgets/zenda_ai_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;

    final accountsAsync = ref.watch(accountsProvider);

    // Expense values
    final todayExpense = ref.watch(todayExpenseProvider);
    final weekExpense = ref.watch(weekExpenseProvider);

    // Streak
    final streak = ref.watch(streakProvider);

    // Budget Breakdown
    final breakdown = ref.watch(budgetBreakdownProvider);

    // AI Advice
    final advice = ref.watch(aiAdviceProvider);

    final legendColumn = Column(
      children: [
        _buildLegendItem(
          context,
          color: const Color(0xFF34D399),
          label: 'Necesidades',
          value: breakdown.totalNecesidades,
          percent: breakdown.percentNecesidades(),
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          color: const Color(0xFFC084FC),
          label: 'Deseos',
          value: breakdown.totalDeseos,
          percent: breakdown.percentDeseos(),
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          color: const Color(0xFFFCD34D),
          label: 'Ahorro',
          value: breakdown.totalAhorro,
          percent: breakdown.percentAhorro(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh providers
            ref.invalidate(accountsProvider);
            ref.invalidate(transactionsProvider);
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 16 : 20,
              vertical: isNarrow ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header & Greetings
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${user?.name.split(' ').first ?? 'Usuario'} 👋',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vamos a mejorar tus finanzas hoy.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),

                SizedBox(height: isNarrow ? 16 : 24),

                // 2. Quick Summary
                SummaryCard(
                  todayExpense: todayExpense,
                  weekExpense: weekExpense,
                ),

                SizedBox(height: isNarrow ? 16 : 24),

                // 3. Streak
                Row(
                  children: [
                    const Text(
                      'Tu Racha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StreakCard(streakDays: streak),
                  ],
                ),

                SizedBox(height: isNarrow ? 16 : 24),

                // 4. Accounts Module
                Text(
                  'Mis Cuentas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isNarrow ? 12 : 16),
                SizedBox(
                  height: isNarrow ? 130 : 140,
                  child: accountsAsync.when(
                    data: (accounts) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          accounts.length +
                          1, // +1 for "Add Account" placeholder
                      itemBuilder: (context, index) {
                        if (index == accounts.length) {
                          // Placeholder "Add Account" card
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.grey),
                            ),
                          );
                        }
                        return AccountCard(account: accounts[index]);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Text('Error al cargar cuentas: $err'),
                  ),
                ),

                SizedBox(height: isNarrow ? 24 : 32),

                // 5. 50/30/20 Breakdown & Advice
                Text(
                  'Tu Presupuesto 50/30/20',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basado en tus gastos de los últimos 30 días',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                SizedBox(height: isNarrow ? 16 : 24),

                // Row with Chart and Legend/Advice
                if (isNarrow) ...[
                  BudgetPieChart(breakdown: breakdown),
                  const SizedBox(height: 16),
                  legendColumn,
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pie Chart
                      Expanded(
                        flex: 2,
                        child: BudgetPieChart(breakdown: breakdown),
                      ),
                      const SizedBox(width: 24),
                      // Legend
                      Expanded(flex: 3, child: legendColumn),
                    ],
                  ),
                ],

                SizedBox(height: isNarrow ? 16 : 24),

                // 6. AI Advice Card
                ZendaAiCard(advice: advice),

                SizedBox(height: isNarrow ? 56 : 80), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 16 : 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1220) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildBottomOption(
                  context,
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: true,
                ),
              ),
              Expanded(
                child: _buildBottomOption(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Movs',
                ),
              ),
              Expanded(
                child: _buildBottomOption(
                  context,
                  icon: Icons.pie_chart_rounded,
                  label: 'Presupuesto',
                ),
              ),
              Expanded(
                child: _buildBottomOption(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add transaction placeholder
          context.push('/add-transaction');
        },
        backgroundColor: const Color(0xFF34D399),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required double value,
    required double percent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.black87,
                fontSize: 13,
              ),
            ),
            Text(
              'S/ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? const Color(0xFF34D399)
        : (isDark ? Colors.grey[400]! : Colors.grey[600]!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
