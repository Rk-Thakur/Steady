import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
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
    expect(find.text('Corner coffee'), findsOneWidget);
    expect(find.text('Gas station'), findsOneWidget);
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
    expect(find.textContaining(r'$62.96'), findsOneWidget);
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
    expect(find.text('Take it from Fun money instead'), findsOneWidget);
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
}
