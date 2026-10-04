import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/insights.dart';
import '../../domain/models/models.dart';
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
    final store = StoreScope.of(context);
    final symbol = store.symbol;
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);

    // Rolling window ending today.
    final insights = spendingInsights(
      period: Period.lastDays(store.today, _month ? 30 : 7),
      entries: store.entries,
      categories: store.categories,
    );
    final topMood = insights.topMood;
    // Biggest first; neutral (and untagged) always last.
    final moods = [...Mood.values.where((m) => m != Mood.neutral)]
      ..sort((a, b) => insights.byMood[b]!.compareTo(insights.byMood[a]!));
    moods.add(Mood.neutral);
    final maxMood = math.max(
      1,
      insights.byMood.values.fold(0, (a, b) => math.max(a, b)),
    );
    final trigger = insights.trigger;
    final plannedFraction = insights.taggedCents == 0
        ? 0.0
        : insights.plannedCents / insights.taggedCents;
    final plannedPct = (plannedFraction * 100).round();
    final monthPeriod = summaryPeriodFor(
      today: store.today,
      isMonth: true,
      weekStartsOn: store.settings.weekStartsOn,
      entries: store.entries,
    );

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
                subtitle: formatMonthYear(monthPeriod.start),
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
                trigger == null
                    ? 'Add a mood when you log a spend, and what drives your spending shows up here.'
                    : "When you're ${trigger.mood.label.toLowerCase()}, "
                          '${trigger.category.toLowerCase()} costs you '
                          '${whole(trigger.cents)} a ${_month ? 'month' : 'week'}.',
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
              for (final mood in moods)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          mood.label,
                          style: SteadyType.caption.copyWith(
                            fontWeight: mood == topMood
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: mood == Mood.neutral ? c.muted : c.ink,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Bar(
                          value: insights.byMood[mood]! / maxMood,
                          height: 12,
                          track: Colors.transparent,
                          fill: mood == topMood
                              ? c.primary
                              : mood == Mood.neutral
                              ? c.line
                              : c.billPending,
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          whole(insights.byMood[mood]!),
                          textAlign: TextAlign.right,
                          style: SteadyType.caption.copyWith(
                            fontWeight: mood == topMood
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mood == Mood.neutral ? c.muted : c.ink,
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
                    '${whole(insights.taggedCents)} total',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (insights.taggedCents == 0)
                Text(
                  'Mark spends as planned or unplanned when you log them.',
                  style: SteadyType.caption.copyWith(color: c.muted),
                )
              else ...[
                SplitBar(
                  fraction: plannedFraction,
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
                      _PctLabel(pct: plannedPct, label: 'planned'),
                      _PctLabel(pct: 100 - plannedPct, label: 'unplanned'),
                    ],
                  ),
                ),
              ],
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
                insights.lateNightCount == 0
                    ? 'Nothing logged after 10 PM.'
                    : '${whole(insights.lateNightCents)} after 10 PM · '
                          '${insights.lateNightCount} ${insights.lateNightCount == 1 ? 'purchase' : 'purchases'}',
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
