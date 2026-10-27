import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/app_error_widget.dart';
import '../../../../core/common/widgets/confirm_dialog.dart';
import '../../../../core/common/widgets/shimmer_placeholders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../router/route_names.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../providers/category_providers.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider).items;
    final currency = ref.watch(currencyCodeProvider);
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addTransaction),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: state.filter,
            onSelected: (filter) =>
                ref.read(transactionProvider.notifier).setFilter(filter),
          ),
          Expanded(
            child: switch (state.status) {
              TransactionStatus.initial || TransactionStatus.loading
                  when state.items.isEmpty =>
                const _TransactionsShimmer(),
              TransactionStatus.error => AppErrorWidget(
                message: state.message ?? 'Could not load transactions',
                onRetry: () => ref.read(transactionProvider.notifier).load(),
              ),
              _ when state.visibleItems.isEmpty => const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                subtitle: 'Tap + to add your first transaction.',
              ),
              _ => RefreshIndicator(
                onRefresh: () => ref.read(transactionProvider.notifier).load(),
                child: _TransactionList(
                  items: state.visibleItems,
                  categoryById: categoryById,
                  currency: currency,
                  onEdit: (transaction) =>
                      context.push(RouteNames.editTransaction(transaction.id)),
                  onDelete: (transaction) =>
                      _confirmDelete(context, ref, transaction),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete transaction?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(transactionProvider.notifier).delete(transaction.id);
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
          vertical: 8,
        ),
        children: [
          for (final filter in TransactionFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_label(filter)),
                selected: selected == filter,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }

  String _label(TransactionFilter filter) => switch (filter) {
    TransactionFilter.all => 'All',
    TransactionFilter.income => 'Income',
    TransactionFilter.expense => 'Expense',
  };
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.items,
    required this.categoryById,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Transaction> items;
  final Map<String, Category> categoryById;
  final String currency;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        0,
        AppDimensions.pagePadding,
        96,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final transaction = items[index];
        final category = categoryById[transaction.categoryId];
        final date = _formatDate(transaction.transactionDate);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: ValueKey(transaction.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.expense,
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) => showConfirmDialog(
              context,
              title: 'Delete transaction?',
              confirmLabel: 'Delete',
            ),
            onDismissed: (_) => onDelete(transaction),
            child: Card(
              child: TransactionTile(
                transaction: transaction,
                title: category?.name ?? 'Uncategorised',
                subtitle: transaction.note?.isNotEmpty == true
                    ? '$date · ${transaction.note}'
                    : date,
                iconKey: category?.iconKey,
                currency: currency,
                onTap: () => onEdit(transaction),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _TransactionsShimmer extends StatelessWidget {
  const _TransactionsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: const [
        TransactionTileShimmer(),
        SizedBox(height: 18),
        TransactionTileShimmer(),
        SizedBox(height: 18),
        TransactionTileShimmer(),
        SizedBox(height: 18),
        TransactionTileShimmer(),
      ],
    );
  }
}
