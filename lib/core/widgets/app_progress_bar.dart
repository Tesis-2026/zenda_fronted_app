import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6.0,
    this.backgroundColor,
    this.isDark = false,
  });

  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF3F4F6));
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
