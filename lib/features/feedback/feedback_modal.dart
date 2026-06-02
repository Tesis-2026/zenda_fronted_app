import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/field_label.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/services_providers.dart';

/// Call [FeedbackModal.show] from any screen to display the feedback bottom
/// sheet. Built on the standard [showAppFormSheet]; on success it closes and
/// shows a thank-you toast.
class FeedbackModal {
  const FeedbackModal._();

  static Future<void> show(BuildContext context, {String? screenName}) async {
    final l10n = context.l10n;
    final key = GlobalKey<_FeedbackBodyState>();
    final ok = await showAppFormSheet(
      context,
      title: l10n.feedbackTitle,
      primaryLabel: l10n.feedbackSubmitButton,
      body: _FeedbackBody(key: key, screenName: screenName),
      onSubmit: () => key.currentState?.submit() ?? Future.value(false),
    );
    if (ok == true && context.mounted) {
      showAppToast(context, l10n.feedbackThanks, type: ToastType.success);
    }
  }
}

class _FeedbackBody extends ConsumerStatefulWidget {
  const _FeedbackBody({super.key, this.screenName});

  final String? screenName;

  @override
  ConsumerState<_FeedbackBody> createState() => _FeedbackBodyState();
}

class _FeedbackBodyState extends ConsumerState<_FeedbackBody> {
  final _messageController = TextEditingController();
  String _type = 'GENERAL';
  int _rating = 0;

  static const _types = ['GENERAL', 'BUG', 'FEATURE', 'UI'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Validates and submits the feedback. Returns `true` to close the sheet.
  Future<bool> submit() async {
    final l10n = context.l10n;
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      showAppToast(context, l10n.feedbackMessageRequired,
          type: ToastType.warning);
      return false;
    }
    try {
      await ref.read(feedbackApiServiceProvider).submit(
            type: _type,
            message: message,
            screenName: widget.screenName,
            rating: _rating > 0 ? _rating : null,
          );
      return true;
    } catch (_) {
      if (mounted) {
        showAppToast(context, l10n.feedbackSubmitError, type: ToastType.error);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l10n.feedbackTypeLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _types.map((t) {
            return ChoiceChip(
              label: Text(t),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.feedbackRatingLabel),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFB8C00),
              ),
              onPressed: () => setState(() => _rating = i + 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.feedbackMessageLabel),
        const SizedBox(height: 8),
        AppTextField(
          controller: _messageController,
          hintText: l10n.feedbackMessageHint,
          maxLines: 4,
        ),
      ],
    );
  }
}
