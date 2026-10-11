import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/notification_inbox.dart';
import 'package:steady/app/notifications.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/reminders.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

/// A phone with reminders waiting in its notification list.
class _PhoneWithReminders implements Notifications {
  _PhoneWithReminders(this.waiting);

  List<DeliveredNotification> waiting;
  final cleared = <int>[];

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
  Future<bool> onTime() async => true;
  @override
  Future<void> askForOnTime() async {}
  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {}
  @override
  Future<List<DeliveredNotification>> delivered() async => List.of(waiting);
  @override
  Future<void> clearDelivered(Iterable<int> ids) async {
    cleared.addAll(ids);
    waiting = [
      for (final n in waiting)
        if (!ids.contains(n.id)) n,
    ];
  }
}

/// Back to the do-nothing default.
class _Off implements Notifications {
  const _Off();
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

void main() {
  const oct2 = LocalDate(2026, 10, 2);
  final dot = find.byKey(const ValueKey('unread-dot'));

  tearDown(() {
    Notifications.instance = const _Off();
    NotificationInbox.instance.reset();
  });

  Future<void> pumpToday(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    // Let the app's reschedule timer run, so nothing is left pending.
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('no new reminders: no dot on the bell', (tester) async {
    Notifications.instance = _PhoneWithReminders([]);
    await pumpToday(tester);
    expect(dot, findsNothing);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
  });

  testWidgets('a reminder arrived: red dot; Notifications lists it and '
      'marks it read', (tester) async {
    final phone = _PhoneWithReminders([
      const DeliveredNotification(
        id: 7,
        title: 'Rent due in 2 days',
        body: r'$1,450.00 on Oct 8 · already set aside',
        route: Routes.bills,
      ),
      const DeliveredNotification(
        id: 9,
        title: 'Log your spends',
        body: 'Nothing logged yet today.',
        route: Routes.logSpend,
      ),
    ]);
    Notifications.instance = phone;
    await pumpToday(tester);

    expect(dot, findsOneWidget);
    expect(find.bySemanticsLabel('Notifications, 2 new'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications, 2 new'));
    await tester.pumpAndSettle();
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('Rent due in 2 days'), findsOneWidget);
    expect(find.text('Log your spends'), findsWidgets);
    expect(find.text('COMING UP'), findsOneWidget);
    // Seen: cleared from the phone's list too.
    expect(phone.cleared, unorderedEquals([7, 9]));
    expect(NotificationInbox.instance.value, isEmpty);

    // Back on Today: the dot is gone.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(dot, findsNothing);
  });

  testWidgets('a reminder arriving while the app is open shows the dot', (
    tester,
  ) async {
    final phone = _PhoneWithReminders([]);
    Notifications.instance = phone;
    await pumpToday(tester);
    expect(dot, findsNothing);

    phone.waiting = [
      const DeliveredNotification(id: 3, title: 'Payday', body: 'Log it.'),
    ];
    await NotificationInbox.instance.refresh();
    await tester.pump();
    expect(dot, findsOneWidget);
  });
}
