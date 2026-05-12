import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.hasShadow = false,
    this.backgroundColor,
    this.margin,
    @Deprecated('AppCard auto-detects dark mode via Theme — remove this param')
    this.isDark = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  // ignore: deprecated_member_use_from_same_package
  final bool isDark;
  final bool hasShadow;
  final Color? backgroundColor;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (dark ? AppColors.darkCard : AppColors.cardBackground);
    final borderColor = dark ? AppColors.darkBorder : const Color(0xFFF3F4F6);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: hasShadow && !dark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
