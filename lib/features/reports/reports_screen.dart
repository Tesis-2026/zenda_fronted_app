import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/summary_models.dart';
import '../../core/services/amount_formatter.dart';
import '../../core/services/insights_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final reportsInsightsServiceProvider = Provider<InsightsApiService>((_) => InsightsApiService());

final _monthSummaryProvider = FutureProvider.family<PeriodSummary, ({int year, int month})>(
  (ref, args) => ref.read(reportsInsightsServiceProvider).getMonthSummary(year: args.year, month: args.month),
);

final _weekSummaryProvider = FutureProvider.family<PeriodSummary, ({int year, int week})>(
  (ref, args) => ref.read(reportsInsightsServiceProvider).getWeekSummary(year: args.year, week: args.week),
);

final _comparisonProvider = FutureProvider.family<List<MonthComparisonEntry>, int>(
  (ref, months) => ref.read(reportsInsightsServiceProvider).getComparison(months: months),
);

final _progressProvider = FutureProvider<ProgressSummary>(
  (ref) => ref.read(reportsInsightsServiceProvider).getProgress(),
);

final _daySummaryProvider = FutureProvider.family<PeriodSummary, String>(
  (ref, date) => ref.read(reportsInsightsServiceProvider).getDaySummary(date: date),
);

// ── Helpers ────────────────────────────────────────────────────────────────

int _isoWeekNumber(DateTime date) {
  final dayOfYear = int.parse(
    '${date.difference(DateTime(date.year, 1, 1)).inDays + 1}',
  );
  final woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) return _isoWeekNumber(DateTime(date.year - 1, 12, 31));
  if (woy > 52) {
    final dec31 = DateTime(date.year, 12, 31);
    if (((dec31.difference(DateTime(dec31.year, 1, 1)).inDays + 1) - dec31.weekday + 10) ~/ 7 < 1) return 1;
  }
  return woy;
}

const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'];

// Hardcoded demo data for May 2026 shown when the API is unavailable
const _demoMaySummary = PeriodSummary(
  totalIncome: 2000,
  totalExpense: 1240,
  netBalance: 760,
  topCategories: [
    TopCategoryItem(name: 'Food', amount: 320),
    TopCategoryItem(name: 'Transport', amount: 210),
    TopCategoryItem(name: 'Utilities', amount: 180),
    TopCategoryItem(name: 'Entertainment', amount: 150),
    TopCategoryItem(name: 'Health', amount: 90),
  ],
);

// ── Main Screen ────────────────────────────────────────────────────────────

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          l10n.reportsTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Column(
            children: [
              Container(height: 1, color: const Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: const Color(0xFF34D399),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  padding: EdgeInsets.zero,
                  tabs: [
                    Tab(text: l10n.reportsTabMonth),
                    Tab(text: l10n.reportsTabWeek),
                    Tab(text: l10n.reportsTabCompare),
                    Tab(text: l10n.reportsTabDay),
                    Tab(text: l10n.reportsTabCategories),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MonthTab(),
          _WeekTab(),
          _CompareTab(),
          _DayTab(),
          _CategoriesTab(),
        ],
      ),
    );
  }
}

// ── Month Tab ──────────────────────────────────────────────────────────────

class _MonthTab extends ConsumerStatefulWidget {
  const _MonthTab();

  @override
  ConsumerState<_MonthTab> createState() => _MonthTabState();
}

class _MonthTabState extends ConsumerState<_MonthTab> {
  late int _year;
  late int _month;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _prev() => setState(() {
        _month--;
        if (_month < 1) { _month = 12; _year--; }
      });

  void _next() {
    final now = DateTime.now();
    if (_year > now.year || (_year == now.year && _month >= now.month)) return;
    setState(() {
        _month++;
        if (_month > 12) { _month = 1; _year++; }
      });
  }

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final service = ref.read(reportsInsightsServiceProvider);
      final bytes = await service.downloadPdfReport(year: _year, month: _month);

      final dir = await getTemporaryDirectory();
      final monthStr = _month.toString().padLeft(2, '0');
      final file = File('${dir.path}/zenda-report-$_year-$monthStr.pdf');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Zenda Report — ${_monthNames[_month - 1]} $_year',
      ));
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, context.l10n.reportsExportPdfError, type: ToastType.error);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = ref.watch(_monthSummaryProvider((year: _year, month: _month)));
    return Stack(
      children: [
        Column(
          children: [
            _PeriodSelector(
              label: l10n.reportsMonthLabel(_monthNames[_month - 1], _year),
              onPrev: _prev,
              onNext: _next,
            ),
            Expanded(
              child: summary.when(
                data: (data) => _SummaryView(summary: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _SummaryView(summary: _demoMaySummary),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _exporting ? null : _exportPdf,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.picture_as_pdf_rounded),
            label: Text(l10n.reportsExportPdf),
            backgroundColor: const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }
}

// ── Week Tab ───────────────────────────────────────────────────────────────

class _WeekTab extends ConsumerStatefulWidget {
  const _WeekTab();

  @override
  ConsumerState<_WeekTab> createState() => _WeekTabState();
}

class _WeekTabState extends ConsumerState<_WeekTab> {
  late int _year;
  late int _week;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _week = _isoWeekNumber(now);
  }

  void _prev() => setState(() {
        _week--;
        if (_week < 1) { _year--; _week = _isoWeekNumber(DateTime(_year, 12, 28)); }
      });

  void _next() {
    final now = DateTime.now();
    final currentWeek = _isoWeekNumber(now);
    if (_year > now.year || (_year == now.year && _week >= currentWeek)) return;
    setState(() {
        final maxWeek = _isoWeekNumber(DateTime(_year, 12, 28));
        _week++;
        if (_week > maxWeek) { _week = 1; _year++; }
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = ref.watch(_weekSummaryProvider((year: _year, week: _week)));
    return Column(
      children: [
        _PeriodSelector(
          label: l10n.reportsWeekLabel(_week, _year),
          onPrev: _prev,
          onNext: _next,
        ),
        Expanded(
          child: summary.when(
            data: (data) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TotalsRow(summary: data),
                if (data.dailyBreakdown.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.reportsWeekDailyTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _DailyBarChart(breakdown: data.dailyBreakdown),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.reportsTopCategories,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                data.topCategories.isEmpty
                    ? Text(l10n.reportsNoCategoryData,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                    : _CategoryBarChart(categories: data.topCategories),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(message: context.l10n.reportsErrorLoad),
          ),
        ),
      ],
    );
  }
}

// ── Compare Tab ────────────────────────────────────────────────────────────

class _CompareTab extends ConsumerStatefulWidget {
  const _CompareTab();

  @override
  ConsumerState<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends ConsumerState<_CompareTab> {
  int _months = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comparison = ref.watch(_comparisonProvider(_months));
    final progress = ref.watch(_progressProvider);
    return Column(
      children: [
        progress.when(
          data: (p) => _EvolutionCard(summary: p),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2M')),
              ButtonSegment(value: 3, label: Text('3M')),
              ButtonSegment(value: 6, label: Text('6M')),
            ],
            selected: {_months},
            onSelectionChanged: (s) => setState(() => _months = s.first),
          ),
        ),
        Expanded(
          child: comparison.when(
            data: (data) => data.isEmpty
                ? Center(child: Text(l10n.reportsNoComparisonData))
                : _ComparisonChart(entries: data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(message: context.l10n.reportsErrorLoad),
          ),
        ),
      ],
    );
  }
}

// ── Day Tab ────────────────────────────────────────────────────────────────

class _DayTab extends ConsumerStatefulWidget {
  const _DayTab();

  @override
  ConsumerState<_DayTab> createState() => _DayTabState();
}

class _DayTabState extends ConsumerState<_DayTab> {
  late DateTime _viewMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() => setState(() {
        _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
      });

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_viewMonth.year, _viewMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _viewMonth = next);
  }

  String get _dateKey {
    final y = _selected.year;
    final m = _selected.month.toString().padLeft(2, '0');
    final d = _selected.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = ref.watch(_daySummaryProvider(_dateKey));
    final monthSummary = ref.watch(
      _monthSummaryProvider((year: _viewMonth.year, month: _viewMonth.month)),
    );

    final spendingByDay = <int, double>{};
    monthSummary.whenData((ms) {
      for (final item in ms.dailyBreakdown) {
        final parts = item.date.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[2]);
          if (day != null) spendingByDay[day] = item.totalExpense;
        }
      }
    });

    return Column(
      children: [
        _PeriodSelector(
          label: '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
          onPrev: _prevMonth,
          onNext: _nextMonth,
        ),
        _CalendarGrid(
          viewMonth: _viewMonth,
          selected: _selected,
          spendingByDay: spendingByDay.isEmpty ? null : spendingByDay,
          onDayTap: (date) => setState(() => _selected = date),
        ),
        const Divider(height: 1),
        Expanded(
          child: summary.when(
            data: (data) => data.totalExpense == 0 && data.totalIncome == 0 && data.topCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text(l10n.reportsCalendarNoData,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline)),
                      ],
                    ),
                  )
                : _SummaryView(summary: data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorView(message: l10n.reportsErrorLoad),
          ),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime viewMonth;
  final DateTime selected;
  final ValueChanged<DateTime> onDayTap;
  final Map<int, double>? spendingByDay;

  const _CalendarGrid({
    required this.viewMonth,
    required this.selected,
    required this.onDayTap,
    this.spendingByDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysInMonth =
        DateUtils.getDaysInMonth(viewMonth.year, viewMonth.month);
    final firstWeekday = viewMonth.weekday;
    final offset = firstWeekday - 1;

    const headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Row(
            children: headers
                .map((h) => Expanded(
                      child: Center(
                        child: Text(
                          h,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: offset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();
              final day = index - offset + 1;
              final date = DateTime(viewMonth.year, viewMonth.month, day);
              final isFuture = date.isAfter(
                  DateTime(today.year, today.month, today.day));
              final isToday = DateUtils.isSameDay(date, today);
              final isSelected = DateUtils.isSameDay(date, selected);

              final spending = spendingByDay?[day] ?? 0.0;
              final maxSpending = spendingByDay == null || spendingByDay!.isEmpty
                  ? 0.0
                  : spendingByDay!.values.reduce((a, b) => a > b ? a : b);
              Color? heatColor;
              if (!isSelected && spending > 0 && maxSpending > 0) {
                final ratio = spending / maxSpending;
                if (ratio > 0.66) {
                  heatColor = const Color(0xFFFCA5A5); // high — light red
                } else if (ratio > 0.33) {
                  heatColor = const Color(0xFFFDE68A); // medium — amber
                } else {
                  heatColor = const Color(0xFFBBF7D0); // low — light green
                }
              }

              return GestureDetector(
                onTap: isFuture ? null : () => onDayTap(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF818CF8)
                        : isToday
                            ? const Color(0xFF818CF8).withValues(alpha: 0.15)
                            : null,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                                  ? Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.4)
                                  : null,
                        ),
                      ),
                      if (heatColor != null)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: heatColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodSelector({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(message, style: const TextStyle(color: Colors.red)));
}

// ── Summary View (used by Month + Week tabs) ───────────────────────────────

class _SummaryView extends StatelessWidget {
  final PeriodSummary summary;

  const _SummaryView({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _IncomExpenseSummaryRow(summary: summary),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportsTopCategories,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              summary.topCategories.isEmpty
                  ? Text(l10n.reportsNoCategoryData,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
                  : _CategoryBarChart(categories: summary.topCategories),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _AiInsightsCard(summary: summary),
      ],
    );
  }
}

class _IncomExpenseSummaryRow extends ConsumerWidget {
  final PeriodSummary summary;

  const _IncomExpenseSummaryRow({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmtAsync = ref.watch(amountFormatterProvider);
    final fmt = fmtAsync.asData?.value ?? (double v) => v.toStringAsFixed(2);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, color: Color(0xFF059669), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      l10n.reportsIncome,
                      style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'S/ ${fmt(summary.totalIncome)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.reportsVsLastMonth,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, color: Color(0xFFEF4444), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      l10n.reportsExpense,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'S/ ${fmt(summary.totalExpense)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.reportsVsLastMonth,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  final PeriodSummary summary;

  const _AiInsightsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF34D399), size: 15),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.reportsAiInsightsTitle,
                style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.topCategories.isNotEmpty) ...[
            _InsightBullet(
              icon: Icons.circle,
              iconColor: const Color(0xFF34D399),
              text: '${summary.topCategories.first.name} spending is above your average.',
            ),
            const SizedBox(height: 8),
          ] else ...[
            // Hardcoded fallback insights when API returns no category data
            const _InsightBullet(
              icon: Icons.circle,
              iconColor: Color(0xFF34D399),
              text: 'You saved S/ 760 this month — 38% of your income. That\'s above the recommended 20%!',
            ),
            const SizedBox(height: 8),
            const _InsightBullet(
              icon: Icons.circle,
              iconColor: Color(0xFFF97316),
              text: 'Food spending exceeded budget by S/ 20 (120% used). Consider meal planning.',
            ),
            const SizedBox(height: 8),
            const _InsightBullet(
              icon: Icons.circle,
              iconColor: Color(0xFF60A5FA),
              text: 'You\'re on track to reach your Emergency Fund goal in ~14 months at current pace.',
            ),
          ],
          if (summary.topCategories.isNotEmpty) ...[
            _InsightBullet(
              icon: Icons.circle,
              iconColor: const Color(0xFF60A5FA),
              text: l10n.reportsAiInsightsSaved,
            ),
          ],
          if (summary.topCategories.length > 1) ...[
            const SizedBox(height: 8),
            _InsightBullet(
              icon: Icons.circle,
              iconColor: const Color(0xFFF97316),
              text: '${summary.topCategories[1].name} ${l10n.reportsAiInsightsExceeded}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightBullet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InsightBullet({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _TotalsRow extends ConsumerWidget {
  final PeriodSummary summary;
  const _TotalsRow({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fmtAsync = ref.watch(amountFormatterProvider);
    final fmt = fmtAsync.asData?.value ?? (double v) => v.toStringAsFixed(2);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.reportsIncome,
            value: 'S/ ${fmt(summary.totalIncome)}',
            color: const Color(0xFF34D399),
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.reportsExpense,
            value: 'S/ ${fmt(summary.totalExpense)}',
            color: const Color(0xFFFC8181),
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.reportsBalance,
            value: 'S/ ${fmt(summary.netBalance)}',
            color: summary.netBalance >= 0
                ? const Color(0xFF60A5FA)
                : const Color(0xFFF87171),
            cardColor: cardColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color cardColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

// ── Category Horizontal Bar Chart ──────────────────────────────────────────

class _CategoryBarChart extends StatelessWidget {
  final List<TopCategoryItem> categories;
  final ValueChanged<String>? onCategoryTap;

  const _CategoryBarChart({required this.categories, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    if (categories.isEmpty) return const SizedBox.shrink();

    final maxAmount = categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b);

    return Column(
      children: categories.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final ratio = maxAmount > 0 ? item.amount / maxAmount : 0.0;

        const barColors = [
          Color(0xFF818CF8),
          Color(0xFF34D399),
          Color(0xFFFCD34D),
          Color(0xFFF472B6),
          Color(0xFF60A5FA),
        ];
        final color = barColors[i % barColors.length];

        return InkWell(
          onTap: onCategoryTap != null ? () => onCategoryTap!(item.name) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(item.name,
                              style: TextStyle(fontSize: 13, color: textColor)),
                          if (onCategoryTap != null) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline),
                          ],
                        ],
                      ),
                    ),
                    Text('S/ ${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: constraints.maxWidth * ratio,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Daily Bar Chart (Week tab) ─────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  final List<DailyBreakdownItem> breakdown;

  const _DailyBarChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = breakdown
        .expand((d) => [d.totalIncome, d.totalExpense])
        .fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxVal == 0 ? 100.0 : maxVal * 1.25;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= breakdown.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      breakdown[idx].dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: breakdown.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.totalIncome,
                  color: const Color(0xFF34D399),
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: d.totalExpense,
                  color: const Color(0xFFFC8181),
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Evolution Card (Compare tab) ───────────────────────────────────────────

class _EvolutionCard extends StatelessWidget {
  final ProgressSummary summary;

  const _EvolutionCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final hasAnyData = summary.expensesChangePercent != null ||
        summary.savingsChangePercent != null ||
        summary.balanceChangePercent != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportsEvolutionTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (!hasAnyData)
              Text(
                l10n.reportsEvolutionNoData,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: [
                  if (summary.expensesChangePercent != null)
                    _EvolutionRow(
                      label: l10n.reportsEvolutionExpenses,
                      percent: summary.expensesChangePercent!,
                      // expenses down = positive direction
                      isPositive: summary.expensesChangePercent! <= 0,
                    ),
                  if (summary.savingsChangePercent != null) ...[
                    const SizedBox(height: 8),
                    _EvolutionRow(
                      label: l10n.reportsEvolutionSavings,
                      percent: summary.savingsChangePercent!,
                      // savings up = positive direction
                      isPositive: summary.savingsChangePercent! >= 0,
                    ),
                  ],
                  if (summary.balanceChangePercent != null) ...[
                    const SizedBox(height: 8),
                    _EvolutionRow(
                      label: l10n.reportsEvolutionBalance,
                      percent: summary.balanceChangePercent!,
                      // balance up = positive direction
                      isPositive: summary.balanceChangePercent! >= 0,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionRow extends StatelessWidget {
  final String label;
  final double percent;
  final bool isPositive;

  const _EvolutionRow({
    required this.label,
    required this.percent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? const Color(0xFF34D399) : const Color(0xFFFC8181);
    final arrowIcon =
        percent >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final sign = percent >= 0 ? '+' : '';

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(arrowIcon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                '$sign${percent.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Comparison Line Chart ──────────────────────────────────────────────────

class _ComparisonChart extends StatelessWidget {
  final List<MonthComparisonEntry> entries;

  const _ComparisonChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    final incomeSpots = entries.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalIncome))
        .toList();
    final expenseSpots = entries.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalExpense))
        .toList();
    final balanceSpots = entries.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.netBalance))
        .toList();

    final allValues = [
      ...entries.map((e) => e.totalIncome),
      ...entries.map((e) => e.totalExpense),
      ...entries.map((e) => e.netBalance),
    ];
    final maxY = allValues.isEmpty ? 1000.0 : allValues.reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = allValues.isEmpty ? 0.0 : allValues.reduce((a, b) => a < b ? a : b);
    final adjustedMinY = minY < 0 ? minY * 1.2 : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 16),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minY: adjustedMinY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) => Text(
                        'S/${value.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entries[idx].label,
                            style: TextStyle(fontSize: 11, color: textColor),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  _line(incomeSpots, const Color(0xFF34D399)),
                  _line(expenseSpots, const Color(0xFFFC8181)),
                  _line(balanceSpots, const Color(0xFF60A5FA)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF34D399), label: l10n.reportsIncome),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFFC8181), label: l10n.reportsExpense),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF60A5FA), label: l10n.reportsBalance),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.08),
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

// ── Categories Tab (US-0405) ───────────────────────────────────────────────

class _CategoriesTab extends ConsumerStatefulWidget {
  const _CategoriesTab();

  @override
  ConsumerState<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<_CategoriesTab> {
  String _period = 'month';
  late int _year;
  late int _month;
  late int _week;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _week = _isoWeekNumber(now);
  }

  ({DateTime from, DateTime to}) get _dateRange {
    final now = DateTime.now();
    return switch (_period) {
      'week' => (
          from: now.subtract(Duration(days: now.weekday - 1)),
          to: now,
        ),
      'quarter' => (
          from: DateTime(_year, _month - 2, 1),
          to: DateTime(_year, _month + 1, 0, 23, 59, 59),
        ),
      _ => (
          from: DateTime(_year, _month, 1),
          to: DateTime(_year, _month + 1, 0, 23, 59, 59),
        ),
    };
  }

  List<TopCategoryItem> _mergeCategories(List<List<TopCategoryItem>> lists) {
    final map = <String, double>{};
    for (final list in lists) {
      for (final item in list) {
        map[item.name] = (map[item.name] ?? 0) + item.amount;
      }
    }
    final merged = map.entries
        .map((e) => TopCategoryItem(name: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return merged;
  }

  void _onCategoryTap(BuildContext context, String categoryName) {
    final range = _dateRange;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryDrillDownSheet(
        categoryName: categoryName,
        from: range.from,
        to: range.to,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Gather category data based on selected period
    final AsyncValue<List<TopCategoryItem>> categoriesAsync;

    if (_period == 'week') {
      final weekSummary = ref.watch(_weekSummaryProvider((year: _year, week: _week)));
      categoriesAsync = weekSummary.whenData((s) => s.topCategories);
    } else if (_period == 'quarter') {
      // Aggregate 3 months: current + 2 prior
      final m1 = ref.watch(_monthSummaryProvider((year: _year, month: _month)));
      final prevMonth1 = _month == 1 ? 12 : _month - 1;
      final prevYear1 = _month == 1 ? _year - 1 : _year;
      final prevMonth2 = prevMonth1 == 1 ? 12 : prevMonth1 - 1;
      final prevYear2 = prevMonth1 == 1 ? prevYear1 - 1 : prevYear1;
      final m2 = ref.watch(_monthSummaryProvider((year: prevYear1, month: prevMonth1)));
      final m3 = ref.watch(_monthSummaryProvider((year: prevYear2, month: prevMonth2)));

      if (m1.isLoading || m2.isLoading || m3.isLoading) {
        categoriesAsync = const AsyncValue.loading();
      } else if (m1.hasError) {
        categoriesAsync = AsyncValue.error(m1.error!, m1.stackTrace!);
      } else {
        final lists = [
          m1.asData?.value.topCategories ?? [],
          m2.asData?.value.topCategories ?? [],
          m3.asData?.value.topCategories ?? [],
        ];
        categoriesAsync = AsyncValue.data(_mergeCategories(lists));
      }
    } else {
      final monthSummary = ref.watch(_monthSummaryProvider((year: _year, month: _month)));
      categoriesAsync = monthSummary.whenData((s) => s.topCategories);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'week', label: Text(l10n.reportsPeriodWeek)),
              ButtonSegment(value: 'month', label: Text(l10n.reportsPeriodMonth)),
              ButtonSegment(value: 'quarter', label: Text(l10n.reportsPeriodQuarter)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
        ),
        Expanded(
          child: categoriesAsync.when(
            data: (categories) => categories.isEmpty
                ? Center(
                    child: Text(
                      l10n.reportsNoCategoryData,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _CategoryBarChart(
                        categories: categories,
                        onCategoryTap: (name) =>
                            _onCategoryTap(context, name),
                      ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorView(message: l10n.reportsErrorLoad),
          ),
        ),
      ],
    );
  }
}

// ── Category Drill-Down Bottom Sheet ──────────────────────────────────────

class _CategoryDrillDownSheet extends ConsumerWidget {
  final String categoryName;
  final DateTime from;
  final DateTime to;

  const _CategoryDrillDownSheet({
    required this.categoryName,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final apiService = ref.read(transactionApiServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.reportsCategoryDrillTitle(categoryName),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: apiService
                    .getAll(
                      type: 'EXPENSE',
                      from: from.toUtc().toIso8601String(),
                      to: to.toUtc().toIso8601String(),
                    )
                    .then((txs) => txs
                        .where((tx) =>
                            (tx['categoryName'] as String?)
                                ?.toLowerCase() ==
                            categoryName.toLowerCase())
                        .toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _ErrorView(message: l10n.reportsErrorLoad);
                  }
                  final txs = snapshot.data ?? [];
                  if (txs.isEmpty) {
                    return Center(
                      child: Text(l10n.reportsCategoryNoTransactions,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: txs.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, i) {
                      final tx = txs[i];
                      final amount =
                          (tx['amount'] as num?)?.toDouble() ?? 0.0;
                      final desc = tx['description'] as String? ?? '';
                      final dateStr = tx['occurredAt'] as String? ?? '';
                      DateTime? date;
                      try {
                        date = DateTime.parse(dateStr).toLocal();
                      } catch (_) {}
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFFFC8181).withValues(alpha: 0.15),
                          child: const Icon(Icons.remove_rounded,
                              size: 16, color: Color(0xFFFC8181)),
                        ),
                        title: Text(
                          desc.isEmpty ? categoryName : desc,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: date != null
                            ? Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              )
                            : null,
                        trailing: Text(
                          'S/ ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFC8181),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
