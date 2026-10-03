import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/core/money.dart';
import 'package:steady/domain/daily_number.dart';
import 'package:steady/domain/models/models.dart';

/// The five worked examples from Handoff 4 · "Daily number · worked examples".
/// Shared setup: $1,392.00 money, $359.98 bills, $200.00 goals, payday Oct 15.
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  const oct3 = LocalDate(2026, 10, 3);
  const payday = LocalDate(2026, 10, 15);

  DailyNumberInput base({
    LocalDate today = oct2,
    int money = 139200,
    int incomeToday = 0,
    int spentToday = 0,
  }) => DailyNumberInput(
    today: today,
    nextPayday: payday,
    moneyAtStartOfDayCents: money,
    unpaidBillsBeforePaydayCents: 35998,
    goalSetAsidesCents: 20000,
    incomeTodayCents: incomeToday,
    spentTodayCents: spentToday,
  );

  group('Handoff 4 worked examples', () {
    test(r'1 · Normal day: $64.00 allowance, spent $17.80 → $46.20', () {
      final n = DailyNumberCalculator.calculate(base(spentToday: 1780));

      expect(n.daysLeft, 13);
      expect(n.poolCents, 83202);
      expect(n.dailyAllowanceCents, 6400);
      expect(n.safeToSpendCents, 4620);
      expect(formatMoney(n.safeToSpendCents), r'$46.20');
      expect(n.isOverspent, isFalse);
    });

    test(
      r'2 · Tomorrow after a normal day: ($832.02 − $17.80) ÷ 12 → $67.85',
      () {
        final n = DailyNumberCalculator.calculate(
          base(today: oct3, money: 139200 - 1780),
        );

        expect(n.daysLeft, 12);
        expect(n.safeToSpendCents, 6785);

        // Same answer when rolled forward from day 1.
        final today = DailyNumberCalculator.calculate(base(spentToday: 1780));
        expect(DailyNumberCalculator.tomorrow(today).safeToSpendCents, 6785);
      },
    );

    test(r'3 · Overspent: spent $76.40 → −$12.40 today, $62.96 tomorrow', () {
      final today = DailyNumberCalculator.calculate(base(spentToday: 7640));

      expect(today.safeToSpendCents, -1240);
      expect(today.isOverspent, isTrue);
      expect(today.overspentByCents, 1240);
      expect(formatMoney(today.safeToSpendCents), '−\$12.40');

      // $755.62 ÷ 12 = $62.968… rounded down, never up.
      final tomorrow = DailyNumberCalculator.tomorrow(today);
      expect(tomorrow.daysLeft, 12);
      expect(tomorrow.safeToSpendCents, 6296);
    });

    test(r'4 · Income straight to today: ($832.02 + $640.00) ÷ 13 − $17.80 → $95.43', () {
      final n = DailyNumberCalculator.calculate(
        base(incomeToday: 64000, spentToday: 1780),
      );

      expect(n.dailyAllowanceCents, 11323);
      expect(n.safeToSpendCents, 9543);
    });

    test(
      r'5 · Income to Vault: daily number unchanged at $46.20, Vault + $640.00',
      () {
        final plan = CyclePlan(
          startDate: oct2,
          openingBalanceCents: 139200,
          goalSetAsideCents: 20000,
        );
        final entries = [
          _spend('coffee', 540, oct2),
          _spend('gas', 1240, oct2),
          _income('gig', 64000, oct2, toVault: true),
        ];
        final input = DailyNumberCalculator.inputFromLedger(
          today: oct2,
          nextPayday: payday,
          plan: plan,
          entries: entries,
          bills: [_bill('bills', 35998, const LocalDate(2026, 10, 8))],
        );

        expect(DailyNumberCalculator.calculate(input).safeToSpendCents, 4620);

        const vault = Vault(
          openingBalanceCents: 194000,
          steadyPayWeeklyCents: 78000,
        );
        expect(vault.balanceCents(entries) - vault.openingBalanceCents, 64000);
      },
    );
  });

  group('inputFromLedger', () {
    final plan = CyclePlan(
      startDate: oct2,
      openingBalanceCents: 139200,
      goalSetAsideCents: 20000,
    );

    test(
      'earlier days move into money-at-start-of-day, today stays separate',
      () {
        final input = DailyNumberCalculator.inputFromLedger(
          today: oct3,
          nextPayday: payday,
          plan: plan,
          entries: [
            _spend('a', 1780, oct2),
            _spend('b', 500, oct3),
            _income('c', 10000, oct3),
          ],
          bills: const [],
        );

        expect(input.moneyAtStartOfDayCents, 139200 - 1780);
        expect(input.spentTodayCents, 500);
        expect(input.incomeTodayCents, 10000);
      },
    );

    test('ignores entries before the cycle and in the future', () {
      final input = DailyNumberCalculator.inputFromLedger(
        today: oct2,
        nextPayday: payday,
        plan: plan,
        entries: [
          _spend('old', 9999, const LocalDate(2026, 9, 30)),
          _spend('future', 9999, oct3),
        ],
        bills: const [],
      );

      expect(input.moneyAtStartOfDayCents, 139200);
      expect(input.spentTodayCents, 0);
    });

    test('reserves only unpaid bills due before payday, overdue included', () {
      final input = DailyNumberCalculator.inputFromLedger(
        today: oct2,
        nextPayday: payday,
        plan: plan,
        entries: const [],
        bills: [
          _bill('due', 12800, const LocalDate(2026, 10, 8)),
          _bill('overdue', 1000, const LocalDate(2026, 9, 30)),
          _bill('paid', 5000, const LocalDate(2026, 10, 5), paidOn: oct2),
          _bill('on payday', 7000, payday),
          _bill('after', 3000, const LocalDate(2026, 10, 20)),
        ],
      );

      expect(input.unpaidBillsBeforePaydayCents, 12800 + 1000);
    });
  });

  group('edge cases', () {
    test('payday is today: divide by 1', () {
      final n = DailyNumberCalculator.calculate(
        DailyNumberInput(
          today: payday,
          nextPayday: payday,
          moneyAtStartOfDayCents: 5000,
          unpaidBillsBeforePaydayCents: 0,
          goalSetAsidesCents: 0,
        ),
      );
      expect(n.daysLeft, 1);
      expect(n.safeToSpendCents, 5000);
    });

    test('payday passed with no income logged still divides by 1', () {
      expect(
        DailyNumberCalculator.daysLeft(const LocalDate(2026, 10, 17), payday),
        1,
      );
    });

    test('a negative pool rounds down, never toward zero', () {
      final n = DailyNumberCalculator.calculate(
        DailyNumberInput(
          today: oct2,
          nextPayday: oct2.addDays(3),
          moneyAtStartOfDayCents: -100,
          unpaidBillsBeforePaydayCents: 0,
          goalSetAsidesCents: 0,
        ),
      );
      expect(n.dailyAllowanceCents, -34);
    });

    test('day counts ignore daylight saving changes', () {
      // US clocks go back on Nov 1, 2026; Europe on Oct 25.
      expect(
        const LocalDate(2026, 10, 20).daysUntil(const LocalDate(2026, 11, 5)),
        16,
      );
    });
  });

  group('formatMoney', () {
    test('groups thousands and pads cents', () {
      expect(formatMoney(999999999), r'$9,999,999.99');
      expect(formatMoney(5), r'$0.05');
      expect(formatMoney(-540), '−\$5.40');
      expect(formatMoney(64000, signed: true), r'+$640.00');
      expect(formatMoney(4699, showCents: false), r'$46');
    });
  });
}

Entry _spend(String id, int cents, LocalDate date) => Entry(
  id: id,
  type: EntryType.spend,
  amountCents: cents,
  localDate: date,
  createdAtUtc: DateTime.utc(2026),
  timeZoneId: 'UTC',
);

Entry _income(String id, int cents, LocalDate date, {bool toVault = false}) =>
    Entry(
      id: id,
      type: EntryType.income,
      amountCents: cents,
      localDate: date,
      createdAtUtc: DateTime.utc(2026),
      timeZoneId: 'UTC',
      toVault: toVault,
    );

Bill _bill(String id, int cents, LocalDate due, {LocalDate? paidOn}) => Bill(
  id: id,
  name: id,
  amountCents: cents,
  recurrence: Recurrence.monthly,
  dueDate: due,
  paidOn: paidOn,
);
