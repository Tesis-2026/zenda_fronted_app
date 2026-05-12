import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final onSurface = colors.textPrimary;
    final muted = colors.textMuted;
    final surface = colors.card;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shield icon in rounded square
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.consentTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.consentSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                    ),
                    const SizedBox(height: 28),

                    // Three bullet points
                    _BulletPoint(text: l10n.consentBullet1),
                    const SizedBox(height: 12),
                    _BulletPoint(text: l10n.consentBullet2),
                    const SizedBox(height: 12),
                    _BulletPoint(text: l10n.consentBullet3),

                    const SizedBox(height: 24),

                    // Checkbox agreement area
                    GestureDetector(
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _accepted
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accepted
                                ? AppColors.primary
                                : context.colors.border,
                            width: _accepted ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _accepted,
                              onChanged: (v) => setState(() => _accepted = v ?? false),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  l10n.consentCheckbox,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: onSurface,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Law note
                    Text(
                      l10n.consentLawNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (!_accepted) {
                      showAppToast(context, l10n.consentMustAccept, type: ToastType.warning);
                      return;
                    }
                    context.go('/auth/register');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.consentAcceptButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textPrimary,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}
