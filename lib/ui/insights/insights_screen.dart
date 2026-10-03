import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/demo_insights.dart';
import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// 06 Spending triggers.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _month = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final symbol = StoreScope.of(context).symbol;
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);
    final maxMood = InsightsDemo.moods
        .map((m) => m.cents)
        .reduce((a, b) => a > b ? a : b);

    return TabBody(
      gap: SteadySpace.s3,
      children: [
        TabTitle(
          'Insights',
          trailing: Segmented<bool>(
            expand: false,
            itemHeight: 36,
            options: const [false, true],
            selected: _month,
            labelOf: (m) => m ? 'Month' : 'Week',
            onSelected: (m) => setState(() => _month = m),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _LinkCard(
                title: 'Weekly summary',
                subtitle: 'In, spent, saved',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.summaryWeek),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LinkCard(
                title: 'Monthly summary',
                subtitle: monthSummaryDemo.range,
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.summaryMonth),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s4),
          decoration: BoxDecoration(
            color: c.highlight,
            borderRadius: BorderRadius.circular(SteadyRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR BIGGEST TRIGGER',
                style: SteadyType.overline.copyWith(color: c.onHighlight),
              ),
              const SizedBox(height: 6),
              Text(
                InsightsDemo.trigger,
                style: SteadyType.title.copyWith(
                  fontSize: 22,
                  height: 1.2,
                  color: c.onHighlight,
                ),
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Spend by mood',
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 11),
              for (final m in InsightsDemo.moods)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          m.mood,
                          style: SteadyType.caption.copyWith(
                            fontWeight: m.top
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: m.neutral ? c.muted : c.ink,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Bar(
                          value: m.cents / maxMood,
                          height: 12,
                          track: Colors.transparent,
                          fill: m.top
                              ? c.primary
                              : m.neutral
                              ? c.line
                              : c.billPending,
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          whole(m.cents),
                          textAlign: TextAlign.right,
                          style: SteadyType.caption.copyWith(
                            fontWeight: m.top
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: m.neutral ? c.muted : c.ink,
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
                      'Planned vs unplanned',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${whole(InsightsDemo.plannedTotalCents)} total',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SplitBar(
                fraction: InsightsDemo.plannedFraction,
                left: c.primary,
                right: c.chartOver,
              ),
              const SizedBox(height: 10),
              DefaultTextStyle(
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.ink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PctLabel(
                      pct: (InsightsDemo.plannedFraction * 100).round(),
                      label: 'planned',
                    ),
                    _PctLabel(
                      pct: 100 - (InsightsDemo.plannedFraction * 100).round(),
                      label: 'unplanned',
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
              Text(
                'Late-night spending',
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${whole(InsightsDemo.lateNightCents)} after 10 PM · ${InsightsDemo.lateNightCount} purchases',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
              const SizedBox(height: SteadySpace.s3),
              SteadyButton(
                'Turn on a 10 PM pause nudge',
                kind: ButtonKind.inverse,
                height: 44,
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.reminders),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PctLabel extends StatelessWidget {
  const _PctLabel({required this.pct, required this.label});
  final int pct;
  final String label;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$pct%',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        TextSpan(text: ' $label'),
      ],
    ),
  );
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Panel(
    radius: 18,
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: SteadySpace.s3,
    ),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SteadyType.body.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: SteadyType.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.muted,
          ),
        ),
      ],
    ),
  );
}
