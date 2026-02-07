import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';
import 'onboarding_prefs.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.receipt_long_rounded,
      'gradientColors': [
        const Color(0xFF34D399),
        const Color(0xFF10B981),
      ],
      'title': 'Registra tus gastos en segundos',
      'subtitle': 'Anota con un toque o escanea una boleta (demo).',
      'microcopy': 'Menos fricción, más control.',
    },
    {
      'icon': Icons.pie_chart_rounded,
      'gradientColors': [
        const Color(0xFF60A5FA),
        const Color(0xFF3B82F6),
      ],
      'title': 'Entiende tu dinero con 50/30/20',
      'subtitle': 'Zenda te muestra si vas equilibrado: necesidades, deseos y ahorro.',
      'microcopy': 'Aprende sin complicarte.',
    },
    {
      'icon': Icons.local_fire_department_rounded,
      'gradientColors': [
        const Color(0xFFFCD34D),
        const Color(0xFFF59E0B),
      ],
      'title': 'Mantén tu racha y mejora cada día 🔥',
      'subtitle': 'Gana constancia registrando a diario y viendo tu progreso.',
      'microcopy': 'Lo importante es volver mañana.',
    },
  ];

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
      context.go('/login');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
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
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return OnboardingPage(
                  icon: page['icon'],
                  gradientColors: page['gradientColors'],
                  title: page['title'],
                  subtitle: page['subtitle'],
                  microcopy: page['microcopy'],
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
                  'Saltar',
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
                        _pages.length,
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
                        onPressed: _nextPage,
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
                          _currentPage == _pages.length - 1 ? 'Empezar' : 'Siguiente',
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
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Ya tengo cuenta',
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
