import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import '../bills/bill_tile.dart';
import 'category_edit_screen.dart';
import '../widgets/tones.dart';

/// P3 Categories & bills.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _bills = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final bills = store.bills.toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    String recurrence(Bill b) => switch (b.recurrence) {
      Recurrence.weekly => 'Weekly',
      Recurrence.everyTwoWeeks => 'Every 2 weeks',
      Recurrence.monthly => 'Monthly · ${_ordinal(b.dueDate.day)}',
      Recurrence.yearly => 'Yearly',
    };

    Widget addRow(String label, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: SteadyType.body.copyWith(
            fontWeight: FontWeight.w700,
            color: c.primary,
          ),
        ),
      ),
    );

    return SteadyPage(
      title: 'Categories & bills',
      children: [
        Segmented<bool>(
          options: const [false, true],
          selected: _bills,
          labelOf: (b) => b ? 'Bills' : 'Categories',
          onSelected: (b) => setState(() => _bills = b),
        ),
        if (!_bills)
          Text(
            'Your daily number is the limit that counts. A monthly limit on '
            'a category is an optional warning inside it, so you can see '
            'where the money goes. It never takes money out of your number.',
            style: SteadyType.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: c.muted,
            ),
          ),
        if (!_bills)
          GroupedList(
            padding: const EdgeInsets.only(left: 14, right: SteadySpace.s2),
            children: [
              for (final cat in store.categories)
                // Tap to edit; long-press to delete (with Undo).
                Semantics(
                  onLongPressHint: 'Delete category',
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context)
                            .pushNamed(Routes.categoryEdit, arguments: cat.id),
                    onLongPress: () => deleteCategoryFlow(context, cat),
                    child: Row(
                      children: [
                        LetterTile(
                          letter: cat.name,
                          tone: toneOf(cat.tone),
                          size: 32,
                          radius: 10,
                        ),
                        const SizedBox(width: SteadySpace.s3),
                        // The limit under the name: fits small phones and
                        // large text ("$64 left of $420" is long).
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: SteadySpace.s2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: SteadyType.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  _limitLabel(
                                    store.leftThisMonth(cat),
                                    cat,
                                    symbol,
                                  ),
                                  style: SteadyType.caption.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit ${cat.name}',
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: c.muted,
                          ),
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(Routes.categoryEdit, arguments: cat.id),
                        ),
                      ],
                    ),
                  ),
                ),
              addRow(
                '+ New category',
                () => Navigator.of(context).pushNamed(Routes.categoryEdit),
              ),
            ],
          )
        else ...[
          const Overline('Recurring bills'),
          GroupedList(
            children: [
              for (final (i, b) in bills.indexed)
                BillTile(
                  key: ValueKey(b.id),
                  bill: b,
                  amountCents: b.amountCents,
                  today: store.today,
                  meta: recurrence(b),
                  symbol: symbol,
                  index: i,
                  onTap: () =>
                      Navigator.of(context)
                          .pushNamed(Routes.billEdit, arguments: b.id),
                ),
              addRow(
                '+ Add a bill',
                () => Navigator.of(context).pushNamed(Routes.billEdit),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}

/// "$64 left of $90", "$5 over $90", or "No limit". Left counts this month's
/// spending and anything taken to cover an overspend.
String _limitLabel(int? left, BudgetCategory cat, String symbol) {
  final limit = cat.monthlyLimitCents;
  if (limit == null || left == null) return 'No limit';
  String whole(int cents) =>
      formatMoney(cents, symbol: symbol, showCents: false);
  return left >= 0
      ? '${whole(left)} left of ${whole(limit)}'
      : '${whole(-left)} over ${whole(limit)}';
}
