import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> pumpApp(WidgetTester tester, {bool vault = true}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    if (!vault) {
      store.updateVault(
        const Vault(openingBalanceCents: 0, steadyPayWeeklyCents: 0),
      );
    }
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('Today shows the Vault next to the number; tap opens it', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    final next = store.nextVaultRelease!;
    expect(next.date, const LocalDate(2026, 10, 5)); // next Monday
    expect(
      find.textContaining('joins your number Mon, Oct 5', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(
      find.textContaining('joins your number', findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your steady pay'), findsOneWidget);
    // Real income: the sample's client payment this week, nothing earlier.
    expect(store.weeklyIncomeCents.last, 64000);
    expect(find.textContaining('No income logged'), findsNothing);

    // "?" explains it.
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Steady pay comes out.', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets('no Vault: no strip on Today; the Vault tab explains first', (
    tester,
  ) async {
    final store = await pumpApp(tester, vault: false);
    expect(find.textContaining('joins your number'), findsNothing);
    await tester.tap(find.text('Vault').last);
    await tester.pumpAndSettle();
    expect(find.text('How the Vault works'), findsOneWidget);
    expect(find.text('Vault balance', skipOffstage: false), findsNothing);

    // One week of $640 in 8 → $80 average, so it starts at the $300 floor.
    // To the bottom, clear of the floating tab bar.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set steady pay'));
    await tester.pumpAndSettle();
    expect(store.vault.steadyPayWeeklyCents, 30000);
    expect(
      find.text('Lower pay = longer buffer', skipOffstage: false),
      findsOneWidget,
    );
  });
}
