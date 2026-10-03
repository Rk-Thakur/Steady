import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// P1 Settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final s = store.settings;
    final c = context.colors;
    final name = s.displayName?.trim();
    final hasName = name != null && name.isNotEmpty;
    void go(String route) => Navigator.of(context).pushNamed(route);
    final activeGoals = store.goals.where((g) => !g.isReached).length;
    final billCount = store.bills.where((b) => !b.isPaid).length;

    return SteadyPage(
      title: 'Settings',
      gap: 18,
      children: [
        Panel(
          padding: const EdgeInsets.all(14),
          onTap: () => go(Routes.profile),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: c.hero,
                child: hasName
                    ? Text(
                        name.characters.first.toUpperCase(),
                        style: SteadyType.heading.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: c.onHero,
                        ),
                      )
                    : Icon(Icons.person_outline_rounded, color: c.onHero),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name : 'Add your name',
                      style: SteadyType.heading.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Manual tracking · ${s.currency.code}',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Edit',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ],
          ),
        ),
        _Group(
          label: 'Money',
          children: [
            NavRow(
              icon: Icons.event_outlined,
              label: 'Payday',
              value: formatShortDay(s.nextPayday),
              onTap: () => go(Routes.profile),
            ),
            NavRow(
              icon: Icons.payments_outlined,
              label: 'Income type',
              value: s.incomeType.title,
              onTap: () =>
                  Navigator.of(context)
                      .pushNamed(Routes.onbIncome, arguments: true),
            ),
            NavRow(
              icon: Icons.flag_outlined,
              label: 'Goals',
              value: '$activeGoals active',
              onTap: () => go(Routes.goals),
            ),
            NavRow(
              icon: Icons.people_outline_rounded,
              tone: BannerTone.warning,
              label: 'Split expenses',
              value: store.split == null
                  ? 'Off'
                  : 'With ${store.split!.personName}',
              onTap: () =>
                  go(store.split == null ? Routes.splitSetup : Routes.splits),
            ),
          ],
        ),
        _Group(
          label: 'App',
          children: [
            NavRow(
              icon: Icons.notifications_none_rounded,
              tone: BannerTone.info,
              label: 'Reminders',
              value: '3 on',
              onTap: () => go(Routes.reminders),
            ),
            NavRow(
              icon: Icons.category_outlined,
              tone: BannerTone.info,
              label: 'Categories & bills',
              value: '${store.categories.length} · $billCount',
              onTap: () => go(Routes.categories),
            ),
            NavRow(
              icon: Icons.lock_outline_rounded,
              tone: BannerTone.info,
              label: 'Backup & export',
              onTap: () => go(Routes.backup),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Overline('Appearance'),
            const SizedBox(height: 6),
            Segmented<ThemePreference>(
              options: ThemePreference.values,
              selected: s.theme,
              labelOf: (t) => switch (t) {
                ThemePreference.light => 'Light',
                ThemePreference.dark => 'Dark',
                ThemePreference.system => 'System',
              },
              onSelected: (t) => store.updateSettings(s.copyWith(theme: t)),
            ),
          ],
        ),
        _Group(
          label: 'More',
          children: [
            NavRow(
              icon: Icons.fingerprint_rounded,
              tone: BannerTone.neutral,
              label: 'App lock',
              subtitle: s.appLockEnabled
                  ? '4-digit PIN · locks after 1 min away'
                  : 'Ask for a PIN to open Steady',
              trailing: SteadySwitch(
                value: s.appLockEnabled,
                label: 'App lock',
                onChanged: (v) => v
                    ? Navigator.of(context).pushNamed(Routes.setPin)
                    : store.updateSettings(
                        s.copyWith(appLockEnabled: false, pin: () => null),
                      ),
              ),
            ),
            NavRow(
              icon: Icons.help_outline_rounded,
              tone: BannerTone.neutral,
              label: 'Help & feedback',
              onTap: () => go(Routes.help),
            ),
            if (kDebugMode)
              NavRow(
                icon: Icons.grid_view_rounded,
                tone: BannerTone.neutral,
                label: 'All screens',
                value: 'Debug',
                onTap: () => go(Routes.gallery),
              ),
          ],
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Overline(label),
      const SizedBox(height: 6),
      GroupedList(children: children),
    ],
  );
}
