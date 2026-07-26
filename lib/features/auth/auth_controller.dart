import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/error_codes.dart';
import '../../core/models/user.dart';
import '../../core/services/api_client.dart';
import '../../core/services/auth_api_service.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../features/dashboard/dashboard_providers.dart';

export '../../core/services/auth_api_service.dart' show LockoutInfo;

// Auth service provider
final authServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
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
    final biometricService = ref.read(biometricAuthServiceProvider);
    final biometricStatus = await biometricService.getStatus();
    if (biometricStatus.canAuthenticate && await ApiClient.hasAccessToken()) {
      final unlocked = await biometricService.authenticate(
        reason: 'Confirma tu huella digital para abrir Zenda.',
      );
      if (!unlocked) {
        state = const AuthState.unauthenticated();
        return;
      }
    }

    final user = await authService.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, clearLockout: true);
    final authService = ref.read(authServiceProvider);

    final result = await authService.login(email: email, password: password);

    if (result.requiresEmailVerification) {
      state = const AuthState.unauthenticated();
      return result.pendingVerificationEmail;
    }

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? 'Error desconocido',
        lockout: result.lockout,
      );
    }
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final authService = ref.read(authServiceProvider);

    final result = await authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (result.requiresEmailVerification) {
      state = const AuthState.unauthenticated();
      return result.pendingVerificationEmail;
    }

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? 'Error desconocido',
      );
    }
    return null;
  }

  Future<bool> verifyEmail(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(authServiceProvider).verifyEmail(
          email: email,
          code: code,
        );

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: result.error ?? AuthErrorCode.badRequest,
    );
    return false;
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null, clearLockout: true);
    final biometricService = ref.read(biometricAuthServiceProvider);
    final status = await biometricService.getStatus();

    if (!status.canAuthenticate) {
      state = state.copyWith(
        isLoading: false,
        error:
            '${AuthErrorCode.badRequest}|Activa la huella digital despues de iniciar sesion.',
      );
      return;
    }

    final unlocked = await biometricService.authenticate(
      reason: 'Confirma tu huella digital para ingresar a Zenda.',
    );
    if (!unlocked) {
      state = state.copyWith(
        isLoading: false,
        error:
            '${AuthErrorCode.badRequest}|No se pudo validar la huella digital.',
      );
      return;
    }

    final result = await ref.read(authServiceProvider).restoreStoredSession();
    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      await biometricService.disable();
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? AuthErrorCode.tokenExpired,
      );
    }
  }

  Future<bool> enableBiometricsForCurrentUser() async {
    final user = state.user;
    if (user == null) return false;

    final biometricService = ref.read(biometricAuthServiceProvider);
    final status = await biometricService.getStatus();
    if (!status.canEnable) return false;

    final unlocked = await biometricService.authenticate(
      reason: 'Confirma tu huella digital para activar el acceso seguro.',
    );
    if (!unlocked) return false;

    await biometricService.enableForUser(user.email);
    return true;
  }

  Future<void> disableBiometrics() async {
    await ref.read(biometricAuthServiceProvider).disable();
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    final biometricService = ref.read(biometricAuthServiceProvider);
    final biometricStatus = await biometricService.getStatus();
    final keepBiometricSession =
        biometricStatus.canAuthenticate && await ApiClient.hasStoredSession();

    await authService.logout(preserveBiometricSession: keepBiometricSession);
    if (!keepBiometricSession) {
      await biometricService.disable();
    }
    _clearDataProviders();
    state = const AuthState.unauthenticated();
  }

  // Called when the API layer detects a non-recoverable 401 (refresh failed).
  void _forceLogout() {
    unawaited(ref.read(biometricAuthServiceProvider).disable());
    _clearDataProviders();
    state = const AuthState.unauthenticated();
  }

  void _clearDataProviders() {
    // Invalidate non-autoDispose providers so the next login gets fresh data.
    ref.invalidate(transactionsProvider);
    ref.invalidate(streakStateProvider);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateCurrentUser(User user) {
    if (!state.isAuthenticated) return;
    state = AuthState.authenticated(user);
  }
}

// Auth state provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// Auth state class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  /// Server-reported lockout state from the most recent failed login attempt.
  /// Populated by the auth notifier from the 401 body (B14); read by
  /// `LoginScreen` to render the countdown (B11). Cleared on a successful
  /// login or on the next attempt.
  final LockoutInfo? lockout;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.lockout,
  });

  const AuthState.initial()
    : user = null,
      isLoading = true,
      error = null,
      lockout = null;

  const AuthState.authenticated(User this.user)
    : isLoading = false,
      error = null,
      lockout = null;

  const AuthState.unauthenticated()
    : user = null,
      isLoading = false,
      error = null,
      lockout = null;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    LockoutInfo? lockout,
    bool clearLockout = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lockout: clearLockout ? null : (lockout ?? this.lockout),
    );
  }
}
