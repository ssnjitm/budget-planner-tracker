import 'package:budget_planner_tracker/core/error/exceptions.dart';
import 'package:budget_planner_tracker/core/money/money.dart';
import 'package:budget_planner_tracker/core/money/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMoneyToMinor', () {
    test('parses whole and decimal amounts to minor units', () {
      expect(parseMoneyToMinor('1500'), 150000);
      expect(parseMoneyToMinor('1500.5'), 150050);
      expect(parseMoneyToMinor('1500.50'), 150050);
      expect(parseMoneyToMinor('0.01'), 1);
      expect(parseMoneyToMinor('1,500.50'), 150050);
    });

    test('parses negative amounts', () {
      expect(parseMoneyToMinor('-12.34'), -1234);
    });

    test('throws on invalid input', () {
      expect(() => parseMoneyToMinor(''), throwsA(isA<ValidationException>()));
      expect(
        () => parseMoneyToMinor('abc'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => parseMoneyToMinor('1.2.3'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => parseMoneyToMinor('1.234'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('formatMinor', () {
    test('formats minor units with the currency symbol', () {
      expect(formatMinor(150050), 'Rs 1,500.50');
    });

    test('omits the symbol when requested', () {
      expect(formatMinor(150050, withSymbol: false), '1,500.50');
    });
  });

  group('Money', () {
    test('adds and subtracts within a currency', () {
      const a = Money.fromMinor(1000);
      const b = Money.fromMinor(250);
      expect((a + b).minorUnits, 1250);
      expect((a - b).minorUnits, 750);
    });

    test('rejects cross-currency arithmetic', () {
      expect(
        () => const Money.fromMinor(100, 'NPR') +
            const Money.fromMinor(100, 'USD'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parse uses the shared money formatter', () {
      expect(Money.parse('99.99').minorUnits, 9999);
    });
  });
}
