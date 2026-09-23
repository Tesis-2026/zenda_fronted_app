import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/streak_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/zenda_theme_x.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final StreakState streak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeToday = streak.isActiveToday(DateTime.now());
    final milestone = streak.nextMilestone;
    final progress = (streak.currentDays / milestone).clamp(0.0, 1.0);

    return Semantics(
      button: true,
      label:
          'Racha de ${streak.currentDays} días. Récord ${streak.bestDays} días.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push('/progress'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 28,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak.currentDays == 1
                              ? '1 día de racha'
                              : '${streak.currentDays} días de racha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activeToday
                              ? '¡Cumpliste hoy! Vuelve mañana para continuar.'
                              : 'Registra un movimiento hoy para encender tu racha.',
                          style: TextStyle(
                            fontSize: 12,
                            color: activeToday
                                ? AppColors.primary
                                : colors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: colors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Próxima meta: $milestone días',
                  style: TextStyle(fontSize: 11, color: colors.textMuted),
                ),
                const Spacer(),
                Text(
                  'Récord: ${streak.bestDays}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
