import 'package:flutter/material.dart';

import '../../app/notifications.dart';
import '../../core/date_format.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// P2 Reminders. Local notifications, scheduled on this phone.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const _presetTimes = [13 * 60, 20 * 60 + 30];
  static const _quietOptions = [23 * 60, 22 * 60, 0];

  /// Null until asked; false shows how to turn notifications back on.
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (StoreScope.read(context).settings.reminders.anyOn) _askPermission();
    });
  }

  Future<void> _askPermission() async {
    if (!Notifications.instance.enabled) return;
    final allowed = await Notifications.instance.requestPermission();
    if (mounted) setState(() => _allowed = allowed);
  }

  void _update(ReminderSettings Function(ReminderSettings r) change) {
    final store = StoreScope.read(context);
    final before = store.settings.reminders;
    final after = change(before);
    store.updateSettings(store.settings.copyWith(reminders: after));
    if (after.anyOn && !before.anyOn || _allowed == null) _askPermission();
  }

  Future<void> _pickTime(int current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _update(
        (r) => r.copyWith(logAtMinutes: picked.hour * 60 + picked.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = StoreScope.of(context).settings.reminders;
    final times = [
      ..._presetTimes,
      if (!_presetTimes.contains(r.logAtMinutes)) r.logAtMinutes,
    ];
    final quietIndex = _quietOptions.indexOf(r.quietFromMinutes);
    Widget row(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: child,
    );

    return SteadyPage(
      title: 'Reminders',
      gap: 18,
      children: [
        if (_allowed == false && r.anyOn)
          SoftBanner(
            tone: BannerTone.warning,
            child: LeadText(
              lead: 'Notifications are off for Steady.',
              body: "Turn them on in your phone's Settings app to get these reminders.",
              leadColor: c.warningFg,
            ),
          )
        else
          const SoftBanner(
            child: Text(
              'Manual tracking works when logging is a habit. A short daily nudge keeps your number accurate.',
            ),
          ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            row(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchRow(
                    title: 'Log your spends',
                    subtitle: 'A nudge if nothing is logged by this time',
                    value: r.logSpends,
                    onChanged: (v) => _update((r) => r.copyWith(logSpends: v)),
                  ),
                  if (r.logSpends) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: SteadySpace.s2,
                      runSpacing: SteadySpace.s2,
                      children: [
                        for (final t in times)
                          SteadyChip(
                            label: _timeLabel(t),
                            selected: t == r.logAtMinutes,
                            onTap: () =>
                                _update((r) => r.copyWith(logAtMinutes: t)),
                          ),
                        AddChip(
                          label: '+ Time',
                          onTap: () => _pickTime(r.logAtMinutes),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            row(
              SwitchRow(
                title: 'Bill due soon',
                subtitle: '2 days before each bill, plus the morning of',
                value: r.billsDue,
                onChanged: (v) => _update((r) => r.copyWith(billsDue: v)),
              ),
            ),
            row(
              SwitchRow(
                title: '10 PM pause',
                subtitle:
                    'A nudge to check "Can I afford it?" before late buys',
                value: r.latePause,
                onChanged: (v) => _update((r) => r.copyWith(latePause: v)),
              ),
            ),
            row(
              SwitchRow(
                title: 'Weekly & monthly recap',
                subtitle: 'Sunday evening, and the 1st of each month',
                value: r.recaps,
                onChanged: (v) => _update((r) => r.copyWith(recaps: v)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Quiet hours: no reminders from '
                '${_quietLabel(r.quietFromMinutes)} to 7 AM.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            LinkText(
              'Change',
              onTap: () => _update(
                (r) => r.copyWith(
                  quietFromMinutes:
                      _quietOptions[(quietIndex + 1) % _quietOptions.length],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _timeLabel(int minutes) =>
      formatTime(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));

  static String _quietLabel(int minutes) =>
      minutes == 0 ? 'midnight' : _timeLabel(minutes).replaceAll(':00', '');
}
