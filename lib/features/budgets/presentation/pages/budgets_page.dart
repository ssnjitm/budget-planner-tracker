import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/app_error_widget.dart';
import '../../../../core/common/widgets/confirm_dialog.dart';
import '../../../../core/common/widgets/shimmer_placeholders.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../router/route_names.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/budget_providers.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);
    final progress = ref.watch(budgetProgressProvider);
    final currency = ref.watch(currencyCodeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addBudget),
        icon: const Icon(Icons.add),
        label: const Text('Add budget'),
      ),
      body: switch (state.status) {
        BudgetStatus.initial ||
        BudgetStatus.loading when state.items.isEmpty => const _BudgetShimmer(),
        BudgetStatus.error => AppErrorWidget(
          message: state.message ?? 'Could not load budgets',
          onRetry: () => ref.read(budgetProvider.notifier).load(),
        ),
        _ when state.items.isEmpty => const AppEmptyState(
          icon: Icons.savings_outlined,
          title: 'No budgets yet',
          subtitle: 'Set a monthly limit per category to track spending.',
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.pagePadding,
            AppDimensions.pagePadding,
            96,
          ),
          itemCount: progress.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = progress[index];
            final isOver = item.remainingMinor < 0;
            final color = isOver ? AppColors.expense : AppColors.primary;
            return Dismissible(
              key: ValueKey(item.budget.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.expense,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) => showConfirmDialog(
                context,
                title: 'Delete budget?',
                confirmLabel: 'Delete',
              ),
              onDismissed: (_) =>
                  ref.read(budgetProvider.notifier).delete(item.budget.id),
              child: InkWell(
                onTap: () =>
                    context.push(RouteNames.editBudget(item.budget.id)),
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.categoryName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _monthLabel(item.budget.periodStart),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(item.ratio * 100).round()}%',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: item.ratio,
                            minHeight: 8,
                            backgroundColor: color.withValues(alpha: 0.15),
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent ${Money.fromMinor(item.spentMinor, currency).format()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${isOver ? 'Over' : 'Left'} '
                              '${Money.fromMinor(item.remainingMinor.abs(), currency).format()}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: color),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      },
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _BudgetShimmer extends StatelessWidget {
  const _BudgetShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: const [
        BudgetCardShimmer(),
        SizedBox(height: 12),
        BudgetCardShimmer(),
        SizedBox(height: 12),
        BudgetCardShimmer(),
      ],
    );
  }
}
