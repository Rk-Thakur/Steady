import 'package:flutter/material.dart';

import '../../app/notification_inbox.dart';
import '../../app/notifications.dart';
import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../data/store_scope.dart';
import '../../domain/reminders.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../shell/home_shell.dart';
import '../widgets/kit.dart';
import '../widgets/empty_state.dart';

/// N1 Notifications: reminders that just arrived ("New"), then what Steady
/// will remind you about next, planned on this phone from your bills,
/// payday and Reminders settings.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _shown = 12;

  /// What was new when the screen opened. It stays listed here while the
  /// screen is open, though opening it marks it read (the bell's dot goes).
  List<DeliveredNotification> _new = NotificationInbox.instance.value;

  @override
  void initState() {
    super.initState();
    NotificationInbox.instance.refresh().then((_) {
      if (!mounted) return;
      setState(() => _new = NotificationInbox.instance.value);
      NotificationInbox.instance.markRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final plan = store.plannedNotifications(DateTime.now()).take(_shown);
    final today = store.today;
    String dayLabel(LocalDate d) => d == today
        ? 'Today'
        : d == today.addDays(1)
        ? 'Tomorrow'
        : formatShortDay(d);

    final byDay = <LocalDate, List<PlannedNotification>>{};
    for (final n in plan) {
      byDay.putIfAbsent(LocalDate.fromDateTime(n.at), () => []).add(n);
    }

    return SteadyPage(
      title: 'Notifications',
      // With new ones listed, "Coming up" heads its own section instead.
      subtitle: _new.isEmpty ? 'Coming up' : null,
      gap: 14,
      trailing: LinkText(
        'Settings',
        onTap: () => Navigator.of(context).pushNamed(Routes.reminders),
      ),
      children: [
        if (_new.isNotEmpty) ...[
          const Overline('New'),
          GroupedList(
            children: [
              for (final n in _new)
                _Item(
                  Icons.notifications_active_outlined,
                  BannerTone.danger,
                  n.title,
                  n.body,
                  '',
                  n.route ?? Routes.home,
                ),
            ],
          ),
          const Overline('Coming up'),
        ],
        if (byDay.isEmpty)
          store.settings.reminders.anyOn
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'Nothing coming up',
                  body: 'No reminders in the next two weeks.',
                )
              : const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  tone: BannerTone.neutral,
                  title: 'Reminders are off',
                  body: 'Turn them on in Settings to get nudges here.',
                ),
        for (final day in byDay.entries) ...[
          Overline(dayLabel(day.key)),
          GroupedList(
            children: [
              for (final n in day.value)
                _Item(
                  _icon(n.kind),
                  _tone(n.kind),
                  n.title,
                  n.body,
                  formatTime(n.at),
                  n.route,
                ),
            ],
          ),
        ],
        Text(
          'Reminders are scheduled on this phone. Nothing comes from a server.',
          textAlign: TextAlign.center,
          style: SteadyType.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
      ],
    );
  }

  static IconData _icon(ReminderKind kind) => switch (kind) {
    ReminderKind.logSpends => Icons.edit_note_rounded,
    ReminderKind.payday => Icons.payments_outlined,
    ReminderKind.billDue => Icons.event_outlined,
    ReminderKind.latePause => Icons.nightlight_outlined,
    ReminderKind.weeklyRecap => Icons.bar_chart_rounded,
    ReminderKind.monthlyRecap => Icons.calendar_month_outlined,
    ReminderKind.backup => Icons.save_alt_rounded,
    ReminderKind.debt => Icons.people_outline_rounded,
  };

  static BannerTone _tone(ReminderKind kind) => switch (kind) {
    ReminderKind.logSpends => BannerTone.info,
    ReminderKind.payday || ReminderKind.billDue => BannerTone.primary,
    ReminderKind.latePause || ReminderKind.backup => BannerTone.warning,
    ReminderKind.weeklyRecap || ReminderKind.monthlyRecap => BannerTone.neutral,
    ReminderKind.debt => BannerTone.warning,
  };
}

class _Item extends StatelessWidget {
  const _Item(
    this.icon,
    this.tone,
    this.title,
    this.body,
    this.time,
    this.route,
  );
  final IconData icon;
  final BannerTone tone;
  final String title;
  final String body;
  final String time;
  final String route;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: () => switch (route) {
        Routes.home => goToTab(context, ShellTab.today),
        Routes.bills => goToTab(context, ShellTab.bills),
        Routes.goalDetail => Navigator.of(context).pushNamed(
          route,
          arguments: StoreScope.of(context).goals.firstOrNull?.id,
        ),
        _ => openRouteLink(Navigator.of(context), route),
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: icon, tone: tone),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SteadyType.body.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    body,
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                  const SizedBox(height: SteadySpace.s1),
                  Text(
                    time,
                    style: SteadyType.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
