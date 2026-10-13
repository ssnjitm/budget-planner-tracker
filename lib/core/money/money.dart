import '../error/exceptions.dart';
import 'money_formatter.dart';

class Money implements Comparable<Money> {
  const Money.fromMinor(this.minorUnits, [this.currency = 'NPR']);

  factory Money.zero([String currency = 'NPR']) =>
      Money.fromMinor(0, currency);

  factory Money.parse(String input, [String currency = 'NPR']) =>
      Money.fromMinor(parseMoneyToMinor(input), currency);

  final int minorUnits;
  final String currency;

  bool get isZero => minorUnits == 0;

  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money.fromMinor(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money.fromMinor(minorUnits - other.minorUnits, currency);
  }

  Money operator -() => Money.fromMinor(-minorUnits, currency);

  String format({bool withSymbol = true}) =>
      formatMinor(minorUnits, currency: currency, withSymbol: withSymbol);

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ValidationException(
        'Currency mismatch: $currency vs ${other.currency}',
      );
    }
  }

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          other.minorUnits == minorUnits &&
          other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => format();
}
