import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

void main() {
  Future<BudgetStore> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => const LocalDate(2026, 10, 2));
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.bySemanticsLabel(d).last);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  NavigatorState nav(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  testWidgets(
    'Set a PIN (with confirm), then the lock screen only opens with it',
    (tester) async {
      final store = await pumpApp(tester);
      expect(store.settings.appLockEnabled, isFalse);

      nav(tester).pushNamed(Routes.setPin);
      await tester.pumpAndSettle();
      await typePin(tester, '1234');
      expect(find.text('Enter it again to confirm'), findsOneWidget);
      await typePin(tester, '1234');
      expect(store.settings.appLockEnabled, isTrue);
      expect(store.settings.pin, '1234');

      nav(tester).pushNamed(Routes.lock);
      await tester.pumpAndSettle();
      await typePin(tester, '9999');
      expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await typePin(tester, '1234');
      expect(find.text('Steady is locked'), findsNothing);
    },
  );

  testWidgets('Mismatched confirmation starts PIN setup again', (tester) async {
    final store = await pumpApp(tester);
    nav(tester).pushNamed(Routes.setPin);
    await tester.pumpAndSettle();
    await typePin(tester, '1234');
    await typePin(tester, '4321');
    expect(find.text("PINs didn't match. Start again."), findsOneWidget);
    expect(store.settings.appLockEnabled, isFalse);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
