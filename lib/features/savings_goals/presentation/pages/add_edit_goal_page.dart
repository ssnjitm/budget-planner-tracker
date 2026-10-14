import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/common/widgets/money_text_field.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_providers.dart';

class AddEditGoalPage extends ConsumerStatefulWidget {
  const AddEditGoalPage({this.goalId, super.key});

  final String? goalId;

  @override
  ConsumerState<AddEditGoalPage> createState() => _AddEditGoalPageState();
}

class _AddEditGoalPageState extends ConsumerState<AddEditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  DateTime? _targetDate;
  bool _saving = false;

  bool get _isEditing => widget.goalId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.goalId;
    if (id != null) {
      final existing = ref
          .read(savingsProvider)
          .goals
          .where((goal) => goal.id == id)
          .firstOrNull;
      if (existing != null) {
        _nameCtrl.text = existing.name;
        _targetCtrl.text = (existing.targetMinor / 100).toStringAsFixed(2);
        _targetDate = existing.targetDate;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyCodeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit goal' : 'Add goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Goal name',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            MoneyTextField(
              controller: _targetCtrl,
              label: 'Target amount ($currency)',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target date (optional)',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(
                  _targetDate == null
                      ? 'No deadline'
                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                ),
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
                  : Text(_isEditing ? 'Save changes' : 'Create goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      setState(() => _targetDate = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final now = ref.read(clockProvider)().toUtc();
    final goal = SavingsGoal(
      id: widget.goalId ?? ref.read(uuidProvider).newId(),
      name: _nameCtrl.text.trim(),
      targetMinor: parseMoneyToMinor(_targetCtrl.text),
      targetDate: _targetDate,
      createdAt: now,
      updatedAt: now,
    );
    final notifier = ref.read(savingsProvider.notifier);
    final ok = _isEditing
        ? await notifier.updateGoal(goal)
        : await notifier.addGoal(goal);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(savingsProvider).message ?? 'Failed')),
      );
    }
  }
}
