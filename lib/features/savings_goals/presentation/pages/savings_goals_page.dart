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
import '../providers/savings_providers.dart';

class SavingsGoalsPage extends ConsumerWidget {
  const SavingsGoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsProvider);
    final currency = ref.watch(currencyCodeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addGoal),
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
      body: switch (state.status) {
        SavingsStatus.initial || SavingsStatus.loading
            when state.goals.isEmpty =>
          const _SavingsShimmer(),
        SavingsStatus.error => AppErrorWidget(
          message: state.message ?? 'Could not load goals',
          onRetry: () => ref.read(savingsProvider.notifier).load(),
        ),
        _ when state.goals.isEmpty => const AppEmptyState(
          icon: Icons.flag_outlined,
          title: 'No savings goals yet',
          subtitle: 'Create a goal and track your progress.',
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.pagePadding,
            AppDimensions.pagePadding,
            96,
          ),
          itemCount: state.goals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final goal = state.goals[index];
            final saved = state.savedMinor(goal.id);
            final ratio = goal.targetMinor <= 0
                ? 0.0
                : (saved / goal.targetMinor).clamp(0, 1).toDouble();
            return Dismissible(
              key: ValueKey(goal.id),
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
                title: 'Delete goal?',
                message: 'Its contributions will be removed too.',
                confirmLabel: 'Delete',
              ),
              onDismissed: (_) =>
                  ref.read(savingsProvider.notifier).deleteGoal(goal.id),
              child: InkWell(
                onTap: () => context.push(RouteNames.goalDetail(goal.id)),
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
                              child: Text(
                                goal.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${(ratio * 100).round()}%',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.goal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: AppColors.goal.withValues(
                              alpha: 0.15,
                            ),
                            color: AppColors.goal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Money.fromMinor(saved, currency).format(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'of ${Money.fromMinor(goal.targetMinor, currency).format()}',
                              style: Theme.of(context).textTheme.bodySmall,
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
}

class _SavingsShimmer extends StatelessWidget {
  const _SavingsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: const [
        SavingsGoalCardShimmer(),
        SizedBox(height: 12),
        SavingsGoalCardShimmer(),
        SizedBox(height: 12),
        SavingsGoalCardShimmer(),
      ],
    );
  }
}
