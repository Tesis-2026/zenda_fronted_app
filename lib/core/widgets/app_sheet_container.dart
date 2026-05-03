import 'package:flutter/material.dart';

class AppSheetContainer extends StatelessWidget {
  const AppSheetContainer({
    super.key,
    required this.child,
    this.isDark = false,
    this.topRadius = 24.0,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 40),
    this.avoidKeyboard = true,
  });

  final Widget child;
  final bool isDark;
  final double topRadius;
  final EdgeInsets padding;
  final bool avoidKeyboard;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inner = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );

    if (!avoidKeyboard) return inner;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: inner,
    );
  }
}
