import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// Split groups, driven through the screens.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  setUpAll(() async {
    for (final f in ['Manrope', 'BricolageGrotesque']) {
      await (FontLoader(
        f,
      )..addFont(rootBundle.load('assets/fonts/$f.ttf'))).load();
    }
  });

  Future<BudgetStore> open(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text).last;
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('home lists people and groups from the sample', (tester) async {
    await open(tester, Routes.splits);
    expect(find.text('Owed to you'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text(r'Owes you $64.50'), findsOneWidget);
    expect(find.text('Flat 4B'), findsWidgets);
    expect(find.text('You & Alex'), findsWidgets);
  });

  testWidgets('create a group with new people, add an expense, settle up', (
    tester,
  ) async {
    final store = await open(tester, Routes.splitSetup);

    await tester.enterText(find.byType(TextField).first, 'Goa trip');
    // Existing people are offered; add Sam from the list and Rahul as new.
    await tapText(tester, '+ Sam');
    await tester.enterText(find.byType(TextField).at(1), 'Rahul');
    await tester.pumpAndSettle();
    await tapText(tester, 'Add');
    expect(find.text('Rahul  ✕'), findsOneWidget);
    await tapText(tester, 'Create group');

    final trip = store.splits.groups.firstWhere((g) => g.name == 'Goa trip');
    expect(trip.memberIds.length, 2);
    expect(find.text('All square.'), findsOneWidget);

    // Add expense: $90 dinner, you paid, split between all three.
    await tapText(tester, 'Add expense');
    await tester.enterText(find.byType(TextField).at(0), 'Dinner');
    await tester.enterText(find.byType(TextField).at(1), '90');
    await tester.pumpAndSettle();
    expect(find.text(r'$30.00'), findsNWidgets(3)); // live preview
    expect(
      find.textContaining(
        'The full \$90.00 counts as your spending today',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    await tapText(tester, 'Save');

    expect(store.splits.expenses.where((e) => e.name == 'Dinner'), hasLength(1));
    expect(find.textContaining('Dinner', findRichText: true), findsWidgets);
    expect(find.text('Sam pays you'), findsOneWidget);
    expect(find.text('Rahul pays you'), findsOneWidget);
    expect(store.entries.where((e) => e.merchant == 'Dinner'), hasLength(1));

    // Settle up with Rahul from the group.
    await tapText(tester, 'Settle');
    expect(find.text('Settle up'), findsOneWidget);
  });

  testWidgets('settle up: nudge when they owe you; records and clears', (
    tester,
  ) async {
    final store = await open(tester, Routes.splits);
    await tapText(tester, 'Alex');
    expect(find.text('Alex owes you'), findsOneWidget);
    expect(find.text(r'$64.50'), findsNWidgets(2)); // total + the group
    expect(find.text('Send Alex a nudge'), findsOneWidget);
    expect(
      find.text(
        r'Adds $64.50 to today'
        "'"
        's money',
      ),
      findsOneWidget,
    );

    await tapText(tester, 'Record as settled');
    await tapText(tester, 'Record as settled'); // confirm sheet
    expect(
      store.splitBalances.where((b) => b.personId == 'person-split'),
      isEmpty,
    );
    expect(
      store.entries.where((e) => e.merchant == 'Alex paid you back'),
      hasLength(1),
    );
  });

  testWidgets('reminders about a person can be turned off and snoozed', (
    tester,
  ) async {
    final store = await open(tester, Routes.splits);
    await tapText(tester, 'Alex');
    await tapText(tester, 'Snooze reminders for a week');
    expect(
      store.splits.person('person-split')!.remindSnoozedUntil,
      oct2.addDays(7),
    );
    expect(find.textContaining('Snoozed until'), findsOneWidget);
  });

  testWidgets('a person you owe gets no nudge button', (tester) async {
    final store = BudgetStore.sample(clock: () => oct2);
    // Make Priya owe nothing and be owed: she paid a big shared bill.
    store.addGroupExpense(
      groupId: 'flat',
      name: 'Deposit',
      amountCents: 90000,
      date: oct2,
      paidBy: 'person-priya',
      shares: const {youId: 30000, 'person-sam': 30000, 'person-priya': 30000},
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.settleUp, arguments: 'person-priya');
    await tester.pumpAndSettle();
    expect(find.text('You owe Priya'), findsOneWidget);
    expect(find.textContaining('nudge'), findsNothing);
  });
}
