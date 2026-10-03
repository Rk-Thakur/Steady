import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';

/// List row: 40px letter tile, merchant + "Category · planned", amount.
class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.entry,
    required this.category,
    required this.symbol,
  });

  final Entry entry;
  final BudgetCategory? category;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (tileBg, tileFg) = switch (category?.tone) {
      CategoryTone.warning => (c.warningBg, c.warningFg),
      CategoryTone.info => (c.infoBg, c.infoFg),
      CategoryTone.danger => (c.dangerBg, c.dangerFg),
      _ => (c.primarySoft, c.positive),
    };

    final title =
        entry.merchant ??
        category?.name ??
        (entry.isIncome ? 'Income' : 'Spend');
    final meta = [
      if (category != null) category!.name,
      if (entry.isIncome) entry.toVault ? 'to Vault' : 'income',
      if (entry.planned != null) entry.planned! ? 'planned' : 'unplanned',
    ].join(' · ');

    final amount = entry.isSpend
        ? formatMoney(-entry.amountCents, symbol: symbol)
        : formatMoney(entry.amountCents, symbol: symbol, signed: true);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SteadySpace.s2),
        child: Row(
          children: [
            Container(
              width: SteadySize.iconTile,
              height: SteadySize.iconTile,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExcludeSemantics(
                child: Text(
                  title.characters.first.toUpperCase(),
                  style: SteadyType.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tileFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              amount,
              style: SteadyType.body.copyWith(
                fontWeight: FontWeight.w700,
                color: entry.isIncome ? c.positive : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
