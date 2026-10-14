import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/category_icons.dart';
import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/confirm_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/category_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryProvider);
    final expense = state.byType(TransactionType.expense);
    final income = state.byType(TransactionType.income);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      body: state.items.isEmpty
          ? const AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Add a category to organise your spending.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
                96,
              ),
              children: [
                if (expense.isNotEmpty) ...[
                  const _SectionLabel('Expense'),
                  for (final category in expense)
                    _CategoryTile(
                      category: category,
                      onTap: () => _showForm(context, ref, category: category),
                      onDelete: () => _confirmDelete(context, ref, category),
                    ),
                ],
                if (income.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionLabel('Income'),
                  for (final category in income)
                    _CategoryTile(
                      category: category,
                      onTap: () => _showForm(context, ref, category: category),
                      onDelete: () => _confirmDelete(context, ref, category),
                    ),
                ],
              ],
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete category?',
      message: 'Existing transactions keep their category label.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await ref.read(categoryProvider.notifier).delete(category.id);
    }
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    var type = category?.type ?? TransactionType.expense;
    var iconKey = category?.iconKey ?? CategoryIcons.keys.first;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Add category' : 'Edit category'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (selection) =>
                      setDialogState(() => type = selection.first),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: iconKey,
                  decoration: const InputDecoration(labelText: 'Icon'),
                  items: [
                    for (final key in CategoryIcons.keys)
                      DropdownMenuItem(
                        value: key,
                        child: Row(
                          children: [
                            Icon(CategoryIcons.resolve(key), size: 20),
                            const SizedBox(width: 10),
                            Text(key),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => iconKey = value ?? iconKey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) {
      return;
    }

    final now = ref.read(clockProvider)().toUtc();
    final notifier = ref.read(categoryProvider.notifier);
    if (category == null) {
      await notifier.add(
        Category(
          id: ref.read(uuidProvider).newId(),
          name: nameCtrl.text.trim(),
          type: type,
          iconKey: iconKey,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await notifier.update(
        Category(
          id: category.id,
          name: nameCtrl.text.trim(),
          type: type,
          iconKey: iconKey,
          createdAt: category.createdAt,
          updatedAt: now,
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              CategoryIcons.resolve(category.iconKey),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(category.name),
          onTap: onTap,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
