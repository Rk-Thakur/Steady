import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

/// A reminder that has arrived and is still in the phone's notification
/// list (not tapped or cleared yet).
@immutable
class DeliveredNotification {
  const DeliveredNotification({
    required this.id,
    required this.title,
    required this.body,
    this.route,
  });

  final int id;
  final String title;
  final String body;

  /// Where tapping it goes (a route, or "route#argument").
  final String? route;
}

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

  /// Whether reminders arrive at their time. Android needs "Alarms &
  /// reminders" allowed for that; without it, up to an hour late.
  Future<bool> onTime();

  /// Opens the system screen to allow on-time reminders (Android).
  Future<void> askForOnTime();

  /// Replaces everything pending with [plan].
  Future<void> replaceAll(List<PlannedNotification> plan);

  /// Steady's reminders that arrived and are still in the notification list.
  Future<List<DeliveredNotification>> delivered();

  /// Removes these from the notification list (they've been seen in the app).
  Future<void> clearDelivered(Iterable<int> ids);
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

class LocalNotifications implements Notifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();

  /// The Android channel. High importance, so reminders pop up as a banner
  /// (a channel's importance can't change once created, hence a new id).
  static const _channelId = 'steady_reminders';

  /// The first channel, default importance (no banner). Removed at launch.
  static const _oldChannelId = 'reminders';

  /// Android: the wave mark in the status bar, tinted Steady green, and
  /// the full-colour logo beside the text. (iOS always shows the app icon.)
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Reminders',
      channelDescription: 'Logging nudges, bills due soon and recaps',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_steady',
      color: Color(0xFF1F5A47),
      largeIcon: DrawableResourceAndroidBitmap('ic_notification_large'),
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
    await _android?.deleteNotificationChannel(channelId: _oldChannelId);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> onTime() async {
    final android = _android;
    if (android == null) return true; // iOS delivers on time
    return await android.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> askForOnTime() async {
    await _android?.requestExactAlarmsPermission();
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
    // Exact when allowed; otherwise Android may deliver up to an hour late.
    final mode = await onTime()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final used = <int>{};
    for (final n in plan) {
      await _plugin.zonedSchedule(
        id: _idFor(n, used),
        title: n.title,
        body: n.body,
        payload: n.route,
        // Each reminder fires once (the plan is rebuilt whenever data
        // changes), so only the instant matters: UTC needs no time-zone
        // database, and DateTime already resolved daylight saving.
        scheduledDate: tz.TZDateTime.from(n.at.toUtc(), tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: mode,
      );
    }
    debugPrint(
      'Steady: scheduled ${plan.length} reminders '
      '(${mode == AndroidScheduleMode.exactAllowWhileIdle ? 'on time' : 'inexact'})',
    );
  }

  /// An id from the reminder's minute and kind, so a reminder that already
  /// arrived never shares its id with a future one: clearing it from the
  /// notification list can't cancel anything still to come. Same minute and
  /// kind (two bills due at 9 AM) take the next free id.
  static int _idFor(PlannedNotification n, Set<int> used) {
    final minute = n.at.toUtc().millisecondsSinceEpoch ~/ 60000;
    var id = (minute * 16 + n.kind.index * 2) % 0x7fffffff;
    while (!used.add(id)) {
      id = (id + 1) % 0x7fffffff;
    }
    return id;
  }

  @override
  Future<List<DeliveredNotification>> delivered() async {
    final active = await _plugin.getActiveNotifications();
    return [
      for (final n in active)
        // Android also lists other channels' notifications from this app.
        if (n.id != null && (n.channelId == null || n.channelId == _channelId))
          DeliveredNotification(
            id: n.id!,
            title: n.title ?? '',
            body: n.body ?? '',
            route: n.payload,
          ),
    ];
  }

  @override
  Future<void> clearDelivered(Iterable<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }
}
