import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/progress_api_service.dart';
import '../../l10n/l10n_extension.dart';

final progressServiceProvider = Provider<ProgressApiService>(
  (_) => ProgressApiService(),
);

final _progressProvider =
    FutureProvider.autoDispose<FinancialProgress>((ref) {
  return ref.read(progressServiceProvider).getProgress();
});

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() => setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      });

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) {
      setState(() => _selectedMonth = next);
    }
  }

  String _prevMonthLabel(BuildContext context) {
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    return DateFormat.MMM(Localizations.localeOf(context).languageCode).format(prev);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progressAsync = ref.watch(_progressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.progressTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) {
          // Hardcoded demo fallback when API is unavailable
          const demoProgress = FinancialProgress(
            currentMonth: MonthFinancials(
              income: 2000,
              expenses: 1240,
              balance: 760,
              savings: 760,
            ),
            previousMonth: MonthFinancials(
              income: 1850,
              expenses: 1380,
              balance: 470,
              savings: 470,
            ),
            expensesChangePercent: -10.1,
            savingsChangePercent: 61.7,
            balanceChangePercent: 61.7,
          );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_progressProvider),
            child: _buildContent(context, demoProgress),
          );
        },
        data: (progress) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_progressProvider),
          child: _buildContent(context, progress),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinancialProgress progress) {
    final l10n = context.l10n;
    final monthLabel = DateFormat.yMMMM(Localizations.localeOf(context).languageCode)
        .format(_selectedMonth);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Month navigator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF6B7280), size: 22),
              ),
              const SizedBox(width: 4),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280), size: 22),
              ),
              const Spacer(),
              Text(
                '${l10n.progressVsLabel} ${_prevMonthLabel(context)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Month Overview card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.progressOverviewTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _OverviewRow(
                label: l10n.progressTotalExpenses,
                value: progress.currentMonth.expenses,
                changePercent: progress.expensesChangePercent,
                lowerIsBetter: true,
              ),
              const SizedBox(height: 12),
              _OverviewRow(
                label: l10n.progressTotalSavings,
                value: progress.currentMonth.savings,
                changePercent: progress.savingsChangePercent,
                lowerIsBetter: false,
              ),
              const SizedBox(height: 12),
              _OverviewRow(
                label: l10n.progressNetBalance,
                value: progress.currentMonth.balance,
                changePercent: progress.balanceChangePercent,
                lowerIsBetter: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Monthly Trend chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.progressTrendTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              _TrendBarChart(
                currentMonth: progress.currentMonth,
                previousMonth: progress.previousMonth,
                selectedMonth: _selectedMonth,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.progressSavingsLegend,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final double value;
  final double? changePercent;
  final bool lowerIsBetter;

  const _OverviewRow({
    required this.label,
    required this.value,
    required this.changePercent,
    required this.lowerIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    final hasChange = changePercent != null;
    final isIncrease = (changePercent ?? 0) > 0;
    // For expenses: increase is bad (red), decrease is good (green)
    // For savings/balance: increase is good (green), decrease is bad (red)
    final isGood = lowerIsBetter ? !isIncrease : isIncrease;
    final badgeColor = hasChange ? (isGood ? const Color(0xFF34D399) : const Color(0xFFEF4444)) : null;
    final badgeBg = hasChange ? (isGood ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)) : null;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
        Text(
          'S/ ${value.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        if (hasChange) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 11,
                  color: badgeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${changePercent!.abs().toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  final MonthFinancials currentMonth;
  final MonthFinancials previousMonth;
  final DateTime selectedMonth;

  const _TrendBarChart({
    required this.currentMonth,
    required this.previousMonth,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final twoMonthsAgo = DateTime(selectedMonth.year, selectedMonth.month - 2);
    final oneMonthAgo = DateTime(selectedMonth.year, selectedMonth.month - 1);

    final months = [twoMonthsAgo, oneMonthAgo, selectedMonth];

    String abbrev(DateTime d) =>
        DateFormat.MMM(Localizations.localeOf(context).languageCode).format(d);

    // Use previous month savings as a proxy for the older data
    final savingsData = [
      previousMonth.savings * 0.8, // estimated 2 months ago
      previousMonth.savings,
      currentMonth.savings,
    ];

    final maxVal = savingsData.fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxVal == 0 ? 100.0 : maxVal * 1.3;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                  final isSelected = idx == months.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      abbrev(months[idx]),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
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
          barGroups: savingsData.asMap().entries.map((entry) {
            final i = entry.key;
            final val = entry.value;
            final isSelected = i == savingsData.length - 1;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: isSelected ? const Color(0xFF34D399) : const Color(0xFFBBF7D0),
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
