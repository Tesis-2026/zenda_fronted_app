import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../auth/auth_controller.dart';
import '../../l10n/l10n_extension.dart';

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
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    try {
      await UserApiService().updateProfile(
        fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        university: _universityController.text.trim().isEmpty ? null : _universityController.text.trim(),
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
        const SizedBox(height: 32),
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
      ],
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
