import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';
import '../budget/budget_screen.dart';
import '../goals/goals_screen.dart';
import '../income/income_screen.dart';
import '../progress/progress_screen.dart';

/// "Gestión" tab — hosts Progreso / Presupuestos / Metas / Ingresos as sub-tabs
/// (chip switcher, same pattern as the Movimientos filter chips). Each sub-view
/// is the corresponding screen rendered in `embedded: true` mode (no Scaffold).
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key, this.initialTab = 0});

  /// 0 = Progreso, 1 = Presupuestos, 2 = Metas, 3 = Ingresos.
  final int initialTab;

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  late int _tab = widget.initialTab.clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    final labels = [
      l10n.managementTabProgress,
      l10n.managementTabBudgets,
      l10n.managementTabGoals,
      l10n.managementTabIncome,
    ];

    return Scaffold(
      backgroundColor: colors.bg,
      bottomNavigationBar: const AppBottomNav(activeIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            // Header: title + user menu
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    l10n.managementTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const UserMenuButton(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Sub-tab chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _TabChip(
                        label: labels[i],
                        selected: _tab == i,
                        onTap: () => setState(() => _tab = i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Active sub-view (kept alive via IndexedStack)
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  ProgressScreen(embedded: true),
                  BudgetScreen(embedded: true),
                  GoalsScreen(embedded: true),
                  IncomeScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
