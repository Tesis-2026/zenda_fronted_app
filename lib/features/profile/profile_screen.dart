import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../auth/auth_controller.dart';
import '../feedback/feedback_modal.dart';
import '../../l10n/l10n_extension.dart';

final profileUserServiceProvider = Provider<UserApiService>((_) => UserApiService());

final _profileProvider = FutureProvider<User>((ref) async {
  return ref.read(profileUserServiceProvider).getProfile();
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
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
      await ref.read(profileUserServiceProvider).updateProfile(
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
        showAppToast(context, context.l10n.profileErrorSave, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileSignOutDialogTitle),
        content: Text(l10n.profileSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/auth/login');
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
    if (level == null) return context.l10n.commonNotSet;
    final name = level.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  String _currencyDisplay(BuildContext context, String currency) {
    if (currency == 'PEN' || currency.isEmpty) return context.l10n.profileCurrencyPEN;
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
        onLeadingPressed: _isEditing ? () => setState(() => _isEditing = false) : null,
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
                  icon: Icon(Icons.edit_outlined, color: context.colors.icon, size: 20),
                  onPressed: () => profileAsync.whenData((user) => _startEdit(user)),
                  tooltip: l10n.profileEdit,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
                  fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            user.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
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
        // ── Surveys ───────────────────────────────────────────────────────────
        _NavSection(
          label: l10n.profileSectionSurveys,
          items: [
            _NavItem(
              icon: Icons.compare_arrows_rounded,
              iconColor: AppColors.primary,
              title: l10n.surveyComparisonNavTitle,
              onTap: () => context.push('/surveys/comparison'),
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

  void _showFeedback(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FeedbackSheetProxy(),
    );
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            DropdownMenuItem(
                value: 'PEN', child: Text(l10n.profileCurrencyPEN)),
            DropdownMenuItem(
                value: 'USD', child: Text(l10n.profileCurrencyUSD)),
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
                onPressed:
                    _isSaving ? null : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52)),
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
                            strokeWidth: 2, color: Colors.white),
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

  const _InfoRow({required this.icon, required this.label, required this.value});

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
                if (i > 0)
                  const Divider(height: 1, indent: 56),
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
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

// ── Feedback proxy (avoids importing FeedbackModal state in build) ─────────────

class _FeedbackSheetProxy extends StatelessWidget {
  const _FeedbackSheetProxy();

  @override
  Widget build(BuildContext context) {
    return FeedbackModal(screenName: 'profile');
  }
}
