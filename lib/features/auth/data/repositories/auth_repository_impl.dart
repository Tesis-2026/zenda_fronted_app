import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthResult> register(String email, String password, String fullName) async {
    try {
      final AuthResult authResult = await remoteDataSource.register(email, password, fullName);
      await tokenStorage.saveToken(authResult.accessToken);
      return authResult;
    } on ServerException catch (e) {
      // Re-throw standardized as Domain Failure
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Ocurrió un error en el cliente durante el registro');
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final AuthResult authResult = await remoteDataSource.login(email, password);
      await tokenStorage.saveToken(authResult.accessToken);
      return authResult;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Credenciales incorrectas o red inestable');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await tokenStorage.deleteToken();
    } catch (e) {
      throw const CacheFailure('No se pudo borrar las credenciales locales');
    }
  }
}
