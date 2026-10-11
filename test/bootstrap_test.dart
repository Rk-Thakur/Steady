import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/bootstrap.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database_key.dart';
import 'package:steady/ui/today/today_states.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<void> boot(
    WidgetTester tester,
    Future<BudgetStore> Function() open,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(SteadyBootstrap(open: open));
    // Splash stays at least 900 ms; its dots animate, so no pumpAndSettle.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('fresh install: splash, then onboarding', (tester) async {
    await boot(
      tester,
      () async => BudgetStore.fromSnapshot(
        const BudgetSnapshot(
          settings: null,
          plan: null,
          categories: [],
          entries: [],
          bills: [],
          goals: [],
          vault: null,
          overspendDecisions: {},
        ),
        clock: () => oct2,
      ),
    );
    expect(find.text('Know what you can spend today.'), findsOneWidget);
  });

  testWidgets('returning user: straight to Today', (tester) async {
    await boot(tester, () async => BudgetStore.sample(clock: () => oct2));
    expect(find.text(r'$46.20'), findsOneWidget);
  });

  testWidgets('returning user with App lock: Today, locked', (tester) async {
    await boot(tester, () async {
      final store = BudgetStore.sample(clock: () => oct2);
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '1234'),
      );
      return store;
    });
    expect(find.text('Steady is locked'), findsOneWidget);
  });

  testWidgets('lost database key: recovery screen, not a crash', (
    tester,
  ) async {
    await boot(tester, () async => throw const DatabaseKeyLostException());
    expect(find.text("We can't open your data"), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);
  });

  testWidgets('other failures: explain and offer to try again', (tester) async {
    var attempts = 0;
    await boot(tester, () async {
      attempts++;
      if (attempts == 1) throw StateError('disk full');
      return BudgetStore.sample(clock: () => oct2);
    });
    expect(find.text("Steady couldn't start"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.text(r'$46.20'), findsOneWidget);
  });

  testWidgets('a slow phone sees Today taking shape, then the app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SteadyBootstrap(
        open: () async {
          await Future<void>.delayed(const Duration(seconds: 3));
          return BudgetStore.sample(clock: () => oct2);
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(TodayLoadingBody), findsNothing); // still the logo
    await tester.pump(const Duration(milliseconds: 700)); // past 1.2 s
    await tester.pump(const Duration(milliseconds: 300)); // cross-fade
    expect(find.byType(TodayLoadingBody), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // opened
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TodayLoadingBody), findsNothing);
    expect(find.text('Safe to spend today'), findsOneWidget);
  });

  testWidgets('a fast phone never sees the skeleton', (tester) async {
    var sawSkeleton = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SteadyBootstrap(open: () async => BudgetStore.sample(clock: () => oct2)),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      if (find.byType(TodayLoadingBody).evaluate().isNotEmpty) {
        sawSkeleton = true;
      }
    }
    expect(sawSkeleton, isFalse);
    expect(find.text('Safe to spend today'), findsOneWidget);
  });
}
