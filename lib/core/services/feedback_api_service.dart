import 'api_client.dart';

class FeedbackApiService {
  Future<void> submit({
    required String type,
    required String message,
    String? screenName,
    int? rating,
  }) async {
    await ApiClient.post('/feedback', {
      'type': type,
      'message': message,
      if (screenName != null) 'screenName': screenName,
      if (rating != null) 'rating': rating,
    });
  }
}
