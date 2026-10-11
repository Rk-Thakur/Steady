import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/widgets/kit.dart';

/// Long-press a category to delete it (after asking), with Undo.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> open(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
    await tester.pumpAndSettle();
    return store;
  }

  Finder chip(String name) => find.widgetWithText(SteadyChip, name);

  testWidgets('Log spend: long-press a chip, confirm; no bar over Save', (
    tester,
  ) async {
    final store = await open(tester, Routes.logSpend);
    await tester.longPress(chip('Fun'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Fun?'), findsOneWidget);
    await tester.tap(find.text('Delete category'));
    await tester.pumpAndSettle();
    expect(store.categoryById('fun'), isNull);
    expect(chip('Fun'), findsNothing);
    expect(find.text('Fun deleted.'), findsNothing);
  });

  testWidgets('cancelling keeps the category', (tester) async {
    final store = await open(tester, Routes.logSpend);
    await tester.longPress(chip('Health'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.categoryById('health'), isNotNull);
  });

  testWidgets('deleting the selected category (Food) clears the choice', (
    tester,
  ) async {
    final store = await open(tester, Routes.logSpend);
    expect(tester.widget<SteadyChip>(chip('Food')).selected, isTrue);
    await tester.longPress(chip('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete category'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.entries.last.categoryId, isNull);
  });

  testWidgets('Settings › Categories: long-press, delete, Undo', (
    tester,
  ) async {
    final store = await open(tester, Routes.categories);
    final inTransport = store.entries
        .where((e) => e.categoryId == 'transport')
        .length;
    expect(inTransport, greaterThan(0)); // the Gas station spend
    final before = store.categories.map((c) => c.id).toList();

    await tester.longPress(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Transport?'), findsOneWidget);
    expect(
      find.textContaining('lose the category', skipOffstage: false),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete category'));
    await tester.pumpAndSettle();
    expect(store.categoryById('transport'), isNull);
    expect(find.text('Transport deleted.'), findsOneWidget);
    // Entries keep their amounts, and their link for Undo.
    expect(
      store.entries.where((e) => e.categoryId == 'transport'),
      hasLength(inTransport),
    );

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    // Back in its old place, not at the end.
    expect(store.categories.map((c) => c.id).toList(), before);

    // A tap still opens a category for editing.
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
  });
}
