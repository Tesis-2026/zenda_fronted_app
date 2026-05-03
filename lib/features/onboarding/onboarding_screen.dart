import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_prefs.dart';
import '../../l10n/l10n_extension.dart';

class OnboardingScreen extends StatelessWidget {
  final bool redirectToRegister;

  const OnboardingScreen({
    super.key,
    this.redirectToRegister = false,
  });

  Future<void> _completeOnboarding(BuildContext context) async {
    await OnboardingPrefs.setOnboardingCompleted();
    if (context.mounted) {
      context.go('/consent');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF34D399),
      body: SafeArea(
        child: Column(
          children: [
            // Top green hero section
            SizedBox(
              height: size.height * 0.42,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Z logo circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        'Z',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF34D399),
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Zenda',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.splashTagline,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Bottom white card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      // Feature rows
                      _FeatureRow(
                        icon: Icons.bar_chart_rounded,
                        iconColor: const Color(0xFF34D399),
                        text: l10n.onboardingFeature1,
                      ),
                      const SizedBox(height: 20),
                      _FeatureRow(
                        icon: Icons.track_changes_rounded,
                        iconColor: const Color(0xFF34D399),
                        text: l10n.onboardingFeature2,
                      ),
                      const SizedBox(height: 20),
                      _FeatureRow(
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        text: l10n.onboardingFeature3,
                      ),
                      const Spacer(),
                      // Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _completeOnboarding(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D399),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.onboardingStart,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Already have account link
                      TextButton(
                        onPressed: () => context.go('/auth/login'),
                        child: Text(
                          l10n.onboardingHaveAccount,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
