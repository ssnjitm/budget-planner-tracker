import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/money_text_field.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/category_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

class AddEditBudgetPage extends ConsumerStatefulWidget {
  const AddEditBudgetPage({this.budgetId, super.key});

  final String? budgetId;

  @override
  ConsumerState<AddEditBudgetPage> createState() => _AddEditBudgetPageState();
}

class _AddEditBudgetPageState extends ConsumerState<AddEditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _limitCtrl = TextEditingController();

  String? _categoryId;
  DateTime _period = DateTime(DateTime.now().year, DateTime.now().month);
  bool _saving = false;

  bool get _isEditing => widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.budgetId;
    if (id != null) {
      final existing = ref
          .read(budgetProvider)
          .items
          .where((budget) => budget.id == id)
          .firstOrNull;
      if (existing != null) {
        _categoryId = existing.categoryId;
        _period = existing.periodStart;
        _limitCtrl.text = (existing.limitMinor / 100).toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoryProvider)
        .byType(TransactionType.expense);
    final currency = ref.watch(currencyCodeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit budget' : 'Add budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
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
            MoneyTextField(
              controller: _limitCtrl,
              label: 'Monthly limit ($currency)',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickPeriod,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Month',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(_monthLabel(_period)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Create budget'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _period,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select month',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _period = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final now = ref.read(clockProvider)().toUtc();
    final budget = Budget(
      id: widget.budgetId ?? ref.read(uuidProvider).newId(),
      categoryId: _categoryId!,
      periodStart: _period,
      limitMinor: parseMoneyToMinor(_limitCtrl.text),
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(budgetProvider.notifier);
    final ok = _isEditing
        ? await notifier.update(budget)
        : await notifier.add(budget);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(budgetProvider).message ?? 'Failed')),
      );
    }
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
