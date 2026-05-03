import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../l10n/l10n_extension.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final onSurface = isDark ? Colors.white : const Color(0xFF1F2937);
    final muted = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionLabel(label: l10n.settingsSectionGeneral, muted: muted!),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            items: [
              _SettingsItem(
                icon: Icons.category_rounded,
                iconBg: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF374151),
                title: l10n.settingsCategoriesLabel,
                onTap: () => context.push('/categories'),
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                iconBg: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF374151),
                title: l10n.settingsNotificationsLabel,
                onTap: () => context.push('/notifications'),
              ),
              _SettingsItem(
                icon: Icons.bar_chart_rounded,
                iconBg: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF374151),
                title: l10n.reportsTitle,
                onTap: () => context.push('/reports'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: l10n.settingsSectionResearch, muted: muted),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            items: [
              _SettingsItem(
                icon: Icons.assignment_outlined,
                iconBg: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF374151),
                title: l10n.settingsSurveysLabel,
                onTap: () => _showSurveysSheet(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            items: [
              _SettingsItem(
                icon: Icons.logout_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                title: l10n.commonSignOut,
                titleColor: const Color(0xFFEF4444),
                onTap: () => _confirmSignOut(context, ref, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSurveysSheet(BuildContext context, dynamic l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurveysSheet(l10n: l10n),
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, WidgetRef ref, dynamic l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileSignOutDialogTitle),
        content: Text(l10n.profileSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.commonSignOut,
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}

// ── Surveys bottom sheet ──────────────────────────────────────────────────────

class _SurveysSheet extends StatelessWidget {
  const _SurveysSheet({required this.l10n});
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                l10n.settingsSurveysSheetTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SurveyTile(
            icon: Icons.psychology_outlined,
            title: l10n.settingsSurveyPreLabel,
            subtitle: l10n.settingsSurveyPreSubtitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/surveys/pre');
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _SurveyTile(
            icon: Icons.psychology_rounded,
            title: l10n.settingsSurveyPostLabel,
            subtitle: l10n.settingsSurveyPostSubtitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/surveys/post');
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _SurveyTile(
            icon: Icons.assignment_turned_in_outlined,
            title: l10n.settingsSurveySusLabel,
            subtitle: l10n.settingsSurveySusSubtitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/surveys/sus');
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _SurveyTile(
            icon: Icons.compare_arrows_rounded,
            title: l10n.settingsSurveyComparisonLabel,
            subtitle: l10n.settingsSurveyComparisonSubtitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/surveys/comparison');
            },
          ),
        ],
      ),
    );
  }
}

class _SurveyTile extends StatelessWidget {
  const _SurveyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF059669)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ── Reusable components ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.muted});
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDark,
    required this.cardBg,
    required this.items,
  });

  final bool isDark;
  final Color cardBg;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 60,
                color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
              ),
            _SettingsRow(item: items[i], isDark: isDark),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.isDark});
  final _SettingsItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 18, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: item.titleColor ??
                      (isDark ? Colors.white : const Color(0xFF1F2937)),
                ),
              ),
            ),
            if (item.titleColor == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.grey[600] : const Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}
