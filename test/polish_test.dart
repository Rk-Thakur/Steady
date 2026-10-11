import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/theme/app_theme.dart';
import 'package:steady/theme/transitions.dart';
import 'package:steady/ui/bills/bills_screen.dart';
import 'package:steady/ui/goals/goal_screens.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/today/hero_card.dart';
import 'package:steady/ui/widgets/confetti.dart';
import 'package:steady/ui/widgets/empty_state.dart';

/// Motion and feel: the hero reacting, pull to refresh, haptics, bars
/// filling, empty states.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> pumpToday(
    WidgetTester tester, {
    BudgetStore? store,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    store ??= BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    return store;
  }

  Entry entry(String id, EntryType type, int cents) => Entry(
    id: id,
    type: type,
    amountCents: cents,
    localDate: oct2,
    createdAtUtc: DateTime.now().toUtc(),
    timeZoneId: 'UTC',
    merchant: id,
    categoryId: type == EntryType.spend ? 'food' : null,
    planned: type == EntryType.spend ? false : null,
  );

  Matrix4 heroTransform(WidgetTester tester, {required bool scale}) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(HeroReaction),
          matching: find.byType(Transform),
        ),
      )
      .elementAt(scale ? 1 : 0)
      .transform;

  testWidgets('the number going up: the hero pulses, then settles', (
    tester,
  ) async {
    final store = await pumpToday(tester);
    store.addEntry(entry('Refund', EntryType.income, 2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // mid-pulse
    expect(
      heroTransform(tester, scale: true).getMaxScaleOnAxis(),
      greaterThan(1),
    );
    await tester.pumpAndSettle();
    expect(heroTransform(tester, scale: true).getMaxScaleOnAxis(), 1);
  });

  testWidgets('tipping into overspent: a shake and a firm tap', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final store = await pumpToday(tester);
    store.addEntry(entry('Groceries', EntryType.spend, 9000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60)); // mid-shake
    expect(
      heroTransform(tester, scale: false).getTranslation().x.abs(),
      greaterThan(0),
    );
    expect(haptics, contains('HapticFeedbackType.mediumImpact'));
    await tester.pumpAndSettle();
    expect(heroTransform(tester, scale: false).getTranslation().x, 0);
    expect(find.text('Spread it out (recommended)'), findsOneWidget);
  });

  testWidgets('with "reduce motion" on, the hero just updates', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final store = await pumpToday(tester);
    store.addEntry(entry('Refund', EntryType.income, 2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(heroTransform(tester, scale: true).getMaxScaleOnAxis(), 1);
  });

  testWidgets('choosing a chip and saving a spend give haptic taps', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpToday(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.logSpend);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    await tester.enterText(find.byType(TextField).first, '4');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(haptics, contains('HapticFeedbackType.lightImpact'));
  });

  testWidgets('pull down on Today to refresh', (tester) async {
    await pumpToday(tester);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pump(); // start
    await tester.pump(const Duration(seconds: 1)); // spinner and refresh
    await tester.pumpAndSettle();
    expect(find.text('Safe to spend today'), findsOneWidget);
  });

  testWidgets('progress bars fill from empty when a screen opens', (
    tester,
  ) async {
    await pumpToday(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.goals);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // route + fill
    // Only the Goals screen's bars (Today is still there mid-transition).
    final goalBars = find.descendant(
      of: find.byType(GoalsScreen),
      matching: find.byType(FractionallySizedBox),
    );
    final fills = tester
        .widgetList<FractionallySizedBox>(goalBars)
        .map((f) => f.widthFactor ?? 1)
        .toList();
    await tester.pumpAndSettle();
    final settled = tester
        .widgetList<FractionallySizedBox>(goalBars)
        .map((f) => f.widthFactor ?? 1)
        .toList();
    // Mid-way each bar is short of where it ends up.
    expect(fills.length, settled.length);
    for (var i = 0; i < fills.length; i++) {
      if (settled[i] > 0) expect(fills[i], lessThan(settled[i]));
    }
  });

  testWidgets('empty states: friendly, and they settle (no endless motion)', (
    tester,
  ) async {
    final store = BudgetStore.sample(clock: () => oct2);
    for (final g in store.goals.toList()) {
      store.removeGoal(g.id);
    }
    await pumpToday(tester, store: store);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.goals);
    await tester.pumpAndSettle(); // would time out on an endless animation
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No goals yet'), findsOneWidget);
  });

  Future<void> addMoney(
    WidgetTester tester,
    String goalId,
    String amount,
  ) async {
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.goalDetail, arguments: goalId);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add money'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, amount);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to goal'));
  }

  testWidgets('passing a milestone: confetti and a cheer, then it clears', (
    tester,
  ) async {
    final store = await pumpToday(tester);
    final fund = store.goalById('emergency')!; // 62% saved
    await addMoney(tester, fund.id, '400'); // → 75%
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(find.text('Three-quarters there. Nearly done!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ConfettiBurst), findsNothing); // removed itself
  });

  testWidgets('a goal reached: the big burst', (tester) async {
    final store = await pumpToday(tester);
    final fund = store.goalById('emergency')!;
    await addMoney(tester, fund.id, '${fund.remainingCents / 100}');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ConfettiBurst), findsOneWidget);
    await tester.pumpAndSettle();
    expect(store.goalById(fund.id)!.isReached, isTrue);
    expect(find.byType(ConfettiBurst), findsNothing);
  });

  testWidgets('tabs ease in when chosen', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.text('Bills').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    FadeTransition billsFade() => tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(BillsScreen),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(billsFade().opacity.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(billsFade().opacity.value, 1);
  });

  testWidgets('Android: screens step in sideways (shared axis)', (
    tester,
  ) async {
    await pumpToday(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.history);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final shifts = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.text('History'),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.getTranslation().x);
    // Still sliding in from the right.
    expect(shifts.any((x) => x > 0), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  test('iOS keeps its native transition (swipe back)', () {
    final theme = AppTheme.light();
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<SharedAxisPageTransitionsBuilder>(),
    );
  });
}
