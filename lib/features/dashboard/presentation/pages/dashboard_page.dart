import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                12,
                AppDimensions.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push(RouteNames.addTransaction),
                    icon: const Icon(Icons.add_circle, size: 20),
                    label: const Text('Add transaction'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                12,
                AppDimensions.pagePadding,
                24,
              ),
              sliver: SliverList.list(
                children: [
                  Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  const _MonthlySummaryCard(),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.south_rounded,
                          label: 'Income',
                          amount: 'NPR 0',
                          color: AppColors.income,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.north_rounded,
                          label: 'Expenses',
                          amount: 'NPR 0',
                          color: AppColors.expense,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Daily avg.',
                          amount: 'NPR 0',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  const _SectionHeading(title: 'Budget usage', action: 'View all'),
                  const SizedBox(height: 12),
                  const _EmptyCard(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'Your budgets will show here',
                    description: 'Create a monthly budget to track your spending.',
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  const _SectionHeading(title: 'Smart insights'),
                  const SizedBox(height: 12),
                  const _EmptyCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Insights start with your activity',
                    description: 'Add a transaction and we’ll help you spot patterns.',
                    iconColor: AppColors.warning,
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

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

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
                      'This month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'NPR 0',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Set a budget',
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const Text('0%', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: Color(0x55FFFFFF),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
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
  const _SectionHeading({required this.title, this.action});

  final String title;
  final String? action;

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
          Text(
            action,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
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
                  Text(description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
