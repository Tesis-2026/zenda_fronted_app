import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/recommendations_api_service.dart';
import '../../core/services/study_telemetry_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';

class _ChatBubble {
  final String? id;
  final String text;
  final bool isUser;
  final bool feedbackSubmitted;

  const _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    this.feedbackSubmitted = false,
  });

  _ChatBubble copyWith({bool? feedbackSubmitted}) => _ChatBubble(
    id: id,
    text: text,
    isUser: isUser,
    feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
  );
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
  String? _submittingFeedbackMessageId;

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

  Future<void> _openFeedbackSheet(_ChatBubble bubble) async {
    final messageId = bubble.id;
    if (messageId == null || _submittingFeedbackMessageId != null) return;

    final feedback = await showModalBottomSheet<_AiFeedbackDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AiFeedbackSheet(),
    );
    if (feedback == null || !mounted) return;

    setState(() => _submittingFeedbackMessageId = messageId);
    try {
      StudyTelemetryService.track(
        'ai_answer_feedback',
        metadata: {'rating': feedback.rating, 'source': 'ai_chat'},
        backend: false,
      );
      await ref
          .read(aiChatServiceProvider)
          .submitFeedback(
            messageId: messageId,
            rating: feedback.rating,
            helpful: feedback.helpful,
            clear: feedback.clear,
            personalized: feedback.personalized,
            comment: feedback.comment,
          );
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere(
          (message) => message.id == messageId,
        );
        if (index >= 0) {
          _messages[index] = _messages[index].copyWith(feedbackSubmitted: true);
        }
      });
      showAppToast(
        context,
        'Gracias, tu calificación ayuda a mejorar Zenda AI.',
        type: ToastType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        'No se pudo enviar la calificación. Inténtalo de nuevo.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _submittingFeedbackMessageId = null);
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
                final bubble = _messages[i];
                return _MessageBubble(
                  bubble: bubble,
                  isSubmittingFeedback:
                      bubble.id == _submittingFeedbackMessageId,
                  onFeedback:
                      !bubble.isUser &&
                          bubble.id != null &&
                          !bubble.feedbackSubmitted
                      ? () => _openFeedbackSheet(bubble)
                      : null,
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
  const _MessageBubble({
    required this.bubble,
    required this.isSubmittingFeedback,
    this.onFeedback,
  });

  final _ChatBubble bubble;
  final bool isSubmittingFeedback;
  final VoidCallback? onFeedback;

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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bubble.text,
                    style: TextStyle(color: colors.textPrimary, height: 1.5),
                  ),
                  if (bubble.feedbackSubmitted) ...[
                    const SizedBox(height: 10),
                    const _FeedbackSubmittedBadge(),
                  ] else if (onFeedback != null) ...[
                    const SizedBox(height: 10),
                    _FeedbackButton(
                      loading: isSubmittingFeedback,
                      onPressed: onFeedback,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : const Icon(Icons.star_outline_rounded, size: 18),
      label: Text(
        loading ? 'Enviando...' : 'Calificar respuesta',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FeedbackSubmittedBadge extends StatelessWidget {
  const _FeedbackSubmittedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Calificación enviada',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeedbackDraft {
  const _AiFeedbackDraft({
    required this.rating,
    required this.helpful,
    required this.clear,
    required this.personalized,
    required this.comment,
  });

  final int rating;
  final bool helpful;
  final bool clear;
  final bool personalized;
  final String comment;
}

class _AiFeedbackSheet extends StatefulWidget {
  const _AiFeedbackSheet();

  @override
  State<_AiFeedbackSheet> createState() => _AiFeedbackSheetState();
}

class _AiFeedbackSheetState extends State<_AiFeedbackSheet> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _helpful = true;
  bool _clear = true;
  bool _personalized = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Califica esta respuesta',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu evaluación ayuda a medir calidad, claridad y personalización del agente para el piloto.',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final selected = value <= _rating;
                    return IconButton(
                      tooltip: '$value estrellas',
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      onPressed: () => setState(() => _rating = value),
                      icon: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 34,
                        color: selected
                            ? const Color(0xFFF59E0B)
                            : colors.textMuted,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FeedbackChip(
                      label: 'Útil',
                      selected: _helpful,
                      onSelected: (value) => setState(() => _helpful = value),
                    ),
                    _FeedbackChip(
                      label: 'Clara',
                      selected: _clear,
                      onSelected: (value) => setState(() => _clear = value),
                    ),
                    _FeedbackChip(
                      label: 'Personalizada',
                      selected: _personalized,
                      onSelected: (value) =>
                          setState(() => _personalized = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Comentario opcional',
                    hintText: '¿Qué fue útil o qué debería mejorar?',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: colors.fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _rating == 0
                      ? null
                      : () => Navigator.of(context).pop(
                          _AiFeedbackDraft(
                            rating: _rating,
                            helpful: _helpful,
                            clear: _clear,
                            personalized: _personalized,
                            comment: _commentController.text,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Enviar calificación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      checkmarkColor: AppColors.primary,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.4)
            : context.colors.border,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : context.colors.textMuted,
        fontWeight: FontWeight.w700,
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
