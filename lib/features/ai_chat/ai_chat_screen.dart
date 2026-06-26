import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/recommendations_api_service.dart';
import '../../core/services/study_telemetry_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/l10n_extension.dart';

class _ChatBubble {
  final String? id;
  final String text;
  final bool isUser;
  final bool feedbackSubmitted;
  final int? feedbackRating;

  _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    this.feedbackSubmitted = false,
    this.feedbackRating,
  });

  _ChatBubble copyWith({bool? feedbackSubmitted, int? feedbackRating}) {
    return _ChatBubble(
      id: id,
      text: text,
      isUser: isUser,
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
      feedbackRating: feedbackRating ?? this.feedbackRating,
    );
  }
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatBubble>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Fetch the server-persisted history first. New users start with an empty
    // chat until they ask something; no fake assistant message is shown.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final active = await ref.read(aiChatServiceProvider).getActive();
        if (!mounted || active.messages.isEmpty) return;
        setState(() {
          _messages.addAll(
            active.messages.map(
              (m) => _ChatBubble(
                id: m.id,
                text: m.content,
                isUser: m.role == 'user',
              ),
            ),
          );
        });
        _scrollToBottom();
      } catch (_) {
        // Best-effort: the next sendMessage will recreate the conversation
        // server-side. Do not show a fake assistant message.
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatBubble(text: text, isUser: true));
      _loading = true;
    });
    _inputController.clear();
    StudyTelemetryService.track(
      'chat_message_sent',
      metadata: {'message_length': text.length, 'source': 'ai_chat'},
      backend: false,
    );
    _scrollToBottom();

    try {
      // Backend owns the conversation history (B7). We send only the new
      // user message; the server appends it + the assistant reply.
      final result = await ref.read(aiChatServiceProvider).sendMessage(text);
      if (mounted) {
        setState(
          () => _messages.add(
            _ChatBubble(
              id: result.assistantMessageId,
              text: result.reply,
              isUser: false,
            ),
          ),
        );
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _messages.add(
            _ChatBubble(text: context.l10n.aiChatError, isUser: false),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitFeedback(int index, int rating) async {
    if (index < 0 || index >= _messages.length) return;
    final bubble = _messages[index];
    final messageId = bubble.id;
    if (bubble.isUser || messageId == null || bubble.feedbackSubmitted) return;

    setState(() {
      _messages[index] = bubble.copyWith(
        feedbackSubmitted: true,
        feedbackRating: rating,
      );
    });
    StudyTelemetryService.track(
      'ai_answer_feedback',
      metadata: {'rating': rating, 'source': 'ai_chat'},
      backend: false,
    );

    try {
      await ref
          .read(aiChatServiceProvider)
          .submitMessageFeedback(
            messageId,
            rating: rating,
            helpful: rating >= 4,
            clear: rating >= 4,
            personalized: rating >= 4,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages[index] = bubble.copyWith(
          feedbackSubmitted: false,
          feedbackRating: null,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la evaluación.')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.aiChatTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.aiChatSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.aiChatOnline,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(
                  bubble: _messages[i],
                  onFeedback: (rating) => _submitFeedback(i, rating),
                );
              },
            ),
          ),
          if (!_loading)
            _QuickActions(
              onTap: (text) {
                _inputController.text = text;
                _send();
              },
              labels: [
                l10n.aiChatQuickAnalyze,
                l10n.aiChatQuickBudget,
                l10n.aiChatQuickGoal,
              ],
            ),
          _InputBar(
            controller: _inputController,
            onSend: _send,
            loading: _loading,
            hint: l10n.aiChatInputHint,
            sendLabel: l10n.aiChatSend,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 2),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.bubble, required this.onFeedback});
  final _ChatBubble bubble;
  final ValueChanged<int> onFeedback;

  @override
  Widget build(BuildContext context) {
    final isUser = bubble.isUser;
    final colors = context.colors;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            bubble.text,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
      );
    }

    // AI message with avatar on the left
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    bubble.text,
                    style: TextStyle(color: colors.textPrimary, height: 1.5),
                  ),
                ),
                if (bubble.id != null)
                  _AssistantFeedbackBar(
                    submitted: bubble.feedbackSubmitted,
                    rating: bubble.feedbackRating,
                    onFeedback: onFeedback,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantFeedbackBar extends StatelessWidget {
  const _AssistantFeedbackBar({
    required this.submitted,
    required this.rating,
    required this.onFeedback,
  });

  final bool submitted;
  final int? rating;
  final ValueChanged<int> onFeedback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (submitted) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Gracias por evaluar (${rating ?? '-'}/5)',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué tan útil fue esta respuesta?',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(5, (index) {
              final value = index + 1;
              return SizedBox(
                width: 44,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => onFeedback(value),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: const SizedBox(
          width: 40,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onTap, required this.labels});

  final void Function(String) onTap;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: colors.card,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: labels
              .map(
                (label) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      label,
                      style: TextStyle(fontSize: 12, color: colors.primary),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    onPressed: () => onTap(label),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.loading,
    required this.hint,
    required this.sendLabel,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;
  final String hint;
  final String sendLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colors.fill,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: loading ? null : onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
