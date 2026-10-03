import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../data/store_scope.dart';
import '../routes.dart';
import '../shell/home_shell.dart';
import '../widgets/kit.dart';

/// N1 Notifications. Demo list from the design until local notifications
/// are scheduled and stored.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SteadyPage(
      title: 'Notifications',
      gap: 14,
      trailing: LinkText(
        'Settings',
        onTap: () => Navigator.of(context).pushNamed(Routes.reminders),
      ),
      children: const [
        Overline('Today'),
        GroupedList(
          children: [
            _Item(
              Icons.payments_outlined,
              BannerTone.primary,
              'Did you get paid?',
              'A client payment was expected this week.',
              '7:00 AM',
              Routes.paidPrompt,
              unread: true,
            ),
            _Item(
              Icons.priority_high_rounded,
              BannerTone.danger,
              "You went over today's number",
              'By \$12.40. See two easy ways to fix it.',
              '9:48 PM',
              Routes.home,
              unread: true,
            ),
            _Item(
              Icons.trending_up_rounded,
              BannerTone.warning,
              'Streamly price went up',
              'Now \$17.99/mo. Keep it or set a cancel reminder.',
              '9:05 AM',
              Routes.bills,
              unread: true,
            ),
            _Item(
              Icons.edit_note_rounded,
              BannerTone.info,
              'Time to log yesterday?',
              'Nothing logged on Thursday.',
              '8:30 AM',
              Routes.todayCatchUp,
              unread: true,
            ),
          ],
        ),
        Overline('Earlier'),
        GroupedList(
          children: [
            _Item(
              Icons.event_outlined,
              BannerTone.primary,
              'Car insurance due in 2 days',
              '\$128.00 on Oct 8 · already set aside',
              'Yesterday',
              Routes.bills,
            ),
            _Item(
              Icons.flag_outlined,
              BannerTone.primary,
              'Halfway there!',
              'Emergency fund passed 50%.',
              'Sep 30',
              Routes.goalDetail,
            ),
            _Item(
              Icons.people_outline_rounded,
              BannerTone.warning,
              'Split balance: \$64.50',
              'Alex owes you. Record it when you settle.',
              'Sep 29',
              Routes.settleUp,
            ),
            _Item(
              Icons.bar_chart_rounded,
              BannerTone.neutral,
              'Your weekly recap',
              'In \$820 · spent \$412.60 · saved \$236.80',
              'Sep 27',
              Routes.summaryWeek,
            ),
            _Item(
              Icons.calendar_month_outlined,
              BannerTone.neutral,
              'Your September recap',
              'Tired was your top spending trigger.',
              'Oct 1',
              Routes.summaryMonth,
            ),
          ],
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(
    this.icon,
    this.tone,
    this.title,
    this.body,
    this.time,
    this.route, {
    this.unread = false,
  });
  final IconData icon;
  final BannerTone tone;
  final String title;
  final String body;
  final String time;
  final String route;
  final bool unread;

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
        _ => Navigator.of(context).pushNamed(route),
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
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
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
            SizedBox(
              width: 8,
              child: unread
                  ? Semantics(
                      label: 'Unread',
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
