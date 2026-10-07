import 'package:flutter/material.dart';

import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../domain/after_payday.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/steady_card.dart';

/// "Before next payday": one bar per bill this cycle (paid vs to go),
/// the reserved total, and a nudge when subscriptions need a look.
class BillsCard extends StatelessWidget {
  const BillsCard({
    super.key,
    required this.bills,
    required this.reservedCents,
    required this.needsReviewCount,
    required this.symbol,
    this.afterPayday = const [],
    this.payday,
    this.onSeeAll,
  });

  final List<CycleBill> bills;
  final int reservedCents;
  final int needsReviewCount;
  final String symbol;

  /// Big bills due on [payday] or just after it (not reserved this cycle).
  final List<Bill> afterPayday;
  final LocalDate? payday;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final paid = bills.where((b) => b.paid).length;
    final toGo = bills.length - paid;

    return SteadyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Before next payday',
            actionLabel: 'See all',
            onAction: onSeeAll,
          ),
          const SizedBox(height: SteadySpace.s1),
          if (bills.isNotEmpty)
            ExcludeSemantics(
              child: SizedBox(
                height: 34,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < bills.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bills[i].paid ? c.billPaid : c.billPending,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: SteadySpace.s3),
          Text.rich(
            TextSpan(
              style: SteadyType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: c.muted,
              ),
              children: [
                TextSpan(
                  text:
                      '${bills.length} ${bills.length == 1 ? 'bill' : 'bills'} · ',
                ),
                TextSpan(
                  text:
                      '${formatMoney(reservedCents, symbol: symbol)} reserved',
                  style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' · $paid paid, $toGo to go'),
              ],
            ),
          ),
          if (afterPayday.isNotEmpty && payday != null) ...[
            const SizedBox(height: SteadySpace.s3),
            Semantics(
              button: onSeeAll != null,
              child: InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: SteadySize.minTouchTarget,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: c.mutedStrong,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _afterPaydayLine(),
                          style: SteadyType.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: c.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (needsReviewCount > 0) ...[
            const SizedBox(height: SteadySpace.s3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 18, color: c.warningFg),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.ink,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '$needsReviewCount ${needsReviewCount == 1 ? 'subscription' : 'subscriptions'}',
                            style: TextStyle(
                              color: c.warningFg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: needsReviewCount == 1
                                ? ' needs a look'
                                : ' need a look',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "Rent ($1,450.00) is due the day after payday. It comes from your next
  /// pay." / "2 bills ($1,600.00) are due just after payday. …"
  String _afterPaydayLine() {
    final total = afterPayday.fold(0, (sum, b) => sum + b.amountCents);
    final money = formatMoney(total, symbol: symbol);
    if (afterPayday.length == 1) {
      final b = afterPayday.single;
      return '${b.name} ($money) is due ${afterPaydayLabel(b.dueDate, payday!)}. '
          'It comes from your next pay.';
    }
    return '${afterPayday.length} bills ($money) are due just after payday. '
        'They come from your next pay.';
  }
}
