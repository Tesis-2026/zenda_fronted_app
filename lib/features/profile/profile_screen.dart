import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/services/user_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../providers/repositories_providers.dart';
import '../auth/auth_controller.dart';
import '../feedback/feedback_modal.dart';
import '../../l10n/l10n_extension.dart';

final profileUserServiceProvider = Provider<UserApiService>(
  (_) => UserApiService(),
);

final _profileProvider = FutureProvider<User>((ref) async {
  return ref.read(profileUserServiceProvider).getProfile();
});

final _biometricStatusProvider = FutureProvider<BiometricStatus>((ref) async {
  return ref.read(biometricAuthServiceProvider).getStatus();
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isPreferenceSaving = false;
  bool _isBiometricSaving = false;
  String _currency = 'PEN';

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _universityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _universityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  void _startEdit(User user) {
    _nameController.text = user.name;
    _ageController.text = user.age?.toString() ?? '';
    _universityController.text = user.university ?? '';
    _currency = user.currency.isNotEmpty ? user.currency : 'PEN';
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileUserServiceProvider)
          .updateProfile(
            fullName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            age: int.tryParse(_ageController.text),
            university: _universityController.text.trim().isEmpty
                ? null
                : _universityController.text.trim(),
            currency: _currency,
          );
      ref.invalidate(_profileProvider);
      if (mounted) setState(() => _isEditing = false);
    } catch (_) {
      if (mounted) {
        showAppToast(
          context,
          context.l10n.profileErrorSave,
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveCurrencyPreference(User user, String currency) async {
    if (currency == user.currency || _isPreferenceSaving) return;
    setState(() => _isPreferenceSaving = true);
    try {
      final updated = await ref
          .read(profileUserServiceProvider)
          .updateProfile(currency: currency);
      ref.read(authNotifierProvider.notifier).updateCurrentUser(updated);
      ref.invalidate(_profileProvider);
      if (!mounted) return;
      showAppToast(context, 'Moneda guardada.', type: ToastType.success);
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        context.l10n.profileErrorSave,
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isPreferenceSaving = false);
    }
  }

  Future<void> _saveNumberFormatPreference(String format) async {
    if (_isPreferenceSaving) return;
    setState(() => _isPreferenceSaving = true);
    try {
      await ref.read(numberFormatProvider.notifier).setFormat(format);
      if (!mounted) return;
      showAppToast(
        context,
        context.l10n.profileNumberFormatSaved,
        type: ToastType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        context.l10n.profileErrorSave,
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isPreferenceSaving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.profileSignOutDialogTitle,
      message: l10n.profileSignOutDialogContent,
      confirmLabel: l10n.commonSignOut,
      tone: ConfirmTone.neutral,
      icon: Icons.logout_rounded,
    );
    if (confirmed && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/auth/login');
    }
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    setState(() => _isBiometricSaving = true);
    try {
      if (enabled) {
        final activated = await ref
            .read(authNotifierProvider.notifier)
            .enableBiometricsForCurrentUser();
        if (!mounted) return;
        showAppToast(
          context,
          activated
              ? 'Huella digital activada.'
              : 'No se pudo validar la huella digital.',
          type: activated ? ToastType.success : ToastType.error,
        );
      } else {
        await ref.read(authNotifierProvider.notifier).disableBiometrics();
        if (!mounted) return;
        showAppToast(
          context,
          'Huella digital desactivada.',
          type: ToastType.info,
        );
      }
      ref.invalidate(_biometricStatusProvider);
    } finally {
      if (mounted) setState(() => _isBiometricSaving = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _incomeTypeLabel(BuildContext context, IncomeType? type) {
    if (type == null) return context.l10n.commonNotSet;
    final l10n = context.l10n;
    return switch (type) {
      IncomeType.scholarship => l10n.incomeTypeScholarship,
      IncomeType.partTime => l10n.incomeTypePartTime,
      IncomeType.family => l10n.incomeTypeFamily,
      IncomeType.mixed => l10n.incomeTypeMixed,
    };
  }

  String _literacyLabel(FinancialLiteracyLevel? level) {
    final l10n = context.l10n;
    return switch (level) {
      null => l10n.commonNotSet,
      FinancialLiteracyLevel.beginner => l10n.literacyLevelLow,
      FinancialLiteracyLevel.intermediate => l10n.literacyLevelMedium,
      FinancialLiteracyLevel.advanced => l10n.literacyLevelHigh,
    };
  }

  String _currencyDisplay(BuildContext context, String currency) {
    if (currency == 'PEN' || currency.isEmpty) {
      return context.l10n.profileCurrencyPEN;
    }
    if (currency == 'USD') return context.l10n.profileCurrencyUSD;
    return currency;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_profileProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: ZendaAppBar(
        title: l10n.profileTitle,
        onLeadingPressed: _isEditing
            ? () => setState(() => _isEditing = false)
            : null,
        actions: [
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.fill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: context.colors.icon,
                    size: 20,
                  ),
                  onPressed: () =>
                      profileAsync.whenData((user) => _startEdit(user)),
                  tooltip: l10n.profileEdit,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.profileErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_profileProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (user) =>
            _isEditing ? _buildEditView(user) : _buildReadView(user),
      ),
    );
  }

  Widget _buildReadView(User user) {
    final l10n = context.l10n;
    final biometricStatus = ref.watch(_biometricStatusProvider);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Text(
              _initials(user.name),
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            user.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Info card
        AppCard(
          borderRadius: 20.0,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.school_outlined,
                label: l10n.profileUniversity,
                value: user.university ?? l10n.commonNotSet,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(
                icon: Icons.work_outline_rounded,
                label: l10n.profileIncomeType,
                value: _incomeTypeLabel(context, user.incomeType),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(
                icon: Icons.bar_chart_rounded,
                label: l10n.profileFinancialLiteracy,
                value: _literacyLabel(user.financialLiteracyLevel),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(
                icon: Icons.monetization_on_outlined,
                label: l10n.profileCurrency,
                value: _currencyDisplay(context, user.currency),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPreferencesSection(user),
        const SizedBox(height: 24),
        _buildBiometricSection(biometricStatus),
        const SizedBox(height: 16),
        // ── Finanzas ──────────────────────────────────────────────────────────
        _NavSection(
          label: l10n.profileSectionFinance,
          items: [
            _NavItem(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.primary,
              title: l10n.reportsTitle,
              onTap: () => context.push('/reports'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ── Learn & Grow ──────────────────────────────────────────────────────
        _NavSection(
          label: l10n.profileSectionLearnGrow,
          items: [
            _NavItem(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: l10n.challengesTitle,
              onTap: () => context.push('/challenges'),
            ),
            _NavItem(
              icon: Icons.military_tech_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: l10n.badgesTitle,
              onTap: () => context.push('/badges'),
            ),
            _NavItem(
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.primary,
              title: l10n.progressTitle,
              onTap: () => context.push('/progress'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ── Support ───────────────────────────────────────────────────────────
        _NavSection(
          label: l10n.profileSectionSupport,
          items: [
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF6B7280),
              title: l10n.profileSendFeedback,
              onTap: () => _showFeedback(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _confirmLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFFEF2F2),
            side: const BorderSide(color: Color(0xFFFCA5A5)),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(l10n.commonSignOut),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBiometricSection(AsyncValue<BiometricStatus> statusAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Seguridad'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: statusAsync.when(
            loading: () => const Row(
              children: [
                Icon(Icons.fingerprint_rounded, color: AppColors.textSubtle),
                SizedBox(width: 12),
                Expanded(child: Text('Revisando biometria...')),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            error: (_, _) => Row(
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  color: AppColors.textSubtle,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('No se pudo revisar la huella digital.'),
                ),
                IconButton(
                  onPressed: () => ref.invalidate(_biometricStatusProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: context.l10n.commonRetry,
                ),
              ],
            ),
            data: (status) {
              final canChange =
                  !_isBiometricSaving && (status.canEnable || status.enabled);
              final subtitle = status.enabled
                  ? status.canEnable
                        ? 'Activa para este dispositivo.'
                        : 'Activa, pero no disponible en este momento.'
                  : status.canEnable
                  ? 'Usa tu ${status.methodLabel} al abrir Zenda.'
                  : 'Configura una huella en tu dispositivo para activarla.';

              return Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Huella digital',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: status.enabled,
                    onChanged: canChange ? _toggleBiometrics : null,
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(User user) {
    final l10n = context.l10n;
    final numberFormatAsync = ref.watch(numberFormatProvider);
    final numberFormat = numberFormatAsync.asData?.value ?? 'dot';
    final isLoadingFormat =
        numberFormatAsync.isLoading && !numberFormatAsync.hasValue;
    final disabled = _isPreferenceSaving || isLoadingFormat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.profileSectionPreferences),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('currency-${user.currency}'),
                initialValue: user.currency.isEmpty ? 'PEN' : user.currency,
                decoration: InputDecoration(
                  labelText: l10n.profileCurrency,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'PEN',
                    child: Text(l10n.profileCurrencyPEN),
                  ),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text(l10n.profileCurrencyUSD),
                  ),
                ],
                onChanged: disabled
                    ? null
                    : (value) {
                        if (value != null) {
                          _saveCurrencyPreference(user, value);
                        }
                      },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: ValueKey('number-format-$numberFormat'),
                initialValue: numberFormat,
                decoration: InputDecoration(
                  labelText: l10n.profileNumberFormat,
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'dot',
                    child: Text(l10n.profileNumberFormatDot),
                  ),
                  DropdownMenuItem(
                    value: 'comma',
                    child: Text(l10n.profileNumberFormatComma),
                  ),
                ],
                onChanged: disabled
                    ? null
                    : (value) {
                        if (value != null && value != numberFormat) {
                          _saveNumberFormatPreference(value);
                        }
                      },
              ),
              if (_isPreferenceSaving) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 2),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedback(BuildContext context) {
    FeedbackModal.show(context, screenName: 'profile');
  }

  Widget _buildEditView(User user) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppTextField(
          controller: _nameController,
          labelText: l10n.profileFullNameLabel,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _ageController,
          labelText: l10n.profileAgeLabel,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _universityController,
          labelText: l10n.profileUniversityLabel,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _currency,
          decoration: InputDecoration(
            labelText: l10n.profileCurrency,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            DropdownMenuItem(
              value: 'PEN',
              child: Text(l10n.profileCurrencyPEN),
            ),
            DropdownMenuItem(
              value: 'USD',
              child: Text(l10n.profileCurrencyUSD),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _currency = v);
          },
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _saveEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 52),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSubtle),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigation section card ────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
}

class _NavSection extends StatelessWidget {
  const _NavSection({required this.label, required this.items});
  final String label;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                _NavRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.item});
  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 17, color: item.iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
