import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_chat_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';

class _ChatBubble {
  final String text;
  final bool isUser;
  _ChatBubble({required this.text, required this.isUser});
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = context.l10n;
      setState(() => _messages.add(_ChatBubble(text: l10n.aiChatWelcome, isUser: false)));
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
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.text != context.l10n.aiChatWelcome || !m.isUser == false)
          .map((m) => ChatMessage(role: m.isUser ? 'user' : 'assistant', content: m.text))
          .toList();

      final reply = await ref.read(aiChatServiceProvider).sendMessage(history);
      if (mounted) {
        setState(() => _messages.add(_ChatBubble(text: reply, isUser: false)));
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _messages.add(_ChatBubble(text: context.l10n.aiChatError, isUser: false)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
              ),
              child: const Icon(Icons.psychology_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(l10n.aiChatTitle),
          ],
        ),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: UserMenuButton(),
          ),
        ],
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
                  return _TypingBubble(isDark: isDark);
                }
                return _MessageBubble(bubble: _messages[i], isDark: isDark);
              },
            ),
          ),
          if (!_loading)
            _QuickActions(
              isDark: isDark,
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
            isDark: isDark,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 2),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.bubble, required this.isDark});
  final _ChatBubble bubble;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUser = bubble.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF34D399)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
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
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1F2937)),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF34D399)),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isDark,
    required this.onTap,
    required this.labels,
  });

  final bool isDark;
  final void Function(String) onTap;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: isDark ? const Color(0xFF0B1220) : Colors.white,
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
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                        ),
                      ),
                      backgroundColor: const Color(0xFF34D399).withValues(alpha: 0.12),
                      side: BorderSide(
                        color: const Color(0xFF34D399).withValues(alpha: 0.3),
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
    required this.isDark,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;
  final String hint;
  final String sendLabel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
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
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: loading ? null : onSend,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
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
