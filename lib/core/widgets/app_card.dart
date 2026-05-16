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
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool hasShadow;
  final Color? backgroundColor;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.cardBackground;
    const borderColor = Color(0xFFF3F4F6);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: hasShadow
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
