import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// 04 Bills radar: everything due before payday, and subscriptions to review.
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  /// Review messages shown after Keep / Remind, by bill id.
  final _reviewed = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final today = store.today;
    final payday = store.nextPayday;
    final covered = store.dailyNumber.poolCents >= 0;
    final review = store.bills
        .where((b) => b.needsReview || _reviewed.containsKey(b.id))
        .toList();
    final upcoming = store.upcomingBills
        .where((b) => !review.contains(b))
        .toList();
    String m(int cents) => formatMoney(cents, symbol: symbol);

    return TabBody(
      children: [
        TabTitle(
          'Bills radar',
          subtitle:
              '${formatShortDate(today)} → ${formatShortDate(payday)} (next payday)',
          trailing: CircleIconButton(
            icon: Icons.add_rounded,
            label: 'Add a bill',
            onTap: () => Navigator.of(context).pushNamed(Routes.billEdit),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s4),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(SteadyRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      m(store.reservedBillsCents),
                      style: SteadyType.title.copyWith(fontSize: 30),
                    ),
                  ),
                  Icon(
                    covered ? Icons.check_rounded : Icons.priority_high_rounded,
                    size: 16,
                    color: covered ? c.positive : c.dangerFg,
                  ),
                  const SizedBox(width: SteadySpace.s1),
                  Text(
                    covered ? 'All covered' : 'Not covered',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: covered ? c.positive : c.dangerFg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Timeline(
                bills: store.upcomingBills,
                today: today,
                payday: payday,
              ),
              const SizedBox(height: SteadySpace.s1),
              DefaultTextStyle(
                style: SteadyType.caption.copyWith(
                  fontSize: 12,
                  color: c.mutedStrong,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Today'), Text('Payday')],
                ),
              ),
            ],
          ),
        ),
        if (review.isNotEmpty) ...[
          Text(
            'Needs a look (${review.where((b) => b.needsReview).length})',
            style: SteadyType.heading,
          ),
          for (final b in review)
            _ReviewCard(
              bill: b,
              symbol: symbol,
              message: _reviewed[b.id],
              onKeep: () {
                store.updateBill(b.copyWith(needsReview: false));
                setState(
                  () => _reviewed[b.id] =
                      'Kept. We will not flag this ${b.priceWentUp ? 'price' : 'again'}.',
                );
              },
              onRemind: () {
                store.updateBill(b.copyWith(needsReview: false));
                setState(
                  () => _reviewed[b.id] =
                      'Reminder set for ${formatShortDate(b.dueDate.addDays(-2))}, 2 days before it renews.',
                );
              },
            ),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Upcoming', style: SteadyType.heading),
            const SizedBox(height: SteadySpace.s1),
            if (upcoming.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SteadySpace.s3),
                child: Text(
                  'Nothing else due before payday.',
                  style: SteadyType.body.copyWith(color: c.muted),
                ),
              ),
            for (var i = 0; i < upcoming.length; i++) ...[
              if (i > 0) Divider(color: c.line, height: 1),
              InkWell(
                onTap: () =>
                    Navigator.of(context)
                        .pushNamed(Routes.billEdit, arguments: upcoming[i].id),
                child: ValueRow(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  label: upcoming[i].name,
                  labelWidget: _BillLabel(
                    bill: upcoming[i],
                    today: today,
                    payday: payday,
                  ),
                  value:
                      '${upcoming[i].isEstimate ? '~' : ''}${m(upcoming[i].reservedBefore(payday))}',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Today → payday axis with a dot per unpaid bill. Amber = needs a look,
/// outlined = estimate, filled = fixed amount.
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.bills,
    required this.today,
    required this.payday,
  });
  final List<Bill> bills;
  final LocalDate today;
  final LocalDate payday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final span = today.daysUntil(payday).clamp(1, 1000);
    return ExcludeSemantics(
      child: SizedBox(
        height: 24,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth - 20;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 11,
                  child: Container(height: 2, color: c.dashed),
                ),
                for (final b in bills)
                  Positioned(
                    left:
                        w * (today.daysUntil(b.dueDate).clamp(0, span) / span),
                    top: 5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.needsReview
                            ? c.warningFg
                            : b.isEstimate
                            ? c.surface
                            : c.primary,
                        border: b.isEstimate && !b.needsReview
                            ? Border.all(color: c.primary, width: 2)
                            : null,
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  top: 2,
                  child: Container(
                    width: 6,
                    height: 20,
                    decoration: BoxDecoration(
                      color: c.ink,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.bill,
    required this.symbol,
    required this.message,
    required this.onKeep,
    required this.onRemind,
  });

  final Bill bill;
  final String symbol;
  final String? message;
  final VoidCallback onKeep;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    // Yearly costs round to the nearest whole unit.
    String perYear(int cents) => formatMoney(
      (cents * 12 + 50) ~/ 100 * 100,
      symbol: symbol,
      showCents: false,
    );
    final yearly = perYear(bill.amountCents);
    final (title, body, tone, icon) = bill.priceWentUp
        ? (
            '${bill.name} · price went up',
            'Now ${m(bill.amountCents)}, up from ${m(bill.previousAmountCents!)} · '
                '${perYear(bill.amountCents - bill.previousAmountCents!)} more a year',
            BannerTone.warning,
            Icons.trending_up_rounded,
          )
        : (
            '${bill.name} · still using it?',
            'Renews ${formatShortDate(bill.dueDate)} · ${m(bill.amountCents)}/mo · $yearly a year',
            BannerTone.danger,
            Icons.help_outline_rounded,
          );
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icon: icon, tone: tone, size: 36, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      body,
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (message == null)
            ButtonRow(
              children: [
                SteadyButton(
                  'Keep it',
                  kind: ButtonKind.secondary,
                  height: 44,
                  onPressed: onKeep,
                ),
                SteadyButton(
                  'Remind me to cancel',
                  kind: ButtonKind.inverse,
                  height: 44,
                  onPressed: onRemind,
                ),
              ],
            )
          else
            SoftBanner(
              radius: 12,
              child: Text(
                message!,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: c.positive,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Car insurance · Oct 8", "Electric · Oct 11 · est.", "Gym · 2× before
/// payday", and overdue bills in the alert color.
class _BillLabel extends StatelessWidget {
  const _BillLabel({
    required this.bill,
    required this.today,
    required this.payday,
  });
  final Bill bill;
  final LocalDate today;
  final LocalDate payday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final times = bill.occurrencesBefore(payday).length;
    final overdue = bill.isOverdueOn(today);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: bill.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: overdue
                ? ' · overdue since ${formatShortDate(bill.dueDate)}'
                : ' · ${formatShortDate(bill.dueDate)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
              color: overdue ? c.dangerFg : c.muted,
            ),
          ),
          TextSpan(
            text:
                '${times > 1 ? ' · $times× before payday' : ''}${bill.isEstimate ? ' · est.' : ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.muted,
            ),
          ),
        ],
      ),
      style: SteadyType.body.copyWith(fontSize: 15),
    );
  }
}
