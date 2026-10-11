import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/core/money.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('Today shows the design numbers from sample data', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Friday, Oct 2'), findsOneWidget);
    expect(find.text(r'$46.20'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
    expect(find.text(r'Spent $17.80 of $64.00'), findsOneWidget);
    expect(find.text('Payday Oct 15'), findsOneWidget);
    expect(find.text('Corner coffee', skipOffstage: false), findsOneWidget);
    expect(find.text('Gas station', skipOffstage: false), findsOneWidget);
    expect(find.textContaining(r'$359.98 reserved'), findsOneWidget);
  });

  testWidgets('Overspending switches to the S4 state with tomorrow\'s number', (
    tester,
  ) async {
    final store = await pumpApp(tester);

    store.addEntry(
      Entry(
        id: 'big',
        type: EntryType.spend,
        amountCents: 5860, // brings today to $76.40
        localDate: oct2,
        createdAtUtc: DateTime.now().toUtc(),
        timeZoneId: 'UTC',
        merchant: 'Groceries',
        categoryId: 'food',
        planned: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('−\$12.40'), findsOneWidget);
    expect(find.text(r'Over by $12.40'), findsOneWidget);
    expect(find.textContaining(r"Tomorrow's number: $62.96"), findsOneWidget);
  });

  testWidgets('Tapping the hero opens the breakdown', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(r'$46.20'));
    await tester.pumpAndSettle();

    expect(find.text("How today's number works"), findsOneWidget);
    expect(find.text(r'$832.02'), findsOneWidget);
    expect(find.text('÷ 13'), findsOneWidget);
  });

  testWidgets('Logging a spend updates Today (live preview, then saved)', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Log spend').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '23.40');
    await tester.pump();

    // Live preview in the footer: $46.20 → $22.80.
    expect(find.text('\$46.20 → \$22.80'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('\$22.80'), findsOneWidget);
  });

  testWidgets('Overspent: S4 offers the fix, Spread it out returns to Today', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    store.addEntry(
      Entry(
        id: 'big',
        type: EntryType.spend,
        amountCents: 5860,
        localDate: oct2,
        createdAtUtc: DateTime.now().toUtc(),
        timeZoneId: 'UTC',
        merchant: 'Groceries',
        categoryId: 'food',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Spread it out (recommended)'), findsOneWidget);
    expect(find.text('Cover it from Fun instead'), findsOneWidget);
    // What covering does, before choosing: tomorrow stays at today's level.
    expect(
      find.textContaining(
        RegExp(
          r'^Fun has \$[\d.,]+ left of its monthly limit\. Covering \$12\.40',
        ),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Log spend'), findsNothing); // S4 shows only the fix

    await tester.tap(find.text('Spread it out (recommended)'));
    await tester.pumpAndSettle();
    expect(find.text('Sorted.'), findsOneWidget);
    expect(find.text('Log spend'), findsOneWidget);
  });

  testWidgets('Swipe an entry left to delete it, then Undo', (tester) async {
    final store = await pumpApp(tester);
    expect(find.text(r'$46.20'), findsOneWidget);

    // Scroll the row out from under the floating tab bar first.
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.fling(find.text('Corner coffee'), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(
      store.todayEntries.map((e) => e.merchant),
      isNot(contains('Corner coffee')),
    );
    expect(find.text('Corner coffee'), findsNothing);
    expect(find.text(r'$51.60'), findsOneWidget); // $46.20 + $5.40

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Corner coffee'), findsOneWidget);
    expect(find.text(r'$46.20'), findsOneWidget);
  });

  testWidgets('logging a reserved bill as a spend offers Mark as paid', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    final bill = store.upcomingBills.first;
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.logSpend);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      '${bill.amountCents / 100}',
    );
    await tester.enterText(find.byType(TextField).at(1), bill.name);
    await tester.pumpAndSettle();
    final spentBefore = store.dailyNumber.spentTodayCents;

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Is this your ${bill.name} bill?'), findsOneWidget);

    await tester.tap(find.text('Mark ${bill.name} as paid'));
    await tester.pumpAndSettle();
    // Paid from its reservation: not counted as today's spending.
    expect(store.dailyNumber.spentTodayCents, spentBefore);
    expect(store.bills.firstWhere((b) => b.id == bill.id).lastPaidOn, oct2);
  });

  testWidgets('"No, it\'s a normal spend" logs it as before', (tester) async {
    final store = await pumpApp(tester);
    final bill = store.upcomingBills.first;
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.logSpend);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), bill.name);
    await tester.pumpAndSettle();
    final spentBefore = store.dailyNumber.spentTodayCents;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("No, it's a normal spend"));
    await tester.pumpAndSettle();
    expect(store.dailyNumber.spentTodayCents, spentBefore + 1200);
  });

  testWidgets('the hero says why the number moved; the sheet shows the sums', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    // Same as yesterday in the sample: no change line.
    expect(find.textContaining('from yesterday'), findsNothing);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    store.addEntry(
      Entry(
        id: 'yesterday-big',
        type: EntryType.spend,
        amountCents: 10000,
        localDate: oct2.addDays(-1),
        createdAtUtc: DateTime.now().toUtc(),
        timeZoneId: 'UTC',
        merchant: 'Concert tickets',
        categoryId: 'fun',
        planned: false,
      ),
    );
    await tester.pumpAndSettle();
    final change = store.numberChange!;
    expect(change.totalCents, lessThan(0));
    expect(
      find.textContaining('from yesterday: you spent more'),
      findsOneWidget,
    );

    await tester.tap(find.text('Safe to spend today'));
    await tester.pumpAndSettle();
    expect(find.text('Since yesterday'), findsOneWidget);
    expect(find.text("Yesterday's number"), findsOneWidget);
    expect(find.text(r'$64.00'), findsOneWidget);
    expect(find.textContaining("Over yesterday's number"), findsOneWidget);
    expect(find.text('Worked out'), findsOneWidget);
  });

  testWidgets('a new cycle opens its summary once; the banner reopens it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2)..payWontCome();
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();

    expect(find.text('Left when it ended'), findsOneWidget);
    expect(find.text('Moved into your goals'), findsOneWidget);
    expect(
      find.textContaining(
        'Your daily number (÷ ${store.dailyNumber.daysLeft} days)',
      ),
      findsOneWidget,
    );
    final carried = formatMoney(
      store.cycleSummary!.carriedOverCents,
      symbol: r'$',
    );
    expect(find.text(carried), findsNWidgets(2)); // end of last, start of this

    // Close it: it doesn't come back by itself.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('Left when it ended'), findsNothing);
    store.notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text('Left when it ended'), findsNothing);

    await tester.tap(find.text('See what carried over'));
    await tester.pumpAndSettle();
    expect(find.text('Left when it ended'), findsOneWidget);
  });

  testWidgets('a big bill just after payday gets a heads-up', (tester) async {
    final store = await pumpApp(tester);
    final daily = store.dailyNumber.dailyAllowanceCents;
    store.addBill(
      Bill(
        id: 'rent2',
        name: 'Storage unit',
        amountCents: 9000,
        recurrence: Recurrence.monthly,
        dueDate: store.nextPayday.addDays(1),
      ),
    );
    await tester.pumpAndSettle();
    // Not reserved this cycle: today's number is unchanged.
    expect(store.dailyNumber.dailyAllowanceCents, daily);
    expect(
      find.text(
        r'Storage unit ($90.00) is due the day after payday. '
        'It comes from your next pay.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    // The Bills tab explains it.
    await tester.tap(find.text('Bills').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Right after payday', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining(r'keep $90.00 in your account', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Storage Unit', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Oct 16 · the day after payday', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Log spend warns about a category limit as you type', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    final food = store.categoryById('food')!;
    final left = store.leftThisMonth(food)!;
    String whole(int c) => formatMoney(c, symbol: r'$', showCents: false);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.logSpend);
    await tester.pumpAndSettle();
    expect(
      find.text('Food: ${whole(left)} left of \$420 this month.'),
      findsOneWidget,
    );

    // Leave exactly 10% of the limit: getting close.
    final close = left - 4200;
    await tester.enterText(find.byType(TextField).first, '${close / 100}');
    await tester.pumpAndSettle();
    expect(
      find.text(
        r'Food: $42 left of $420 this month after this. Getting close.',
      ),
      findsOneWidget,
    );

    // $10 past the limit.
    await tester.enterText(
      find.byType(TextField).first,
      '${(left + 1000) / 100}',
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining(r'This takes Food $10 over its $420 monthly limit.'),
      findsOneWidget,
    );

    // Health has no limit: no line.
    await tester.tap(find.text('Health'));
    await tester.pumpAndSettle();
    expect(find.textContaining('monthly limit'), findsNothing);
    expect(find.textContaining('this month'), findsNothing);
  });
}
