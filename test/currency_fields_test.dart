import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// Amount fields show the user's currency, not always "$".
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> openInRupees(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    store.updateSettings(store.settings.copyWith(currency: Currency.inr));
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('typing an amount shows ₹', (tester) async {
    final store = await openInRupees(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.logSpend);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '250');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '₹250'), findsOneWidget);
    expect(find.widgetWithText(TextField, r'$250'), findsNothing);
    expect(store.symbol, '₹');
  });

  testWidgets('a filled-in amount shows ₹', (tester) async {
    final store = await openInRupees(tester);
    final g = store.goals.firstWhere((g) => g.isActive);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.goalNew, arguments: GoalNewArgs(goalId: g.id));
    await tester.pumpAndSettle();
    final target =
        '₹${g.targetCents ~/ 100}.${(g.targetCents % 100).toString().padLeft(2, '0')}';
    expect(find.widgetWithText(TextField, target), findsOneWidget);
    expect(find.textContaining(r'$'), findsNothing);
  });
}
