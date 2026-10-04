import 'dart:math' as math;

import '../core/local_date.dart';
import 'models/models.dart';

/// "Take it from Fun money" (S4): an overspend is covered by what's left of a
/// category's budget this month instead of being spread over the next days.
///
/// The cover is only as good as that unspent money: if spending in the
/// category later eats into it, the cover shrinks by the same amount and that
/// part is spread over the remaining days after all. A new pay cycle starts
/// from real money, so covers end with the cycle they were made in.

/// Spent in [categoryId] during [day]'s calendar month (bill payments aside:
/// they come from reserved money, not from day-to-day budgets).
int spentInCategoryThisMonth(
  String categoryId,
  LocalDate day,
  Iterable<Entry> entries,
) {
  var cents = 0;
  for (final e in entries) {
    if (e.isSpend &&
        !e.isBillPayment &&
        e.categoryId == categoryId &&
        e.localDate.year == day.year &&
        e.localDate.month == day.month) {
      cents += e.amountCents;
    }
  }
  return cents;
}

/// Taken from [categoryId] for overspends during [day]'s calendar month.
int takenFromCategoryThisMonth(
  String categoryId,
  LocalDate day,
  Map<LocalDate, OverspendDecision> decisions,
) {
  var cents = 0;
  for (final d in decisions.entries) {
    if (d.value.takesFromCategory &&
        d.value.categoryId == categoryId &&
        d.key.year == day.year &&
        d.key.month == day.month) {
      cents += d.value.amountCents;
    }
  }
  return cents;
}

/// What's left of [category]'s monthly limit in [day]'s month, after its own
/// spending and anything taken to cover overspends. Null without a limit.
int? leftInCategoryThisMonth(
  BudgetCategory category,
  LocalDate day,
  Iterable<Entry> entries,
  Map<LocalDate, OverspendDecision> decisions,
) {
  final limit = category.monthlyLimitCents;
  if (limit == null) return null;
  return limit -
      spentInCategoryThisMonth(category.id, day, entries) -
      takenFromCategoryThisMonth(category.id, day, decisions);
}

/// The total still covered for the daily number on [today]: decisions made in
/// this cycle before today (today's own number already counts today's
/// spending), each month and category capped by its unspent budget.
int categoryCoverCents({
  required LocalDate today,
  required LocalDate cycleStart,
  required Map<LocalDate, OverspendDecision> decisions,
  required Iterable<Entry> entries,
  required Iterable<BudgetCategory> categories,
}) {
  // (category, year, month) → taken.
  final taken = <(String, int, int), int>{};
  for (final d in decisions.entries) {
    if (!d.value.takesFromCategory ||
        d.key.isBefore(cycleStart) ||
        !d.key.isBefore(today)) {
      continue;
    }
    final key = (d.value.categoryId!, d.key.year, d.key.month);
    taken[key] = (taken[key] ?? 0) + d.value.amountCents;
  }

  var cover = 0;
  for (final t in taken.entries) {
    final (id, year, month) = t.key;
    final limit = categories
        .where((c) => c.id == id)
        .firstOrNull
        ?.monthlyLimitCents;
    if (limit == null) continue; // category or its limit is gone
    final spent = spentInCategoryThisMonth(
      id,
      LocalDate(year, month, 1),
      entries,
    );
    cover += math.max(0, math.min(t.value, limit - spent));
  }
  return cover;
}
