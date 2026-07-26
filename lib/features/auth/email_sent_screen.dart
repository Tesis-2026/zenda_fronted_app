import 'dart:async';

import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';

class EmailSentScreen extends ConsumerStatefulWidget {
  const EmailSentScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends ConsumerState<EmailSentScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _error;
  int _resendCooldown = 60;
  Timer? _timer;

  String get _email {
    final explicit = widget.email.trim();
    if (explicit.isNotEmpty) return explicit;
    return ref.read(authNotifierProvider).user?.email ?? '';
  }

  String get _code => _controllers.map((c) => c.text).join();

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

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (_isLoading || _code.length != 6) return;
    final email = _email;
    if (email.isEmpty) {
      setState(() => _error = context.l10n.errorAuthBadRequest);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final ok = await ref
        .read(authNotifierProvider.notifier)
        .verifyEmail(email, _code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!ok) {
      setState(() => _error = context.l10n.authVerifyInvalidCode);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      return;
    }

    showAppToast(
      context,
      'Correo verificado correctamente.',
      type: ToastType.success,
    );
    context.go('/profile-setup');
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    final email = _email;
    if (email.isEmpty) return;

    final result =
        await ref.read(authServiceProvider).resendEmailVerification(email);
    if (!mounted) return;

    if (!result.isSuccess) {
      showAppToast(
        context,
        context.l10n.resolveError(result.error ?? ''),
        type: ToastType.error,
      );
      return;
    }

    _startCooldown();
    setState(() => _error = null);
    showAppToast(context, 'Codigo reenviado.', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final email = _email;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () => context.go('/auth/login'),
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
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF34D399).withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 44,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.emailVerifTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.emailVerifSubtitle(email),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    _StepRow(number: 1, text: l10n.emailVerifStep1, active: true),
                    Divider(height: 1, color: colors.border),
                    _StepRow(number: 2, text: l10n.emailVerifStep2),
                    Divider(height: 1, color: colors.border),
                    _StepRow(number: 3, text: l10n.emailVerifStep3),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
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
                  ),
                ),
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
              const SizedBox(height: 16),
              Text(
                l10n.authVerifyResendAvailable(_formatCountdown(_resendCooldown)),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSubtle,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
                  TextButton(
                    onPressed: _resendCooldown == 0 ? _resend : null,
                    child: Text(l10n.emailVerifResendAction),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading || _code.length != 6 ? null : _verify,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.emailVerifOpenApp,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    this.active = false,
  });

  final int number;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xFF34D399)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: active ? Colors.white : colors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

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
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
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
            borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
