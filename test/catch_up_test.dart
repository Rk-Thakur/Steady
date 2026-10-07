import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// Missed days: catch-up, "Not now", and the estimate banner.
void main() {
  const oct2 = LocalDate(2026, 10, 2); // the sample's last logged day
  late LocalDate now;

  setUp(() => now = oct2);

  /// The sample, opened [days] later with nothing logged since.
  BudgetStore later(int days) {
    final store = BudgetStore.sample(clock: () => now);
    now = oct2.addDays(days);
    return store;
  }

  Future<void> pump(WidgetTester tester, BudgetStore store) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
  }

  test('"No spends" days are saved and survive a restart', () async {
    final repo = BudgetRepository(SteadyDatabase(NativeDatabase.memory()));
    addTearDown(repo.close);
    var store = later(3);
    expect(store.missedDays, [oct2.addDays(1), oct2.addDays(2)]);
    expect(store.showCatchUp, isTrue);
    await repo.replaceAll(store.toSnapshot());

    store = BudgetStore.fromSnapshot(
      await repo.load(),
      clock: () => now,
      repository: repo,
    );
    store.markCaughtUp();
    expect(store.missedDays, isEmpty);
    await store.flush();

    store = BudgetStore.fromSnapshot(
      await repo.load(),
      clock: () => now,
      repository: repo,
    );
    expect(store.settings.caughtUpThrough, oct2.addDays(2));
    expect(store.missedDays, isEmpty);
    // A new gap after that still counts.
    now = now.addDays(2);
    expect(store.missedDays, [oct2.addDays(3), oct2.addDays(4)]);
    await store.flush();
  });

  test("the Vault's Monday release isn't something you logged", () {
    // The sample has a Vault; Monday Oct 5 releases into the number.
    final store = later(4)..refreshDay(); // Tuesday Oct 6
    expect(
      store.entries.any((e) => e.fromVault && e.localDate == oct2.addDays(3)),
      isTrue,
    );
    expect(store.missedDays, [
      oct2.addDays(1),
      oct2.addDays(2),
      oct2.addDays(3),
    ]);
  });

  testWidgets('answering every day returns to the normal Today', (
    tester,
  ) async {
    final store = later(3);
    await pump(tester, store);
    expect(find.textContaining('A best guess'), findsOneWidget);
    expect(find.text('Can I afford it?'), findsNothing);

    await tester.tap(find.text('Nothing').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('A best guess'), findsOneWidget); // one left
    await tester.tap(find.text('Nothing').first);
    await tester.pumpAndSettle();

    expect(
      find.text('All caught up. Your number is exact again.'),
      findsOneWidget,
    );
    expect(find.text('Can I afford it?'), findsOneWidget);
    expect(
      find.text('Your number is an estimate.', findRichText: true),
      findsNothing,
    );
    expect(store.settings.caughtUpThrough, oct2.addDays(2));
  });

  testWidgets('"Not now" shows the day, with a banner to come back', (
    tester,
  ) async {
    final store = later(3);
    await pump(tester, store);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now, show my day'));
    await tester.pumpAndSettle();

    expect(find.text('Can I afford it?'), findsOneWidget);
    expect(
      find.textContaining('Nothing is logged for 2 days', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Catch up'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A best guess'), findsOneWidget);
    expect(store.showCatchUp, isTrue);
  });

  testWidgets('one missed day: a banner, answered in place', (tester) async {
    final store = later(2);
    await pump(tester, store);
    expect(store.showCatchUp, isFalse);
    expect(
      find.textContaining('Nothing is logged for Sat', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('I spent nothing'));
    await tester.pumpAndSettle();
    expect(store.missedDays, isEmpty);
    expect(
      find.textContaining('Your number is an estimate', findRichText: true),
      findsNothing,
    );
  });
}
