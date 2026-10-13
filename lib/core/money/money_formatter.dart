import 'package:intl/intl.dart';

import '../error/exceptions.dart';

final RegExp _digits = RegExp(r'^\d+$');

int parseMoneyToMinor(String input, {int decimals = 2}) {
  final cleaned = input.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty) {
    throw const ValidationException('Amount is required');
  }
  final negative = cleaned.startsWith('-');
  final body = negative ? cleaned.substring(1) : cleaned;
  final parts = body.split('.');
  if (parts.length > 2) {
    throw ValidationException('Invalid amount: $input');
  }
  final whole = parts[0].isEmpty ? '0' : parts[0];
  var fraction = parts.length == 2 ? parts[1] : '';
  if (parts[0].isEmpty && fraction.isEmpty) {
    throw ValidationException('Invalid amount: $input');
  }
  if (!_digits.hasMatch(whole)) {
    throw ValidationException('Invalid amount: $input');
  }
  if (fraction.length > decimals) {
    throw ValidationException('Too many decimal places: $input');
  }
  if (fraction.isNotEmpty && !_digits.hasMatch(fraction)) {
    throw ValidationException('Invalid amount: $input');
  }
  fraction = fraction.padRight(decimals, '0');
  final minor = int.tryParse('$whole$fraction');
  if (minor == null) {
    throw ValidationException('Invalid amount: $input');
  }
  return negative ? -minor : minor;
}

String formatMinor(
  int minorUnits, {
  String currency = 'NPR',
  bool withSymbol = true,
}) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: withSymbol ? _symbolFor(currency) : '',
    decimalDigits: 2,
  );
  return formatter.format(minorUnits / 100);
}

String _symbolFor(String currency) {
  switch (currency.toUpperCase()) {
    case 'NPR':
      return 'Rs ';
    case 'INR':
      return '₹';
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    default:
      return '$currency ';
  }
}
