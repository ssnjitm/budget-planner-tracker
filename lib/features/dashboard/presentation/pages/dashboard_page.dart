import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/money.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../router/route_names.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../transactions/domain/entities/category.dart';
import '../../../transactions/presentation/providers/account_providers.dart';
import '../../../transactions/presentation/providers/category_providers.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final budgetProgress = ref.watch(budgetProgressProvider);
    final categories = ref.watch(categoryProvider).items;
    final accounts = ref.watch(accountProvider).items;
    final currency = ref.watch(currencyCodeProvider);

    final categoryById = {for (final Category c in categories) c.id: c};
    final accountById = {for (final a in accounts) a.id: a.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          8,
          AppDimensions.pagePadding,
          96,
        ),
        children: [
          _NetWorthCard(summary: summary, currency: currency),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.south_rounded,
                  label: 'Income',
                  amount: Money.fromMinor(
                    summary.incomeMinor,
                    currency,
                  ).format(),
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.north_rounded,
                  label: 'Expenses',
                  amount: Money.fromMinor(
                    summary.expenseMinor,
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
                child: _MetricCard(
                  icon: Icons.calculate_outlined,
                  label: 'Daily avg.',
                  amount: Money.fromMinor(
                    summary.dailyAverageMinor,
                    currency,
                  ).format(),
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.savings_outlined,
                  label: 'Saved',
                  amount: Money.fromMinor(
                    summary.savedMinor,
                    currency,
                  ).format(),
                  color: AppColors.goal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          _SectionHeading(
            title: 'Budget usage',
            action: 'Manage',
            onAction: () => context.go(RouteNames.budgets),
          ),
          const SizedBox(height: 12),
          if (budgetProgress.isEmpty)
            const _EmptyCard(
              icon: Icons.pie_chart_outline_rounded,
              title: 'Your budgets will show here',
              description: 'Create a monthly budget to track your spending.',
            )
          else
            for (final progress in budgetProgress.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                progress.categoryName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${(progress.ratio * 100).round()}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress.ratio,
                            minHeight: 6,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            color: progress.remainingMinor < 0
                                ? AppColors.expense
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          _SectionHeading(
            title: 'Recent activity',
            action: 'See all',
            onAction: () => context.go(RouteNames.transactions),
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const _EmptyCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'No activity yet',
              description: 'Add a transaction and we will show it here.',
              iconColor: AppColors.warning,
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    Builder(
                      builder: (context) {
                        final transaction = recent[i];
                        final category = transaction.categoryId == null
                            ? null
                            : categoryById[transaction.categoryId];
                        final accountName =
                            accountById[transaction.accountId] ?? 'Account';
                        return TransactionTile(
                          transaction: transaction,
                          title: category?.name ?? 'Transfer',
                          subtitle: accountName,
                          iconKey: category?.iconKey,
                          currency: currency,
                          onTap: () => context.push(
                            RouteNames.editTransaction(transaction.id),
                          ),
                        );
                      },
                    ),
                    if (i != recent.length - 1)
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

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({required this.summary, required this.currency});

  final DashboardSummary summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF287456)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net worth',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Money.fromMinor(summary.netWorthMinor, currency).format(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.white, fontSize: 32),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'This month',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    Money.fromMinor(summary.netMinor, currency).format(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget usage',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              Text(
                '${(summary.budgetRatio * 100).round()}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: summary.budgetRatio,
              minHeight: 6,
              backgroundColor: const Color(0x55FFFFFF),
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        if (action case final action?)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
