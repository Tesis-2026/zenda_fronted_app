import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_api_service.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../l10n/l10n_extension.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _error;
  int _resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = AuthApiService();
    final resetToken = await authService.verifyOtp(
      email: widget.email,
      code: _code,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resetToken == null) {
      setState(() => _error = context.l10n.authVerifyInvalidCode);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } else {
      context.go('/auth/reset-password', extra: resetToken);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    final authService = AuthApiService();
    await authService.sendOtp(widget.email);
    if (!mounted) return;
    _startCooldown();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () => context.go('/auth/forgot-password'),
          icon: Icon(
            Icons.chevron_left,
            color: colors.textPrimary,
            size: 22,
          ),
          label: Text(
            l10n.authBack,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 36,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.authVerifyTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                l10n.authVerifySubtitle(widget.email),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 6-digit OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) {
                    if (v.length == 1 && i < 5) {
                      _focusNodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                    if (_code.length == 6) _verify();
                  },
                )),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 12),

              // Resend cooldown countdown
              Text(
                l10n.authVerifyResendAvailable(_formatCountdown(_resendCooldown)),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSubtle,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Resend link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.authCodeNotReceived} ',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: _resendCooldown == 0 ? _resend : null,
                    child: Text(
                      l10n.authVerifyResend,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _resendCooldown == 0
                            ? const Color(0xFF34D399)
                            : colors.textSubtle,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || _code.length != 6 ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
                          l10n.authVerifyButton,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF34D399), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
