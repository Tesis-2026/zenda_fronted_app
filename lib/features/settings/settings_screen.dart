import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../core/widgets/app_sheet_container.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/sheet_header.dart';
import '../../features/auth/auth_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider).asData?.value ?? const Locale('en');
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: ZendaAppBar(title: l10n.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionLabel(l10n.settingsSectionGeneral, color: colors.textMuted),
          const SizedBox(height: 8),
          _SettingsCard(
            items: [
              _SettingsItem(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: l10n.settingsLanguageLabel,
                subtitle: locale.languageCode == 'es'
                    ? l10n.settingsLanguageSpanish
                    : l10n.settingsLanguageEnglish,
                onTap: () => _showLanguageDialog(context, ref, l10n, locale),
              ),
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
          SectionLabel(l10n.settingsSectionResearch, color: colors.textMuted),
          const SizedBox(height: 8),
          _SettingsCard(
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

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, dynamic l10n, Locale current) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsLanguageDialogTitle),
        children: [
          _LanguageOption(
            label: l10n.settingsLanguageEnglish,
            selected: current.languageCode == 'en',
            onTap: () {
              ctx.pop();
              ref.read(localeProvider.notifier).setLocale('en');
            },
          ),
          _LanguageOption(
            label: l10n.settingsLanguageSpanish,
            selected: current.languageCode == 'es',
            onTap: () {
              ctx.pop();
              ref.read(localeProvider.notifier).setLocale('es');
            },
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
            onPressed: () => ctx.pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
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
    return AppSheetContainer(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.settingsSurveysSheetTitle,
            onClose: () => context.pop(),
            fontSize: 17,
          ),
          const SizedBox(height: 16),
          _SurveyTile(
            icon: Icons.psychology_outlined,
            title: l10n.settingsSurveyPreLabel,
            subtitle: l10n.settingsSurveyPreSubtitle,
            onTap: () {
              context.pop();
              context.push('/surveys/pre');
            },
          ),
          const Divider(height: 1),
          _SurveyTile(
            icon: Icons.psychology_rounded,
            title: l10n.settingsSurveyPostLabel,
            subtitle: l10n.settingsSurveyPostSubtitle,
            onTap: () {
              context.pop();
              context.push('/surveys/post');
            },
          ),
          const Divider(height: 1),
          _SurveyTile(
            icon: Icons.assignment_turned_in_outlined,
            title: l10n.settingsSurveySusLabel,
            subtitle: l10n.settingsSurveySusSubtitle,
            onTap: () {
              context.pop();
              context.push('/surveys/sus');
            },
          ),
          const Divider(height: 1),
          _SurveyTile(
            icon: Icons.compare_arrows_rounded,
            title: l10n.settingsSurveyComparisonLabel,
            subtitle: l10n.settingsSurveyComparisonSubtitle,
            onTap: () {
              context.pop();
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
    final colors = context.colors;
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
                color: colors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSubtle),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});

  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasShadow: true,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 60,
                color: Color(0xFFF3F4F6),
              ),
            _SettingsRow(item: items[i]),
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
    this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final String? subtitle;
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});
  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: item.titleColor ?? colors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.titleColor == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.textSubtle,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.primary
                    : context.colors.textPrimary,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}
