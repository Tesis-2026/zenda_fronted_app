import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../core/widgets/section_label.dart';
import '../../l10n/l10n_extension.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            ],
          ),
        ],
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
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
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
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
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

