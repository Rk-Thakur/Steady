import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/bills/bill_tile.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/widgets/kit.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> open(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('Profile: the week can start on any day', (tester) async {
    final store = await open(tester, Routes.profile);
    for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.widgetWithText(SteadyChip, d), findsOneWidget);
    }
    await tester.tap(find.widgetWithText(SteadyChip, 'Wed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.settings.weekStartsOn, DateTime.wednesday);
  });

  testWidgets('Settings › Bills: the same bill rows as Bills radar', (
    tester,
  ) async {
    final store = await open(tester, Routes.categories);
    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    expect(find.byType(BillTile), findsNWidgets(store.bills.length));
    // Title Case, with how often it repeats.
    expect(find.text('Phone Plan'), findsOneWidget);
    expect(find.textContaining('Monthly'), findsWidgets);
    await tester.tap(find.text('Phone Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Edit bill'), findsOneWidget);
  });
}
