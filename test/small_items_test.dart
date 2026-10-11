import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/notifications.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/reminders.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// A phone where notifications for Steady are turned off.
class _BlockedNotifications implements Notifications {
  @override
  bool get enabled => true;
  @override
  Future<void> init() async {}
  @override
  Stream<String> get taps => const Stream.empty();
  @override
  Future<String?> launchRoute() async => null;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<bool> permissionGranted() async => false;
  @override
  Future<bool> onTime() async => true;
  @override
  Future<void> askForOnTime() async {}
  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {}
  @override
  Future<List<DeliveredNotification>> delivered() async => const [];
  @override
  Future<void> clearDelivered(Iterable<int> ids) async {}
}

/// Android without "Alarms & reminders": allowed, but not on time.
class _LateNotifications implements Notifications {
  int asked = 0;
  @override
  bool get enabled => true;
  @override
  Future<void> init() async {}
  @override
  Stream<String> get taps => const Stream.empty();
  @override
  Future<String?> launchRoute() async => null;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> permissionGranted() async => true;
  @override
  Future<bool> onTime() async => false;
  @override
  Future<void> askForOnTime() async => asked++;
  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {}
  @override
  Future<List<DeliveredNotification>> delivered() async => const [];
  @override
  Future<void> clearDelivered(Iterable<int> ids) async {}
}

void main() {
  const oct2 = LocalDate(2026, 10, 2);

  Future<BudgetStore> open(
    WidgetTester tester,
    String route, {
    BudgetStore? store,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    store ??= BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
    await tester.pumpAndSettle();
    return store;
  }

  group('Insights before moods are tagged', () {
    testWidgets('nothing tagged: how to start', (tester) async {
      final store = BudgetStore.sample(clock: () => oct2);
      for (final e in store.entries.where((e) => e.mood != null).toList()) {
        store.updateEntry(
          Entry(
            id: e.id,
            type: e.type,
            amountCents: e.amountCents,
            localDate: e.localDate,
            createdAtUtc: e.createdAtUtc,
            timeZoneId: e.timeZoneId,
            merchant: e.merchant,
            categoryId: e.categoryId,
            planned: e.planned,
          ),
        );
      }
      await tester.pumpWidget(
        SteadyApp(store: store, initialRoute: Routes.home),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Insights').last);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Tag moods for a week and your spending patterns show up here.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('No moods yet.'), findsOneWidget);
    });

    testWidgets('a few tagged: progress toward a clear picture', (
      tester,
    ) async {
      final store = BudgetStore.sample(clock: () => oct2);
      await tester.pumpWidget(
        SteadyApp(store: store, initialRoute: Routes.home),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Insights').last);
      await tester.pumpAndSettle();
      // The sample tags two spends with a mood this week.
      expect(
        find.textContaining('2 of 5 tagged spends so far'),
        findsOneWidget,
      );
      // The bars show once anything is tagged.
      expect(find.text('Tired'), findsWidgets);
      expect(find.textContaining('No moods yet.'), findsNothing);
    });
  });

  group('notifications turned off on the phone', () {
    setUp(() => Notifications.instance = _BlockedNotifications());
    tearDown(() => Notifications.instance = const _Stub());

    testWidgets('Settings says Blocked; Reminders says where to fix it', (
      tester,
    ) async {
      final store = BudgetStore.sample(clock: () => oct2);
      store.updateSettings(
        store.settings.copyWith(
          reminders: store.settings.reminders.copyWith(logSpends: true),
        ),
      );
      await open(tester, Routes.settings, store: store);
      expect(find.text('Blocked'), findsOneWidget);
      expect(
        find.text("Notifications are off for Steady in your phone's Settings"),
        findsOneWidget,
      );

      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Notifications are off for Steady.',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('with every reminder off, nothing is flagged', (tester) async {
      final store = BudgetStore.sample(clock: () => oct2);
      store.updateSettings(
        store.settings.copyWith(reminders: ReminderSettings.off),
      );
      await open(tester, Routes.settings, store: store);
      expect(find.text('Blocked'), findsNothing);
    });
  });

  testWidgets('coming back to the app (e.g. from a notification) on Settings '
      'is error-free', (tester) async {
    final store = BudgetStore.sample(clock: () => oct2);
    store.updateSettings(
      store.settings.copyWith(appLockEnabled: true, pin: () => '1234'),
    );
    await open(tester, Routes.settings, store: store);
    final binding = tester.binding;
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Reminders'), findsOneWidget);
  });

  testWidgets('Android, not on time: Reminders explains and asks', (
    tester,
  ) async {
    final late = _LateNotifications();
    Notifications.instance = late;
    addTearDown(() => Notifications.instance = const _Stub());
    final store = BudgetStore.sample(clock: () => oct2);
    store.updateSettings(
      store.settings.copyWith(
        reminders: store.settings.reminders.copyWith(logSpends: true),
      ),
    );
    await open(tester, Routes.reminders, store: store);
    expect(
      find.textContaining(
        'Reminders may arrive up to an hour late.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(late.asked, 1);
  });

  testWidgets('App lock off: the hint mentions Face ID / fingerprint', (
    tester,
  ) async {
    await open(tester, Routes.settings);
    expect(
      find.textContaining('Keep your money private', skipOffstage: false),
      findsOneWidget,
    );
  });
}

/// Back to the do-nothing default after each test.
class _Stub implements Notifications {
  const _Stub();
  @override
  bool get enabled => false;
  @override
  Future<void> init() async {}
  @override
  Stream<String> get taps => const Stream.empty();
  @override
  Future<String?> launchRoute() async => null;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<bool> permissionGranted() async => false;
  @override
  Future<bool> onTime() async => true;
  @override
  Future<void> askForOnTime() async {}
  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {}
  @override
  Future<List<DeliveredNotification>> delivered() async => const [];
  @override
  Future<void> clearDelivered(Iterable<int> ids) async {}
}
