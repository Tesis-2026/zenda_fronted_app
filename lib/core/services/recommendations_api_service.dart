import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

class Recommendation {
  final String id;
  final String type;
  final String title;
  final String body;
  final double? impactScore;
  final String? actionLabel;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.impactScore,
    this.actionLabel,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'GENERAL',
      title: (json['message'] as String?) ?? '',
      body: (json['suggestedAction'] as String?) ?? '',
      impactScore: (json['impactScore'] as num?)?.toDouble(),
      actionLabel: json['actionLabel'] as String?,
    );
  }
}

class RecommendationsApiService {
  Future<List<Recommendation>> getAll() async {
    final list = await ApiClient.getList('/recommendations');
    return list
        .cast<Map<String, dynamic>>()
        .map(Recommendation.fromJson)
        .toList();
  }

  Future<void> submitFeedback(String id, {required bool accepted}) async {
    await ApiClient.post('/recommendations/$id/feedback', {'accepted': accepted});
  }
}

// ── AI Chat ───────────────────────────────────────────────────────────────────

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

abstract class AiChatApiService {
  Future<String> sendMessage(List<ChatMessage> messages);
}

class LiveAiChatApiService extends AiChatApiService {
  @override
  Future<String> sendMessage(List<ChatMessage> messages) async {
    final body = await ApiClient.post('/ai/chat', {
      'messages': messages.map((m) => m.toJson()).toList(),
    });
    return body['reply'] as String? ?? 'No se recibió respuesta.';
  }
}

final aiChatServiceProvider =
    Provider<AiChatApiService>((ref) => LiveAiChatApiService());
