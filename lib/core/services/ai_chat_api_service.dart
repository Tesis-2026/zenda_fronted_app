import 'api_client.dart';

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiChatApiService {
  Future<String> sendMessage(List<ChatMessage> messages) async {
    final body = await ApiClient.post('/ai/chat', {
      'messages': messages.map((m) => m.toJson()).toList(),
    });
    return body['reply'] as String? ?? 'No response received.';
  }
}
