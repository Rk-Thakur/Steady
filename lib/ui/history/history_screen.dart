import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import '../widgets/tones.dart';

/// V3 History: every entry by day, searchable and filterable.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _Filter { all, spending, income }

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _filter = _Filter.all;
  String _query = '';

  bool _matches(BudgetStore store, Entry e) {
    if (_filter == _Filter.spending && !e.isSpend) return false;
    if (_filter == _Filter.income && !e.isIncome) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return [
      e.merchant,
      store.categoryById(e.categoryId)?.name,
      e.mood?.label,
      e.note,
    ].any((s) => s != null && s.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final entries = store.history.where((e) => _matches(store, e)).toList();
    final groups = <LocalDate, List<Entry>>{};
    for (final e in entries) {
      groups.putIfAbsent(e.localDate, () => []).add(e);
    }

    String dayLabel(LocalDate d) {
      final diff = d.daysUntil(store.today);
      if (diff == 0) return 'Today · ${formatShortDay(d)}';
      if (diff == 1) return 'Yesterday · ${formatShortDay(d)}';
      return formatShortDay(d);
    }

    return SteadyPage(
      title: 'History',
      gap: 14,
      children: [
        SteadyField(
          label: 'Search entries',
          hideLabel: true,
          hint: 'Search by name, category or mood',
          prefixIcon: Icons.search_rounded,
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        ChipGroup<_Filter>(
          options: _Filter.values,
          selected: _filter,
          labelOf: (f) => switch (f) {
            _Filter.all => 'All',
            _Filter.spending => 'Spending',
            _Filter.income => 'Income',
          },
          onSelected: (f) => setState(() => _filter = f),
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SteadySpace.s7),
            child: Text(
              _query.isEmpty
                  ? 'Nothing logged yet.'
                  : 'No entries match "$_query".',
              textAlign: TextAlign.center,
              style: SteadyType.body.copyWith(color: c.muted),
            ),
          ),
        for (final day in groups.keys)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  SteadySpace.s1,
                  0,
                  SteadySpace.s1,
                ),
                child: Overline(dayLabel(day)),
              ),
              Panel(
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    for (var i = 0; i < groups[day]!.length; i++) ...[
                      if (i > 0) Divider(color: c.lineSoft, height: 1),
                      SwipeToDelete(
                        entry: groups[day]![i],
                        child: HistoryRow(entry: groups[day]![i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Tappable entry row → Edit entry.
class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key, required this.entry});
  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final cat = store.categoryById(entry.categoryId);
    final title =
        entry.merchant ?? cat?.name ?? (entry.isIncome ? 'Income' : 'Spend');
    final meta = <String>[
      if (entry.isIncome) ...[
        'Income',
        entry.toVault ? 'to Vault' : 'to today',
      ],
      if (entry.isSpend && cat != null) cat.name,
      if (entry.mood != null) entry.mood!.label,
      if (entry.splitId != null)
        'shared · ${store.splits.group(entry.splitId!)?.name ?? 'split'}',
      if (entry.isSpend && entry.planned == false && entry.mood == null)
        'unplanned',
      if (entry.isSpend && entry.planned == true && entry.splitId == null)
        'planned',
    ].join(' · ');
    final amount = entry.isSpend
        ? formatMoney(-entry.amountCents, symbol: store.symbol)
        : formatMoney(entry.amountCents, symbol: store.symbol, signed: true);

    return InkWell(
      onTap: () =>
          Navigator.of(context)
              .pushNamed(Routes.editEntry, arguments: entry.id),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: [
            LetterTile(
              letter: title,
              tone: entry.isIncome ? BannerTone.primary : toneOf(cat?.tone),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SteadySpace.s2),
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
            ),
            const SizedBox(width: SteadySpace.s2),
            Text(
              amount,
              style: SteadyType.body.copyWith(
                fontWeight: FontWeight.w800,
                color: entry.isIncome ? c.positive : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Handoff 2 · Gestures: swipe a row left to delete it, with a 5-second
/// Undo snackbar. Tapping the row still opens Edit entry.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.entry,
    required this.child,
    this.aboveTabBar = false,
  });
  final Entry entry;
  final Widget child;

  /// On tab screens the snackbar floats above the tab bar.
  final bool aboveTabBar;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    return Dismissible(
      key: ValueKey('swipe-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SteadySpace.s5),
        decoration: BoxDecoration(
          color: c.dangerBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: c.dangerFg, size: 20),
            const SizedBox(width: 6),
            Text(
              'Delete',
              style: SteadyType.body.copyWith(
                fontWeight: FontWeight.w700,
                color: c.dangerFg,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        store.removeEntry(entry.id);
        final name = entry.merchant ?? 'Entry';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              margin: aboveTabBar
                  ? EdgeInsets.fromLTRB(
                      SteadySpace.s4,
                      0,
                      SteadySpace.s4,
                      SteadySize.tabBarOffset(MediaQuery.paddingOf(context)) +
                          SteadySize.tabBarHeight +
                          SteadySpace.s2,
                    )
                  : null,
              content: Text(
                '$name deleted. Your daily number was recalculated.',
              ),
              action: SnackBarAction(
                label: 'Undo',
                textColor: c.highlight,
                onPressed: () => store.addEntry(entry),
              ),
            ),
          );
      },
      child: child,
    );
  }
}
