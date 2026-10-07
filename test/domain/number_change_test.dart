import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/daily_number.dart';
import 'package:steady/domain/number_change.dart';
import 'package:steady/ui/today/number_change_text.dart';

void main() {
  // Monday Oct 5, payday Oct 15: 10 days left. Yesterday's number: $64.00,
  // so a day spent exactly on budget leaves $640.00 for the 10 days.
  const today = LocalDate(2026, 10, 5);
  const cycleStart = LocalDate(2026, 9, 30);

  DailyNumber number({int start = 64000, int income = 0, int bills = 0}) =>
      DailyNumberCalculator.calculate(
        DailyNumberInput(
          today: today,
          nextPayday: const LocalDate(2026, 10, 15),
          moneyAtStartOfDayCents: start,
          incomeTodayCents: income,
          unpaidBillsBeforePaydayCents: bills,
          goalSetAsidesCents: 0,
        ),
      );

  NumberChange? change(
    DailyNumber n, {
    required int spentYesterday,
    int? yesterday = 6400,
    LocalDate start = cycleStart,
  }) => numberChangeSinceYesterday(
    today: n,
    yesterdayCents: yesterday,
    yesterdaySpentCents: spentYesterday,
    cycleStart: start,
  );

  test('spending less yesterday spreads over the days left', () {
    // Spent $21.50 of $64.00: $42.50 left over, ÷ 10 = +$4.25.
    final c = change(number(start: 64000 + 4250), spentYesterday: 2150)!;
    expect(c.totalCents, 425);
    expect(c.spendingCents, 425);
    expect(c.otherCents, 0);
    expect(c.mainReason, NumberChangeReason.spending);
    expect(
      NumberChangeText.headline(c, r'$'),
      r'Up $4.25 from yesterday: you spent less',
    );
  });

  test('spending more lowers it the same way', () {
    final c = change(number(start: 64000 - 2000), spentYesterday: 8400)!;
    expect(c.totalCents, -200);
    expect(
      NumberChangeText.headline(c, r'$'),
      r'Down $2.00 from yesterday: you spent more',
    );
  });

  test('income logged today', () {
    final c = change(number(income: 3000), spentYesterday: 6400)!;
    expect(c.incomeCents, 300);
    expect(c.mainReason, NumberChangeReason.income);
    expect(NumberChangeText.headline(c, r'$'), endsWith('income logged today'));
  });

  test('a new bill is "bills or goals changed"', () {
    final c = change(number(bills: 5000), spentYesterday: 6400)!;
    expect(c.totalCents, -500);
    expect(c.spendingCents, 0);
    expect(c.otherCents, -500);
    expect(NumberChangeText.parts(c, 10), [
      ('Bills, goals, balance or payday changed', -500),
    ]);
    expect(
      NumberChangeText.headline(c, r'$'),
      r'Down $5.00 from yesterday: bills or goals changed',
    );
  });

  test('the biggest part in the direction of the change is named', () {
    // Spent $10 less (+$1.00) but a $50 bill was added (−$5.00).
    final c = change(number(start: 65000, bills: 5000), spentYesterday: 5400)!;
    expect(c.spendingCents, 100);
    expect(c.otherCents, -500);
    expect(c.mainReason, NumberChangeReason.other);
  });

  test('a cent of rounding is not a change of its own', () {
    // $640.07 over 10 days: rounds to $64.00, the 7 cents spread is 1.
    final c = change(number(start: 64007), spentYesterday: 6393)!;
    expect(c.otherCents, 0);
    expect(c.isUnchanged, isTrue);
    expect(NumberChangeText.headline(c, r'$'), isNull);
  });

  test('nothing to compare on a cycle\'s first day or with no record', () {
    expect(change(number(), spentYesterday: 0, yesterday: null), isNull);
    expect(change(number(), spentYesterday: 0, start: today), isNull);
  });
}
