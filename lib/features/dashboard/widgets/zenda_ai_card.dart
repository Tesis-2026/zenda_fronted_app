import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n_extension.dart';

class ZendaAiCard extends StatelessWidget {
  final String advice;

  const ZendaAiCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF818CF8), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.aiCardTitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            advice,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/ai-chat'),
                child: Text(
                  '→ ${l10n.aiCardPredictionsChat}',
                  style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/predictions'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${l10n.aiCardViewForecast} →',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.push('/recommendations'),
            child: Text(
              '→ ${l10n.aiCardSeeRecommendations}',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
