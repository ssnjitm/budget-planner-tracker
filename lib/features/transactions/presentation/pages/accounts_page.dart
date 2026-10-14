import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/confirm_dialog.dart';
import '../../../../core/money/money.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);
    final currency = ref.watch(currencyCodeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add account'),
      ),
      body: state.items.isEmpty
          ? const AppEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No accounts yet',
              subtitle: 'Add an account to start tracking balances.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
                96,
              ),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final account = state.items[index];
                final balance = state.balances[account.id] ?? 0;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(account.name),
                    subtitle: Text(
                      'Balance ${Money.fromMinor(balance, currency).format()}',
                    ),
                    onTap: () => _showForm(context, ref, account: account),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, account),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete account?',
      message: 'Transactions linked to this account will remain.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await ref.read(accountProvider.notifier).delete(account.id);
    }
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    Account? account,
  }) async {
    final nameCtrl = TextEditingController(text: account?.name ?? '');
    final balanceCtrl = TextEditingController(
      text: account == null
          ? ''
          : (account.openingBalanceMinor / 100).toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Add account' : 'Edit account'),
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
              TextFormField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Opening balance'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return null;
                  }
                  try {
                    parseMoneyToMinor(value!);
                    return null;
                  } on Exception {
                    return 'Enter a valid amount';
                  }
                },
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
    );

    if (saved != true) {
      return;
    }

    final now = ref.read(clockProvider)().toUtc();
    final openingMinor = balanceCtrl.text.trim().isEmpty
        ? 0
        : parseMoneyToMinor(balanceCtrl.text);
    final notifier = ref.read(accountProvider.notifier);
    if (account == null) {
      await notifier.add(
        Account(
          id: ref.read(uuidProvider).newId(),
          name: nameCtrl.text.trim(),
          openingBalanceMinor: openingMinor,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await notifier.update(
        Account(
          id: account.id,
          name: nameCtrl.text.trim(),
          openingBalanceMinor: openingMinor,
          isActive: account.isActive,
          createdAt: account.createdAt,
          updatedAt: now,
        ),
      );
    }
  }
}
