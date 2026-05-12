import 'package:flutter/material.dart';
import '../../core/theme/zenda_theme_x.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final String microcopy;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.microcopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.1),
            
            // Hero visual - Icon with gradient background
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.08),
            
            // Content card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Microcopy with accent
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: gradientColors[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      microcopy,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: gradientColors[0],
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
    );
  }
}
