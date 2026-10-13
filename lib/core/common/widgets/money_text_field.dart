import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../money/money_formatter.dart';

class MoneyTextField extends StatelessWidget {
  const MoneyTextField({
    required this.controller,
    this.label = 'Amount',
    this.currency = 'NPR',
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String currency;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: onChanged,
      validator: validator ??
          (value) {
            try {
              return parseMoneyToMinor(value ?? '') <= 0
                  ? 'Enter a valid amount'
                  : null;
            } on Exception {
              return 'Enter a valid amount';
            }
          },
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$currency ',
        prefixIcon: const Icon(Icons.payments_outlined),
      ),
    );
  }
}
