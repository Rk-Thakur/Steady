import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/cycle.dart';
import 'package:steady/domain/models/models.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);
  const oct15 = LocalDate(2026, 10, 15);

  Entry e(
    String id,
    EntryType type,
    int cents,
    LocalDate date, {
    bool toVault = false,
    bool fromVault = false,
  }) => Entry(
    id: id,
    type: type,
    amountCents: cents,
    localDate: date,
    createdAtUtc: DateTime.utc(2026),
    timeZoneId: 'UTC',
    toVault: toVault,
    fromVault: fromVault,
  );

  const plan = CyclePlan(
    startDate: oct2,
    openingBalanceCents: 139200,
    goalSetAsideCents: 20000,
  );

  group('moneyAtStartOf', () {
    test(
      'counts entries from the cycle start up to (not including) the day',
      () {
        final entries = [
          e('old', EntryType.spend, 9999, oct2.addDays(-1)),
          e('a', EntryType.spend, 1780, oct2),
          e('b', EntryType.income, 50000, oct2.addDays(3)),
          e('vault', EntryType.income, 64000, oct2.addDays(3), toVault: true),
          e('later', EntryType.spend, 1000, oct15),
        ];
        expect(moneyAtStartOf(oct15, plan, entries), 139200 - 1780 + 50000);
      },
    );
  });

  group('startNewCycle', () {
    final goals = [
      const Goal(
        id: 'g1',
        name: 'Fund',
        targetCents: 300000,
        savedCents: 186000,
        dailySetAsideCents: 1000,
      ),
      const Goal(
        id: 'g2',
        name: 'Laptop',
        targetCents: 120000,
        savedCents: 24000,
        dailySetAsideCents: 538,
      ),
      const Goal(
        id: 'paused',
        name: 'Paused',
        targetCents: 50000,
        savedCents: 0,
        dailySetAsideCents: 500,
        paused: true,
      ),
    ];

    test('moves the set-aside into goals and opens with the rest', () {
      // 13-day cycle: 13 × $10.00 + 13 × $5.38 = $199.94 planned ≤ $200 set aside.
      final next = startNewCycle(
        start: oct15,
        current: plan,
        entries: [e('spent', EntryType.spend, 70000, oct2.addDays(1))],
        goals: goals,
        frequency: PayFrequency.monthly,
        lastPayday: oct15,
      );
      expect(next.movedToGoalsCents, 13000 + 6994);
      expect(
        next.goals.firstWhere((g) => g.id == 'g1').savedCents,
        186000 + 13000,
      );
      expect(
        next.goals.firstWhere((g) => g.id == 'g2').savedCents,
        24000 + 6994,
      );
      expect(next.goals.firstWhere((g) => g.id == 'paused').savedCents, 0);
      expect(next.plan.startDate, oct15);
      expect(next.plan.openingBalanceCents, 139200 - 70000 - 19994);
      expect(next.nextPayday, const LocalDate(2026, 11, 15));
      // New 31-day cycle: 31 × ($10.00 + $5.38).
      expect(next.plan.goalSetAsideCents, 31 * (1000 + 538));
    });

    test('never moves more than there is (overspent cycle)', () {
      final next = startNewCycle(
        start: oct15,
        current: plan,
        entries: [
          e('spent', EntryType.spend, 129200, oct2.addDays(1)),
        ], // $100 left
        goals: goals,
        frequency: PayFrequency.monthly,
      );
      expect(next.movedToGoalsCents, lessThanOrEqualTo(10000));
      expect(next.plan.openingBalanceCents, greaterThanOrEqualTo(0));
    });

    test('a goal never receives more than it still needs', () {
      final next = startNewCycle(
        start: oct15,
        current: plan,
        entries: const [],
        goals: [
          const Goal(
            id: 'almost',
            name: 'Almost',
            targetCents: 1000,
            savedCents: 900,
            dailySetAsideCents: 1000,
          ),
        ],
        frequency: PayFrequency.monthly,
      );
      expect(next.goals.single.savedCents, 1000);
      expect(next.goals.single.isReached, isTrue);
      expect(next.plan.goalSetAsideCents, 0);
    });
  });

  group('when a cycle starts', () {
    final pay = e('pay', EntryType.income, 300000, oct15);
    test('pay logged on or after payday starts it', () {
      expect(
        incomeStartsCycle(
          entry: pay,
          today: oct15,
          nextPayday: oct15,
          frequency: PayFrequency.monthly,
        ),
        isTrue,
      );
    });
    test('pay before payday just raises the daily number', () {
      expect(
        incomeStartsCycle(
          entry: e('early', EntryType.income, 1, oct2),
          today: oct2,
          nextPayday: oct15,
          frequency: PayFrequency.monthly,
        ),
        isFalse,
      );
    });
    test('Vault deposits and pay that varies never start one', () {
      expect(
        incomeStartsCycle(
          entry: e('v', EntryType.income, 1, oct15, toVault: true),
          today: oct15,
          nextPayday: oct15,
          frequency: PayFrequency.monthly,
        ),
        isFalse,
      );
      expect(
        incomeStartsCycle(
          entry: pay,
          today: oct15,
          nextPayday: oct15,
          frequency: PayFrequency.varies,
        ),
        isFalse,
      );
    });
    test('awaiting pay from payday on, only for regular pay', () {
      expect(
        awaitingPay(
          today: oct2,
          nextPayday: oct15,
          frequency: PayFrequency.monthly,
        ),
        isFalse,
      );
      expect(
        awaitingPay(
          today: oct15,
          nextPayday: oct15,
          frequency: PayFrequency.monthly,
        ),
        isTrue,
      );
      expect(
        awaitingPay(
          today: oct15,
          nextPayday: oct15,
          frequency: PayFrequency.varies,
        ),
        isFalse,
      );
    });
  });

  group('Vault releases', () {
    test('every Monday since the last release, up to today', () {
      const vault = Vault(
        openingBalanceCents: 0,
        steadyPayWeeklyCents: 78000,
        lastReleaseDate: LocalDate(2026, 9, 28),
      );
      expect(releasesDue(vault, const LocalDate(2026, 10, 19)), [
        const LocalDate(2026, 10, 5),
        const LocalDate(2026, 10, 12),
        const LocalDate(2026, 10, 19),
      ]);
      expect(releasesDue(vault, const LocalDate(2026, 10, 4)), isEmpty);
    });
    test('none when steady pay isn\'t set', () {
      const off = Vault(
        openingBalanceCents: 0,
        steadyPayWeeklyCents: 0,
        lastReleaseDate: LocalDate(2026, 9, 28),
      );
      expect(releasesDue(off, const LocalDate(2026, 12, 1)), isEmpty);
    });
    test('balance: deposits in, releases out', () {
      const vault = Vault(
        openingBalanceCents: 100000,
        steadyPayWeeklyCents: 78000,
      );
      expect(
        vault.balanceCents([
          e('in', EntryType.income, 64000, oct2, toVault: true),
          e('out', EntryType.income, 78000, oct2, fromVault: true),
          e('pay', EntryType.income, 50000, oct2),
        ]),
        100000 + 64000 - 78000,
      );
    });
  });

  group('Bill.paid', () {
    final bill = Bill(
      id: 'car',
      name: 'Car',
      amountCents: 12800,
      recurrence: Recurrence.monthly,
      dueDate: const LocalDate(2026, 10, 8),
    );

    test('moves to the next due date and records when it was paid', () {
      final p = bill.paid(paidOn: oct2, paidCents: 12800);
      expect(p.dueDate, const LocalDate(2026, 11, 8));
      expect(p.lastPaidOn, oct2);
      expect(p.isReservedBefore(oct15), isFalse);
      expect(p.needsReview, isFalse);
    });

    test('a fixed bill that came in higher is flagged "price went up"', () {
      final p = bill.paid(paidOn: oct2, paidCents: 13900);
      expect(p.needsReview, isTrue);
      expect(p.priceWentUp, isTrue);
      expect(p.previousAmountCents, 12800);
    });

    test('an estimate takes the real amount without a flag', () {
      final est = Bill(
        id: 'el',
        name: 'Electric',
        amountCents: 9600,
        recurrence: Recurrence.monthly,
        dueDate: oct2,
        isEstimate: true,
      );
      final p = est.paid(paidOn: oct2, paidCents: 10400);
      expect(p.amountCents, 10400);
      expect(p.needsReview, isFalse);
    });
  });
}
