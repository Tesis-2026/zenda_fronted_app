import 'api_client.dart';

class ZendaBadge {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isEarned;
  final DateTime? earnedAt;

  const ZendaBadge({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.isEarned,
    this.earnedAt,
  });

  factory ZendaBadge.fromJson(Map<String, dynamic> json) {
    return ZendaBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      isEarned: json['isEarned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null
          ? DateTime.tryParse(json['earnedAt'] as String)
          : null,
    );
  }
}

class BadgesApiService {
  Future<List<ZendaBadge>> getAll() async {
    final list = await ApiClient.getList('/badges');
    return list.cast<Map<String, dynamic>>().map(ZendaBadge.fromJson).toList();
  }
}
