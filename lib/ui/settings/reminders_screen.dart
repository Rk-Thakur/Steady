import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// P2 Reminders. Local notifications only (scheduling is not wired yet).
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _daily = true;
  bool _bills = true;
  bool _night = true;
  bool _recap = false;
  final _times = ['1:00 PM', '8:30 PM'];
  String _selected = '8:30 PM';
  static const _extraTimes = ['6:00 PM', '10:00 AM'];
  static const _quiet = ['11 PM', '10 PM', 'midnight'];
  int _quietIndex = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final extra = _extraTimes.where((t) => !_times.contains(t)).toList();
    Widget row(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: child,
    );

    return SteadyPage(
      title: 'Reminders',
      gap: 18,
      children: [
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
                    value: _daily,
                    onChanged: (v) => setState(() => _daily = v),
                  ),
                  if (_daily) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: SteadySpace.s2,
                      runSpacing: SteadySpace.s2,
                      children: [
                        for (final t in _times)
                          SteadyChip(
                            label: t,
                            selected: t == _selected,
                            onTap: () => setState(() => _selected = t),
                          ),
                        if (extra.isNotEmpty)
                          AddChip(
                            label: '+ Time',
                            onTap: () => setState(() {
                              _times.add(extra.first);
                              _selected = extra.first;
                            }),
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
                value: _bills,
                onChanged: (v) => setState(() => _bills = v),
              ),
            ),
            row(
              SwitchRow(
                title: '10 PM pause',
                subtitle: 'Asks "planned or impulse?" before late-night buys',
                value: _night,
                onChanged: (v) => setState(() => _night = v),
              ),
            ),
            row(
              SwitchRow(
                title: 'Weekly & monthly recap',
                subtitle: 'Sunday evening, and the 1st of each month',
                value: _recap,
                onChanged: (v) => setState(() => _recap = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Quiet hours: no reminders from ${_quiet[_quietIndex]} to 7 AM.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            LinkText(
              'Change',
              onTap: () => setState(
                () => _quietIndex = (_quietIndex + 1) % _quiet.length,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
