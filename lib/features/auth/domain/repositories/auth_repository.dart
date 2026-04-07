import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> register(String email, String password, String fullName);
  Future<AuthResult> login(String email, String password);
  Future<void> logout();
}
