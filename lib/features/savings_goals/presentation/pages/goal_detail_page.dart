import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/app_error_widget.dart';
import '../../../../core/common/widgets/money_text_field.dart';
import '../../../../core/money/money.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../router/route_names.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/goal_entry.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_providers.dart';

class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({required this.goalId, super.key});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsProvider);
    final currency = ref.watch(currencyCodeProvider);
    final goal = state.goals.where((g) => g.id == goalId).firstOrNull;

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal')),
        body: AppErrorWidget(
          message: 'This goal is no longer available.',
          onRetry: () => context.pop(),
        ),
      );
    }

    final entries = state.entriesFor(goalId);
    final saved = state.savedMinor(goalId);
    final ratio = goal.targetMinor <= 0
        ? 0.0
        : (saved / goal.targetMinor).clamp(0, 1).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.editGoal(goal.id)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEntry(context, ref, goal),
        icon: const Icon(Icons.add),
        label: const Text('Add money'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          96,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Money.fromMinor(saved, currency).format(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${Money.fromMinor(goal.targetMinor, currency).format()} target',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.goal.withValues(alpha: 0.15),
                      color: AppColors.goal,
                    ),
                  ),
                  if (goal.targetDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Target date: ${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'HISTORY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No contributions yet. Add money to start saving.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            for (final entry in entries)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.goal.withValues(alpha: 0.12),
                    child: Icon(
                      entry.entryType == GoalEntryType.contribute
                          ? Icons.add_rounded
                          : Icons.remove_rounded,
                      color: AppColors.goal,
                    ),
                  ),
                  title: Text(
                    entry.entryType == GoalEntryType.contribute
                        ? 'Contribution'
                        : 'Withdrawal',
                  ),
                  subtitle: Text(
                    '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Money.fromMinor(entry.signedMinor, currency).format(),
                        style: TextStyle(
                          color: entry.entryType == GoalEntryType.contribute
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => ref
                            .read(savingsProvider.notifier)
                            .deleteEntry(entry.id),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _addEntry(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final amountCtrl = TextEditingController();
    var type = GoalEntryType.contribute;
    final currency = ref.read(currencyCodeProvider);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<GoalEntryType>(
                segments: const [
                  ButtonSegment(
                    value: GoalEntryType.contribute,
                    label: Text('Contribute'),
                  ),
                  ButtonSegment(
                    value: GoalEntryType.withdraw,
                    label: Text('Withdraw'),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (selection) =>
                    setDialogState(() => type = selection.first),
              ),
              const SizedBox(height: 16),
              MoneyTextField(
                controller: amountCtrl,
                label: 'Amount ($currency)',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) {
      return;
    }
    int amount;
    try {
      amount = parseMoneyToMinor(amountCtrl.text);
    } on Exception {
      return;
    }
    if (amount <= 0) {
      return;
    }
    final now = ref.read(clockProvider)().toUtc();
    await ref
        .read(savingsProvider.notifier)
        .addEntry(
          GoalEntry(
            id: ref.read(uuidProvider).newId(),
            goalId: goal.id,
            amountMinor: amount,
            entryType: type,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
