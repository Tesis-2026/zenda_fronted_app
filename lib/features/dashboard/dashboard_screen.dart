import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../features/auth/auth_controller.dart';
import 'dashboard_providers.dart';
import 'widgets/streak_card.dart';
import 'widgets/zenda_ai_card.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';
import '../notifications/notifications_inbox_providers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
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
    final l10n = context.l10n;
    final colors = context.colors;
    final onSurface = colors.textPrimary;
    final onSurfaceMuted = colors.textMuted;

    final budgetSummaryAsync = ref.watch(budgetSummaryProvider);
    final monthSummaryAsync = ref.watch(monthSummaryProvider);
    final now = DateTime.now();
    final accountReportAsync = ref.watch(
      accountReportProvider((month: now.month, year: now.year)),
    );

    final streak = ref.watch(streakProvider);
    final advice = ref.watch(aiAdviceProvider(l10n));

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
        ref.invalidate(budgetSummaryProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(daySummaryProvider);
        ref.invalidate(weekSummaryProvider);
        ref.invalidate(monthSummaryProvider);
        ref.invalidate(accountsProvider);
        ref.invalidate(
          accountReportProvider((month: now.month, year: now.year)),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                _DashboardBell(),
                const SizedBox(width: 8),
                const UserMenuButton(),
              ],
            ),

            const SizedBox(height: 20),

            // Total money = sum of registered budgets
            _TotalMoneyCard(summary: budgetSummaryAsync),

            const SizedBox(height: 12),

            _AccountReportCard(report: accountReportAsync),

            const SizedBox(height: 12),

            // 50/30/20 Budget card
            _BudgetRuleCard(),

            const SizedBox(height: 12),

            // Income / Expense summary
            _SummaryCards(income: income, expense: expense),

            const SizedBox(height: 16),

            StreakCard(streakDays: streak),

            const SizedBox(height: 16),

            ZendaAiCard(advice: advice),
          ],
        ),
      ),
    );
  }
}

/// Shows the user's total money — the sum of their registered category budgets —
/// plus how much is available vs. spent. Money is tracked through budgets;
/// there are no accounts. Tapping routes to the budgets manager.
class _TotalMoneyCard extends StatelessWidget {
  final AsyncValue<BudgetTotals> summary;

  const _TotalMoneyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totals = summary.asData?.value;
    final total = totals?.total ?? 0.0;
    final available = totals?.available ?? 0.0;
    final spent = totals?.spent ?? 0.0;
    final hasBudgets = total > 0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardTotalMoney,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
              GestureDetector(
                onTap: () => context.push('/budgets'),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (hasBudgets)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.dashboardAvailableLabel}: S/ ${available.toStringAsFixed(2)}   ·   ${l10n.dashboardSpentLabel}: S/ ${spent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/budgets'),
                  child: Text(
                    '▶  ${l10n.dashboardViewAll}',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () => context.push('/budgets'),
              child: Text(
                '+  ${l10n.budgetEmptySubtitle}',
                style: const TextStyle(color: Color(0xFF34D399), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountReportCard extends StatelessWidget {
  const _AccountReportCard({required this.report});

  final AsyncValue<AccountReport> report;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = report.asData?.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: report.when(
        loading: () => const SizedBox(
          height: 88,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => const Text(
          'No se pudieron cargar las cuentas.',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontWeight: FontWeight.w600,
          ),
        ),
        data: (_) {
          final accounts = data?.accounts.take(4).toList() ?? const [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cuentas',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Disponible S/ ${(data?.totalAssets ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if ((data?.totalCreditDebt ?? 0) > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Deuda de tarjeta S/ ${data!.totalCreditDebt.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              for (final account in accounts) ...[
                _AccountMiniRow(account: account),
                const SizedBox(height: 8),
              ],
              if ((data?.insights ?? const []).isNotEmpty) ...[
                const SizedBox(height: 4),
                for (final insight in data!.insights.take(2))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      insight,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AccountMiniRow extends StatelessWidget {
  const _AccountMiniRow({required this.account});

  final AccountReportItem account;

  @override
  Widget build(BuildContext context) {
    final isCredit = account.type == AccountType.creditCard;
    final amount = isCredit ? account.debt : account.currentBalance;
    final color = isCredit ? const Color(0xFFDC2626) : const Color(0xFF111827);
    return Row(
      children: [
        Icon(
          accountTypeIcon(account.type),
          size: 18,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            account.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          isCredit
              ? 'S/ ${amount.toStringAsFixed(0)} deuda'
              : 'S/ ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
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
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 12,
                  ),
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
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                  ),
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

    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardBudgetTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                month,
                style: TextStyle(fontSize: 13, color: colors.textMuted),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendDot(
                color: AppColors.primary,
                label: '${l10n.dashboardNeeds} 50%',
              ),
              GestureDetector(
                onTap: () => context.push('/budgets'),
                child: const Text(
                  'Gestionar →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// Dashboard-styled notification bell with unread badge. Routes to the inbox.
class _DashboardBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final unread = ref.watch(unreadNotificationsCountProvider);

    return GestureDetector(
      onTap: () => context.push('/notifications/inbox'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: colors.iconStrong,
            ),
          ),
          if (unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.card, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
