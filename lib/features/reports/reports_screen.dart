import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/summary_models.dart';
import '../../core/services/insights_api_service.dart';
import '../../l10n/l10n_extension.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final _insightsServiceProvider = Provider<InsightsApiService>((_) => InsightsApiService());

final _monthSummaryProvider = FutureProvider.family<PeriodSummary, ({int year, int month})>(
  (ref, args) => ref.read(_insightsServiceProvider).getMonthSummary(year: args.year, month: args.month),
);

final _weekSummaryProvider = FutureProvider.family<PeriodSummary, ({int year, int week})>(
  (ref, args) => ref.read(_insightsServiceProvider).getWeekSummary(year: args.year, week: args.week),
);

final _comparisonProvider = FutureProvider.family<List<MonthComparisonEntry>, int>(
  (ref, months) => ref.read(_insightsServiceProvider).getComparison(months: months),
);

final _daySummaryProvider = FutureProvider.family<PeriodSummary, String>(
  (ref, date) => ref.read(_insightsServiceProvider).getDaySummary(date: date),
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
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.reportsTabMonth),
            Tab(text: l10n.reportsTabWeek),
            Tab(text: l10n.reportsTabCompare),
            Tab(text: l10n.reportsTabDay),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MonthTab(),
          _WeekTab(),
          _CompareTab(),
          _DayTab(),
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
      final service = ref.read(_insightsServiceProvider);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportsExportPdfError)),
      );
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
                error: (e, _) => _ErrorView(message: context.l10n.reportsErrorLoad),
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
            data: (data) => _SummaryView(summary: data),
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
    return Column(
      children: [
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

  const _CalendarGrid({
    required this.viewMonth,
    required this.selected,
    required this.onDayTap,
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
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
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
        _TotalsRow(summary: summary),
        const SizedBox(height: 24),
        Text(l10n.reportsTopCategories,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        summary.topCategories.isEmpty
            ? Text(l10n.reportsNoCategoryData,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            : _CategoryBarChart(categories: summary.topCategories),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final PeriodSummary summary;
  const _TotalsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.reportsIncome,
            value: 'S/ ${summary.totalIncome.toStringAsFixed(2)}',
            color: const Color(0xFF34D399),
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.reportsExpense,
            value: 'S/ ${summary.totalExpense.toStringAsFixed(2)}',
            color: const Color(0xFFFC8181),
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.reportsBalance,
            value: 'S/ ${summary.netBalance.toStringAsFixed(2)}',
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

  const _CategoryBarChart({required this.categories});

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

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name,
                      style: TextStyle(fontSize: 13, color: textColor)),
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
        );
      }).toList(),
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
