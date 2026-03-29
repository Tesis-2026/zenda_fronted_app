import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../auth/auth_controller.dart';

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
          const SnackBar(content: Text('Could not save changes. Check your connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign out'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _confirmLogout,
              tooltip: 'Sign out',
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_profileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) => _isEditing ? _buildEditView(user) : _buildReadView(user),
      ),
    );
  }

  Widget _buildReadView(User user) {
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
        _infoTile('Age', user.age?.toString() ?? 'Not set'),
        _infoTile('University', user.university ?? 'Not set'),
        _infoTile('Currency', user.currency),
        _infoTile('Income type', user.incomeType?.name ?? 'Not set'),
        _infoTile('Monthly income', user.averageMonthlyIncome != null ? 'S/ ${user.averageMonthlyIncome!.toStringAsFixed(2)}' : 'Not set'),
        _infoTile('Financial literacy', user.financialLiteracyLevel?.name ?? 'Not set'),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => _startEdit(user),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit profile'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF34D399),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _universityController,
          decoration: InputDecoration(
            labelText: 'University',
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
                child: const Text('Cancel'),
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
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
