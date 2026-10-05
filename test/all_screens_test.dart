import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/settings.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// Opens every screen at three phone sizes, in light and dark. Any layout overflow or build error fails.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  // Real fonts, so text widths match the device (tests default to a
  // square-glyph placeholder font that is much wider).
  setUpAll(() async {
    for (final (family, file) in [
      ('Manrope', 'Manrope'),
      ('BricolageGrotesque', 'BricolageGrotesque'),
    ]) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$file.ttf'));
      await loader.load();
    }
  });

  final routes = <(String, Object? Function(BudgetStore))>[
    (Routes.home, (_) => null),
    (Routes.splash, (_) => null),
    (Routes.welcome, (_) => null),
    (Routes.onbIncome, (_) => null),
    (Routes.onbMoney, (_) => null),
    (Routes.onbReveal, (_) => null),
    (Routes.notifPermission, (_) => null),
    (Routes.afford, (_) => null),
    (Routes.logSpend, (_) => null),
    (Routes.logIncome, (_) => null),
    (Routes.bills, (_) => null),
    (Routes.vault, (_) => null),
    (Routes.insights, (_) => null),
    (Routes.todayEmpty, (_) => null),
    (Routes.todayLoading, (_) => null),
    (Routes.todayCatchUp, (_) => null),
    (Routes.paidPrompt, (_) => null),
    (Routes.splitSetup, (_) => null),
    (Routes.splits, (_) => null),
    (Routes.settleUp, (s) => s.splitBalances.first.personId),
    (Routes.splitGroup, (s) => s.splits.groups.last.id),
    (Routes.groupExpense, (s) => s.splits.groups.last.id),
    (Routes.settings, (_) => null),
    (Routes.profile, (_) => null),
    (Routes.reminders, (_) => null),
    (Routes.categories, (_) => null),
    (Routes.categoryEdit, (s) => s.categories.first.id),
    (Routes.billEdit, (_) => null),
    (Routes.backup, (_) => null),
    (Routes.help, (_) => null),
    (Routes.notifications, (_) => null),
    (Routes.goals, (_) => null),
    (Routes.goalNew, (_) => null),
    (Routes.goalDetail, (s) => s.goals.first.id),
    (Routes.goalDone, (s) => s.goals.first.id),
    (Routes.history, (_) => null),
    (Routes.editEntry, (s) => s.history.first.id),
    (Routes.summaryWeek, (_) => null),
    (Routes.summaryMonth, (_) => null),
    (Routes.setPin, (_) => null),
    (Routes.lock, (_) => null),
    (Routes.gallery, (_) => null),
  ];

  // Design size, narrowest supported width, and a short phone (iPhone SE).
  for (final (width, height) in [
    (390.0, 844.0),
    (360.0, 780.0),
    (375.0, 667.0),
  ]) {
    for (final theme in [ThemePreference.light, ThemePreference.dark]) {
      for (final (route, argsOf) in routes) {
        testWidgets(
          '$route · ${width.toInt()}×${height.toInt()} · ${theme.name}',
          (tester) async {
            tester.view.physicalSize = Size(width, height);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            final store = BudgetStore.sample(clock: () => oct2);
            store.updateSettings(store.settings.copyWith(theme: theme));
            await tester.pumpWidget(
              SteadyApp(store: store, initialRoute: Routes.home),
            );
            await tester.pump();

            if (route != Routes.home) {
              final nav = tester.state<NavigatorState>(
                find.byType(Navigator).first,
              );
              nav.pushNamed(route, arguments: argsOf(store));
            }
            // Not pumpAndSettle: splash dots and skeletons animate forever.
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull);

            // Let the splash timer fire and route away cleanly.
            await tester.pump(const Duration(seconds: 2));
            await tester.pump(const Duration(milliseconds: 400));
          },
        );
      }
    }
  }

  // Large text (iOS Larger Text / Android font size): every screen must lay
  // out without overflowing.
  for (final scale in [1.3, 2.0]) {
    for (final (width, height) in [(390.0, 844.0), (375.0, 667.0)]) {
      for (final (route, argsOf) in routes) {
        testWidgets(
          'large text ×$scale · $route · ${width.toInt()}×${height.toInt()}',
          (tester) async {
            tester.view.physicalSize = Size(width, height);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );

            final store = BudgetStore.sample(clock: () => oct2);
            await tester.pumpWidget(
              SteadyApp(store: store, initialRoute: Routes.home),
            );
            await tester.pump();
            if (route != Routes.home) {
              tester
                  .state<NavigatorState>(find.byType(Navigator).first)
                  .pushNamed(route, arguments: argsOf(store));
            }
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull);
            await tester.pump(const Duration(seconds: 2));
            await tester.pump(const Duration(milliseconds: 400));
          },
        );
      }
    }
  }
}
