import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _ageController = TextEditingController();
  final _universityController = TextEditingController();
  final _incomeController = TextEditingController();
  IncomeType? _selectedIncomeType;
  bool _saving = false;

  static const _green = Color(0xFF34D399);

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _universityController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final age = int.tryParse(_ageController.text.trim());
      final income = double.tryParse(_incomeController.text.trim());
      final university = _universityController.text.trim().isEmpty
          ? null
          : _universityController.text.trim();

      await UserApiService().updateProfile(
        age: age,
        university: university,
        incomeType: _selectedIncomeType,
        averageMonthlyIncome: income,
        profileCompleted: true,
      );

      if (mounted) {
        ref.invalidate(authNotifierProvider);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile. Continuing anyway.')),
        );
        context.go('/dashboard');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip() async {
    try {
      await UserApiService().updateProfile(profileCompleted: true);
    } catch (_) {}
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, isDark),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _AgePage(controller: _ageController, l10n: l10n, isDark: isDark),
                  _UniversityPage(controller: _universityController, l10n: l10n, isDark: isDark),
                  _IncomeTypePage(
                    selected: _selectedIncomeType,
                    onSelect: (t) => setState(() => _selectedIncomeType = t),
                    l10n: l10n,
                    isDark: isDark,
                  ),
                  _MonthlyIncomePage(controller: _incomeController, l10n: l10n, isDark: isDark),
                  _CompletePage(l10n: l10n, isDark: isDark),
                ],
              ),
            ),
            if (_page < 4) _buildFooter(l10n, isDark),
            if (_page == 4) _buildCompleteFooter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
    if (_page == 4) return const SizedBox.shrink();
    final onSurface = isDark ? Colors.white : const Color(0xFF1F2937);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(4, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page >= i ? _green : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              TextButton(
                onPressed: _skip,
                child: Text(l10n.profileSetupSkip, style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.profileSetupTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.profileSetupSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
    final isLast = _page == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _saving ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  isLast ? l10n.profileSetupSave : l10n.profileSetupNext,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildCompleteFooter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: () => context.go('/dashboard'),
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            l10n.profileSetupGoToDashboard,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _AgePage extends StatelessWidget {
  const _AgePage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupAge,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.profileSetupAgeHint,
              prefixIcon: const Icon(Icons.cake_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UniversityPage extends StatelessWidget {
  const _UniversityPage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupUniversity,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.profileSetupUniversityHint,
              prefixIcon: const Icon(Icons.school_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeTypePage extends StatelessWidget {
  const _IncomeTypePage({
    required this.selected,
    required this.onSelect,
    required this.l10n,
    required this.isDark,
  });
  final IncomeType? selected;
  final void Function(IncomeType) onSelect;
  final AppLocalizations l10n;
  final bool isDark;

  String _labelFor(IncomeType t, AppLocalizations l10n) => switch (t) {
        IncomeType.none => l10n.incomeTypeNone,
        IncomeType.partTime => l10n.incomeTypePartTime,
        IncomeType.fullTime => l10n.incomeTypeFullTime,
        IncomeType.freelance => l10n.incomeTypeFreelance,
        IncomeType.allowance => l10n.incomeTypeAllowance,
      };

  IconData _iconFor(IncomeType t) => switch (t) {
        IncomeType.none => Icons.do_not_disturb_outlined,
        IncomeType.partTime => Icons.access_time_outlined,
        IncomeType.fullTime => Icons.work_outline,
        IncomeType.freelance => Icons.laptop_outlined,
        IncomeType.allowance => Icons.family_restroom_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupIncomeType,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...IncomeType.values.map((t) {
            final isSelected = selected == t;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => onSelect(t),
                leading: Icon(_iconFor(t), color: isSelected ? const Color(0xFF34D399) : Colors.grey),
                title: Text(_labelFor(t, l10n)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399))
                    : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: isSelected
                    ? const Color(0xFF34D399).withOpacity(0.1)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MonthlyIncomePage extends StatelessWidget {
  const _MonthlyIncomePage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupMonthlyIncome,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.profileSetupMonthlyIncomeHint,
              prefixIcon: const Icon(Icons.attach_money_outlined),
              prefixText: 'S/ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  const _CompletePage({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.profileSetupCompleteTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.profileSetupCompleteBody,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
