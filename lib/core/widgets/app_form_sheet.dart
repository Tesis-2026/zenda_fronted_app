import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_primary_button.dart';
import 'sheet_header.dart';

/// Standard modal bottom sheet for every CREATE / EDIT flow.
///
/// See `lib/core/widgets/README.md` for the modal standard. Composes the shared
/// affordances so screens only provide the form body and a submit callback:
/// grab handle + [SheetHeader] (title + close, always) + optional subtitle +
/// scrollable body + a pinned [AppPrimaryButton] footer. Rises with the keyboard
/// and caps its height so long forms scroll instead of overflowing.
///
/// [onSubmit] runs with the primary button showing its loading spinner. Return
/// `true` to close the sheet (success), `false` to keep it open (e.g. validation
/// failed). Throwing also keeps it open and stops the spinner. The sheet result
/// (`Future<bool?>`) is `true` when submitted successfully, `null` when dismissed.
Future<bool?> showAppFormSheet(
  BuildContext context, {
  required String title,
  required Widget body,
  required String primaryLabel,
  required Future<bool> Function() onSubmit,
  String? subtitle,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  double maxHeightFactor = 0.92,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AppFormSheet(
      title: title,
      subtitle: subtitle,
      body: body,
      primaryLabel: primaryLabel,
      onSubmit: onSubmit,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      maxHeightFactor: maxHeightFactor,
    ),
  );
}

class AppFormSheet extends StatefulWidget {
  const AppFormSheet({
    super.key,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onSubmit,
    this.subtitle,
    this.secondaryLabel,
    this.onSecondary,
    this.maxHeightFactor = 0.92,
  });

  final String title;
  final Widget body;
  final String primaryLabel;
  final Future<bool> Function() onSubmit;
  final String? subtitle;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final double maxHeightFactor;

  @override
  State<AppFormSheet> createState() => _AppFormSheetState();
}

class _AppFormSheetState extends State<AppFormSheet> {
  bool _submitting = false;

  Future<void> _handlePrimary() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final close = await widget.onSubmit();
      if (!mounted) return;
      if (close) {
        Navigator.of(context).pop(true);
        return;
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * widget.maxHeightFactor;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            // Sheet top radius token (28) — see README §2.
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: SheetHeader(
                  title: widget.title,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                  child: Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: widget.body,
                ),
              ),
              Padding(
                // Reserve the system bottom inset (gesture / transparent nav
                // bar) so the primary button clears it on edge-to-edge devices.
                padding: EdgeInsets.fromLTRB(
                    24, 8, 24, 24 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppPrimaryButton(
                      label: widget.primaryLabel,
                      isLoading: _submitting,
                      onPressed: _handlePrimary,
                    ),
                    if (widget.secondaryLabel != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          onPressed: _submitting
                              ? null
                              : (widget.onSecondary ??
                                  () => Navigator.of(context).pop()),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.fillLight,
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.secondaryLabel!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
