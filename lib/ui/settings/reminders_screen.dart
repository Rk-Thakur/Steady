import 'package:flutter/material.dart';

import '../../app/notifications.dart';
import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../domain/reminders.dart';
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
  static const _paydayPresets = [8 * 60, 9 * 60];
  static const _quietOptions = [23 * 60, 22 * 60, 0];

  /// Null until asked; false shows how to turn notifications back on.
  bool? _allowed;

  /// False on Android without "Alarms & reminders": up to an hour late.
  bool? _onTime;

  /// Back from the phone's Settings app: notifications may be on now.
  late final _lifecycle = AppLifecycleListener(onResume: _recheck);

  @override
  void initState() {
    super.initState();
    _lifecycle; // start listening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (StoreScope.read(context).settings.reminders.anyOn) _askPermission();
      _checkOnTime();
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _recheck() async {
    if (!Notifications.instance.enabled) return;
    final allowed = await Notifications.instance.permissionGranted();
    if (mounted) setState(() => _allowed = allowed);
    await _checkOnTime();
  }

  Future<void> _checkOnTime() async {
    if (!Notifications.instance.enabled) return;
    final onTime = await Notifications.instance.onTime();
    if (mounted) setState(() => _onTime = onTime);
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

  Future<void> _pickTime(
    int current,
    ReminderSettings Function(ReminderSettings r, int minutes) apply,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _update((r) => apply(r, picked.hour * 60 + picked.minute));
    }
  }

  /// Preset chips, the current time if it isn't one of them, and "+ Time".
  Widget _times({
    required List<int> presets,
    required int selected,
    required ValueChanged<int> onSelected,
    required VoidCallback onPick,
  }) => Wrap(
    spacing: SteadySpace.s2,
    runSpacing: 0, // chips carry their own touch padding
    children: [
      for (final t in [...presets, if (!presets.contains(selected)) selected])
        SteadyChip(
          label: _timeLabel(t),
          selected: t == selected,
          onTap: () => onSelected(t),
        ),
      AddChip(label: '+ Time', onTap: onPick),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final store = StoreScope.of(context);
    final r = store.settings.reminders;
    final regularPay = store.settings.payFrequency != PayFrequency.varies;
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
              body: Theme.of(context).platform == TargetPlatform.iOS
                  ? 'To get these reminders, open Settings › Steady › '
                        'Notifications and turn on Allow Notifications.'
                  : 'To get these reminders, open Settings › Apps › Steady › '
                        'Notifications and turn them on.',
              leadColor: c.warningFg,
            ),
          )
        else if (_onTime == false && r.anyOn)
          SoftBanner(
            tone: BannerTone.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeadText(
                  lead: 'Reminders may arrive up to an hour late.',
                  body:
                      'Android holds them back unless Steady may set alarms. '
                      'Allow "Alarms & reminders" for Steady to get them on '
                      'time.',
                  leadColor: c.warningFg,
                ),
                LinkText('Allow', onTap: Notifications.instance.askForOnTime),
              ],
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
                    _times(
                      presets: _presetTimes,
                      selected: r.logAtMinutes,
                      onSelected: (t) =>
                          _update((r) => r.copyWith(logAtMinutes: t)),
                      onPick: () => _pickTime(
                        r.logAtMinutes,
                        (r, t) => r.copyWith(logAtMinutes: t),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            row(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchRow(
                    title: 'Payday reminder',
                    subtitle: regularPay
                        ? 'On payday (${formatShortDay(store.nextPayday)}), '
                              'to log your pay and start a new cycle'
                        : "Your pay varies, so there's no fixed payday",
                    value: regularPay && r.payday,
                    onChanged: regularPay
                        ? (v) => _update((r) => r.copyWith(payday: v))
                        : null,
                  ),
                  if (regularPay && r.payday) ...[
                    const SizedBox(height: 10),
                    _times(
                      presets: _paydayPresets,
                      selected: r.paydayAtMinutes,
                      onSelected: (t) =>
                          _update((r) => r.copyWith(paydayAtMinutes: t)),
                      onPick: () => _pickTime(
                        r.paydayAtMinutes,
                        (r, t) => r.copyWith(paydayAtMinutes: t),
                      ),
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
                subtitle:
                    '${weekdayName(lastDayOfWeek(store.settings.weekStartsOn))} '
                    'evening (end of your week), and the 1st of each month',
                value: r.recaps,
                onChanged: (v) => _update((r) => r.copyWith(recaps: v)),
              ),
            ),
            row(
              SwitchRow(
                title: 'Money owed to you',
                subtitle:
                    'When someone owes you '
                    '${formatMoney(ReminderSettings.debtMinimumCents, symbol: store.symbol, showCents: false)}+ '
                    'for a week, then weekly',
                value: r.debtsOwedToYou,
                onChanged: (v) => _update((r) => r.copyWith(debtsOwedToYou: v)),
              ),
            ),
            row(
              SwitchRow(
                title: 'Money you owe',
                subtitle: 'A weekly nudge to pay people back',
                value: r.debtsYouOwe,
                onChanged: (v) => _update((r) => r.copyWith(debtsYouOwe: v)),
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
