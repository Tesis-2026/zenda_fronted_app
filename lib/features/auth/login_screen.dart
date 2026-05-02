import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/error_codes.dart';
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

  // Lockout countdown state — persisted across app restarts
  static const _lockoutKey = 'zenda.auth.lockout_until';
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _restoreLockout();
  }

  Future<void> _restoreLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMs = prefs.getInt(_lockoutKey);
    if (storedMs == null) return;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(storedMs);
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining > 0) {
      setState(() => _lockoutSeconds = remaining);
      _startLockoutTimer();
    } else {
      await prefs.remove(_lockoutKey);
    }
  }

  void _startLockoutCountdown() async {
    _lockoutTimer?.cancel();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockoutKey, expiresAt.millisecondsSinceEpoch);
    setState(() => _lockoutSeconds = 15 * 60);
    _startLockoutTimer();
  }

  void _startLockoutTimer() {
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_lockoutSeconds > 0) {
          _lockoutSeconds--;
        } else {
          t.cancel();
          SharedPreferences.getInstance()
              .then((p) => p.remove(_lockoutKey));
        }
      });
    });
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Check if login was successful — route to profile setup if not completed
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      final profileCompleted = authState.user?.profileCompleted ?? true;
      context.go(profileCompleted ? '/dashboard' : '/profile-setup');
    }
  }

  void _showForgotPasswordDialog() {
    context.go('/auth/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    // Show error if exists
    // Show error if exists
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        // Wrong credentials → suggest creating an account instead of a generic snackbar.
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
                  child: Text(
                    l10n.commonCancel,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/onboarding?flow=register');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.authSignUp),
                ),
              ],
            ),
          );
        } else if (next.error == AuthErrorCode.accountLocked) {
          _startLockoutCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lock_clock, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.authLockedAccount)),
                ],
              ),
              backgroundColor: const Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 6),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.resolveError(next.error!))),
                ],
              ),
              backgroundColor: const Color(0xFFFB7185),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                GestureDetector(
                  onLongPress: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.authOnboardingReset)),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34D399).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.authLoginTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.authLoginSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? const Color(0xFFF1F5F9).withValues(alpha: 0.7) : const Color(0xFF6B7280),
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  style: isDark ? const TextStyle(color: Colors.white) : const TextStyle(color: Color(0xFF1F2937)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.authEmailLabel,
                    hintText: l10n.authEmailHint,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterEmail;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return l10n.validationInvalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  style: isDark ? const TextStyle(color: Colors.white) : const TextStyle(color: Color(0xFF1F2937)),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.authPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationEnterPassword;
                    }
                    if (value.length < 8) {
                      return l10n.validationMinPassword;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      l10n.authForgotPassword,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF60A5FA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Lockout countdown banner
                if (_lockoutSeconds > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.authLockedCountdown(_formatCountdown(_lockoutSeconds)),
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
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

                // Login button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (authState.isLoading || _lockoutSeconds > 0) ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: const Color(0xFF34D399).withValues(alpha: 0.5),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : _lockoutSeconds > 0
                            ? Text(
                                _formatCountdown(_lockoutSeconds),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )
                        : Text(
                            l10n.authSignIn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.commonOr,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB))),
                  ],
                ),

                const SizedBox(height: 24),

                // Google button (demo only)
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: null, // Disabled
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(l10n.authContinueGoogle),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.authNoAccount,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF1F5F9).withValues(alpha: 0.7) : const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/onboarding?flow=register'),
                      child: Text(
                        l10n.authSignUp,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF34D399),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.authPrivacyNote,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
