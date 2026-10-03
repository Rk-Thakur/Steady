import 'package:flutter/material.dart';

import '../data/store_scope.dart';
import '../theme/tokens.dart';
import 'routes.dart';
import 'widgets/kit.dart';

/// Debug-only index of every screen on the design canvas, grouped like the
/// canvas rows. Opened from Settings › All screens.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final firstEntry = store.history.firstOrNull?.id;
    final firstGoal = store.goals.firstOrNull?.id;
    final c = context.colors;

    final sections = <(String, List<(String, String, Object?)>)>[
      (
        'Key screens',
        [
          ('01 Today · Safe to spend', Routes.home, null),
          ('02 Can I afford it?', Routes.afford, null),
          ('03 Log spend + mood', Routes.logSpend, null),
          ('04 Bills radar', Routes.bills, null),
          ('05 Paycheck Vault', Routes.vault, null),
          ('06 Spending triggers', Routes.insights, null),
        ],
      ),
      (
        'Step 1 · Onboarding',
        [
          ('O0 Splash', Routes.splash, null),
          ('O1 Welcome', Routes.welcome, null),
          ('O2 How you get paid', Routes.onbIncome, null),
          ('O3 Set up your money', Routes.onbMoney, null),
          ('O4 Your daily number', Routes.onbReveal, null),
          ('O5 Allow reminders', Routes.notifPermission, null),
        ],
      ),
      (
        'Step 3 · Split expenses',
        [
          ('H1 Split setup', Routes.splitSetup, null),
          ('H2 Splits', Routes.splits, null),
          ('H3 Settle up', Routes.settleUp, null),
        ],
      ),
      (
        'Step 4 · Edge states for Today',
        [
          ('S1 Empty · new manual user', Routes.todayEmpty, null),
          ('S2 Loading skeleton', Routes.todayLoading, null),
          ('S3 Catch-up reminder', Routes.todayCatchUp, null),
          ('S4 Overspent today', '', null),
        ],
      ),
      (
        'Step 5 · Settings & profile',
        [
          ('P1 Settings', Routes.settings, null),
          ('P2 Reminders', Routes.reminders, null),
          ('P3 Categories & bills', Routes.categories, null),
          ('P4 Backup & export', Routes.backup, null),
          ('App lock · Set PIN (spec, not on canvas)', Routes.setPin, null),
          ('App lock · Locked (spec, not on canvas)', Routes.lock, null),
        ],
      ),
      (
        'Step 6 · Goals',
        [
          ('G1 Goals', Routes.goals, null),
          ('G2 New goal', Routes.goalNew, null),
          if (firstGoal != null)
            ('G3 Goal detail', Routes.goalDetail, firstGoal),
          ('G4 Goal reached', Routes.goalDone, firstGoal),
        ],
      ),
      (
        'Supporting screens',
        [
          ('N1 Notifications', Routes.notifications, null),
          ('N2 Profile', Routes.profile, null),
          ('N3 Help & feedback', Routes.help, null),
          (
            'N4 Edit category',
            Routes.categoryEdit,
            store.categories.firstOrNull?.id,
          ),
          ('N5 Add a bill', Routes.billEdit, null),
        ],
      ),
      (
        'Offline v1 additions',
        [
          ('V1 Log income', Routes.logIncome, null),
          ('V2 Did you get paid?', Routes.paidPrompt, null),
          ('V3 History', Routes.history, null),
          if (firstEntry != null)
            ('V4 Edit entry', Routes.editEntry, firstEntry),
          ('V5 Weekly summary', Routes.summaryWeek, null),
          ('V6 Monthly summary', Routes.summaryMonth, null),
        ],
      ),
    ];

    return SteadyPage(
      title: 'All screens',
      subtitle: 'Debug builds only · dark variants: switch theme in Settings',
      children: [
        for (final (title, items) in sections)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Overline(title),
              const SizedBox(height: 6),
              GroupedList(
                children: [
                  for (final (label, route, args) in items)
                    NavRow(
                      label: label,
                      value: route.isEmpty ? 'Log > \$46 today' : null,
                      onTap: route.isEmpty
                          ? null
                          : () => route == Routes.home
                                ? Navigator.of(context)
                                      .popUntil((r) => r.isFirst)
                                : Navigator.of(context)
                                      .pushNamed(route, arguments: args),
                    ),
                ],
              ),
            ],
          ),
        Text(
          'S4 appears on Today whenever spending passes the daily number.',
          style: SteadyType.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
      ],
    );
  }
}
