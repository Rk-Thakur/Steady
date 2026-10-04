import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/insights.dart';
import 'package:steady/domain/models/models.dart';

void main() {
  // Sun Sep 20 – Sat Sep 26, 2026; "today" is the following Friday.
  const sun = LocalDate(2026, 9, 20);
  const today = LocalDate(2026, 10, 2);
  const categories = [
    BudgetCategory(id: 'food', name: 'Food'),
    BudgetCategory(id: 'fun', name: 'Fun'),
    BudgetCategory(id: 'bills', name: 'Bills & subs'),
  ];

  var n = 0;
  Entry spend(
    LocalDate day,
    int cents, {
    String category = 'food',
    Mood? mood,
    bool? planned,
    String? billId,
    int hour = 12,
  }) => Entry(
    id: 'e${n++}',
    type: EntryType.spend,
    amountCents: cents,
    localDate: day,
    createdAtUtc: DateTime(day.year, day.month, day.day, hour).toUtc(),
    timeZoneId: 'local',
    categoryId: category,
    mood: mood,
    planned: planned,
    billId: billId,
  );

  Entry income(
    LocalDate day,
    int cents, {
    bool toVault = false,
    bool fromVault = false,
  }) => Entry(
    id: 'e${n++}',
    type: EntryType.income,
    amountCents: cents,
    localDate: day,
    createdAtUtc: DateTime.utc(day.year, day.month, day.day),
    timeZoneId: 'UTC',
    toVault: toVault,
    fromVault: fromVault,
  );

  group('periods', () {
    test('a week starts on the chosen weekday', () {
      expect(
        Period.weekOf(today, DateTime.sunday),
        const Period(LocalDate(2026, 9, 27), LocalDate(2026, 10, 3)),
      );
      expect(
        Period.weekOf(today, DateTime.monday),
        const Period(LocalDate(2026, 9, 28), LocalDate(2026, 10, 4)),
      );
      expect(Period.weekOf(sun, DateTime.sunday).start, sun);
    });

    test('months know their length, and the previous month', () {
      final feb = Period.monthOf(const LocalDate(2028, 2, 10));
      expect(feb.days, 29);
      expect(feb.previous, Period.monthOf(const LocalDate(2028, 1, 1)));
      expect(
        Period.monthOf(const LocalDate(2026, 12, 31)).end,
        const LocalDate(2026, 12, 31),
      );
    });

    test('the summary opens on the last finished period, or this one for a new user', () {
      final lastWeek = Period.weekOf(sun, DateTime.sunday);
      expect(
        summaryPeriodFor(
          today: today,
          isMonth: false,
          weekStartsOn: DateTime.sunday,
          entries: [spend(sun, 100)],
        ),
        lastWeek,
      );
      expect(
        summaryPeriodFor(
          today: today,
          isMonth: false,
          weekStartsOn: DateTime.sunday,
          entries: [spend(today, 100)],
        ),
        Period.weekOf(today, DateTime.sunday),
      );
    });
  });

  group('weekly summary', () {
    final week = Period.weekOf(sun, DateTime.sunday);
    final thu = sun.addDays(4);
    final entries = [
      income(sun, 82000),
      income(sun, 50000, toVault: true), // parked, not "in" yet
      income(sun.addDays(1), 78000, fromVault: true), // released: in
      spend(sun, 4300),
      spend(thu, 6000, mood: Mood.tired, planned: false),
      spend(thu, 2800, category: 'fun', mood: Mood.happy),
      spend(sun.addDays(2), 150000, category: 'bills', billId: 'rent'),
      spend(sun.addDays(-1), 9999), // the week before
    ];
    final numbers = {for (final d in week.dates) d: 6400};

    PeriodSummary run({Map<LocalDate, int>? dailyNumbers, LocalDate? asOf}) =>
        summarize(
          period: week,
          isMonth: false,
          today: asOf ?? today,
          entries: entries,
          categories: categories,
          goals: const [
            Goal(
              id: 'g',
              name: 'Emergency fund',
              targetCents: 100000,
              savedCents: 0,
              dailySetAsideCents: 500,
            ),
            Goal(
              id: 'p',
              name: 'Paused',
              targetCents: 100000,
              savedCents: 0,
              dailySetAsideCents: 500,
              paused: true,
            ),
          ],
          dailyNumbers: dailyNumbers ?? numbers,
          fallbackPaceCents: 5000,
        );

    test('in, spent, saved and left over', () {
      final s = run();
      expect(s.inCents, 82000 + 78000);
      expect(s.spentCents, 4300 + 6000 + 2800 + 150000); // bills count as spent
      expect(s.savings.single.name, 'Emergency fund');
      expect(s.savedCents, 7 * 500);
      expect(s.leftOverCents, s.inCents - s.spentCents - s.savedCents);
    });

    test(
      'daily bars leave bill payments out, and flag days over the number',
      () {
        final s = run();
        expect(s.bars.map((b) => b.label), ['S', 'M', 'T', 'W', 'T', 'F', 'S']);
        expect(s.bars.map((b) => b.cents), [4300, 0, 0, 0, 8800, 0, 0]);
        expect(s.bars.map((b) => b.over), [
          false,
          false,
          false,
          false,
          true,
          false,
          false,
        ]);
        expect(s.paceCents, 6400);
        expect(s.daysUnder, 6);
        expect(s.daysCounted, 7);
        expect(s.categories.map((c) => c.name), [
          'Bills & subs',
          'Food',
          'Fun',
        ]);
      },
    );

    test('"worth a look" names the biggest day and what drove it', () {
      final b = run().biggest!;
      expect(b.bar.start, thu);
      expect(b.overByCents, 8800 - 6400);
      expect(b.topCategory, 'Food');
      expect(b.topMood, Mood.tired);
    });

    test('days without a recorded number are not counted', () {
      final s = run(dailyNumbers: {sun: 6400, thu: 9000});
      expect(s.daysCounted, 2);
      expect(s.daysUnder, 2);
      expect(s.paceCents, (6400 + 9000) ~/ 2);
      // Without any record, the pace falls back to today's number.
      expect(run(dailyNumbers: {}).paceCents, 5000);
    });

    test('the current week counts only finished days and days so far', () {
      final s = run(asOf: thu);
      expect(s.daysCounted, 4); // Sun–Wed; Thursday isn't over yet
      expect(s.savedCents, 5 * 500);
    });
  });

  test('monthly bars group by 7 days against a weekly pace', () {
    final sept = Period.monthOf(sun);
    final s = summarize(
      period: sept,
      isMonth: true,
      today: today,
      entries: [
        spend(const LocalDate(2026, 9, 3), 50000),
        spend(const LocalDate(2026, 9, 29), 1000),
      ],
      categories: categories,
      goals: const [],
      dailyNumbers: {for (final d in sept.dates) d: 6400},
      fallbackPaceCents: 0,
    );
    expect(s.bars.map((b) => b.label), [
      'Wk 1',
      'Wk 2',
      'Wk 3',
      'Wk 4',
      'Wk 5',
    ]);
    expect(s.paceCents, 6400 * 7);
    expect(s.bars.first.over, isTrue);
    expect(s.biggest!.overByCents, 50000 - 6400 * 7);
  });

  test('a goal started mid-week only counts its days since then', () {
    final week = Period.weekOf(sun, DateTime.sunday);
    final s = summarize(
      period: week,
      isMonth: false,
      today: today,
      entries: const [],
      categories: categories,
      goals: [
        Goal(
          id: 'new',
          name: 'New',
          targetCents: 100000,
          savedCents: 0,
          dailySetAsideCents: 500,
          createdOn: sun.addDays(5), // Friday
        ),
        Goal(
          id: 'later',
          name: 'Later',
          targetCents: 100000,
          savedCents: 0,
          dailySetAsideCents: 500,
          createdOn: today,
        ),
      ],
      dailyNumbers: const {},
      fallbackPaceCents: 0,
    );
    expect(s.savings.map((g) => (g.name, g.cents)), [('New', 2 * 500)]);
  });

  group('insights', () {
    final period = Period.lastDays(today, 30);

    test('moods, planned share and the biggest trigger', () {
      final i = spendingInsights(
        period: period,
        categories: categories,
        entries: [
          spend(today, 6000, mood: Mood.tired, planned: false),
          spend(today.addDays(-3), 8200, mood: Mood.tired, planned: false),
          spend(today, 3000, category: 'fun', mood: Mood.tired),
          spend(
            today,
            9600,
            category: 'fun',
            mood: Mood.stressed,
            planned: true,
          ),
          spend(today, 2000), // untagged → neutral
          spend(
            today,
            150000,
            category: 'bills',
            billId: 'rent',
            planned: true,
          ), // not everyday
          spend(today.addDays(-31), 99900, mood: Mood.bored), // outside window
        ],
      );
      expect(i.byMood[Mood.tired], 17200);
      expect(i.byMood[Mood.stressed], 9600);
      expect(i.byMood[Mood.bored], 0);
      expect(i.byMood[Mood.neutral], 2000);
      expect(i.topMood, Mood.tired);
      expect(i.trigger, (mood: Mood.tired, category: 'Food', cents: 14200));
      expect(i.plannedCents, 9600);
      expect(i.unplannedCents, 14200);
    });

    test('late night means logged 10 PM – 4 AM on the same day', () {
      final i = spendingInsights(
        period: period,
        categories: categories,
        entries: [
          spend(today, 1000, hour: 23),
          spend(today, 1000, hour: 2),
          spend(today, 1000, hour: 21),
        ],
      );
      expect(i.lateNightCount, 2);
      expect(i.lateNightCents, 2000);
      expect(
        spendingInsights(
          period: period,
          categories: categories,
          entries: const [],
        ).trigger,
        isNull,
      );
    });
  });
}
