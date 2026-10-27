import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/money_text_field.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/category_providers.dart';
import '../providers/transaction_providers.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  const AddEditTransactionPage({
    this.transactionId,
    this.initialType,
    super.key,
  });

  final String? transactionId;
  final TransactionType? initialType;

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  String? _categoryId;
  bool _saving = false;

  bool get _isEditing => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.transactionId;
    if (id != null) {
      final existing = ref
          .read(transactionProvider)
          .items
          .where((transaction) => transaction.id == id)
          .firstOrNull;
      if (existing != null) {
        _type = existing.type;
        _date = existing.transactionDate;
        _categoryId = existing.categoryId;
        _noteCtrl.text = existing.note ?? '';
        _amountCtrl.text = formatMinor(
          existing.amountMinor,
          withSymbol: false,
        ).trim();
      }
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final currency = ref.watch(currencyCodeProvider);
    final categories = categoryState.byType(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit transaction' : 'Add transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
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
              selected: {_type},
              onSelectionChanged: (selection) => setState(() {
                _type = selection.first;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: 18),
            MoneyTextField(
              key: const Key('amount_field'),
              controller: _amountCtrl,
              label: 'Amount ($currency)',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) => value == null ? 'Pick a category' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_button'),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final now = ref.read(clockProvider)().toUtc();
    final amountMinor = parseMoneyToMinor(_amountCtrl.text);
    final transaction = Transaction(
      id: widget.transactionId ?? ref.read(uuidProvider).newId(),
      categoryId: _categoryId!,
      type: _type,
      amountMinor: amountMinor,
      transactionDate: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(transactionProvider.notifier);
    final ok = _isEditing
        ? await notifier.update(transaction)
        : await notifier.add(transaction);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Transaction updated' : 'Transaction added',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      final message =
          ref.read(transactionProvider).message ?? 'Something went wrong';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.expense),
      );
    }
  }
}
