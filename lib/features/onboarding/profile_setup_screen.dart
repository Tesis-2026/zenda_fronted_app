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
          SnackBar(content: Text(context.l10n.profileSetupSaveError)),
        );
        context.go('/surveys/pre');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip() async {
    try {
      await UserApiService().updateProfile(profileCompleted: true);
    } catch (_) {
      // Non-blocking: skip still navigates forward even if the update fails
    }
    if (mounted) context.go('/surveys/pre');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _page == 4
          ? const Color(0xFF34D399)
          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
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
    return Container(
      color: const Color(0xFF34D399),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: () => context.go('/surveys/pre'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF065F46),
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

class _AgePage extends StatefulWidget {
  const _AgePage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  State<_AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<_AgePage> {
  int _age = 21;

  @override
  void initState() {
    super.initState();
    final parsed = int.tryParse(widget.controller.text.trim());
    if (parsed != null && parsed >= 16 && parsed <= 60) _age = parsed;
    widget.controller.text = _age.toString();
  }

  void _adjust(int delta) {
    final next = (_age + delta).clamp(16, 60);
    setState(() => _age = next);
    widget.controller.text = next.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupAge,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(l10n.profileSetupAgeHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 48),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _adjust(-1),
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Text(
                      '$_age',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34D399),
                          ),
                    ),
                    Text(
                      l10n.profileSetupAgeStepperLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                _StepperButton(
                  icon: Icons.add_rounded,
                  onTap: () => _adjust(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF34D399).withValues(alpha: 0.15),
          border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: const Color(0xFF34D399), size: 24),
      ),
    );
  }
}

class _UniversityPage extends StatelessWidget {
  const _UniversityPage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  static const _popular = [
    'UPC', 'PUCP', 'UNMSM', 'UL', 'USMP', 'UNFV', 'UNI', 'UTEC',
  ];

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
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.profileSetupPopularUniversities,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popular
                .map((u) => GestureDetector(
                      onTap: () => controller.text = u,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        child: Text(u,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                )),
                      ),
                    ))
                .toList(),
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
                    ? const Color(0xFF34D399).withValues(alpha: 0.1)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MonthlyIncomePage extends StatefulWidget {
  const _MonthlyIncomePage({required this.controller, required this.l10n, required this.isDark});
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  State<_MonthlyIncomePage> createState() => _MonthlyIncomePageState();
}

class _MonthlyIncomePageState extends State<_MonthlyIncomePage> {
  static const _quickValues = [500.0, 1200.0, 2000.0];
  double? _selected;

  @override
  void initState() {
    super.initState();
    final v = double.tryParse(widget.controller.text.trim());
    if (v != null && _quickValues.contains(v)) _selected = v;
  }

  void _pickQuick(double value) {
    setState(() => _selected = value);
    widget.controller.text = value.toStringAsFixed(0);
  }

  String _formatQuick(double v) {
    if (v == 500) return 'S/ 500';
    if (v == 1200) return 'S/ 1,200';
    if (v == 2000) return 'S/ 2,000';
    return 'S/ ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final isDark = widget.isDark;
    final displayVal = double.tryParse(widget.controller.text.trim()) ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupMonthlyIncome,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(l10n.profileSetupMonthlyIncomeHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'S/ ${displayVal == 0.0 ? '0' : displayVal.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF34D399),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _quickValues.map((v) {
              final isSelected = _selected == v;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _pickQuick(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF34D399)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF34D399)
                            : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      _formatQuick(v),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF1F2937)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() => _selected = null),
            decoration: InputDecoration(
              hintText: l10n.profileSetupMonthlyIncomeHint,
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
    return Container(
      width: double.infinity,
      color: const Color(0xFF34D399),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                l10n.profileSetupCompleteTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profileSetupCompleteBody,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileSetupComplete40pct,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.profileSetupCompleteImproves,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
