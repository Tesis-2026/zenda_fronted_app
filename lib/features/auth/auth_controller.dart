import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user.dart';
import '../../core/services/api_client.dart';
import '../../core/services/auth_api_service.dart';
import '../../features/dashboard/dashboard_providers.dart';

// Auth service provider
final authServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

// Auth state notifier
class AuthNotifier extends Notifier<AuthState> {

  @override
  AuthState build() {
    _checkAuthStatus();
    // Redirect to login whenever a token refresh fails mid-session.
    final sub = ApiClient.onSessionExpired.listen((_) => _forceLogout());
    ref.onDispose(sub.cancel);
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
        error: result.error ?? 'Error desconocido',
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
        error: result.error ?? 'Error desconocido',
      );
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    _clearDataProviders();
    state = const AuthState.unauthenticated();
  }

  // Called when the API layer detects a non-recoverable 401 (refresh failed).
  void _forceLogout() {
    _clearDataProviders();
    state = const AuthState.unauthenticated();
  }

  void _clearDataProviders() {
    // Invalidate non-autoDispose providers so the next login gets fresh data.
    ref.invalidate(accountsProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(streakStateProvider);
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
