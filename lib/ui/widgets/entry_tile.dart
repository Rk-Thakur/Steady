import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import 'appear_tile.dart';
import 'kit.dart';
import 'tones.dart';

/// One logged entry, the same everywhere it's listed (Today, History).
///
/// A tile that says what it is (a category letter, or an icon for income,
/// the Vault, a bill or a shared expense), the name with a mood pill, what
/// else matters in one line, and the amount with the time it was logged.
///
/// It moves like every list row ([AppearTile]): eases in, one after
/// another by [index], and dips while pressed.
class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, this.index = 0, this.onTap});

  final Entry entry;

  /// Position in its list: later rows start a little later.
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final e = entry;
    final cat = store.categoryById(e.categoryId);
    final title = e.merchant ?? cat?.name ?? (e.isIncome ? 'Income' : 'Spend');
    final meta = <String>[
      if (e.isIncome) e.toVault ? 'Income · to Vault' : 'Income · to today',
      if (e.fromVault) 'from Vault',
      if (e.isBillPayment) 'Bill paid',
      if (e.isSpend && !e.isBillPayment && cat != null) cat.name,
      if (e.splitId != null)
        'shared · ${store.splits.group(e.splitId!)?.name ?? 'split'}',
      if (e.isSpend &&
          e.planned == true &&
          e.splitId == null &&
          !e.isBillPayment)
        'planned',
      if (e.isSpend && e.planned == false) 'unplanned',
    ].join(' · ');
    final amount = e.isSpend
        ? formatMoney(-e.amountCents, symbol: store.symbol)
        : formatMoney(e.amountCents, symbol: store.symbol, signed: true);
    final mood = e.mood == null || e.mood == Mood.neutral ? null : e.mood;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _Leading(entry: e, category: cat, title: title),
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
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SteadyType.body.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (mood != null) ...[_MoodPill(mood)],
                    ],
                  ),
                  if (meta.isNotEmpty)
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
                  amount,
                  style: SteadyType.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: e.isIncome ? c.positive : c.ink,
                  ),
                ),
                Text(
                  formatTime(e.createdAtUtc.toLocal()),
                  style: SteadyType.caption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.muted,
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

/// A category letter, or an icon for entries that aren't everyday spends.
class _Leading extends StatelessWidget {
  const _Leading({
    required this.entry,
    required this.category,
    required this.title,
  });
  final Entry entry;
  final BudgetCategory? category;
  final String title;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final icon = e.fromVault
        ? Icons.savings_outlined
        : e.isIncome
        ? (e.toVault ? Icons.savings_outlined : Icons.south_west_rounded)
        : e.isBillPayment
        ? Icons.receipt_long_outlined
        : e.splitId != null
        ? Icons.people_outline_rounded
        : null;
    if (icon == null) {
      return LetterTile(letter: title, tone: toneOf(category?.tone), size: 44);
    }
    return IconTile(
      icon: icon,
      tone: e.isIncome ? BannerTone.primary : toneOf(category?.tone),
      size: 44,
    );
  }
}

/// "Tired", small and soft, next to the name.
class _MoodPill extends StatelessWidget {
  const _MoodPill(this.mood);
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: c.segmentTrack,
        borderRadius: BorderRadius.circular(SteadyRadius.pill),
      ),
      child: Text(
        mood.label,
        style: SteadyType.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c.mutedStrong,
        ),
      ),
    );
  }
}
