class AuthResult {
  final String accessToken;
  final String? email; // Optional based on what backend strictly returns
  final String? fullName;

  const AuthResult({
    required this.accessToken,
    this.email,
    this.fullName,
  });
}
