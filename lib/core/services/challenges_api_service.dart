import 'api_client.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final String status; // AVAILABLE | ACTIVE | COMPLETED | EXPIRED
  final int? progressCurrent;
  final int? progressTotal;
  final String? daysLeft;
  final String? badgeReward;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.status,
    this.progressCurrent,
    this.progressTotal,
    this.daysLeft,
    this.badgeReward,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsReward: json['pointsReward'] as int? ?? 0,
      status: json['status'] as String? ?? 'AVAILABLE',
      progressCurrent: json['progressCurrent'] as int?,
      progressTotal: json['progressTotal'] as int?,
      daysLeft: json['daysLeft']?.toString(),
      badgeReward: json['badgeReward'] as String?,
    );
  }
}

class ChallengesApiService {
  Future<List<Challenge>> getAll() async {
    final list = await ApiClient.getList('/challenges');
    return list.cast<Map<String, dynamic>>().map(Challenge.fromJson).toList();
  }

  Future<void> accept(String id) async {
    await ApiClient.post('/challenges/$id/accept', {});
  }

  Future<void> complete(String id) async {
    await ApiClient.post('/challenges/$id/complete', {});
  }
}
