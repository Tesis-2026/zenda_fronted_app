import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/transactions/transaction_list_screen.dart';
import '../../providers/pre_survey_provider.dart';
import 'dashboard_providers.dart';
import 'widgets/summary_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/account_card.dart';
import 'widgets/budget_pie_chart.dart';
import 'widgets/zenda_ai_card.dart';
import '../../l10n/l10n_extension.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

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
    final l10n = context.l10n;

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
                color: Colors.black.withValues(alpha: 0.05),
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
                  label: l10n.dashboardNavHome,
                  isActive: _index == 0,
                  onTap: () => _goTo(0),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.dashboardNavTransactions,
                  isActive: _index == 1,
                  onTap: () => _goTo(1),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.pie_chart_rounded,
                  label: l10n.dashboardNavBudget,
                  isActive: _index == 2,
                  onTap: () => _goTo(2),
                ),
              ),
              Expanded(
                child: _BottomOption(
                  icon: Icons.person_rounded,
                  label: l10n.dashboardNavProfile,
                  isActive: false,
                  onTap: () => context.push('/profile'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                context.push('/add-transaction');
              },
              backgroundColor: const Color(0xFF34D399),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                l10n.dashboardRecord,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
    final l10n = context.l10n;

    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.grey[400] : Colors.grey[600];

    final accountsAsync = ref.watch(accountsProvider);

    // Post-survey banner: show after 30 days if pre done but post not done
    final preSurveyDone = ref.watch(preSurveyProvider).asData?.value ?? false;
    final postSurveyDone = ref.watch(postSurveyProvider).asData?.value ?? false;

    // Expense values
    final todayExpense = ref.watch(todayExpenseProvider);
    final weekExpense = ref.watch(weekExpenseProvider);

    // Streak
    final streak = ref.watch(streakProvider);

    // Budget Breakdown
    final breakdown = ref.watch(budgetBreakdownProvider);

    // AI Advice
    final advice = ref.watch(aiAdviceProvider(l10n));

    final legendColumn = Column(
      children: [
        _LegendItem(
          color: const Color(0xFF34D399),
          label: l10n.dashboardNeeds,
          value: breakdown.totalNecesidades,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFC084FC),
          label: l10n.dashboardWants,
          value: breakdown.totalDeseos,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFFCD34D),
          label: l10n.dashboardSavings,
          value: breakdown.totalAhorro,
        ),
      ],
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(accountsProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(daySummaryProvider);
        ref.invalidate(weekSummaryProvider);
        ref.invalidate(monthSummaryProvider);
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
                      l10n.dashboardGreeting(user?.name.split(' ').first ?? l10n.dashboardUserFallback),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dashboardMotivation,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: onSurfaceMuted),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),

            SizedBox(height: isNarrow ? 16 : 24),

            if (preSurveyDone && !postSurveyDone)
              FutureBuilder<DateTime?>(
                future: PreSurveyNotifier.completedAt(),
                builder: (context, snap) {
                  final completedAt = snap.data;
                  final daysSince = completedAt != null
                      ? DateTime.now().difference(completedAt).inDays
                      : 0;
                  if (daysSince < 30) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostSurveyBanner(l10n: l10n),
                  );
                },
              ),

            SummaryCard(todayExpense: todayExpense, weekExpense: weekExpense),

            SizedBox(height: isNarrow ? 16 : 24),

            Center(child: StreakCard(streakDays: streak)),

            SizedBox(height: isNarrow ? 16 : 24),

            Text(
              l10n.dashboardMyAccounts,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
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
                error: (err, stack) => Text(l10n.dashboardErrorAccounts(err.toString())),
              ),
            ),

            SizedBox(height: isNarrow ? 24 : 32),

            Text(
              l10n.dashboardBudgetTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.dashboardBudgetSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
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
    return const TransactionListScreen();
  }
}

class _PresupuestoSection extends ConsumerWidget {
  const _PresupuestoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final breakdown = ref.watch(budgetBreakdownProvider);
    final l10n = context.l10n;
    final advice = ref.watch(aiAdviceProvider(l10n));

    final onSurface = isDark ? Colors.white : Colors.black87;

    final legendColumn = Column(
      children: [
        _LegendItem(
          color: const Color(0xFF34D399),
          label: l10n.dashboardNeeds,
          value: breakdown.totalNecesidades,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFC084FC),
          label: l10n.dashboardWants,
          value: breakdown.totalDeseos,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: const Color(0xFFFCD34D),
          label: l10n.dashboardSavings,
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
          Text(
            l10n.dashboardNavBudget,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardBudgetTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dashboardBudgetSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
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

class _PostSurveyBanner extends StatefulWidget {
  const _PostSurveyBanner({required this.l10n});
  final dynamic l10n;

  @override
  State<_PostSurveyBanner> createState() => _PostSurveyBannerState();
}

class _PostSurveyBannerState extends State<_PostSurveyBanner> {
  bool _dismissed = false;

  void _dismiss() => setState(() => _dismissed = true);

  Future<void> _takeSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zenda.post_survey_done', 'true');
    if (!mounted) return;
    context.push('/surveys/post');
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final l10n = widget.l10n;
    const bannerColor = Color(0xFF3B82F6);

    return Container(
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.assignment_rounded, color: bannerColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardPostSurveyBannerTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: bannerColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.dashboardPostSurveyBannerBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: bannerColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _dismiss,
                style: TextButton.styleFrom(
                  foregroundColor: bannerColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Later'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _takeSurvey,
                style: FilledButton.styleFrom(
                  backgroundColor: bannerColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(l10n.dashboardPostSurveyBannerAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
