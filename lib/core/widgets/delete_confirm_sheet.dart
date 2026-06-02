import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../theme/app_colors.dart';

/// Visual tone of a [showConfirmSheet].
enum ConfirmTone {
  /// Irreversible / dangerous action (delete). Red accent.
  destructive,

  /// Significant but non-destructive action (sign out). Primary accent.
  neutral,
}

/// Standard confirmation bottom sheet for destructive / decision actions.
///
/// See `lib/core/widgets/README.md`. Use this for every delete, sign-out, or
/// irreversible confirmation instead of an ad-hoc [AlertDialog]. Returns `true`
/// when the user confirms, `false`/`null` otherwise.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  ConfirmTone tone = ConfirmTone.destructive,
  IconData? icon,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConfirmSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      tone: tone,
      icon: icon,
    ),
  );
  return result == true;
}

/// Destructive-tone shortcut kept for existing call sites.
Future<bool> showDeleteConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showConfirmSheet(
    context,
    title: title,
    message: message,
    confirmLabel: context.l10n.deleteConfirmYes,
    tone: ConfirmTone.destructive,
  );
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.tone,
    this.cancelLabel,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final ConfirmTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool destructive = tone == ConfirmTone.destructive;
    final Color accent = destructive ? AppColors.danger : AppColors.primary;
    final Color accentBg =
        destructive ? AppColors.dangerLight : AppColors.primaryLight;
    final IconData resolvedIcon = icon ??
        (destructive ? Icons.delete_outline_rounded : Icons.info_outline_rounded);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        // Sheet top radius token (28) — see README §2.
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Reserve the system bottom inset (gesture / transparent nav bar) so the
      // buttons clear it on edge-to-edge devices.
      padding: EdgeInsets.only(bottom: 40 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                // Grab handle token (#E5E7EB) — aligned with AppSheetContainer.
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(resolvedIcon, size: 36, color: accent),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.fillLight,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      cancelLabel ?? l10n.commonCancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
