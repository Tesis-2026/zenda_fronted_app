import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Consistent sub-screen AppBar matching the Pencil design.
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
    const bg = AppColors.cardBackground;
    const onBg = AppColors.textDark;
    const divider = AppColors.border;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: onBg),
        onPressed: onLeadingPressed ?? () => context.pop(),
      ),
      iconTheme: const IconThemeData(color: onBg),
      title: Text(
        title,
        style: const TextStyle(
          color: onBg,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
      centerTitle: false,
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(height: 1, child: ColoredBox(color: divider)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
