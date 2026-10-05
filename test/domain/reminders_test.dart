import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/reminders.dart';
import 'package:steady/ui/routes.dart';

void main() {
  // Friday, Oct 2 2026, 3:00 PM.
  final now = DateTime(2026, 10, 2, 15);
  const allOff = ReminderSettings.off;

  AppSettings settings(
    ReminderSettings r, {
    PayFrequency pay = PayFrequency.monthly,
    LocalDate? lastBackupOn,
  }) => AppSettings(
    currency: Currency.usd,
    payFrequency: pay,
    nextPayday: const LocalDate(2026, 10, 15),
    reminders: r,
    lastBackupOn: lastBackupOn,
  );

  List<PlannedNotification> plan(
    ReminderSettings r, {
    List<Bill> bills = const [],
    bool loggedToday = false,
    PayFrequency pay = PayFrequency.monthly,
    LocalDate? lastBackupOn,
  }) => planNotifications(
    now: now,
    settings: settings(r, pay: pay, lastBackupOn: lastBackupOn),
    bills: bills,
    loggedToday: loggedToday,
  );

  Iterable<DateTime> times(List<PlannedNotification> p, ReminderKind k) =>
      p.where((n) => n.kind == k).map((n) => n.at);

  test('nothing is planned with every reminder off', () {
    expect(plan(allOff), isEmpty);
  });

  group('log your spends', () {
    final on = allOff.copyWith(logSpends: true);

    test('every day at the chosen time for a week', () {
      final t = times(plan(on), ReminderKind.logSpends).toList();
      expect(t.length, 7);
      expect(t.first, DateTime(2026, 10, 2, 20, 30));
      expect(t.last, DateTime(2026, 10, 8, 20, 30));
    });

    test("skips today once something is logged, and today's past times", () {
      expect(
        times(plan(on, loggedToday: true), ReminderKind.logSpends).first,
        DateTime(2026, 10, 3, 20, 30),
      );
      final early = on.copyWith(logAtMinutes: 13 * 60);
      expect(
        times(plan(early), ReminderKind.logSpends).first,
        DateTime(2026, 10, 3, 13),
      );
    });
  });

  group('payday reminder', () {
    final on = allOff.copyWith(payday: true);
    Iterable<PlannedNotification> payday(
      ReminderSettings r, {
      PayFrequency pay = PayFrequency.monthly,
    }) => plan(r, pay: pay).where((n) => n.kind == ReminderKind.payday);

    test('on the morning of a regular payday, 9 AM by default', () {
      expect(payday(on).single.at, DateTime(2026, 10, 15, 9));
      expect(payday(on).single.route, Routes.paidPrompt);
    });

    test('at the time you choose', () {
      final p = payday(on.copyWith(paydayAtMinutes: 7 * 60 + 30));
      expect(p.single.at, DateTime(2026, 10, 15, 7, 30));
    });

    test('its own switch: independent of "Log your spends"', () {
      expect(payday(allOff.copyWith(logSpends: true)), isEmpty);
      expect(payday(on), hasLength(1));
    });

    test('none for pay that varies (no fixed payday)', () {
      expect(payday(on, pay: PayFrequency.varies), isEmpty);
    });
  });

  test('bills: 2 days before and the morning of, every occurrence', () {
    final bills = [
      Bill(
        id: 'rent',
        name: 'Rent',
        amountCents: 145000,
        recurrence: Recurrence.monthly,
        dueDate: const LocalDate(2026, 10, 8),
      ),
      Bill(
        id: 'gym',
        name: 'Gym',
        amountCents: 2000,
        recurrence: Recurrence.weekly,
        dueDate: const LocalDate(2026, 10, 3), // 2 days before is past
        isEstimate: true,
      ),
    ];
    final p = plan(allOff.copyWith(billsDue: true), bills: bills);
    final rent = p.where((n) => n.title.startsWith('Rent')).toList();
    expect(rent.map((n) => n.at), [
      DateTime(2026, 10, 6, 9),
      DateTime(2026, 10, 8, 9),
    ]);
    expect(rent.first.title, 'Rent due in 2 days');
    expect(rent.first.body, r'$1,450.00 on Oct 8 · already set aside');
    expect(rent.last.title, 'Rent is due today');

    final gym = p.where((n) => n.title.startsWith('Gym')).toList();
    expect(gym.first.at, DateTime(2026, 10, 3, 9)); // morning of, not before
    expect(gym.first.body, r'About $20.00 · already set aside');
    // A due date after payday isn't set aside yet.
    expect(gym.firstWhere((n) => n.at.day == 17).body, r'About $20.00');
  });

  test('quiet hours move reminders to 7 AM, and drop the 10 PM pause', () {
    final r = allOff.copyWith(
      logSpends: true,
      logAtMinutes: 23 * 60 + 30,
      latePause: true,
      quietFromMinutes: 22 * 60,
    );
    final p = plan(r);
    expect(times(p, ReminderKind.logSpends).first, DateTime(2026, 10, 3, 7));
    expect(times(p, ReminderKind.latePause), isEmpty);

    final pause = plan(allOff.copyWith(latePause: true));
    expect(
      times(pause, ReminderKind.latePause).first,
      DateTime(2026, 10, 2, 22),
    );

    final midnight = plan(
      allOff.copyWith(
        logSpends: true,
        logAtMinutes: 30, // 12:30 AM
        quietFromMinutes: 0,
      ),
    );
    expect(
      times(midnight, ReminderKind.logSpends).first,
      DateTime(2026, 10, 3, 7),
    );
  });

  test('recaps: Sunday evening and the 1st of the month', () {
    final p = plan(allOff.copyWith(recaps: true));
    expect(times(p, ReminderKind.weeklyRecap), [
      DateTime(2026, 10, 4, 18),
      DateTime(2026, 10, 11, 18),
    ]);
    expect(times(p, ReminderKind.monthlyRecap), isEmpty); // Nov 1 is later
    final late = planNotifications(
      now: DateTime(2026, 10, 25, 12),
      settings: settings(allOff.copyWith(recaps: true)),
      bills: const [],
      loggedToday: false,
    );
    final month = late.where((n) => n.kind == ReminderKind.monthlyRecap);
    expect(month.single.at, DateTime(2026, 11, 1, 9));
    expect(month.single.title, 'Your October recap');
  });

  test('backup: on the 1st, unless one was made recently', () {
    final r = allOff.copyWith(backupMonthly: true);
    expect(times(plan(r), ReminderKind.backup), [DateTime(2026, 11, 1, 10)]);
    expect(
      times(
        plan(r, lastBackupOn: const LocalDate(2026, 10, 20)),
        ReminderKind.backup,
      ),
      isEmpty,
    );
  });

  test('soonest first, capped for the iOS limit', () {
    final everything = planNotifications(
      now: now,
      settings: settings(const ReminderSettings(recaps: true)),
      bills: [
        for (var i = 0; i < 20; i++)
          Bill(
            id: 'b$i',
            name: 'Bill $i',
            amountCents: 100,
            recurrence: Recurrence.weekly,
            dueDate: LocalDate(2026, 10, 3 + i % 7),
          ),
      ],
      loggedToday: false,
    );
    expect(everything.length, 60);
    for (var i = 1; i < everything.length; i++) {
      expect(everything[i].at.isBefore(everything[i - 1].at), isFalse);
    }
  });

  group('debt reminders', () {
    final on = allOff.copyWith(debtsOwedToYou: true);
    DebtReminder sam({
      int cents = 3000,
      bool owedToYou = true,
      LocalDate since = const LocalDate(2026, 9, 30),
      bool muted = false,
      LocalDate? snoozedUntil,
    }) => DebtReminder(
      personId: 'person-sam',
      name: 'Sam',
      cents: cents,
      owedToYou: owedToYou,
      since: since,
      groups: 'Goa trip',
      muted: muted,
      snoozedUntil: snoozedUntil,
    );
    List<PlannedNotification> debts(ReminderSettings r, List<DebtReminder> d) =>
        planNotifications(
          now: now,
          settings: settings(r),
          bills: const [],
          loggedToday: false,
          debts: d,
        ).where((n) => n.kind == ReminderKind.debt).toList();

    test('a week after the oldest expense, then weekly, at your time', () {
      final p = debts(on, [sam()]);
      expect(p.map((n) => n.at), [
        DateTime(2026, 10, 7, 20, 30),
        DateTime(2026, 10, 14, 20, 30),
      ]);
      expect(p.first.title, r'Sam owes you $30.00');
      expect(p.first.body, startsWith('Goa trip · since Sep 30'));
      expect(p.first.route, '/splits/settle#person-sam');
    });

    test('long overdue keeps the weekly rhythm', () {
      // Since Sep 1 → first Sep 8, then 15, 22, 29, Oct 6, 13…
      final p = debts(on, [sam(since: const LocalDate(2026, 9, 1))]);
      expect(p.first.at, DateTime(2026, 10, 6, 20, 30));
    });

    test('skips small amounts, muted people and snoozed weeks', () {
      expect(debts(on, [sam(cents: 499)]), isEmpty);
      expect(debts(on, [sam(muted: true)]), isEmpty);
      final snoozed = debts(on, [
        sam(snoozedUntil: const LocalDate(2026, 10, 10)),
      ]);
      expect(snoozed.map((n) => n.at), [DateTime(2026, 10, 14, 20, 30)]);
    });

    test('"you owe" only when switched on', () {
      expect(debts(on, [sam(owedToYou: false)]), isEmpty);
      final p = debts(on.copyWith(debtsYouOwe: true), [sam(owedToYou: false)]);
      expect(p.first.title, r'You owe Sam $30.00');
    });
  });

  test('routes match the app routes', () {
    expect(ReminderRoutes.logSpend, Routes.logSpend);
    expect(ReminderRoutes.paidPrompt, Routes.paidPrompt);
    expect(ReminderRoutes.bills, Routes.bills);
    expect(ReminderRoutes.afford, Routes.afford);
    expect(ReminderRoutes.summaryWeek, Routes.summaryWeek);
    expect(ReminderRoutes.summaryMonth, Routes.summaryMonth);
    expect(ReminderRoutes.backup, Routes.backup);
    expect(ReminderRoutes.settleUp, Routes.settleUp);
  });
}
