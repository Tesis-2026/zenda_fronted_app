import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/error_codes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import 'auth_controller.dart';
import 'login_lockout_controller.dart';
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

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      final profileCompleted = authState.user?.profileCompleted ?? true;
      context.go(profileCompleted ? '/dashboard' : '/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final lockoutSeconds = ref.watch(loginLockoutProvider);
    final l10n = context.l10n;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        if (next.error == AuthErrorCode.invalidCredentials) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.authAccountNotFound),
              content: Text(l10n.authAccountNotFoundMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/onboarding?flow=register');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.authSignUp),
                ),
              ],
            ),
          );
        } else if (next.error == AuthErrorCode.accountLocked) {
          ref.read(loginLockoutProvider.notifier).lock();
          showAppToast(context, l10n.authLockedAccount, type: ToastType.warning);
        } else {
          showAppToast(context, l10n.resolveError(next.error!), type: ToastType.error);
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
                      showAppToast(context, l10n.authOnboardingReset, type: ToastType.info);
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
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
                        horizontal: 16, vertical: 16),
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
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterEmail;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
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
                        horizontal: 16, vertical: 16),
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
                          color: AppColors.primary, width: 2),
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
                          horizontal: 4, vertical: 8),
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
                if (lockoutSeconds > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.authLockedCountdown(
                                _formatCountdown(lockoutSeconds)),
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
                    onPressed: (authState.isLoading || lockoutSeconds > 0)
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : lockoutSeconds > 0
                            ? Text(
                                _formatCountdown(lockoutSeconds),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                      onPressed: () =>
                          context.go('/onboarding?flow=register'),
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
