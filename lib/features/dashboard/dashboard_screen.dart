import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../features/auth/auth_controller.dart';
import '../../providers/pre_survey_provider.dart';
import 'dashboard_providers.dart';
import 'widgets/streak_card.dart';
import 'widgets/zenda_ai_card.dart';
import '../../l10n/l10n_extension.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: const SafeArea(child: _InicioSection()),
      bottomNavigationBar: const AppBottomNav(activeIndex: 0),
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
    final l10n = context.l10n;

    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.grey[400] : Colors.grey[600];

    final accountsAsync = ref.watch(accountsProvider);
    final monthSummaryAsync = ref.watch(monthSummaryProvider);

    final preSurveyDone = ref.watch(preSurveyProvider).asData?.value ?? false;
    final postSurveyDone = ref.watch(postSurveyProvider).asData?.value ?? false;

    final streak = ref.watch(streakProvider);
    final advice = ref.watch(aiAdviceProvider(l10n));

    final totalBalance = accountsAsync.asData?.value.fold<double>(
          0.0,
          (sum, a) => sum + a.balance,
        ) ??
        0.0;

    final income = monthSummaryAsync.when(
      data: (s) => s.totalIncome,
      loading: () => 0.0,
      error: (_, _) => 0.0,
    );
    final expense = monthSummaryAsync.when(
      data: (s) => s.totalExpense,
      loading: () => 0.0,
      error: (_, _) => 0.0,
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardGreeting(
                        user?.name.split(' ').first ??
                            l10n.dashboardUserFallback,
                      ),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMM(
                        Localizations.localeOf(context).languageCode,
                      ).format(DateTime.now()),
                      style: TextStyle(fontSize: 13, color: onSurfaceMuted),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/notifications'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Center(
                      child: Text('🔔', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (preSurveyDone && !postSurveyDone)
              FutureBuilder<DateTime?>(
                future: PreSurveyNotifier.completedAt(),
                builder: (context, snap) {
                  final completedAt = snap.data;
                  final daysSince = completedAt != null
                      ? DateTime.now().difference(completedAt).inDays
                      : 0;
                  if (daysSince < 30) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _PostSurveyBanner(),
                  );
                },
              ),

            // Balance card
            _TotalBalanceCard(totalBalance: totalBalance),

            const SizedBox(height: 12),

            // Income / Expense summary
            _SummaryCards(income: income, expense: expense),

            const SizedBox(height: 20),

            // 50/30/20 Budget card
            _BudgetRuleCard(),

            const SizedBox(height: 20),

            StreakCard(streakDays: streak),

            const SizedBox(height: 16),

            ZendaAiCard(advice: advice),
          ],
        ),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;

  const _TotalBalanceCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardTotalBalance,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardCashDebitCredit,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '▶  ${l10n.dashboardViewAll}',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final double income;
  final double expense;

  const _SummaryCards({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '↑  ${l10n.dashboardMonthlyIncome}',
                  style: const TextStyle(color: Color(0xFF059669), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${income.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '↓  ${l10n.dashboardMonthlyExpense}',
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${expense.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetRuleCard extends StatelessWidget {
  const _BudgetRuleCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final month = DateFormat.MMM(
      Localizations.localeOf(context).languageCode,
    ).format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardBudgetTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                month,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const SizedBox(
                    height: 10,
                    child: ColoredBox(color: Color(0xFF34D399)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const SizedBox(
                    height: 10,
                    child: ColoredBox(color: Color(0xFF60A5FA)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const SizedBox(
                    height: 10,
                    child: ColoredBox(color: Color(0xFFF97316)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF34D399), label: '${l10n.dashboardNeeds} 50%'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF60A5FA), label: '${l10n.dashboardWants} 30%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}

class _PostSurveyBanner extends StatefulWidget {
  const _PostSurveyBanner();

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

    final l10n = context.l10n;
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
              const Icon(Icons.assignment_rounded,
                  color: bannerColor, size: 22),
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
                child: Text(l10n.commonLater),
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
