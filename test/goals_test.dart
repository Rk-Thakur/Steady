import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/core/money.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/widgets/kit.dart';

/// Goals hold their money back from the day they start, not from payday.
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  BudgetStore sample() => BudgetStore.sample(clock: () => oct2);

  group('store', () {
    test('sample goals share the cycle total between them', () {
      final store = sample();
      final held = store.goals.fold(0, (sum, g) => sum + g.cycleSetAsideCents!);
      expect(held, store.plan.goalSetAsideCents);
    });

    test("starting a goal lowers today's number straight away", () {
      final store = sample();
      final before = store.dailyNumber.dailyAllowanceCents;
      store.addGoal(
        Goal(
          id: 'bike',
          name: 'Bike',
          targetCents: 50000,
          savedCents: 0,
          dailySetAsideCents: 1000,
          createdOn: oct2,
        ),
      );
      expect(store.dailyNumber.dailyAllowanceCents, before - 1000);
      final days = store.dailyNumber.daysLeft;
      expect(store.goalById('bike')!.cycleSetAsideCents, 1000 * days);
    });

    test('pausing raises it; resuming lowers it again', () {
      final store = sample();
      store.addGoal(
        Goal(
          id: 'bike',
          name: 'Bike',
          targetCents: 50000,
          savedCents: 0,
          dailySetAsideCents: 1000,
          createdOn: oct2,
        ),
      );
      final before = store.dailyNumber.dailyAllowanceCents;
      final bike = store.goalById('bike')!;
      store.updateGoal(bike.copyWith(paused: true));
      expect(store.dailyNumber.dailyAllowanceCents, before + 1000);
      store.updateGoal(store.goalById('bike')!.copyWith(paused: false));
      expect(store.dailyNumber.dailyAllowanceCents, before);
    });
  });

  test('deleting a goal gives back what it held this cycle', () {
    final store = sample();
    store.addGoal(
      Goal(
        id: 'bike',
        name: 'Bike',
        targetCents: 50000,
        savedCents: 0,
        dailySetAsideCents: 1000,
        createdOn: oct2,
      ),
    );
    final before = store.dailyNumber.dailyAllowanceCents;
    final total = store.plan.goalSetAsideCents;
    final held = store.goalById('bike')!.cycleSetAsideCents!;
    store.removeGoal('bike');
    expect(store.goalById('bike'), isNull);
    expect(store.plan.goalSetAsideCents, total - held);
    expect(store.dailyNumber.dailyAllowanceCents, before + 1000);
  });

  group('screens', () {
    Future<BudgetStore> open(
      WidgetTester tester,
      String route, {
      Object? args,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = sample();
      await tester.pumpWidget(
        SteadyApp(store: store, initialRoute: Routes.home),
      );
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(route, arguments: args);
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('the list shows what each goal holds this cycle', (
      tester,
    ) async {
      await open(tester, Routes.goals);
      expect(find.textContaining('This pay cycle:'), findsOneWidget);
      expect(
        find.textContaining('set aside this cycle · added on payday'),
        findsWidgets,
      );
    });

    testWidgets('a new goal can start with money already saved', (
      tester,
    ) async {
      final store = await open(tester, Routes.goalNew);
      await tester.enterText(find.byType(TextField).at(0), 'Bike');
      await tester.enterText(find.byType(TextField).at(1), '500');
      await tester.enterText(find.byType(TextField).at(2), '200');
      await tester.pumpAndSettle();
      // $300 left over 5 months (150 days): $2.00 a day.
      expect(find.text(r'$2.00'), findsOneWidget);
      expect(
        find.textContaining('Starts today.', skipOffstage: false),
        findsOneWidget,
      );

      await tester.tap(find.text('Start this goal'));
      await tester.pumpAndSettle();
      final bike = store.goals.firstWhere((g) => g.name == 'Bike');
      expect(bike.savedCents, 20000);
      expect(bike.dailySetAsideCents, 200);
    });

    testWidgets('saving the whole target already: nothing to start', (
      tester,
    ) async {
      await open(tester, Routes.goalNew);
      await tester.enterText(find.byType(TextField).at(1), '500');
      await tester.enterText(find.byType(TextField).at(2), '500');
      await tester.pumpAndSettle();
      expect(
        find.textContaining("That's already the whole target"),
        findsOneWidget,
      );
      final start = tester.widget<SteadyButton>(
        find.widgetWithText(SteadyButton, 'Start this goal'),
      );
      expect(start.onPressed, isNull);
    });

    testWidgets('detail explains how it fills; no made-up history', (
      tester,
    ) async {
      final store = sample();
      final g = store.goals.firstWhere((g) => g.isActive);
      await open(tester, Routes.goalDetail, args: g.id);
      expect(find.text('How it fills up'), findsOneWidget);
      expect(
        find.textContaining('set aside this cycle · added on'),
        findsOneWidget,
      );
      expect(find.textContaining('Leftover sweep'), findsNothing);
      expect(find.text('Payday set-aside'), findsNothing);
    });

    Future<Goal> openEdit(WidgetTester tester, BudgetStore store) async {
      final g = store.goals.firstWhere((g) => g.isActive);
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(Routes.goalDetail, arguments: g.id);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      return g;
    }

    testWidgets('edit: filled in, keeps the pace, saves changes', (
      tester,
    ) async {
      final store = await open(tester, Routes.goals);
      final g = await openEdit(tester, store);
      expect(find.text('Edit goal'), findsOneWidget);
      expect(find.text(g.name), findsWidgets); // in the name field
      final pace = formatMoney(g.dailySetAsideCents, symbol: r'$');
      expect(find.text('Keep $pace/day'), findsOneWidget);
      expect(find.text('Saved so far'), findsOneWidget);

      // Rename and raise the target; same pace.
      await tester.enterText(find.byType(TextField).at(0), 'Rainy day fund');
      await tester.enterText(
        find.byType(TextField).at(1),
        '${(g.targetCents + 100000) / 100}',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      final saved = store.goalById(g.id)!;
      expect(saved.name, 'Rainy day fund');
      expect(saved.targetCents, g.targetCents + 100000);
      expect(saved.dailySetAsideCents, g.dailySetAsideCents);
      expect(saved.savedCents, g.savedCents);
      expect(find.text('Rainy day fund'), findsWidgets); // back on detail
    });

    testWidgets('edit: a new pace changes the number, shown first', (
      tester,
    ) async {
      final store = await open(tester, Routes.goals);
      final g = await openEdit(tester, store);
      final before = store.dailyNumber.dailyAllowanceCents;
      await tester.tap(find.text('3 months'));
      await tester.pumpAndSettle();
      // The preview shows the drop before saving.
      expect(
        find.textContaining(
          '${formatMoney(before, symbol: r'$')} → ',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      // What's still needed over 3 months (90 days), rounded up.
      final pace = (g.remainingCents + 89) ~/ 90;
      expect(store.goalById(g.id)!.dailySetAsideCents, pace);
      final now = store.dailyNumber.dailyAllowanceCents;
      if (pace < g.dailySetAsideCents) {
        expect(now, greaterThan(before)); // slower: more to spend
      } else {
        expect(now, lessThan(before));
      }
    });

    testWidgets('delete: explains the money, then back to the list', (
      tester,
    ) async {
      final store = await open(tester, Routes.goals);
      final g = await openEdit(tester, store);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -1000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete goal'));
      await tester.pumpAndSettle();
      expect(find.text('Delete ${g.name}?'), findsOneWidget);
      expect(
        find.textContaining('no real money moves', skipOffstage: false),
        findsOneWidget,
      );
      await tester.tap(find.text('Delete goal').last);
      await tester.pumpAndSettle();

      expect(store.goalById(g.id), isNull);
      expect(find.text('Goals'), findsWidgets); // the list
      expect(find.text('Edit goal'), findsNothing);
    });

    testWidgets('Add money adds to the goal and closes cleanly', (
      tester,
    ) async {
      final store = await open(tester, Routes.goals);
      final g = store.goals.firstWhere((g) => g.isActive);
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(Routes.goalDetail, arguments: g.id);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add money'));
      await tester.pumpAndSettle();
      final add = tester.widget<SteadyButton>(
        find.widgetWithText(SteadyButton, 'Add to goal'),
      );
      expect(add.onPressed, isNull); // nothing typed yet
      await tester.enterText(find.byType(TextField).last, '10');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to goal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(store.goalById(g.id)!.savedCents, g.savedCents + 1000);
    });
  });
}
