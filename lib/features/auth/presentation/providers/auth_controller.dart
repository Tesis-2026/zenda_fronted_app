import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/user.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- INYECCIÓN DE DEPENDENCIAS CORE & DATA ---

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.read(tokenStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDataSource(dio: apiClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// --- INYECCIÓN DE CASOS DE USO ---

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

// --- STATE MANAGEMENT UI ---

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial()
      : user = null,
        isLoading = true,
        error = null;

  const AuthState.authenticated(this.user)
      : isLoading = false,
        error = null;

  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return const AuthState.initial();
  }

  Future<void> _checkAuthStatus() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.readToken();

    if (token != null && token.isNotEmpty) {
      // Mock / Parse generic info because we have a token 
      // Si el backend te da endpoints /me podrías usar un caso de uso aquí
      final user = _decodeUser(token);
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final usecase = ref.read(loginUseCaseProvider);

    try {
      final authResult = await usecase(email: email, password: password);
      // Actualizamos estado local mapeando a User local representation UI
      final user = User(
        id: '', // Mapeado si hiciera falta
        name: authResult.fullName ?? 'Usuario',
        email: authResult.email ?? email,
      );
      state = AuthState.authenticated(user);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final usecase = ref.read(registerUseCaseProvider);

    try {
      final authResult = await usecase(
        fullName: name,
        email: email,
        password: password,
      );
      final user = User(
        id: '',
        name: authResult.fullName ?? name,
        email: authResult.email ?? email,
      );
      state = AuthState.authenticated(user);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> logout() async {
    final usecase = ref.read(logoutUseCaseProvider);
    await usecase();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  User _decodeUser(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token');
      
      var payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var resp = utf8.decode(base64Url.decode(normalized));
      final decoded = json.decode(resp);
      
      return User(
        id: decoded['id']?.toString() ?? decoded['sub']?.toString() ?? '',
        name: decoded['name'] ?? decoded['fullName'] ?? 'Usuario',
        email: decoded['email'] ?? '',
      );
    } catch (_) {
      return User(id: '', name: 'Usuario Autorizado', email: '');
    }
  }
}

// Global Provider para la UI
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
