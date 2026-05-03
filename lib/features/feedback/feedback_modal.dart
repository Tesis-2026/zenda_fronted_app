import 'package:flutter/material.dart';

import '../../core/services/feedback_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';

/// Call [FeedbackModal.show] from any screen to display the feedback bottom sheet.
class FeedbackModal extends StatefulWidget {
  const FeedbackModal({super.key, this.screenName});

  final String? screenName;

  static Future<void> show(BuildContext context, {String? screenName}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FeedbackModal(screenName: screenName),
    );
  }

  @override
  State<FeedbackModal> createState() => _FeedbackModalState();
}

class _FeedbackModalState extends State<FeedbackModal> {
  final _messageController = TextEditingController();
  final _service = FeedbackApiService();

  String _type = 'GENERAL';
  int _rating = 0;
  bool _submitting = false;
  bool _submitted = false;

  static const _types = ['GENERAL', 'BUG', 'FEATURE', 'UI'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.feedbackTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_submitted) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 56, color: Color(0xFF43A047)),
                    const SizedBox(height: 12),
                    Text(l10n.feedbackThanks,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 16),
              Text(l10n.feedbackTypeLabel),
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
              Text(l10n.feedbackRatingLabel),
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
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.feedbackMessageLabel,
                  hintText: l10n.feedbackMessageHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.feedbackSubmitButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      showAppToast(context, context.l10n.feedbackMessageRequired, type: ToastType.warning);
      return;
    }

    setState(() => _submitting = true);
    try {
      await _service.submit(
        type: _type,
        message: message,
        screenName: widget.screenName,
        rating: _rating > 0 ? _rating : null,
      );
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        showAppToast(context, context.l10n.feedbackSubmitError, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
