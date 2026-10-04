import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import 'cycle.dart';
import 'models/models.dart';

/// Insights and weekly/monthly summaries (Handoff 4), calculated on the phone
/// from the user's own entries. Pure functions so they are easy to test.

// ─── Periods ───────────────────────────────────────────────────────────────

/// A run of calendar days, both ends included.
@immutable
class Period {
  const Period(this.start, this.end);

  /// The week holding [day], starting on [weekStartsOn] ([DateTime.monday]
  /// … [DateTime.sunday]).
  factory Period.weekOf(LocalDate day, int weekStartsOn) {
    final start = day.addDays(-((day.weekday - weekStartsOn) % 7));
    return Period(start, start.addDays(6));
  }

  factory Period.monthOf(LocalDate day) {
    final start = LocalDate(day.year, day.month, 1);
    final next = day.month == 12
        ? LocalDate(day.year + 1, 1, 1)
        : LocalDate(day.year, day.month + 1, 1);
    return Period(start, next.addDays(-1));
  }

  /// The [days] days ending on [day].
  factory Period.lastDays(LocalDate day, int days) =>
      Period(day.addDays(1 - days), day);

  final LocalDate start;
  final LocalDate end;

  int get days => start.daysUntil(end) + 1;

  bool contains(LocalDate d) => !d.isBefore(start) && !d.isAfter(end);

  /// The period of the same kind just before this one.
  Period get previous {
    final isMonth = start.day == 1 && Period.monthOf(start).end == end;
    return isMonth
        ? Period.monthOf(start.addDays(-1))
        : Period(start.addDays(-days), start.addDays(-1));
  }

  Iterable<LocalDate> get dates sync* {
    for (var d = start; !d.isAfter(end); d = d.addDays(1)) {
      yield d;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Period && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start–$end';
}

/// Spending the user chose day to day: bill payments are left out (they were
/// reserved ahead and never count against the daily number).
bool _everyday(Entry e) => e.isSpend && !e.isBillPayment;

// ─── Summaries ─────────────────────────────────────────────────────────────

@immutable
class ChartBar {
  const ChartBar({
    required this.label,
    required this.start,
    required this.cents,
    required this.over,
  });

  final String label;

  /// First day this bar covers.
  final LocalDate start;
  final int cents;

  /// Spent more than that day's number (week) or the weekly pace (month).
  final bool over;
}

@immutable
class NamedAmount {
  const NamedAmount(this.name, this.cents);
  final String name;
  final int cents;
}

@immutable
class PeriodSummary {
  const PeriodSummary({
    required this.period,
    required this.isMonth,
    required this.hasEntries,
    required this.inCents,
    required this.spentCents,
    required this.savings,
    required this.daysUnder,
    required this.daysCounted,
    required this.bars,
    required this.paceCents,
    required this.categories,
    required this.biggest,
  });

  final Period period;
  final bool isMonth;

  /// Anything logged in the period at all.
  final bool hasEntries;

  /// Income that reached the daily number: paychecks not parked in the
  /// Vault, plus the Vault's weekly releases.
  final int inCents;

  /// Every spend, bills included.
  final int spentCents;

  /// Each goal's daily set-asides over the days so far.
  final List<NamedAmount> savings;

  int get savedCents => savings.fold(0, (a, s) => a + s.cents);
  int get leftOverCents => inCents - spentCents - savedCents;

  /// Finished days with a recorded number where spending stayed within it.
  final int daysUnder;
  final int daysCounted;

  /// One bar per day (week) or per 7 days (month).
  final List<ChartBar> bars;

  /// The dashed line: the average daily number (week), or 7× it (month).
  final int paceCents;

  /// Top five categories by spend, bills included.
  final List<NamedAmount> categories;

  /// The biggest bar and what drove it, for "Worth a look". Null when
  /// nothing was spent.
  final BiggestSpend? biggest;
}

@immutable
class BiggestSpend {
  const BiggestSpend({
    required this.bar,
    required this.overByCents,
    required this.topCategory,
    required this.topMood,
  });

  final ChartBar bar;

  /// How far over its limit the bar went (0 when it stayed under).
  final int overByCents;
  final String? topCategory;

  /// The mood behind most of it, unless that was neutral or untagged.
  final Mood? topMood;
}

/// Summarises [period] as of [today]. [dailyNumbers] are the recorded daily
/// numbers; [fallbackPaceCents] (today's number) is used when none exist.
PeriodSummary summarize({
  required Period period,
  required bool isMonth,
  required LocalDate today,
  required Iterable<Entry> entries,
  required Iterable<BudgetCategory> categories,
  required Iterable<Goal> goals,
  required Map<LocalDate, int> dailyNumbers,
  required int fallbackPaceCents,
}) {
  final inPeriod = [
    for (final e in entries)
      if (period.contains(e.localDate)) e,
  ];
  final names = {for (final c in categories) c.id: c.name};
  String nameOf(Entry e) => names[e.categoryId] ?? 'Other';

  var inCents = 0;
  var spent = 0;
  final everydayByDay = <LocalDate, int>{};
  final byCategory = <String, int>{};
  for (final e in inPeriod) {
    if (e.isIncome) {
      if (!e.toVault) inCents += e.amountCents;
      continue;
    }
    spent += e.amountCents;
    byCategory.update(
      nameOf(e),
      (v) => v + e.amountCents,
      ifAbsent: () => e.amountCents,
    );
    if (_everyday(e)) {
      everydayByDay.update(
        e.localDate,
        (v) => v + e.amountCents,
        ifAbsent: () => e.amountCents,
      );
    }
  }

  // Days so far (all of a past period, up to today for the current one).
  final last = today.isBefore(period.end) ? today : period.end;
  final savings = <NamedAmount>[];
  for (final g in goals) {
    // Only the days since the goal was started.
    final from = g.createdOn == null || g.createdOn!.isBefore(period.start)
        ? period.start
        : g.createdOn!;
    final days = from.isAfter(last) ? 0 : from.daysUntil(last) + 1;
    final cents = goalSetAsides([g], days)[g.id] ?? 0;
    if (cents > 0) savings.add(NamedAmount(g.name, cents));
  }

  // Days under: finished days only (today isn't over yet).
  var under = 0;
  var counted = 0;
  final recorded = <int>[];
  for (final d in period.dates) {
    final number = dailyNumbers[d];
    if (number == null || d.isAfter(today)) continue;
    recorded.add(number);
    if (d == today) continue;
    counted++;
    if ((everydayByDay[d] ?? 0) <= number) under++;
  }
  final dailyPace = recorded.isEmpty
      ? math.max(0, fallbackPaceCents)
      : recorded.fold(0, (a, b) => a + b) ~/ recorded.length;
  final pace = isMonth ? dailyPace * 7 : dailyPace;

  final bars = <ChartBar>[];
  final limits = <int>[];
  if (isMonth) {
    var week = 1;
    for (var s = period.start; !s.isAfter(period.end); s = s.addDays(7)) {
      var cents = 0;
      for (var i = 0; i < 7; i++) {
        cents += everydayByDay[s.addDays(i)] ?? 0;
      }
      bars.add(
        ChartBar(
          label: 'Wk ${week++}',
          start: s,
          cents: cents,
          over: cents > pace,
        ),
      );
      limits.add(pace);
    }
  } else {
    for (final d in period.dates) {
      final cents = everydayByDay[d] ?? 0;
      final limit = dailyNumbers[d] ?? pace;
      bars.add(
        ChartBar(
          label: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
          start: d,
          cents: cents,
          over: cents > limit,
        ),
      );
      limits.add(limit);
    }
  }

  final top = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  BiggestSpend? biggest;
  if (bars.any((b) => b.cents > 0)) {
    var i = 0;
    for (var j = 1; j < bars.length; j++) {
      if (bars[j].cents > bars[i].cents) i = j;
    }
    final bar = bars[i];
    final span = Period(bar.start, bar.start.addDays(isMonth ? 6 : 0));
    final driving = [
      for (final e in inPeriod)
        if (_everyday(e) && span.contains(e.localDate)) e,
    ];
    biggest = BiggestSpend(
      bar: bar,
      overByCents: math.max(0, bar.cents - limits[i]),
      topCategory: _largest(driving, nameOf),
      topMood: _largest(
        driving.where((e) => e.mood != null && e.mood != Mood.neutral),
        (e) => e.mood!,
      ),
    );
  }

  return PeriodSummary(
    period: period,
    isMonth: isMonth,
    hasEntries: inPeriod.isNotEmpty,
    inCents: inCents,
    spentCents: spent,
    savings: savings,
    daysUnder: under,
    daysCounted: counted,
    bars: bars,
    paceCents: pace,
    categories: [for (final c in top.take(5)) NamedAmount(c.key, c.value)],
    biggest: biggest,
  );
}

/// The key with the most money behind it.
K? _largest<K>(Iterable<Entry> entries, K Function(Entry) keyOf) {
  final totals = <K, int>{};
  for (final e in entries) {
    totals.update(
      keyOf(e),
      (v) => v + e.amountCents,
      ifAbsent: () => e.amountCents,
    );
  }
  if (totals.isEmpty) return null;
  return totals.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

/// Which period the summary screen opens on: the last finished one, or the
/// current one when nothing was logged before it (a new user).
Period summaryPeriodFor({
  required LocalDate today,
  required bool isMonth,
  required int weekStartsOn,
  required Iterable<Entry> entries,
}) {
  final current = isMonth
      ? Period.monthOf(today)
      : Period.weekOf(today, weekStartsOn);
  final previous = current.previous;
  return entries.any((e) => previous.contains(e.localDate))
      ? previous
      : current;
}

// ─── Insights ──────────────────────────────────────────────────────────────

@immutable
class SpendingInsights {
  const SpendingInsights({
    required this.byMood,
    required this.trigger,
    required this.plannedCents,
    required this.unplannedCents,
    required this.lateNightCents,
    required this.lateNightCount,
  });

  /// Every mood in display order; untagged spending counts as neutral.
  final Map<Mood, int> byMood;

  /// The non-neutral mood and category with the most spending together.
  final ({Mood mood, String category, int cents})? trigger;

  final int plannedCents;
  final int unplannedCents;
  int get taggedCents => plannedCents + unplannedCents;

  /// Logged between 10 PM and 4 AM.
  final int lateNightCents;
  final int lateNightCount;

  /// The non-neutral mood with the most spending, if any.
  Mood? get topMood {
    Mood? top;
    for (final m in byMood.keys) {
      if (m == Mood.neutral || byMood[m]! <= 0) continue;
      if (top == null || byMood[m]! > byMood[top]!) top = m;
    }
    return top;
  }
}

SpendingInsights spendingInsights({
  required Period period,
  required Iterable<Entry> entries,
  required Iterable<BudgetCategory> categories,
}) {
  final names = {for (final c in categories) c.id: c.name};
  final byMood = {for (final m in Mood.values) m: 0};
  final pairs = <(Mood, String), int>{};
  var planned = 0;
  var unplanned = 0;
  var lateCents = 0;
  var lateCount = 0;

  for (final e in entries) {
    if (!_everyday(e) || !period.contains(e.localDate)) continue;
    final mood = e.mood ?? Mood.neutral;
    byMood[mood] = byMood[mood]! + e.amountCents;
    if (mood != Mood.neutral) {
      pairs.update(
        (mood, names[e.categoryId] ?? 'Other'),
        (v) => v + e.amountCents,
        ifAbsent: () => e.amountCents,
      );
    }
    switch (e.planned) {
      case true:
        planned += e.amountCents;
      case false:
        unplanned += e.amountCents;
      case null:
    }
    if (isLateNight(e)) {
      lateCents += e.amountCents;
      lateCount++;
    }
  }

  final top = pairs.entries.isEmpty
      ? null
      : pairs.entries.reduce((a, b) => b.value > a.value ? b : a);
  return SpendingInsights(
    byMood: byMood,
    trigger: top == null
        ? null
        : (mood: top.key.$1, category: top.key.$2, cents: top.value),
    plannedCents: planned,
    unplannedCents: unplanned,
    lateNightCents: lateCents,
    lateNightCount: lateCount,
  );
}

/// Logged between 10 PM and 4 AM on the day it belongs to. An entry added
/// later for an earlier day says nothing about the hour, so it's left out.
bool isLateNight(Entry e) {
  final local = e.createdAtUtc.toLocal();
  if (LocalDate.fromDateTime(local) != e.localDate) return false;
  return local.hour >= 22 || local.hour < 4;
}
