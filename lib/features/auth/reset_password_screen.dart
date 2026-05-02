import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../l10n/l10n_extension.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? prefillToken;
  const ResetPasswordScreen({super.key, this.prefillToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  int _strengthLevel = 0; // 0=none, 1=weak, 2=fair, 3=strong

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.prefillToken ?? '');
    _passwordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    final pw = _passwordController.text;
    int level = 0;
    if (pw.length >= 4) level = 1;
    if (pw.length >= 8) level = 2;
    if (pw.length >= 8 &&
        pw.contains(RegExp(r'[A-Z]')) &&
        pw.contains(RegExp(r'[0-9]'))) {
      level = 3;
    }
    if (level != _strengthLevel) setState(() => _strengthLevel = level);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.resetPassword(
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.go('/auth/reset-success');
    } else {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(result.error ?? l10n.commonUnknownError)),
            ],
          ),
          backgroundColor: const Color(0xFFFB7185),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
          ),
          onPressed: () => context.go('/auth/forgot-password'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Lock icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 36,
                      color: Color(0xFF34D399),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.authSetNewPasswordTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF1F2937),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authSetNewPasswordSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFF1F5F9).withValues(alpha: 0.7)
                            : const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 32),
                // New password field
                _PasswordLabel(text: l10n.authNewPasswordLabel),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: isDark
                      ? const TextStyle(color: Colors.white)
                      : const TextStyle(color: Color(0xFF1F2937)),
                  decoration: _inputDecoration(
                    context,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationEnterNewPassword;
                    }
                    if (value.length < 8) return l10n.validationMinPassword;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Confirm password field
                _PasswordLabel(text: l10n.authConfirmPasswordLabel),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: isDark
                      ? const TextStyle(color: Colors.white)
                      : const TextStyle(color: Color(0xFF1F2937)),
                  decoration: _inputDecoration(
                    context,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationEnterPassword;
                    }
                    if (value != _passwordController.text) {
                      return l10n.validationPasswordsMismatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Strength indicator
                _StrengthBar(level: _strengthLevel),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor:
                          const Color(0xFF34D399).withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.authResetButton,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {Widget? suffixIcon}) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _PasswordLabel extends StatelessWidget {
  final String text;
  const _PasswordLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final int level; // 0=none, 1=weak, 2=fair, 3=strong

  const _StrengthBar({required this.level});

  @override
  Widget build(BuildContext context) {
    if (level == 0) return const SizedBox.shrink();

    final labels = ['', 'Weak', 'Fair', 'Strong'];
    final colors = [
      Colors.transparent,
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF34D399),
    ];
    final activeColor = colors[level];
    final label = labels[level];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < level ? activeColor : activeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: activeColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
