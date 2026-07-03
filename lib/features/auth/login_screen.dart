import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/error_codes.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import 'auth_controller.dart';
import '../../l10n/l10n_extension.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _biometricLoading = false;
  String _biometricLabel = 'huella digital';
  String? _biometricEmail;

  /// Server-authoritative lockout deadline (B11/B14). Set when the login
  /// 401 response carries `lockedUntil`. Null when not locked.
  ///
  /// We deliberately do NOT persist this to SharedPreferences anymore —
  /// the server is the source of truth. If the app restarts, the next
  /// login attempt will get a fresh `lockedUntil` from the 401 body if
  /// the account is still locked.
  DateTime? _lockedUntil;
  Timer? _tickTimer;

  int get _lockoutSeconds {
    final until = _lockedUntil;
    if (until == null) return 0;
    final remaining = until.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadBiometricStatus());
  }

  Future<void> _loadBiometricStatus() async {
    final status = await ref.read(biometricAuthServiceProvider).getStatus();
    if (!mounted) return;
    setState(() {
      _biometricSupported = status.canEnable;
      _biometricEnabled = status.enabled;
      _biometricLabel = status.methodLabel;
      _biometricEmail = status.maskedEmail;
    });
  }

  void _applyLockout(DateTime lockedUntil) {
    if (!lockedUntil.isAfter(DateTime.now())) return;
    _tickTimer?.cancel();
    setState(() => _lockedUntil = lockedUntil);
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_lockoutSeconds <= 0) {
        t.cancel();
        setState(() => _lockedUntil = null);
      } else {
        setState(() {}); // triggers re-render of the countdown text
      }
    });
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final pendingEmail = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (pendingEmail != null && mounted) {
      context.go('/auth/email-sent', extra: pendingEmail);
      return;
    }

    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      await _maybeOfferBiometrics(authState.user);
      if (!mounted) return;
      final profileCompleted = authState.user?.profileCompleted ?? true;
      context.go(profileCompleted ? '/dashboard' : '/profile-setup');
    }
  }

  Future<void> _handleBiometricLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _biometricLoading = true);
    await ref.read(authNotifierProvider.notifier).loginWithBiometrics();
    if (!mounted) return;
    setState(() => _biometricLoading = false);

    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      final profileCompleted = authState.user?.profileCompleted ?? true;
      context.go(profileCompleted ? '/dashboard' : '/profile-setup');
    } else {
      await _loadBiometricStatus();
    }
  }

  Future<void> _maybeOfferBiometrics(User? user) async {
    if (user == null) return;
    final status = await ref.read(biometricAuthServiceProvider).getStatus();
    if (!status.canEnable || status.enabled || !mounted) return;

    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Activar huella digital'),
        content: Text(
          'Puedes usar tu ${status.methodLabel} para abrir Zenda sin escribir tu contrasena en este dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => context.pop(true),
            icon: const Icon(Icons.fingerprint_rounded, size: 18),
            label: const Text('Activar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldEnable != true || !mounted) return;
    final enabled = await ref
        .read(authNotifierProvider.notifier)
        .enableBiometricsForCurrentUser();
    if (!mounted) return;
    await _loadBiometricStatus();
    if (!mounted) return;
    showAppToast(
      context,
      enabled
          ? 'Huella digital activada en este dispositivo.'
          : 'No se pudo activar la huella digital.',
      type: enabled ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        if (next.error == AuthErrorCode.invalidCredentials) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(l10n.authAccountNotFound),
              content: Text(l10n.authAccountNotFoundMessage),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    context.pop();
                    context.go('/onboarding?flow=register');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.authSignUp),
                ),
              ],
            ),
          );
        } else if (next.error == AuthErrorCode.accountLocked) {
          // B11: prefer the server-authoritative lockedUntil from the
          // 401 body (B14). Fall back to a 15-minute estimate only if
          // an older backend response didn't include the field.
          final serverLockedUntil = next.lockout?.lockedUntil;
          _applyLockout(
            serverLockedUntil ??
                DateTime.now().add(const Duration(minutes: 15)),
          );
          showAppToast(
            context,
            l10n.authLockedAccount,
            type: ToastType.warning,
          );
        } else {
          showAppToast(
            context,
            l10n.resolveError(next.error!),
            type: ToastType.error,
          );
        }
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Z logo — circle with white Z
                Center(
                  child: GestureDetector(
                    onLongPress: () {
                      showAppToast(
                        context,
                        l10n.authOnboardingReset,
                        type: ToastType.info,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'Z',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.authWelcomeBack,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.authLoginSubtitle,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.authEmailHint,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterEmail;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return l10n.validationInvalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: l10n.authPasswordHint,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: Colors.grey[500],
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationEnterPassword;
                    }
                    if (value.length < 12) return l10n.validationMinPassword;
                    return null;
                  },
                ),

                // Forgot password — right-aligned
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/auth/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      l10n.authForgotLink,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Lockout banner
                if (_lockoutSeconds > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_clock,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.authLockedCountdown(
                              _formatCountdown(_lockoutSeconds),
                            ),
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else
                  const SizedBox(height: 8),

                // Sign In button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (authState.isLoading || _lockoutSeconds > 0)
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : _lockoutSeconds > 0
                        ? Text(
                            _formatCountdown(_lockoutSeconds),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            l10n.authSignInButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (_biometricSupported && _biometricEnabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: (authState.isLoading || _biometricLoading)
                          ? null
                          : _handleBiometricLogin,
                      icon: _biometricLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fingerprint_rounded, size: 22),
                      label: Text(
                        _biometricEmail == null
                            ? 'Entrar con $_biometricLabel'
                            : 'Entrar con $_biometricLabel ($_biometricEmail)',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.authNoAccount,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => context.go('/onboarding?flow=register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: Text(
                        l10n.authSignUpLink,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
