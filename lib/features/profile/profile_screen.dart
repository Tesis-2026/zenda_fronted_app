import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../auth/auth_controller.dart';
import '../feedback/feedback_modal.dart';
import '../../l10n/l10n_extension.dart';

const _kNumberFormatKey = 'zenda.number_format';
const _kConsentRevokedKey = 'zenda.consent.revoked';

final _profileProvider = FutureProvider<User>((ref) async {
  return UserApiService().getProfile();
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
  bool _useCommaSeparator = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _universityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _universityController = TextEditingController();
    _loadNumberFormat();
  }

  Future<void> _loadNumberFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kNumberFormatKey) ?? 'dot';
    if (mounted) setState(() => _useCommaSeparator = value == 'comma');
  }

  Future<void> _saveNumberFormat(bool useComma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNumberFormatKey, useComma ? 'comma' : 'dot');
    if (!mounted) return;
    setState(() => _useCommaSeparator = useComma);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.profileNumberFormatSaved)),
    );
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
      await UserApiService().updateProfile(
        fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        university: _universityController.text.trim().isEmpty ? null : _universityController.text.trim(),
        currency: _currency,
      );
      ref.invalidate(_profileProvider);
      if (mounted) setState(() => _isEditing = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileErrorSave)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _revokeConsent() async {
    final l10n = context.l10n;
    final prefs = await SharedPreferences.getInstance();
    final alreadyRevoked = prefs.getBool(_kConsentRevokedKey) ?? false;
    if (!mounted) return;

    if (alreadyRevoked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileConsentAlreadyRevoked)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileRevokeConsentDialogTitle),
        content: Text(l10n.profileRevokeConsentDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.profileRevokeConsentConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await prefs.setBool(_kConsentRevokedKey, true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileRevokeConsentDone)),
    );
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_profileProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _confirmLogout,
              tooltip: l10n.profileSignOutTooltip,
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
        data: (user) => _isEditing ? _buildEditView(user) : _buildReadView(user),
      ),
    );
  }

  Widget _buildReadView(User user) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF34D399),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ),
        const SizedBox(height: 32),
        _infoTile(l10n.profileAge, user.age?.toString() ?? l10n.commonNotSet),
        _infoTile(l10n.profileUniversity, user.university ?? l10n.commonNotSet),
        _infoTile(l10n.profileCurrency, user.currency),
        _infoTile(l10n.profileIncomeType, user.incomeType?.name ?? l10n.commonNotSet),
        _infoTile(l10n.profileMonthlyIncome, user.averageMonthlyIncome != null ? 'S/ ${user.averageMonthlyIncome!.toStringAsFixed(2)}' : l10n.commonNotSet),
        _infoTile(l10n.profileFinancialLiteracy, user.financialLiteracyLevel?.name ?? l10n.commonNotSet),
        const SizedBox(height: 24),
        _sectionHeader(l10n.profileNumberFormat),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(l10n.profileNumberFormatDot, style: const TextStyle(fontSize: 12)),
            ),
            ButtonSegment(
              value: true,
              label: Text(l10n.profileNumberFormatComma, style: const TextStyle(fontSize: 12)),
            ),
          ],
          selected: {_useCommaSeparator},
          onSelectionChanged: (s) => _saveNumberFormat(s.first),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _startEdit(user),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.profileEditButton),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF34D399),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/categories'),
          icon: const Icon(Icons.label_outlined),
          label: Text(l10n.profileManageCategories),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeader(l10n.profileSectionFinance),
        _navTile(
          icon: Icons.pie_chart_outline,
          title: l10n.profileBudgets,
          onTap: () => context.push('/budgets'),
        ),
        _navTile(
          icon: Icons.savings_outlined,
          title: l10n.profileGoals,
          onTap: () => context.push('/goals'),
        ),
        _navTile(
          icon: Icons.analytics_outlined,
          title: l10n.predictionsTitle,
          onTap: () => context.push('/predictions'),
        ),
        _navTile(
          icon: Icons.lightbulb_outline,
          title: l10n.recommendationsTitle,
          onTap: () => context.push('/recommendations'),
        ),
        _navTile(
          icon: Icons.trending_up_outlined,
          title: l10n.progressTitle,
          onTap: () => context.push('/progress'),
        ),
        const SizedBox(height: 8),
        _sectionHeader(l10n.profileSectionLearnGrow),
        _navTile(
          icon: Icons.school_outlined,
          title: l10n.educationTitle,
          onTap: () => context.push('/education'),
        ),
        _navTile(
          icon: Icons.flag_outlined,
          title: l10n.challengesTitle,
          onTap: () => context.push('/challenges'),
        ),
        _navTile(
          icon: Icons.military_tech_outlined,
          title: l10n.badgesTitle,
          onTap: () => context.push('/badges'),
        ),
        const SizedBox(height: 8),
        _sectionHeader(l10n.profileSectionSurveys),
        _navTile(
          icon: Icons.assignment_outlined,
          title: l10n.surveyPreTitle,
          onTap: () => context.push('/surveys/pre'),
        ),
        _navTile(
          icon: Icons.assignment_turned_in_outlined,
          title: l10n.surveyPostTitle,
          onTap: () => context.push('/surveys/post'),
        ),
        _navTile(
          icon: Icons.trending_up_outlined,
          title: l10n.surveyComparisonNavTitle,
          onTap: () => context.push('/surveys/comparison'),
        ),
        _navTile(
          icon: Icons.checklist_rounded,
          title: l10n.susSurveyTitle,
          onTap: () => context.push('/surveys/sus'),
        ),
        const SizedBox(height: 8),
        _navTile(
          icon: Icons.psychology_rounded,
          title: l10n.aiChatTitle,
          onTap: () => context.push('/ai-chat'),
        ),
        const SizedBox(height: 8),
        _sectionHeader(l10n.profileSectionSupport),
        _navTile(
          icon: Icons.notifications_outlined,
          title: l10n.notificationsTitle,
          onTap: () => context.push('/notifications'),
        ),
        _navTile(
          icon: Icons.feedback_outlined,
          title: l10n.profileSendFeedback,
          onTap: () => FeedbackModal.show(context, screenName: 'profile'),
        ),
        const SizedBox(height: 8),
        _sectionHeader(l10n.profileSectionPrivacy),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.verified_user_outlined, size: 22),
          title: Text(l10n.profilePrivacyLaw),
          subtitle: Text(
            l10n.profilePrivacyLawSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.profilePrivacyLaw),
                content: Text(l10n.profilePrivacyLawBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.commonOk),
                  ),
                ],
              ),
            );
          },
        ),
        _navTile(
          icon: Icons.gpp_bad_outlined,
          title: l10n.profileRevokeConsent,
          onTap: _revokeConsent,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEditView(User user) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.profileFullNameLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.profileAgeLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _universityController,
          decoration: InputDecoration(
            labelText: l10n.profileUniversityLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _currency,
          decoration: InputDecoration(
            labelText: l10n.profileCurrency,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'PEN', child: Text('PEN — Peruvian Sol (S/)')),
            DropdownMenuItem(value: 'USD', child: Text('USD — US Dollar (\$)')),
          ],
          onChanged: (v) { if (v != null) setState(() => _currency = v); },
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _saveEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  minimumSize: const Size(0, 52),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
