import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
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
  });
}
