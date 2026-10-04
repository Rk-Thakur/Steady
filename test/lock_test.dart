import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/biometrics.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/widgets/kit.dart';

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

  group('Face ID / fingerprint', () {
    late _FakeBiometrics bio;
    setUp(() => Biometrics.instance = bio = _FakeBiometrics());
    tearDown(() => Biometrics.instance = _FakeBiometrics(name: null));

    Finder switchFor(String label) =>
        find.byWidgetPredicate((w) => w is SteadySwitch && w.label == label);

    Future<BudgetStore> lockedApp(WidgetTester tester) async {
      final store = await pumpApp(tester);
      store.updateSettings(
        store.settings.copyWith(
          appLockEnabled: true,
          biometricUnlock: true,
          pin: () => '1234',
        ),
      );
      nav(tester).pushNamed(Routes.lock);
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('offered above the PIN pad, asked for only when tapped', (
      tester,
    ) async {
      bio.answer = true;
      await lockedApp(tester);
      expect(bio.asked, 0); // nothing pops up by itself
      expect(find.text('Enter your PIN to see your numbers.'), findsOneWidget);
      expect(find.text('You can also unlock with Face ID'), findsOneWidget);

      await tester.tap(find.text('You can also unlock with Face ID'));
      await tester.pumpAndSettle();
      expect(bio.asked, 1);
      expect(find.text('Steady is locked'), findsNothing);
    });

    testWidgets('if not recognised it stays locked; the PIN still works', (
      tester,
    ) async {
      bio.answer = false;
      await lockedApp(tester);
      await tester.tap(find.text('You can also unlock with Face ID'));
      await tester.pumpAndSettle();
      expect(bio.asked, 1);
      expect(find.text('Steady is locked'), findsOneWidget);

      await typePin(tester, '1234');
      expect(find.text('Steady is locked'), findsNothing);
    });

    testWidgets('Android wording: "your fingerprint"', (tester) async {
      Biometrics.instance = bio = _FakeBiometrics(name: 'fingerprint');
      await lockedApp(tester);
      expect(
        find.text('You can also unlock with your fingerprint'),
        findsOneWidget,
      );
    });

    testWidgets('Settings: shown with App lock on; turning it on asks once', (
      tester,
    ) async {
      final store = await pumpApp(tester);
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '1234'),
      );
      nav(tester).pushNamed(Routes.settings);
      await tester.pumpAndSettle();
      final row = find.text('Unlock with Face ID', skipOffstage: false);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();

      bio.answer = false; // not recognised: stays off
      await tester.tap(switchFor('Unlock with Face ID'));
      await tester.pumpAndSettle();
      expect(store.settings.biometricUnlock, isFalse);

      bio.answer = true;
      await tester.tap(switchFor('Unlock with Face ID'));
      await tester.pumpAndSettle();
      expect(store.settings.biometricUnlock, isTrue);

      // Turning App lock off turns this off too.
      await tester.tap(switchFor('App lock'));
      await tester.pumpAndSettle();
      expect(store.settings.biometricUnlock, isFalse);
      expect(find.text('Unlock with Face ID'), findsNothing);
    });

    testWidgets('Settings: not set up yet shows where to set it up', (
      tester,
    ) async {
      Biometrics.instance = bio = _FakeBiometrics(name: null)
        ..setUpLater = true;
      final store = await pumpApp(tester);
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '1234'),
      );
      nav(tester).pushNamed(Routes.settings);
      await tester.pumpAndSettle();
      expect(
        find.text(
          "Set it up in your phone's Settings app to use it here",
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      final sw = tester.widget<SteadySwitch>(
        switchFor('Unlock with fingerprint'),
      );
      expect(sw.onChanged, isNull);
    });
  });
}

class _FakeBiometrics implements Biometrics {
  _FakeBiometrics({this.name = 'Face ID'});
  final String? name;
  bool answer = false;
  int asked = 0;

  @override
  Future<String?> availableName() async => name;

  bool setUpLater = false;

  @override
  Future<bool> canBeSetUp() async => setUpLater;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return answer;
  }
}
