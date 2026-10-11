import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/bills/bill_tile.dart';
import 'package:steady/ui/routes.dart';

/// Bills radar rows: countdown, pills, detail line, and tap to edit.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> openRadar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2000); // whole list on screen
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2)
      ..addBill(
        const Bill(
          id: 'late',
          name: 'Gym',
          amountCents: 3000,
          recurrence: Recurrence.monthly,
          dueDate: LocalDate(2026, 9, 29), // 3 days ago, unpaid
        ),
      )
      ..addBill(
        const Bill(
          id: 'lower',
          name: 'water bill', // typed in lower case
          amountCents: 4100,
          recurrence: Recurrence.monthly,
          dueDate: LocalDate(2026, 10, 9),
        ),
      )
      ..addBill(
        const Bill(
          id: 'tomorrow',
          name: 'Cloud storage',
          amountCents: 299,
          recurrence: Recurrence.monthly,
          dueDate: LocalDate(2026, 10, 3),
          isSubscription: true,
        ),
      );
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bills').last);
    await tester.pumpAndSettle();
    return store;
  }

  Finder tileOf(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(BillTile));
  Finder inTile(String name, String text) =>
      find.descendant(of: tileOf(name), matching: find.text(text));

  testWidgets('overdue: pill and "3 days late"', (tester) async {
    await openRadar(tester);
    expect(inTile('Gym', 'Overdue'), findsOneWidget);
    expect(inTile('Gym', '3 days late'), findsOneWidget);
    expect(inTile('Gym', 'Due Sep 29 · monthly'), findsOneWidget);
  });

  testWidgets('due tomorrow; estimates marked with ~ and a pill', (
    tester,
  ) async {
    await openRadar(tester);
    expect(inTile('Cloud Storage', 'Tomorrow'), findsOneWidget);
    expect(inTile('Cloud Storage', r'$2.99'), findsOneWidget);

    final electric = find.byWidgetPredicate(
      (w) => w is BillTile && w.bill.isEstimate,
    );
    expect(electric, findsWidgets);
    expect(
      find.descendant(of: electric.first, matching: find.text('Estimate')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: electric.first, matching: find.textContaining('~')),
      findsOneWidget,
    );
  });

  testWidgets('every row eases in fully, and tapping opens the bill', (
    tester,
  ) async {
    await openRadar(tester);
    for (final fade in tester.widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(BillTile),
        matching: find.byType(FadeTransition),
      ),
    )) {
      expect(fade.opacity.value, 1);
    }
    await tester.tap(find.text('Cloud Storage'));
    await tester.pumpAndSettle();
    expect(find.text('Edit bill'), findsOneWidget);
  });

  testWidgets('names show in Title Case; what was typed is kept', (
    tester,
  ) async {
    final store = await openRadar(tester);
    expect(find.text('Water Bill'), findsOneWidget);
    expect(find.text('water bill'), findsNothing);
    expect(store.bills.firstWhere((b) => b.id == 'lower').name, 'water bill');
  });
}
