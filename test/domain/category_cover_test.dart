import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/category_cover.dart';
import 'package:steady/domain/daily_number.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// S4 "Take it from Fun money": the overspend is covered by what's left of
/// Fun this month instead of being spread; the cover shrinks if Fun spending
/// later eats into it.
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  const fun = BudgetCategory(id: 'fun', name: 'Fun', monthlyLimitCents: 9000);
  var n = 0;

  Entry spend(
    LocalDate day,
    int cents, {
    String category = 'fun',
    String? billId,
  }) => Entry(
    id: 'e${n++}',
    type: EntryType.spend,
    amountCents: cents,
    localDate: day,
    createdAtUtc: DateTime.utc(2026),
    timeZoneId: 'UTC',
    categoryId: category,
    billId: billId,
  );

  const take = OverspendDecision(
    OverspendStrategy.takeFromCategory,
    categoryId: 'fun',
    amountCents: 1240,
  );

  int cover(
    LocalDate today,
    List<Entry> entries, {
    Map<LocalDate, OverspendDecision>? decisions,
    LocalDate cycleStart = const LocalDate(2026, 9, 30),
  }) => categoryCoverCents(
    today: today,
    cycleStart: cycleStart,
    decisions: decisions ?? {oct2: take},
    entries: entries,
    categories: const [fun],
  );

  group('rules', () {
    test('covers from the day after the choice, not the same day', () {
      expect(cover(oct2, const []), 0);
      expect(cover(oct2.addDays(1), const []), 1240);
    });

    test('shrinks as Fun spending eats into what was left', () {
      final tomorrow = oct2.addDays(1);
      // $90 limit, $12.40 taken: $77.60 can still be spent on fun.
      expect(cover(tomorrow, [spend(oct2, 7760)]), 1240);
      expect(cover(tomorrow, [spend(oct2, 8260)]), 740); // $5 too far
      expect(cover(tomorrow, [spend(oct2, 9500)]), 0);
      // Bill payments and other categories don't count against Fun.
      expect(
        cover(tomorrow, [
          spend(oct2, 9000, category: 'food'),
          spend(oct2, 9000, billId: 'x'),
        ]),
        1240,
      );
    });

    test('ends with the pay cycle, and needs the category and its limit', () {
      expect(
        cover(oct2.addDays(20), const [], cycleStart: oct2.addDays(13)),
        0,
      );
      expect(
        categoryCoverCents(
          today: oct2.addDays(1),
          cycleStart: oct2,
          decisions: {oct2: take},
          entries: const [],
          categories: const [
            BudgetCategory(id: 'fun', name: 'Fun'), // limit removed
          ],
        ),
        0,
      );
    });

    test("Fun spending only counts in the decision's own month", () {
      const sep30 = LocalDate(2026, 9, 30);
      expect(
        cover(
          oct2,
          [spend(oct2, 9000)], // October fun spending
          decisions: {sep30: take},
          cycleStart: const LocalDate(2026, 9, 20),
        ),
        1240,
      );
    });

    test("what's left counts spending and what was taken", () {
      expect(
        leftInCategoryThisMonth(fun, oct2, [spend(oct2, 2000)], {oct2: take}),
        9000 - 2000 - 1240,
      );
      expect(
        leftInCategoryThisMonth(
          const BudgetCategory(id: 'x', name: 'X'),
          oct2,
          const [],
          const {},
        ),
        isNull,
      );
    });
  });

  group('in the app', () {
    late LocalDate today;
    BudgetStore overspentStore() {
      today = oct2;
      final store = BudgetStore.sample(clock: () => today);
      // $17.80 spent of $64.00; another $58.60 makes it $12.40 over.
      store.addEntry(spend(oct2, 5860, category: 'food'));
      return store;
    }

    test("tomorrow's number isn't lowered, and Fun's limit is unchanged", () {
      final store = overspentStore();
      expect(store.dailyNumber.overspentByCents, 1240);
      final fun = store.categoryById('fun')!;
      final leftBefore = store.leftThisMonth(fun)!;
      final spread = store.tomorrowNumber.safeToSpendCents;

      store.handleOverspend(
        OverspendStrategy.takeFromCategory,
        categoryId: 'fun',
        overCents: 1240,
      );
      // As if today had ended exactly on the number.
      final i = store.dailyNumber.input;
      final unharmed = DailyNumberCalculator.tomorrow(
        DailyNumberCalculator.calculate(
          DailyNumberInput(
            today: i.today,
            nextPayday: i.nextPayday,
            moneyAtStartOfDayCents: i.moneyAtStartOfDayCents,
            unpaidBillsBeforePaydayCents: i.unpaidBillsBeforePaydayCents,
            goalSetAsidesCents: i.goalSetAsidesCents,
            spentTodayCents: store.dailyNumber.dailyAllowanceCents,
          ),
        ),
      ).safeToSpendCents;
      expect(store.tomorrowNumber.safeToSpendCents, unharmed);
      expect(store.tomorrowNumber.safeToSpendCents, greaterThan(spread));
      expect(store.leftThisMonth(fun), leftBefore - 1240);
      expect(store.categoryById('fun')!.monthlyLimitCents, 9000);

      // And it really is tomorrow's number once tomorrow comes.
      today = oct2.addDays(1);
      store.onClockTick();
      expect(store.dailyNumber.safeToSpendCents, unharmed);
    });

    test('Fun spending past what was left is spread after all', () {
      final store = overspentStore();
      store.handleOverspend(
        OverspendStrategy.takeFromCategory,
        categoryId: 'fun',
        overCents: 1240,
      );
      today = oct2.addDays(1);
      store.onClockTick();
      final before = store.dailyNumber;
      final left = store.leftThisMonth(store.categoryById('fun')!)!;

      // Within what's left: only today's spending changes.
      final within = store.previewWith(spend(today, left));
      expect(within.dailyAllowanceCents, before.dailyAllowanceCents);
      // $10 beyond it: $10 of the cover is gone, spread over the days left.
      final beyond = store.previewWith(spend(today, left + 1000));
      expect(beyond.dailyAllowanceCents, lessThan(before.dailyAllowanceCents));
    });

    testWidgets('S4: Take it from Fun money keeps tomorrow\'s number', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = overspentStore();
      await tester.pumpWidget(
        SteadyApp(store: store, initialRoute: Routes.home),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cover it from Fun instead'));
      await tester.pumpAndSettle();
      expect(find.text('Sorted.'), findsOneWidget);
      expect(
        find.textContaining("came out of what's left of Fun this month"),
        findsOneWidget,
      );
      expect(find.textContaining('Spend less on fun'), findsOneWidget);
    });
  });

  test('limit levels: fine under 80%, close from 80%, over past it', () {
    expect(
      limitLevel(limitCents: 10000, leftAfterCents: 2001),
      LimitLevel.fine,
    );
    expect(
      limitLevel(limitCents: 10000, leftAfterCents: 2000),
      LimitLevel.close,
    );
    expect(limitLevel(limitCents: 10000, leftAfterCents: 0), LimitLevel.close);
    expect(limitLevel(limitCents: 10000, leftAfterCents: -1), LimitLevel.over);
  });
}
