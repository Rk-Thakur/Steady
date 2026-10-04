import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/settings.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// Accessibility on every screen, light and dark: tap targets (Android 48dp,
/// iOS 44pt), every tappable thing has a label, and text contrast (WCAG).
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  setUpAll(() async {
    for (final f in ['Manrope', 'BricolageGrotesque']) {
      await (FontLoader(
        f,
      )..addFont(rootBundle.load('assets/fonts/$f.ttf'))).load();
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
    (Routes.settleUp, (_) => null),
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
  for (final theme in [ThemePreference.light, ThemePreference.dark]) {
    for (final (route, argsOf) in routes) {
      if (route == Routes.splash || route == Routes.todayLoading) continue;
      testWidgets('a11y ${theme.name} $route', (tester) async {
        final handle = tester.ensureSemantics();
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final store = BudgetStore.sample(clock: () => oct2);
        store.updateSettings(store.settings.copyWith(theme: theme));
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
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
        await tester.pump(const Duration(seconds: 2));
      });
    }
  }
}
