import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

class Recommendation {
  final String id;
  final String type;
  final String title;
  final String body;
  final double? impactScore;
  final String? actionLabel;

  // ── Lifecycle (B12 / ARCH-09) ───────────────────────────────────
  // Backend exposes these so the UI can filter stale recs and render
  // the dismiss / view UX. Null means the field is not yet set.

  /// Whether the recommendation is still considered active by the backend.
  /// Backend default: true on insert; flips to false when a new batch
  /// replaces this one. UI should hide isActive=false entries.
  final bool isActive;

  /// When the user first viewed the recommendation in the UI.
  final DateTime? viewedAt;

  /// When the user explicitly dismissed the recommendation.
  final DateTime? dismissedAt;

  /// Server-defined expiry. UI should hide entries older than this.
  final DateTime? expiresAt;

  /// When the user submitted feedback (accepted / rejected). Always null
  /// when no feedback has been given.
  final DateTime? feedbackAt;

  /// Most recent feedback verdict. True = accepted, false = rejected,
  /// null = no feedback yet.
  final bool? feedbackAccepted;

  // ── AI traceability (B12 / supports the >=80% accuracy KPI) ────

  /// Identifier of the model that produced the recommendation.
  /// E.g. "rules-v1" or "azure-foundry-gpt-4o-2024-08-06". Null = unknown.
  final String? modelVersion;

  /// Provider that emitted the rec. E.g. "local-rules" or "azure-foundry".
  final String? source;

  /// Opaque snapshot of the inputs the provider used (period totals,
  /// budget usage, etc.). Shape is provider-specific; UI should not
  /// inspect it directly — surface for analytics / debugging only.
  final Object? inputContextJson;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.impactScore,
    this.actionLabel,
    this.isActive = true,
    this.viewedAt,
    this.dismissedAt,
    this.expiresAt,
    this.feedbackAt,
    this.feedbackAccepted,
    this.modelVersion,
    this.source,
    this.inputContextJson,
  });

  /// True when the user has not yet seen or interacted with the rec.
  bool get isFresh =>
      isActive && viewedAt == null && dismissedAt == null && !isExpired;

  /// True when the server-defined expiry has passed.
  bool get isExpired {
    final until = expiresAt;
    return until != null && until.isBefore(DateTime.now());
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'GENERAL',
      title: (json['message'] as String?) ?? '',
      body: (json['suggestedAction'] as String?) ?? '',
      impactScore: (json['impactScore'] as num?)?.toDouble(),
      actionLabel: json['actionLabel'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      viewedAt: _parseDate(json['viewedAt']),
      dismissedAt: _parseDate(json['dismissedAt']),
      expiresAt: _parseDate(json['expiresAt']),
      feedbackAt: _parseDate(json['feedbackAt']),
      feedbackAccepted: json['feedbackAccepted'] as bool?,
      modelVersion: json['modelVersion'] as String?,
      source: json['source'] as String?,
      inputContextJson: json['inputContextJson'],
    );
  }
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

/// Acceptance-rate stats for the authenticated user. Feeds the
/// `Acceptance Rate >= 60%` thesis KPI dashboard (US-0902).
class RecommendationStats {
  final int total;
  final int accepted;

  /// `accepted / total`, 0..1. Backend returns 0 when total is 0
  /// (no divide-by-zero blow-up).
  final double acceptanceRate;

  const RecommendationStats({
    required this.total,
    required this.accepted,
    required this.acceptanceRate,
  });

  factory RecommendationStats.fromJson(Map<String, dynamic> json) {
    return RecommendationStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      accepted: (json['accepted'] as num?)?.toInt() ?? 0,
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
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

  /// Returns acceptance-rate stats for the current user. Used by the
  /// dashboard to surface the Acceptance Rate KPI without recomputing
  /// it client-side from the full recommendation list.
  Future<RecommendationStats> getStats() async {
    final body = await ApiClient.get('/recommendations/stats');
    return RecommendationStats.fromJson(body);
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

/// Reply returned by `POST /ai/chat`. The backend persists the user
/// message and the assistant reply on the active conversation; the id
/// is returned so a follow-up screen could deep-link to a transcript.
class ChatReply {
  final String conversationId;
  final String reply;

  const ChatReply({required this.conversationId, required this.reply});
}

/// Snapshot of the user's active AI conversation. `conversationId` is
/// null when no conversation has been opened yet — the next
/// `sendMessage` call will create one server-side.
class ActiveConversation {
  final String? conversationId;
  final List<ChatMessage> messages;

  const ActiveConversation({
    required this.conversationId,
    required this.messages,
  });

  factory ActiveConversation.empty() =>
      const ActiveConversation(conversationId: null, messages: []);
}

abstract class AiChatApiService {
  /// Loads the user's active conversation + ordered history. Used on
  /// chat-screen open so history survives app restarts.
  Future<ActiveConversation> getActive();

  /// Sends a single user message. Backend appends the message + the
  /// assistant reply to the active conversation (creates one if needed).
  Future<ChatReply> sendMessage(String message);

  /// Marks the active conversation CLOSED. Messages stay in the DB.
  /// Called from logout so the next session starts fresh.
  Future<void> closeActive();
}

class LiveAiChatApiService extends AiChatApiService {
  @override
  Future<ActiveConversation> getActive() async {
    final body = await ApiClient.get('/ai/chat/active');
    final rawMessages = body['messages'];
    final messages = rawMessages is List
        ? rawMessages
            .cast<Map<String, dynamic>>()
            .map((m) => ChatMessage(
                  role: m['role'] as String,
                  content: m['content'] as String,
                ))
            .toList()
        : <ChatMessage>[];
    return ActiveConversation(
      conversationId: body['conversationId'] as String?,
      messages: messages,
    );
  }

  @override
  Future<ChatReply> sendMessage(String message) async {
    final body = await ApiClient.post(
      '/ai/chat',
      {'message': message},
      authenticated: true,
    );
    return ChatReply(
      conversationId: (body['conversationId'] as String?) ?? '',
      reply: (body['reply'] as String?) ?? 'No se recibió respuesta.',
    );
  }

  @override
  Future<void> closeActive() async {
    await ApiClient.post('/ai/chat/close', {}, authenticated: true);
  }
}

final aiChatServiceProvider =
    Provider<AiChatApiService>((ref) => LiveAiChatApiService());
