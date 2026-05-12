import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Consistent sub-screen AppBar matching the Pencil design:
/// white bg · dark title · back arrow · 1 px bottom divider.
///
/// Use on every screen that is NOT a bottom-nav root (Dashboard,
/// Transactions, AI Chat, Goals, Education).
class ZendaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  /// Override the back button's tap handler. Defaults to [context.pop()].
  final VoidCallback? onLeadingPressed;

  const ZendaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final onBg = isDark ? Colors.white : const Color(0xFF1F2937);
    final divider = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: onBg),
        onPressed: onLeadingPressed ?? () => context.pop(),
      ),
      iconTheme: IconThemeData(color: onBg),
      title: Text(
        title,
        style: TextStyle(
          color: onBg,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
      centerTitle: false,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: divider),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
