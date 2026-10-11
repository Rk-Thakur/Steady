import 'package:flutter/material.dart';

import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../core/text_case.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/appear_tile.dart';
import '../widgets/kit.dart';

/// One bill on Bills radar.
///
/// An icon tile coloured by how soon it's due (receipt, or a repeat arrow
/// for subscriptions), the name with a pill when it's an estimate, overdue
/// or needs a look, a line of detail ([meta]), and the amount with a
/// countdown: "Today", "Tomorrow", "in 6 days", "3 days late".
///
/// Moves like every list row ([AppearTile]).
class BillTile extends StatelessWidget {
  const BillTile({
    super.key,
    required this.bill,
    required this.amountCents,
    required this.today,
    required this.meta,
    required this.symbol,
    this.index = 0,
    this.onTap,
  });

  final Bill bill;

  /// What's shown: e.g. every occurrence before payday added up.
  final int amountCents;
  final LocalDate today;

  /// The detail line under the name ("Due Oct 8 · monthly").
  final String meta;
  final String symbol;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final days = today.daysUntil(bill.dueDate);
    final overdue = days < 0;
    final soon = !overdue && days <= 2;
    final tone = overdue
        ? BannerTone.danger
        : bill.needsReview || soon
        ? BannerTone.warning
        : bill.isSubscription
        ? BannerTone.info
        : BannerTone.primary;
    final countdown = switch (days) {
      0 => 'Today',
      1 => 'Tomorrow',
      final d when d < 0 => '${-d} ${d == -1 ? 'day' : 'days'} late',
      final d => 'in $d days',
    };
    final countdownColor = overdue
        ? c.dangerFg
        : soon
        ? c.warningFg
        : c.muted;
    final pill = overdue
        ? ('Overdue', c.dangerBg, c.dangerFg)
        : bill.needsReview
        ? ('Needs a look', c.warningBg, c.warningFg)
        : bill.isEstimate
        ? ('Estimate', c.segmentTrack, c.mutedStrong)
        : null;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            IconTile(
              icon: bill.isSubscription
                  ? Icons.autorenew_rounded
                  : Icons.receipt_long_outlined,
              tone: tone,
              size: 44,
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wraps: on a tight row the pill moves under the name.
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        titleCase(bill.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SteadyType.body.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (pill case (final label, final bg, final fg)) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(
                              SteadyRadius.pill,
                            ),
                          ),
                          child: Text(
                            label,
                            style: SteadyType.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${bill.isEstimate ? '~' : ''}'
                  '${formatMoney(amountCents, symbol: symbol)}',
                  style: SteadyType.body.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  countdown,
                  style: SteadyType.caption.copyWith(
                    fontSize: 12,
                    fontWeight: overdue || soon
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: countdownColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return AppearTile(index: index, onTap: onTap, child: row);
  }
}
