import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/date_format.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/widgets/entry_tile.dart';
import 'package:steady/ui/widgets/kit.dart';

/// Entry rows (Today, History) and "+ New" category on Log spend.
void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> open(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    if (route != Routes.home) {
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(route);
      await tester.pumpAndSettle();
    }
    return store;
  }

  double opacityOf(WidgetTester tester, Finder tile) => tester
      .widget<FadeTransition>(
        find.descendant(of: tile, matching: find.byType(FadeTransition)).first,
      )
      .opacity
      .value;

  testWidgets('History rows: mood pill, logged time, tap to edit', (
    tester,
  ) async {
    final store = await open(tester, Routes.history);
    final coffee = store.entries.firstWhere(
      (e) => e.merchant == 'Corner coffee',
    );
    expect(find.byType(EntryTile), findsWidgets);
    // Mood shown as a pill beside the name.
    final tile = find.ancestor(
      of: find.text('Corner coffee'),
      matching: find.byType(EntryTile),
    );
    expect(
      find.descendant(of: tile, matching: find.text(coffee.mood!.label)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: tile,
        matching: find.text(formatTime(coffee.createdAtUtc.toLocal())),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Corner coffee'));
    await tester.pumpAndSettle();
    expect(find.text('Edit entry'), findsOneWidget);
  });

  testWidgets('rows ease in one after another, then stay put', (tester) async {
    await open(tester, Routes.home);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.history);
    await tester.pump(); // first frame of the new screen
    await tester.pump(const Duration(milliseconds: 300)); // route transition
    final tiles = find.byType(EntryTile);
    // Mid-way: the first row is further along than a later one.
    await tester.pump(const Duration(milliseconds: 60));
    final first = opacityOf(tester, tiles.first);
    final later = opacityOf(tester, tiles.at(4));
    expect(first, greaterThan(later));
    await tester.pumpAndSettle();
    expect(opacityOf(tester, tiles.first), 1);
    expect(opacityOf(tester, tiles.at(4)), 1);
  });

  testWidgets('with "reduce motion" on, rows just appear', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await open(tester, Routes.home);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.history);
    await tester.pump();
    await tester.pump(); // History is built
    final tiles = find.byType(EntryTile);
    expect(opacityOf(tester, tiles.first), 1);
    expect(opacityOf(tester, tiles.at(4)), 1);
  });

  testWidgets('Log spend: "+ New" makes a category and selects it', (
    tester,
  ) async {
    final store = await open(tester, Routes.logSpend);
    await tester.ensureVisible(find.text('+ New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ New'));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Pets');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on Log spend with Pets chosen; saving logs it under Pets.
    expect(
      tester
          .widget<SteadyChip>(find.widgetWithText(SteadyChip, 'Pets'))
          .selected,
      isTrue,
    );
    final pets = store.categories.firstWhere((c) => c.name == 'Pets');
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.entries.last.categoryId, pets.id);
  });
}
