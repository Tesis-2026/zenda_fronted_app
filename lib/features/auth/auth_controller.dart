import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_api_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

// Auth state notifier
class AuthNotifier extends Notifier<AuthState> {

  @override
  AuthState build() {
    // Check status asynchronously after initialization
    Future.microtask(() => _checkAuthStatus());
    return const AuthState.initial();
  }

  Future<void> _checkAuthStatus() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final authService = ref.read(authServiceProvider);

    final result = await authService.login(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? 'Unknown error',
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final authService = ref.read(authServiceProvider);

    final result = await authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? 'Unknown error',
      );
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth state provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Auth state class
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

  const AuthState.authenticated(User this.user)
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
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
