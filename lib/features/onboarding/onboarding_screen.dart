import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';
import 'onboarding_prefs.dart';
import '../../l10n/l10n_extension.dart';

class OnboardingScreen extends StatefulWidget {
  final bool redirectToRegister;

  const OnboardingScreen({
    Key? key,
    this.redirectToRegister = false,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    await OnboardingPrefs.setOnboardingCompleted();
    if (mounted) {
      if (widget.redirectToRegister) {
        context.go('/auth/register');
      } else {
        context.go('/auth/login');
      }
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final pages = [
      {
        'icon': Icons.receipt_long_rounded,
        'gradientColors': [
          const Color(0xFF34D399),
          const Color(0xFF10B981),
        ],
        'title': l10n.onboardingPage1Title,
        'subtitle': l10n.onboardingPage1Subtitle,
        'microcopy': l10n.onboardingPage1Micro,
      },
      {
        'icon': Icons.pie_chart_rounded,
        'gradientColors': [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
        ],
        'title': l10n.onboardingPage2Title,
        'subtitle': l10n.onboardingPage2Subtitle,
        'microcopy': l10n.onboardingPage2Micro,
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'gradientColors': [
          const Color(0xFFFCD34D),
          const Color(0xFFF59E0B),
        ],
        'title': l10n.onboardingPage3Title,
        'subtitle': l10n.onboardingPage3Subtitle,
        'microcopy': l10n.onboardingPage3Micro,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return OnboardingPage(
                  icon: page['icon'] as IconData,
                  gradientColors: page['gradientColors'] as List<Color>,
                  title: page['title'] as String,
                  subtitle: page['subtitle'] as String,
                  microcopy: page['microcopy'] as String,
                );
              },
            ),

            // Skip button (top right)
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B).withOpacity(0.6)
                      : Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.onboardingSkip,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A).withOpacity(0),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFFF9FAFB).withOpacity(0),
                            const Color(0xFFF9FAFB),
                          ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF34D399)
                                : (isDark
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFFD1D5DB)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Primary button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _nextPage(pages.length),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34D399),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: const Color(0xFF34D399).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == pages.length - 1
                              ? (widget.redirectToRegister ? l10n.onboardingRegister : l10n.onboardingStart)
                              : l10n.onboardingNext,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // "Already have account" link
                    // Solo mostramos esto si NO estamos en el flujo de "redirectToRegister"
                    // porque si venimos de Crear Cuenta, ya sabemos que no tenemos cuenta (o queremos crear una).
                    // Aunque por consistencia, si redirige a Register, el botón "Ya tengo cuenta" debería ir a Login.
                    TextButton(
                      onPressed: () {
                         context.go('/auth/login');
                      },
                      child: Text(
                        l10n.onboardingHaveAccount,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF60A5FA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
