import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../domain/cycle.dart';
import '../../domain/daily_number.dart';
import '../../theme/tokens.dart';

/// "New pay cycle": what was left of the last cycle, what moved to goals,
/// and how the new daily number comes out of it. Opens by itself once on
/// the day a cycle starts; the Today banner reopens it.
Future<void> showCycleSummary(
  BuildContext context, {
  required CycleSummary summary,
  required DailyNumber number,
  required String symbol,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) =>
      _CycleSummarySheet(summary: summary, number: number, symbol: symbol),
);

class _CycleSummarySheet extends StatelessWidget {
  const _CycleSummarySheet({
    required this.summary,
    required this.number,
    required this.symbol,
  });

  final CycleSummary summary;
  final DailyNumber number;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = summary;
    final i = number.input;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    String plus(int cents) => '+${m(cents)}';
    final lastDay = s.start.addDays(-1);
    final caption = SteadyType.caption.copyWith(
      fontWeight: FontWeight.w500,
      color: c.muted,
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: SteadySpace.s4),
      child: Text(
        text.toUpperCase(),
        style: SteadyType.overline.copyWith(color: c.muted),
      ),
    );

    Widget row(
      String label,
      String value, {
      bool strong = false,
      bool indent = false,
    }) => Padding(
      padding: EdgeInsets.only(
        top: indent ? 2 : 10,
        bottom: indent ? 2 : 0,
        left: indent ? SteadySpace.s4 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: (indent ? SteadyType.caption : SteadyType.body).copyWith(
                color: strong ? c.ink : c.muted,
                fontWeight: indent ? FontWeight.w500 : null,
              ),
            ),
          ),
          const SizedBox(width: SteadySpace.s3),
          Text(
            value,
            style: (indent ? SteadyType.caption : SteadyType.body).copyWith(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final String note;
    if (s.leftOverCents < 0) {
      note =
          'Last cycle ended ${m(-s.leftOverCents)} over, so it comes out of '
          'this one and your daily number is a little lower.';
    } else if (s.carriedOverCents > 0) {
      note =
          "Money you didn't spend isn't lost: it carries into this cycle, "
          'so your daily number is a little higher.';
    } else {
      note = 'Every cent you had left went to your goals.';
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.screenMargin,
            0,
            SteadySpace.screenMargin,
            SteadySpace.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New pay cycle', style: SteadyType.title),
              const SizedBox(height: SteadySpace.s1),
              Text(
                '${formatShortDay(s.start)} to '
                '${formatShortDay(i.nextPayday.addDays(-1))} · '
                '${s.start.daysUntil(i.nextPayday)} days',
                style: caption,
              ),
              heading(
                'Last cycle · ${formatShortDay(s.endedCycleStart)} to '
                '${formatShortDay(lastDay)}',
              ),
              row('Left when it ended', m(s.leftOverCents)),
              if (s.goalsAdded.isNotEmpty) ...[
                row('Moved into your goals', m(-s.movedToGoalsCents)),
                for (final (name, cents) in s.goalsAdded)
                  row(name, plus(cents), indent: true),
              ],
              row('Carried over', m(s.carriedOverCents), strong: true),
              heading('This cycle'),
              row('Carried over', m(i.moneyAtStartOfDayCents)),
              if (i.incomeTodayCents > 0)
                row('Pay logged today', plus(i.incomeTodayCents)),
              if (i.billPaymentsTodayCents > 0)
                row('Bills paid today', m(-i.billPaymentsTodayCents)),
              row(
                'Bills due before ${formatShortDay(i.nextPayday)}',
                m(-i.unpaidBillsBeforePaydayCents),
              ),
              if (i.goalSetAsidesCents > 0)
                row('Set aside for goals', m(-i.goalSetAsidesCents)),
              row('To spend until payday', m(number.poolCents), strong: true),
              row(
                'Your daily number (÷ ${number.daysLeft} days)',
                m(number.dailyAllowanceCents),
                strong: true,
              ),
              const SizedBox(height: SteadySpace.s3),
              Text(note, style: caption),
            ],
          ),
        ),
      ),
    );
  }
}
