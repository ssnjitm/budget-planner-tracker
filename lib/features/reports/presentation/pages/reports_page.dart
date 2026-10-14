import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/category_icons.dart';
import '../../../../core/common/widgets/app_empty_state.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedReportMonthProvider);
    final range = ref.watch(reportRangeProvider);
    final series = ref.watch(monthlySeriesProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final currency = ref.watch(currencyCodeProvider);
    final isLoading =
        ref.watch(transactionProvider).status == TransactionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          8,
          AppDimensions.pagePadding,
          32,
        ),
        children: [
          _MonthSelector(
            month: month,
            onPrevious: () =>
                ref.read(selectedReportMonthProvider.notifier).state = DateTime(
                  month.year,
                  month.month - 1,
                ),
            onNext: () => ref.read(selectedReportMonthProvider.notifier).state =
                DateTime(month.year, month.month + 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Income',
                  amount: Money.fromMinor(range.incomeMinor, currency).format(),
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  label: 'Expenses',
                  amount: Money.fromMinor(
                    range.expenseMinor,
                    currency,
                  ).format(),
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Net',
                  amount: Money.fromMinor(range.netMinor, currency).format(),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  label: 'Savings rate',
                  amount: '${(range.savingsRate * 100).round()}%',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          const _SectionLabel('Last 6 months'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _MonthlyChart(series: series, currency: currency),
            ),
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          const _SectionLabel('Spending by category'),
          const SizedBox(height: 12),
          if (breakdown.isEmpty)
            const Card(
              child: AppEmptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'No expenses this month',
                subtitle: 'Add an expense to see the breakdown.',
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < breakdown.length; i++) ...[
                    _BreakdownRow(
                      slice: breakdown[i],
                      total: range.expenseMinor,
                      currency: currency,
                    ),
                    if (i != breakdown.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.filledTonal(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          '${_months[month.month - 1]} ${month.year}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton.filledTonal(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.series, required this.currency});

  final List<MonthlyPoint> series;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final maxValue = series.fold<int>(
      1,
      (max, point) => [
        max,
        point.incomeMinor,
        point.expenseMinor,
      ].reduce((a, b) => a > b ? a : b),
    );

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in series)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 130,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Bar(
                            fraction: point.incomeMinor / maxValue,
                            color: AppColors.income,
                          ),
                          const SizedBox(width: 3),
                          _Bar(
                            fraction: point.expenseMinor / maxValue,
                            color: AppColors.expense,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _shortMonth(point.month),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _shortMonth(DateTime date) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[date.month - 1];
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = (fraction.clamp(0, 1).toDouble() * 120) + 2;
    return Container(
      width: 9,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.slice,
    required this.total,
    required this.currency,
  });

  final CategorySlice slice;
  final int total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : slice.totalMinor / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                CategoryIcons.resolve(slice.iconKey),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  slice.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                Money.fromMinor(slice.totalMinor, currency).format(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
