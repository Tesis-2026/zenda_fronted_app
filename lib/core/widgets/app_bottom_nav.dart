import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/l10n_extension.dart';

/// Persistent pill-style bottom nav.
/// activeIndex: 0=HOME, 1=TXNS, 2=AI, 3=GOALS, 4=PROFILE
class AppBottomNav extends StatelessWidget {
  final int activeIndex;

  const AppBottomNav({super.key, required this.activeIndex});

  void _navigate(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/transactions');
      case 2:
        context.go('/ai-chat');
      case 3:
        context.go('/goals');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF9FAFB);
    final pillBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    final labels = [
      l10n.dashboardNavHome,
      l10n.dashboardNavTransactions,
      l10n.dashboardNavAi,
      l10n.dashboardNavGoals,
      l10n.dashboardNavProfile,
    ];
    const icons = <IconData>[
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.auto_awesome_rounded,
      Icons.flag_rounded,
      Icons.person_rounded,
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        color: bg,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: _NavTab(
                  icon: icons[i],
                  label: labels[i],
                  isActive: i == activeIndex,
                  onTap: () => _navigate(context, i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF34D399) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: isActive ? 0.5 : 0.0,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
