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
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int nextIndex) {
    if (nextIndex == _index) return;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (value) => setState(() => _index = value),
          children: const [
            _InicioSection(),
            _MovsSection(),
            _PresupuestoSection(),
            _PerfilSection(),
          ],
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
                child: _BottomOption(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: _index == 0,
                  onTap: () => _goTo(0),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.receipt_long_rounded,
                  label: 'Movs',
                  isActive: _index == 1,
                  onTap: () => _goTo(1),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.pie_chart_rounded,
                  label: 'Presupuesto',
                  isActive: _index == 2,
                  onTap: () => _goTo(2),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: _index == 3,
                  onTap: () => _goTo(3),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _index == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
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
}

class _InicioSection extends ConsumerWidget {
  const _InicioSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        _LegendItem(
          color: const Color(0xFF34D399),
          label: 'Necesidades',
          value: breakdown.totalNecesidades,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFC084FC),
          label: 'Deseos',
          value: breakdown.totalDeseos,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFFCD34D),
          label: 'Ahorro',
          value: breakdown.totalAhorro,
        ),
      ],
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(accountsProvider);
        ref.invalidate(transactionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isNarrow ? 16 : 20,
          isNarrow ? 16 : 24,
          isNarrow ? 16 : 20,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),

            SizedBox(height: isNarrow ? 16 : 24),

            SummaryCard(todayExpense: todayExpense, weekExpense: weekExpense),

            SizedBox(height: isNarrow ? 16 : 24),

            Row(
              children: [
                const Text(
                  'Tu Racha',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                StreakCard(streakDays: streak),
              ],
            ),

            SizedBox(height: isNarrow ? 16 : 24),

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
                  itemCount: accounts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == accounts.length) {
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error al cargar cuentas: $err'),
              ),
            ),

            SizedBox(height: isNarrow ? 24 : 32),

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

            if (isNarrow) ...[
              BudgetPieChart(breakdown: breakdown),
              const SizedBox(height: 16),
              legendColumn,
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: BudgetPieChart(breakdown: breakdown),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: legendColumn),
                ],
              ),
            ],

            SizedBox(height: isNarrow ? 16 : 24),
            ZendaAiCard(advice: advice),
          ],
        ),
      ),
    );
  }
}

class _MovsSection extends ConsumerWidget {
  const _MovsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final txAsync = ref.watch(transactionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(transactionsProvider);
      },
      child: txAsync.when(
        data: (txs) {
          if (txs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isNarrow ? 16 : 20,
                isNarrow ? 16 : 24,
                isNarrow ? 16 : 20,
                120,
              ),
              children: const [
                Text(
                  'Movimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('Aún no tienes movimientos.'),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isNarrow ? 16 : 20,
              isNarrow ? 16 : 24,
              isNarrow ? 16 : 20,
              120,
            ),
            itemCount: txs.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Text(
                  'Movimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              }
              final tx = txs[index - 1];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFF34D399),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.note ?? tx.category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tx.timestamp.day.toString().padLeft(2, '0')}/${tx.timestamp.month.toString().padLeft(2, '0')} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'S/ ${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 16 : 20,
            isNarrow ? 16 : 24,
            isNarrow ? 16 : 20,
            120,
          ),
          children: [
            const Text(
              'Movimientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Error al cargar movimientos: $err'),
          ],
        ),
      ),
    );
  }
}

class _PresupuestoSection extends ConsumerWidget {
  const _PresupuestoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final breakdown = ref.watch(budgetBreakdownProvider);
    final advice = ref.watch(aiAdviceProvider);

    final legendColumn = Column(
      children: [
        _LegendItem(
          color: const Color(0xFF34D399),
          label: 'Necesidades',
          value: breakdown.totalNecesidades,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFC084FC),
          label: 'Deseos',
          value: breakdown.totalDeseos,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFFCD34D),
          label: 'Ahorro',
          value: breakdown.totalAhorro,
        ),
      ],
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isNarrow ? 16 : 20,
        isNarrow ? 16 : 24,
        isNarrow ? 16 : 20,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Presupuesto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          if (isNarrow) ...[
            BudgetPieChart(breakdown: breakdown),
            const SizedBox(height: 16),
            legendColumn,
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: BudgetPieChart(breakdown: breakdown)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: legendColumn),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ZendaAiCard(advice: advice),
        ],
      ),
    );
  }
}

class _PerfilSection extends ConsumerWidget {
  const _PerfilSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isNarrow ? 16 : 20,
        isNarrow ? 16 : 24,
        isNarrow ? 16 : 20,
        120,
      ),
      children: [
        const Text(
          'Perfil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF34D399).withOpacity(0.2),
                child: Text(
                  (user?.name.isNotEmpty == true)
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          title: const Text('Cerrar sesión'),
          onTap: () {
            ref.read(authNotifierProvider.notifier).logout();
            context.go('/auth/login');
          },
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _BottomOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
