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

  group('per-goal set-aside this cycle', () {
    const fund = Goal(
      id: 'fund',
      name: 'Fund',
      targetCents: 300000,
      savedCents: 0,
      dailySetAsideCents: 1000,
    );

    test('a new goal holds back its daily amount for the days left', () {
      expect(
        cycleSetAsideAfterChange(before: null, after: fund, daysLeft: 10),
        10000,
      );
      // Never more than it still needs.
      expect(
        cycleSetAsideAfterChange(
          before: null,
          after: fund.copyWith(savedCents: 296000),
          daysLeft: 10,
        ),
        4000,
      );
    });

    test('pausing releases the days ahead, keeps the days gone', () {
      // Started a 13-day cycle holding $130; paused with 10 days left.
      final held = fund.copyWith(cycleSetAsideCents: 13000);
      final paused = held.copyWith(paused: true);
      expect(
        cycleSetAsideAfterChange(before: held, after: paused, daysLeft: 10),
        3000,
      );
      // Resuming with 6 days left adds those days back.
      final p = paused.copyWith(cycleSetAsideCents: 3000);
      expect(
        cycleSetAsideAfterChange(
          before: p,
          after: p.copyWith(paused: false),
          daysLeft: 6,
        ),
        9000,
      );
    });

    test('a slower pace always holds less, even when under-held', () {
      // Holds $60 this cycle though $10/day × 10 days would be $100 (a share
      // scaled down when per-goal amounts started being tracked).
      final held = fund.copyWith(cycleSetAsideCents: 6000);
      final slower = held.copyWith(dailySetAsideCents: 800);
      expect(
        cycleSetAsideAfterChange(before: held, after: slower, daysLeft: 10),
        4000, // $2/day less for 10 days
      );
      final faster = held.copyWith(dailySetAsideCents: 1500);
      expect(
        cycleSetAsideAfterChange(before: held, after: faster, daysLeft: 10),
        11000,
      );
    });

    test('a lower target caps what is held', () {
      final held = fund.copyWith(savedCents: 10000, cycleSetAsideCents: 9000);
      expect(
        cycleSetAsideAfterChange(
          before: held,
          after: held.copyWith(targetCents: 15000),
          daysLeft: 5,
        ),
        5000, // only $50 still needed
      );
    });

    test('topping up to the target releases the rest', () {
      final held = fund.copyWith(savedCents: 290000, cycleSetAsideCents: 10000);
      expect(
        cycleSetAsideAfterChange(
          before: held,
          after: held.copyWith(savedCents: 300000),
          daysLeft: 5,
        ),
        0,
      );
    });

    test('older goals share the cycle total by their daily amounts', () {
      final goals = withCycleSetAsides(
        [
          fund,
          fund.copyWith(dailySetAsideCents: 500).withId('b'),
          fund.copyWith(paused: true).withId('c'),
        ],
        14999,
        10,
      );
      expect(goals.map((g) => g.cycleSetAsideCents), [10000, 4999, 0]);
    });

    test('payday moves each goal its own amount, not a share of the total', () {
      // Fund held $130 all cycle; Laptop started late and holds $20.
      final next = startNewCycle(
        start: oct15,
        current: const CyclePlan(
          startDate: oct2,
          openingBalanceCents: 139200,
          goalSetAsideCents: 15000,
        ),
        entries: const [],
        goals: [
          fund.copyWith(cycleSetAsideCents: 13000),
          fund
              .copyWith(dailySetAsideCents: 1000, cycleSetAsideCents: 2000)
              .withId('laptop'),
        ],
        frequency: PayFrequency.monthly,
      );
      expect(next.goals.map((g) => g.savedCents), [13000, 2000]);
      // Both hold the full new 31-day cycle.
      expect(next.goals.map((g) => g.cycleSetAsideCents), [31000, 31000]);
      expect(next.plan.goalSetAsideCents, 62000);
    });
  });
}

extension on Goal {
  Goal withId(String id) => Goal(
    id: id,
    name: name,
    kind: kind,
    targetCents: targetCents,
    savedCents: savedCents,
    dailySetAsideCents: dailySetAsideCents,
    paused: paused,
    cycleSetAsideCents: cycleSetAsideCents,
  );
}
