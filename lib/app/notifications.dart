import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

/// Local notifications (Handoff 4: "Reminders are scheduled on this phone.
/// Nothing comes from a server"). Replaceable in tests; does nothing until
/// [main] installs [LocalNotifications].
abstract class Notifications {
  static Notifications instance = const _NoNotifications();

  /// False for the stand-in, so nothing is planned or scheduled in tests.
  bool get enabled;

  Future<void> init();

  /// Routes of notifications the user tapped while the app was running.
  Stream<String> get taps;

  /// The route of the notification that launched the app, if one did.
  Future<String?> launchRoute();

  /// Asks the OS (once; later calls return the answer). True if allowed.
  Future<bool> requestPermission();

  /// Whether notifications are allowed right now, without asking. False
  /// before the user was ever asked, too.
  Future<bool> permissionGranted();

  /// Replaces everything pending with [plan].
  Future<void> replaceAll(List<PlannedNotification> plan);
}

class _NoNotifications implements Notifications {
  const _NoNotifications();

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
  Future<void> replaceAll(List<PlannedNotification> plan) async {}
}

class LocalNotifications implements Notifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Logging nudges, bills due soon and recaps',
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  bool get enabled => true;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_steady'),
        // Permission is asked for from the onboarding / Reminders screens,
        // not at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null) _taps.add(route);
      },
    );
  }

  @override
  Future<String?> launchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details!.notificationResponse?.payload;
  }

  @override
  Future<bool> permissionGranted() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final p = await ios.checkPermissions();
      return p != null && (p.isEnabled || p.isProvisionalEnabled);
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {
    // Only pending ones: notifications already showing stay put.
    await _plugin.cancelAllPendingNotifications();
    for (var i = 0; i < plan.length; i++) {
      final n = plan[i];
      await _plugin.zonedSchedule(
        id: i,
        title: n.title,
        body: n.body,
        payload: n.route,
        // Each reminder fires once (the plan is rebuilt whenever data
        // changes), so only the instant matters: UTC needs no time-zone
        // database, and DateTime already resolved daylight saving.
        scheduledDate: tz.TZDateTime.from(n.at.toUtc(), tz.UTC),
        notificationDetails: _details,
        // Inexact: no exact-alarm permission, and a minute late is fine.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    debugPrint('Steady: scheduled ${plan.length} reminders');
  }
}
