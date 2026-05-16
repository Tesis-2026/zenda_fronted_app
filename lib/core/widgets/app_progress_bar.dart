import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6.0,
    this.backgroundColor,
  });

  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.fillLight;
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
