import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6.0,
    this.backgroundColor,
    @Deprecated('AppProgressBar auto-detects dark mode via Theme — remove this param')
    this.isDark = false,
  });

  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;
  // ignore: deprecated_member_use_from_same_package
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (dark
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.fillLight);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: bg,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
