import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/field_label.dart';
import '../../features/auth/auth_controller.dart';
import '../../providers/repositories_providers.dart';
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

    final accountsAsync = ref.watch(accountsProvider);
    final monthSummaryAsync = ref.watch(monthSummaryProvider);

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

            // Balance card
            _TotalBalanceCard(
              totalBalance: totalBalance,
              accounts: accountsAsync.asData?.value ?? [],
              onAddAccount: () => _showAddAccountSheet(context, ref),
            ),

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

  Future<void> _showAddAccountSheet(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final key = GlobalKey<_AddAccountBodyState>();
    await showAppFormSheet(
      context,
      title: l10n.accountAddTitle,
      primaryLabel: l10n.accountAddButton,
      body: _AddAccountBody(key: key),
      onSubmit: () async {
        final st = key.currentState;
        if (st == null || !st.isValid) return false;
        await ref.read(accountsRepositoryProvider).upsert(st.buildAccount());
        ref.invalidate(accountsProvider);
        return true;
      },
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final List<Account> accounts;
  final VoidCallback onAddAccount;

  const _TotalBalanceCard({
    required this.totalBalance,
    required this.accounts,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (accounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF6B7280), size: 36),
            const SizedBox(height: 10),
            Text(
              l10n.dashboardNoAccounts,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onAddAccount,
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF34D399), size: 18),
              label: Text(
                l10n.dashboardAddFirstAccount,
                style: const TextStyle(color: Color(0xFF34D399), fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

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
                l10n.dashboardTotalBalance,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
              GestureDetector(
                onTap: onAddAccount,
                child: const Icon(Icons.add_circle_outline,
                    color: Color(0xFF34D399), size: 20),
              ),
            ],
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
                onTap: () => context.go('/transactions'),
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
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textMuted,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendDot(color: AppColors.primary, label: '${l10n.dashboardNeeds} 50%'),
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
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
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

class _AddAccountBody extends StatefulWidget {
  const _AddAccountBody({super.key});

  @override
  State<_AddAccountBody> createState() => _AddAccountBodyState();
}

class _AddAccountBodyState extends State<_AddAccountBody> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final creditLimitController = TextEditingController();
  AccountType selectedType = AccountType.cash;

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    creditLimitController.dispose();
    super.dispose();
  }

  bool get isValid {
    if (nameController.text.trim().isEmpty) return false;
    if (selectedType == AccountType.credit) {
      final limit =
          double.tryParse(creditLimitController.text.replaceAll(',', '.'));
      return limit != null && limit > 0;
    }
    return true;
  }

  Account buildAccount() {
    final balance =
        double.tryParse(balanceController.text.replaceAll(',', '.')) ?? 0.0;
    final creditLimit =
        double.tryParse(creditLimitController.text.replaceAll(',', '.')) ?? 0.0;
    return Account(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      type: selectedType,
      balance: selectedType != AccountType.credit ? balance : 0.0,
      creditLimit: selectedType == AccountType.credit ? creditLimit : 0.0,
      creditAvailable:
          selectedType == AccountType.credit ? creditLimit : 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCredit = selectedType == AccountType.credit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l10n.accountNameLabel),
        const SizedBox(height: 6),
        AppTextField(
          controller: nameController,
          hintText: l10n.accountNameHint,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.accountTypeLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            _TypeChip(
              label: l10n.accountTypeCash,
              selected: selectedType == AccountType.cash,
              onTap: () => setState(() => selectedType = AccountType.cash),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: l10n.accountTypeDebit,
              selected: selectedType == AccountType.debit,
              onTap: () => setState(() => selectedType = AccountType.debit),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: l10n.accountTypeCredit,
              selected: selectedType == AccountType.credit,
              onTap: () => setState(() => selectedType = AccountType.credit),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isCredit) ...[
          FieldLabel(l10n.accountCreditLimit),
          const SizedBox(height: 6),
          AppTextField(
            controller: creditLimitController,
            prefixText: 'S/ ',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ] else ...[
          FieldLabel(l10n.accountInitialBalance),
          const SizedBox(height: 6),
          AppTextField(
            controller: balanceController,
            prefixText: 'S/ ',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF34D399)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
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
            child: Icon(Icons.notifications_outlined,
                size: 20, color: colors.iconStrong),
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
