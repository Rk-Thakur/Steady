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

    test('asks about regular pay on payday, not for pay that varies', () {
      final p = plan(on).where((n) => n.kind == ReminderKind.payday);
      expect(p.single.at, DateTime(2026, 10, 15, 9));
      expect(p.single.route, Routes.paidPrompt);
      expect(
        plan(
          on,
          pay: PayFrequency.varies,
        ).where((n) => n.kind == ReminderKind.payday),
        isEmpty,
      );
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

  test('routes match the app routes', () {
    expect(ReminderRoutes.logSpend, Routes.logSpend);
    expect(ReminderRoutes.paidPrompt, Routes.paidPrompt);
    expect(ReminderRoutes.bills, Routes.bills);
    expect(ReminderRoutes.afford, Routes.afford);
    expect(ReminderRoutes.summaryWeek, Routes.summaryWeek);
    expect(ReminderRoutes.summaryMonth, Routes.summaryMonth);
    expect(ReminderRoutes.backup, Routes.backup);
  });
}
