import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResult> call({required String email, required String password, required String fullName}) async {
    return await repository.register(email, password, fullName);
  }
}
