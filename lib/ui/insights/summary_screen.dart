import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/demo_insights.dart';
import '../../data/store_scope.dart';
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
    final symbol = StoreScope.of(context).symbol;
    final s = _month ? monthSummaryDemo : weekSummaryDemo;
    String m(int cents) => formatMoney(cents, symbol: symbol);

    return SteadyPage(
      title: s.title,
      subtitle: s.range,
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
                  note: s.inNote,
                ),
              ),
              const SizedBox(width: SteadySpace.s2),
              Expanded(
                child: _Stat(
                  label: 'Spent',
                  value: m(s.spentCents),
                  note: s.spentNote,
                ),
              ),
              const SizedBox(width: SteadySpace.s2),
              Expanded(
                child: _Stat(
                  label: 'Saved',
                  value: m(s.savedCents),
                  note: s.savedNote,
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
                    Text(
                      'Left over after spending & saving',
                      style: SteadyType.caption.copyWith(color: c.onHeroMuted),
                    ),
                    Text(
                      m(s.leftOverCents),
                      style: SteadyType.title.copyWith(
                        fontSize: 30,
                        color: c.highlight,
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
                    s.daysUnder,
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
                      s.chartTitle,
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '– – ${s.chartKey}',
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
              for (final cat in s.categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          cat.label,
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
              for (final sv in s.savings)
                ValueRow(
                  padding: const EdgeInsets.only(top: 10),
                  label: sv.label,
                  labelWidget: NameMeta(name: sv.label, meta: sv.note ?? ''),
                  value: formatMoney(sv.cents, symbol: symbol, signed: true),
                  valueColor: c.positive,
                ),
            ],
          ),
        ),
        SoftBanner(
          tone: BannerTone.warning,
          child: LeadText(
            lead: 'Worth a look.',
            body: s.worthALook,
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
              onPressed: () => setState(() => _toast = s.pdfToast),
            ),
          ],
        ),
        Text(
          s.footer,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.note});
  final String label;
  final String value;
  final String note;

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
            note,
            maxLines: 2,
            style: SteadyType.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.positive,
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
  final List<LabeledAmount> bars;
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
                          color: bars[i].cents > pace ? c.chartOver : c.primary,
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
