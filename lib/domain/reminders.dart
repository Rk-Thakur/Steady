import 'package:flutter/foundation.dart';

import '../core/date_format.dart';
import '../core/local_date.dart';
import '../core/money.dart';
import 'models/models.dart';

/// P2 Reminders: which local notifications to schedule, worked out on the
/// phone from the user's own data. Pure, so it is easy to test; the platform
/// side only hands the result to the OS.

enum ReminderKind {
  logSpends,
  payday,
  billDue,
  latePause,
  weeklyRecap,
  monthlyRecap,
  backup,
}

@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    required this.route,
  });

  final ReminderKind kind;

  /// Local wall-clock time.
  final DateTime at;
  final String title;
  final String body;

  /// Where tapping it goes (a route name).
  final String route;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.kind == kind &&
      other.at == at &&
      other.title == title &&
      other.body == body &&
      other.route == route;

  @override
  int get hashCode => Object.hash(kind, at, title, body, route);

  @override
  String toString() => '$at $title';
}

/// Every notification due in the next [days] days, soonest first, capped at
/// [max] (iOS keeps only 64 pending notifications per app).
List<PlannedNotification> planNotifications({
  required DateTime now,
  required AppSettings settings,
  required List<Bill> bills,
  required bool loggedToday,
  int days = 14,
  int max = 60,
}) {
  final r = settings.reminders;
  final today = LocalDate.fromDateTime(now);
  final horizon = today.addDays(days);
  String money(int cents) =>
      formatMoney(cents, symbol: settings.currencySymbol);
  DateTime at(LocalDate d, int minutes) =>
      DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);

  final out = <PlannedNotification>[];
  void add(
    ReminderKind kind,
    DateTime when,
    String title,
    String body,
    String route, {
    bool dropInQuietHours = false,
  }) {
    var time = when;
    if (_isQuiet(time, r.quietFromMinutes)) {
      if (dropInQuietHours) return;
      time = _quietEnd(time, r.quietFromMinutes);
    }
    if (!time.isAfter(now)) return;
    out.add(
      PlannedNotification(
        kind: kind,
        at: time,
        title: title,
        body: body,
        route: route,
      ),
    );
  }

  if (r.logSpends) {
    for (var i = 0; i < 7; i++) {
      final d = today.addDays(i);
      // "A nudge if nothing is logged by this time": today's only if so.
      if (i == 0 && loggedToday) continue;
      add(
        ReminderKind.logSpends,
        at(d, r.logAtMinutes),
        'Anything to log today?',
        'Takes 5 seconds. Keeps your number right.',
        ReminderRoutes.logSpend,
      );
    }
    // Regular pay: ask on payday (pay that varies starts cycles by itself).
    if (settings.payFrequency != PayFrequency.varies &&
        settings.nextPayday.isBefore(horizon)) {
      add(
        ReminderKind.payday,
        at(settings.nextPayday, 9 * 60),
        'Payday today?',
        'Log your pay when it arrives to start your new cycle.',
        ReminderRoutes.paidPrompt,
      );
    }
  }

  if (r.billsDue) {
    for (final b in bills) {
      for (final due in b.occurrencesBefore(horizon.addDays(2))) {
        final amount = b.isEstimate
            ? 'About ${money(b.amountCents)}'
            : money(b.amountCents);
        final setAside = due.isBefore(settings.nextPayday)
            ? ' · already set aside'
            : '';
        add(
          ReminderKind.billDue,
          at(due.addDays(-2), 9 * 60),
          '${b.name} due in 2 days',
          '$amount on ${formatShortDate(due)}$setAside',
          ReminderRoutes.bills,
        );
        add(
          ReminderKind.billDue,
          at(due, 9 * 60),
          '${b.name} is due today',
          '$amount$setAside',
          ReminderRoutes.bills,
        );
      }
    }
  }

  if (r.latePause) {
    for (var i = 0; i < 7; i++) {
      add(
        ReminderKind.latePause,
        at(today.addDays(i), 22 * 60),
        'A 10 PM pause',
        'Thinking of buying something? Check it against your number first.',
        ReminderRoutes.afford,
        dropInQuietHours: true,
      );
    }
  }

  if (r.recaps) {
    for (var d = today; d.isBefore(horizon); d = d.addDays(1)) {
      if (d.weekday == DateTime.sunday) {
        add(
          ReminderKind.weeklyRecap,
          at(d, 18 * 60),
          'Your weekly recap',
          'See what came in, what went out and what you saved.',
          ReminderRoutes.summaryWeek,
        );
      }
      if (d.day == 1) {
        add(
          ReminderKind.monthlyRecap,
          at(d, 9 * 60),
          'Your ${formatMonthYear(d.addDays(-1)).split(' ').first} recap',
          'Your month in one page, calculated on this phone.',
          ReminderRoutes.summaryMonth,
        );
      }
    }
  }

  if (r.backupMonthly) {
    // The 1st of the month, unless a backup was made in the last 3 weeks.
    var first = LocalDate(today.year, today.month, 1);
    if (first.isBefore(today)) {
      first = today.month == 12
          ? LocalDate(today.year + 1, 1, 1)
          : LocalDate(today.year, today.month + 1, 1);
    }
    final last = settings.lastBackupOn;
    final recent = last != null && last.daysUntil(first) < 21;
    if (first.isBefore(horizon.addDays(31)) && !recent) {
      add(
        ReminderKind.backup,
        at(first, 10 * 60),
        'Time for a backup',
        'Save a backup file so your history is safe if you lose your phone.',
        ReminderRoutes.backup,
      );
    }
  }

  out.sort((a, b) => a.at.compareTo(b.at));
  return out.length > max ? out.sublist(0, max) : out;
}

/// Quiet hours run from [quietFrom] (minutes; 0 = midnight) to 7 AM.
bool _isQuiet(DateTime t, int quietFrom) {
  final m = t.hour * 60 + t.minute;
  const end = ReminderSettings.quietEndMinutes;
  return quietFrom == 0 ? m < end : (m >= quietFrom || m < end);
}

/// The 7 AM that ends the quiet hours [t] falls in.
DateTime _quietEnd(DateTime t, int quietFrom) {
  final m = t.hour * 60 + t.minute;
  final nextDay = quietFrom != 0 && m >= quietFrom;
  final d = DateTime(t.year, t.month, t.day + (nextDay ? 1 : 0));
  return d.add(const Duration(minutes: ReminderSettings.quietEndMinutes));
}

/// Route names (kept here so the domain layer doesn't import UI code; checked
/// against [Routes] in tests).
abstract final class ReminderRoutes {
  static const logSpend = '/log/spend';
  static const paidPrompt = '/today/paid-prompt';
  static const bills = '/bills';
  static const afford = '/afford';
  static const summaryWeek = '/summary/week';
  static const summaryMonth = '/summary/month';
  static const backup = '/settings/backup';
}
