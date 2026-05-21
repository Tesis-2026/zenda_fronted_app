import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/l10n_extension.dart';
import 'ai_chat_controller.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || ref.read(aiChatNotifierProvider).loading) return;
    _inputController.clear();
    await ref
        .read(aiChatNotifierProvider.notifier)
        .send(text, errorMessage: context.l10n.aiChatError);
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

    final chat = ref.watch(aiChatNotifierProvider);
    final messages = chat.messages;
    final loading = chat.loading;

    ref.listen(aiChatNotifierProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.loading != next.loading) {
        _scrollToBottom();
      }
    });

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
              child: const Icon(Icons.psychology_rounded, size: 22, color: Colors.white),
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
              itemCount: messages.length + (loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(bubble: messages[i]);
              },
            ),
          ),
          if (!loading)
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
            loading: loading,
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
  const _MessageBubble({required this.bubble});
  final ChatBubble bubble;

  @override
  Widget build(BuildContext context) {
    final isUser = bubble.isUser;
    final colors = context.colors;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
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
            child: const Icon(Icons.psychology_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
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
              child: Text(
                bubble.text,
                style: TextStyle(color: colors.textPrimary, height: 1.5),
              ),
            ),
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
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      onPressed: () => onTap(label),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ))
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
