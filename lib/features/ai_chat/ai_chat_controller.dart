import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/recommendations_api_service.dart';

class ChatBubble {
  final String text;
  final bool isUser;
  const ChatBubble({required this.text, required this.isUser});
}

class AiChatState {
  final List<ChatBubble> messages;
  final bool loading;

  const AiChatState({this.messages = const [], this.loading = false});

  AiChatState copyWith({List<ChatBubble>? messages, bool? loading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  // Hardcoded personalized welcome message shown when chat history is empty.
  static const demoWelcome =
      "Hi! I'm Zenda AI, your personal finance assistant. "
      "I can see your spending this month totals S/ 1,240 across 20 transactions. "
      "Your biggest expense category is Food at S/ 320. "
      "How can I help you today?";

  @override
  AiChatState build() {
    return const AiChatState(
      messages: [ChatBubble(text: demoWelcome, isUser: false)],
    );
  }

  /// Appends the user's [text], requests an AI reply, and appends it.
  /// [errorMessage] is shown as the assistant reply if the request fails.
  Future<void> send(String text, {required String errorMessage}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.loading) return;

    state = state.copyWith(
      messages: [...state.messages, ChatBubble(text: trimmed, isUser: true)],
      loading: true,
    );

    try {
      final history = state.messages
          .where((m) => m.text != demoWelcome || m.isUser)
          .map((m) =>
              ChatMessage(role: m.isUser ? 'user' : 'assistant', content: m.text))
          .toList();

      final reply = await ref.read(aiChatServiceProvider).sendMessage(history);
      state = state.copyWith(
        messages: [...state.messages, ChatBubble(text: reply, isUser: false)],
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(
        messages: [...state.messages, ChatBubble(text: errorMessage, isUser: false)],
        loading: false,
      );
    }
  }
}

final aiChatNotifierProvider =
    NotifierProvider.autoDispose<AiChatNotifier, AiChatState>(AiChatNotifier.new);
