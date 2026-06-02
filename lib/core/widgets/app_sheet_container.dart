import 'package:flutter/material.dart';

class AppSheetContainer extends StatelessWidget {
  const AppSheetContainer({
    super.key,
    required this.child,
    this.topRadius = 24.0,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 40),
    this.avoidKeyboard = true,
  });

  final Widget child;
  final double topRadius;
  final EdgeInsets padding;
  final bool avoidKeyboard;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Add the system bottom inset (gesture / transparent nav bar) to the
    // content padding so the footer / button clears it on edge-to-edge
    // devices. When the keyboard is open this is 0 (the keyboard inset below
    // handles the lift instead).
    final effectivePadding = EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      padding.bottom + media.padding.bottom,
    );
    final inner = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
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
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: inner,
    );
  }
}
