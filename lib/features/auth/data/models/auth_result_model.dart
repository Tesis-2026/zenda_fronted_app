import '../../domain/entities/auth_result.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.accessToken,
    super.email,
    super.fullName,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json, {String? defaultToken}) {
    // Handling different backend structures dynamically like before, prioritizing 'token', 'accessToken' or 'access_token'
    final token = json['accessToken'] ?? json['token'] ?? json['access_token'] ?? defaultToken;

    if (token == null || token.isEmpty) {
      throw Exception('Missing access token in payload');
    }

    String? userEmail;
    String? userFullName;

    if (json.containsKey('user') && json['user'] != null) {
      userEmail = json['user']['email'];
      userFullName = json['user']['fullName'] ?? json['user']['name'];
    } else {
      userEmail = json['email'];
      userFullName = json['fullName'] ?? json['name'];
    }

    return AuthResultModel(
      accessToken: token,
      email: userEmail,
      fullName: userFullName,
    );
  }
}
