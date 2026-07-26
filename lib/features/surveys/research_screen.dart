import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: ZendaAppBar(title: l10n.settingsSectionResearch),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            hasShadow: true,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ResearchTile(
                  icon: Icons.psychology_outlined,
                  title: l10n.settingsSurveyPreLabel,
                  subtitle: l10n.settingsSurveyPreSubtitle,
                  onTap: () => context.push('/surveys/pre'),
                ),
                const Divider(height: 1, indent: 70, color: Color(0xFFF3F4F6)),
                _ResearchTile(
                  icon: Icons.psychology_rounded,
                  title: l10n.settingsSurveyPostLabel,
                  subtitle: l10n.settingsSurveyPostSubtitle,
                  onTap: () => context.push('/surveys/post'),
                ),
                const Divider(height: 1, indent: 70, color: Color(0xFFF3F4F6)),
                _ResearchTile(
                  icon: Icons.assignment_turned_in_outlined,
                  title: l10n.settingsSurveySusLabel,
                  subtitle: l10n.settingsSurveySusSubtitle,
                  onTap: () => context.push('/surveys/sus'),
                ),
                const Divider(height: 1, indent: 70, color: Color(0xFFF3F4F6)),
                _ResearchTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Satisfacción final',
                  subtitle:
                      'Utilidad, claridad del asistente e intención de uso',
                  onTap: () => context.push('/surveys/satisfaction'),
                ),
                const Divider(height: 1, indent: 70, color: Color(0xFFF3F4F6)),
                _ResearchTile(
                  icon: Icons.compare_arrows_rounded,
                  title: l10n.settingsSurveyComparisonLabel,
                  subtitle: l10n.settingsSurveyComparisonSubtitle,
                  onTap: () => context.push('/surveys/comparison'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResearchTile extends StatelessWidget {
  const _ResearchTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
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
