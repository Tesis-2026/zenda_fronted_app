import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/app_toast.dart';
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
  // Celebration screen runs OUTSIDE the PageView (as a separate
  // scaffold) so adjacent pages can't bleed through the green
  // background — mock build had the age stepper visibly leaking
  // through the welcome page.
  bool _completed = false;

  final _ageController = TextEditingController();
  final _universityController = TextEditingController();
  final _incomeController = TextEditingController();
  IncomeType? _selectedIncomeType;
  bool _saving = false;

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

      await ref.read(profileUserServiceProvider).updateProfile(
        age: age,
        university: university,
        incomeType: _selectedIncomeType,
        averageMonthlyIncome: income,
        profileCompleted: true,
      );

      if (mounted) {
        ref.invalidate(authNotifierProvider);
        // Switch to the celebration scaffold instead of advancing the
        // PageView — PageView now owns only the 4 form steps.
        setState(() => _completed = true);
      }
    } catch (_) {
      if (mounted) {
        showAppToast(context, context.l10n.profileSetupSaveError, type: ToastType.error);
        context.go('/dashboard');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    // Celebration screen renders as its own scaffold — outside the
    // PageView — so the form pages cannot leak through the green
    // background.
    if (_completed) {
      final userName =
          ref.watch(authNotifierProvider).user?.name.split(' ').first ?? '';
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _CompletePage(l10n: l10n, userName: userName)),
              _buildCompleteFooter(l10n),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, colors),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _AgePage(controller: _ageController, l10n: l10n),
                  _UniversityPage(controller: _universityController, l10n: l10n),
                  _IncomeTypePage(
                    selected: _selectedIncomeType,
                    onSelect: (t) => setState(() => _selectedIncomeType = t),
                    l10n: l10n,
                  ),
                  _MonthlyIncomePage(controller: _incomeController, l10n: l10n),
                ],
              ),
            ),
            _buildFooter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ZendaColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.profileSetupStep(_page + 1, 4),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.profileSetupSkip,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final filled = i <= _page;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.primary : colors.fill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            _pageTitleFor(_page, l10n),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.15,
                ),
          ),
          if (_pageSubtitleFor(_page, l10n).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _pageSubtitleFor(_page, l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _pageTitleFor(int page, AppLocalizations l10n) => switch (page) {
        0 => l10n.profileSetupAge,
        1 => l10n.profileSetupUniversity,
        2 => l10n.profileSetupIncomeType,
        3 => l10n.profileSetupMonthlyIncome,
        _ => '',
      };

  String _pageSubtitleFor(int page, AppLocalizations l10n) => switch (page) {
        0 => l10n.profileSetupAgeHint,
        1 => l10n.profileSetupUniversitySubtitle,
        2 => l10n.profileSetupIncomeTypeSubtitle,
        3 => l10n.profileSetupMonthlyIncomeHint,
        _ => '',
      };

  Widget _buildFooter(AppLocalizations l10n) {
    final isLast = _page == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _saving ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  isLast ? l10n.profileSetupSave : l10n.profileSetupNext,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildCompleteFooter(AppLocalizations l10n) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: () => context.go('/dashboard'),
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
  const _AgePage({required this.controller, required this.l10n});
  final TextEditingController controller;
  final AppLocalizations l10n;

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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(icon: Icons.remove_rounded, onTap: () => _adjust(-1), filled: false),
            const SizedBox(width: 32),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_age',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontSize: 64,
                      ),
                ),
                Text(
                  l10n.profileSetupAgeStepperLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(width: 32),
            _StepperButton(icon: Icons.add_rounded, onTap: () => _adjust(1), filled: true),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.primary : colors.fill,
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : context.colors.textMuted,
          size: 22,
        ),
      ),
    );
  }
}

class _UniversityPage extends StatelessWidget {
  const _UniversityPage({required this.controller, required this.l10n});
  final TextEditingController controller;
  final AppLocalizations l10n;

  static const _popular = [
    ('UPC', 'Universidad Peruana de Ciencias Aplicadas'),
    ('PUCP', 'Pontificia Universidad Católica del Perú'),
    ('UNMSM', 'Universidad Nacional Mayor de San Marcos'),
    ('UL', 'Universidad de Lima'),
    ('USMP', 'Universidad de San Martín de Porres'),
    ('UNFV', 'Universidad Nacional Federico Villarreal'),
    ('UNI', 'Universidad Nacional de Ingeniería'),
    ('UTEC', 'Universidad de Tecnología e Ingeniería'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.profileSetupUniversityHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profileSetupPopularUniversities,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _popular.length,
              itemBuilder: (context, index) {
                final (abbr, name) = _popular[index];
                return GestureDetector(
                  onTap: () => controller.text = abbr,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      '$abbr — $name',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                );
              },
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
  });
  final IncomeType? selected;
  final void Function(IncomeType) onSelect;
  final AppLocalizations l10n;

  String _labelFor(IncomeType t, AppLocalizations l10n) => switch (t) {
        IncomeType.scholarship => l10n.incomeTypeScholarship,
        IncomeType.partTime => l10n.incomeTypePartTime,
        IncomeType.family => l10n.incomeTypeFamily,
        IncomeType.mixed => l10n.incomeTypeMixed,
      };

  String _subtitleFor(IncomeType t, AppLocalizations l10n) => switch (t) {
        IncomeType.scholarship => l10n.incomeTypeScholarshipSub,
        IncomeType.partTime => l10n.incomeTypePartTimeSub,
        IncomeType.family => l10n.incomeTypeFamilySub,
        IncomeType.mixed => l10n.incomeTypeMixedSub,
      };

  IconData _iconFor(IncomeType t) => switch (t) {
        IncomeType.scholarship => Icons.school_outlined,
        IncomeType.partTime => Icons.work_outline_rounded,
        IncomeType.family => Icons.people_outline_rounded,
        IncomeType.mixed => Icons.shuffle_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...IncomeType.values.map((t) {
            final isSelected = selected == t;
            return GestureDetector(
              onTap: () => onSelect(t),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : colors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(t),
                      color: isSelected ? AppColors.primary : colors.textMuted,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labelFor(t, l10n),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected ? AppColors.primary : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitleFor(t, l10n),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MonthlyIncomePage extends StatefulWidget {
  const _MonthlyIncomePage({required this.controller, required this.l10n});
  final TextEditingController controller;
  final AppLocalizations l10n;

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
    final colors = context.colors;
    final displayVal = double.tryParse(widget.controller.text.trim()) ?? 0.0;
    final displayText = displayVal == 0.0 ? '0' : _formatNumber(displayVal.toStringAsFixed(0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                const Text(
                  'S/',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontSize: 56,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.profileSetupMonthlyIncomePerMonth,
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _quickValues.map((v) {
              final isSelected = _selected == v;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _pickQuick(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : colors.border,
                      ),
                    ),
                    child: Text(
                      _formatQuick(v),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? Colors.white : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String raw) {
    final n = int.tryParse(raw);
    if (n == null) return raw;
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class _CompletePage extends StatelessWidget {
  const _CompletePage({required this.l10n, required this.userName});
  final AppLocalizations l10n;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final title = userName.isNotEmpty
        ? l10n.profileSetupCompleteTitleNamed(userName)
        : l10n.profileSetupCompleteTitle;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(
                    Icons.celebration_outlined,
                    size: 48,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFF1F2937),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileSetupComplete40pct,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.profileSetupCompleteImproves,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
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
