import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/insights.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// V5 Weekly summary / V6 Monthly summary.
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, this.month = false});
  final bool month;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late bool _month = widget.month;
  String? _toast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final store = StoreScope.of(context);
    final symbol = store.symbol;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);

    final weekStartsOn = store.settings.weekStartsOn;
    final period = summaryPeriodFor(
      today: store.today,
      isMonth: _month,
      weekStartsOn: weekStartsOn,
      entries: store.entries,
    );
    PeriodSummary summaryOf(Period p) => summarize(
      period: p,
      isMonth: _month,
      today: store.today,
      entries: store.entries,
      categories: store.categories,
      goals: store.goals,
      dailyNumbers: store.dailyNumbers,
      fallbackPaceCents: store.dailyNumber.dailyAllowanceCents,
    );
    final s = summaryOf(period);
    final prev = summaryOf(period.previous);
    final current = period.contains(store.today);
    final vs = _month
        ? 'vs ${formatMonthYear(prev.period.start).substring(0, 3)}'
        : 'vs last week';

    // "+$120 vs last week": green when the change is good for you.
    _Note note(
      int now,
      int before, {
      bool lowerIsBetter = false,
      bool percent = false,
    }) {
      if (!prev.hasEntries) return _Note('Nothing to compare yet', c.muted);
      final diff = now - before;
      if (diff == 0) return _Note('Same as before', c.muted);
      final text = percent && before > 0
          ? '${diff > 0 ? '+' : '−'}${(diff.abs() * 100 / before).round()}% $vs'
          : '${formatMoney(diff, symbol: symbol, showCents: false, signed: true)} $vs';
      final good = lowerIsBetter ? diff < 0 : diff > 0;
      return _Note(text, good ? c.positive : c.warningFg);
    }

    final inNote = note(s.inCents, prev.inCents);
    final spentNote = note(
      s.spentCents,
      prev.spentCents,
      lowerIsBetter: true,
      percent: true,
    );
    final savedNote = note(s.savedCents, prev.savedCents);

    final range = _month
        ? '${formatMonthYear(period.start)}${current ? ' so far' : ''}'
        : '${formatShortDay(period.start)} – '
              '${current ? 'today' : formatShortDay(period.end)}';
    final worthALook = _worthALook(s, whole);

    return SteadyPage(
      title: _month ? 'Monthly summary' : 'Weekly summary',
      subtitle: range,
      gap: 14,
      children: [
        Segmented<bool>(
          options: const [false, true],
          selected: _month,
          labelOf: (v) => v ? 'Month' : 'Week',
          onSelected: (v) => setState(() {
            _month = v;
            _toast = null;
          }),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Stat(
                  label: 'Money in',
                  value: m(s.inCents),
                  note: inNote,
                ),
              ),
              const SizedBox(width: SteadySpace.s2),
              Expanded(
                child: _Stat(
                  label: 'Spent',
                  value: m(s.spentCents),
                  note: spentNote,
                ),
              ),
              const SizedBox(width: SteadySpace.s2),
              Expanded(
                child: _Stat(
                  label: 'Saved',
                  value: m(s.savedCents),
                  note: savedNote,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s4),
          decoration: BoxDecoration(
            color: c.hero,
            borderRadius: BorderRadius.circular(SteadyRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Negative when bills or spending were paid from money
                    // that came in before this period: say so plainly.
                    Text(
                      s.leftOverCents < 0
                          ? 'More went out than came in'
                          : 'Left over after spending & saving',
                      style: SteadyType.caption.copyWith(color: c.onHeroMuted),
                    ),
                    Text(
                      m(s.leftOverCents.abs()),
                      style: SteadyType.title.copyWith(
                        fontSize: 30,
                        color: s.leftOverCents < 0 ? c.onHero : c.highlight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Days under your number',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.onHeroMuted,
                    ),
                  ),
                  Text(
                    s.daysCounted == 0
                        ? '—'
                        : '${s.daysUnder} of ${s.daysCounted}',
                    style: SteadyType.heading.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.onHero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _month ? 'Spending by week' : 'Spending by day',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '– – ${whole(s.paceCents)} ${_month ? 'weekly pace' : 'daily number'}',
                    style: SteadyType.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _PaceChart(bars: s.bars, pace: s.paceCents, gap: _month ? 14 : 8),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Key(color: c.primary, label: 'Under'),
                  const SizedBox(width: 14),
                  _Key(color: c.chartOver, label: 'Over'),
                ],
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Top categories',
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (s.categories.isEmpty) _Empty('Nothing spent yet.'),
              for (final cat in s.categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          cat.name,
                          style: SteadyType.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Bar(
                          value: cat.cents / (s.categories.first.cents * 1.12),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          m(cat.cents),
                          textAlign: TextAlign.right,
                          style: SteadyType.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Where savings went',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(Routes.goals),
                    child: Text(
                      'Goals',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (s.savings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: _Empty('No goal set-asides in this period.'),
                ),
              for (final sv in s.savings)
                ValueRow(
                  padding: const EdgeInsets.only(top: 10),
                  label: sv.name,
                  labelWidget: NameMeta(name: sv.name, meta: 'Daily set-aside'),
                  value: formatMoney(sv.cents, symbol: symbol, signed: true),
                  valueColor: c.positive,
                ),
            ],
          ),
        ),
        if (worthALook != null)
          SoftBanner(
            tone: BannerTone.warning,
            child: LeadText(
              lead: 'Worth a look.',
              body: worthALook,
              leadColor: c.warningFg,
            ),
          ),
        StatusToast(message: _toast, icon: null),
        ButtonRow(
          children: [
            SteadyButton(
              'See entries',
              kind: ButtonKind.secondary,
              height: 48,
              onPressed: () => Navigator.of(context).pushNamed(Routes.history),
            ),
            SteadyButton(
              'Save as PDF',
              height: 48,
              onPressed: () =>
                  setState(() => _toast = 'PDF reports are coming soon.'),
            ),
          ],
        ),
        Text(
          _month
              ? 'Calculated on this phone from your own entries.'
              : 'Calculated on this phone from your own entries. '
                    'Week starts ${weekdayName(weekStartsOn)}; change it in Profile.',
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
}

/// "Worth a look": the biggest day (or week) and what drove it.
String? _worthALook(PeriodSummary s, String Function(int) whole) {
  final b = s.biggest;
  if (b == null) return null;
  final what = s.isMonth
      ? 'Week ${b.bar.label.substring(3)}'
      : weekdayName(b.bar.start.weekday);
  final drivers = [
    if (b.topCategory != null) 'mostly ${b.topCategory!.toLowerCase()}',
    if (b.topMood != null) 'while ${b.topMood!.label.toLowerCase()}',
  ].join(' ');
  final tail = drivers.isEmpty
      ? '.'
      : '. ${drivers[0].toUpperCase()}${drivers.substring(1)}.';
  if (b.overByCents > 0) {
    return s.isMonth
        ? '$what ran over pace by ${whole(b.overByCents)}$tail'
        : '$what went ${whole(b.overByCents)} over your number$tail';
  }
  return '$what was your biggest ${s.isMonth ? 'week' : 'day'}: '
      '${whole(b.bar.cents)}${drivers.isEmpty ? '' : ', $drivers'}.';
}

class _Note {
  const _Note(this.text, this.color);
  final String text;
  final Color color;
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: SteadyType.caption.copyWith(color: context.colors.muted),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.note});
  final String label;
  final String value;
  final _Note note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(SteadySpace.s3),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SteadyType.caption.copyWith(fontSize: 12, color: c.muted),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: SteadyType.heading.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            note.text,
            maxLines: 2,
            style: SteadyType.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: note.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: SteadyType.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.colors.muted,
        ),
      ),
    ],
  );
}

/// Bars against a dashed pace line. Over the pace = Over color, plus label.
class _PaceChart extends StatelessWidget {
  const _PaceChart({required this.bars, required this.pace, required this.gap});
  final List<ChartBar> bars;
  final int pace;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const height = 110.0;
    final max =
        [...bars.map((b) => b.cents), pace].reduce((a, b) => a > b ? a : b) *
        1.1;
    return SizedBox(
      height: height + 20,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < bars.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: bars[i].cents / max * height,
                        decoration: BoxDecoration(
                          color: bars[i].over ? c.chartOver : c.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                            bottom: Radius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bars[i].label,
                        style: SteadyType.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20 + pace / max * height,
            child: LayoutBuilder(
              builder: (context, box) => Row(
                children: [
                  for (var i = 0; i < (box.maxWidth / 8).floor(); i++)
                    Container(
                      width: 5,
                      height: 2,
                      margin: const EdgeInsets.only(right: 3),
                      color: c.ink,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
