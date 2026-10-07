import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import 'models/models.dart';
import 'schedule.dart';

/// Pay-cycle rules: when a cycle ends, what carries over, and Vault releases.

/// Spendable money at the start of [date] (before that day's entries),
/// counting only entries inside [plan]'s cycle.
int moneyAtStartOf(LocalDate date, CyclePlan plan, Iterable<Entry> entries) {
  var money = plan.openingBalanceCents;
  for (final e in entries) {
    if (e.localDate.isBefore(plan.startDate) || !e.localDate.isBefore(date)) {
      continue;
    }
    money += e.spendableDeltaCents;
  }
  return money;
}

/// How much each active goal sets aside over [days] days, capped at what the
/// goal still needs.
Map<String, int> goalSetAsides(Iterable<Goal> goals, int days) => {
  for (final g in goals)
    if (!g.paused && !g.isReached)
      g.id: math.min(g.dailySetAsideCents * days, g.targetCents - g.savedCents),
};

/// Gives each goal its share of [totalCents] held back this cycle, for goals
/// from before per-goal amounts were tracked. Shares follow each goal's
/// daily set-aside over [days]; the cents left after rounding go to the
/// first goal with a share.
List<Goal> withCycleSetAsides(List<Goal> goals, int totalCents, int days) {
  final shares = goalSetAsides(goals, days);
  final planned = shares.values.fold(0, (a, b) => a + b);
  // Never more than the goals planned to set aside, nor less than nothing.
  final total = math.max(0, math.min(totalCents, planned));
  var given = 0;
  final out = [
    for (final g in goals)
      () {
        final share = planned == 0 ? 0 : (shares[g.id] ?? 0) * total ~/ planned;
        given += share;
        return g.copyWith(cycleSetAsideCents: share);
      }(),
  ];
  final rest = total - given;
  if (rest > 0) {
    final i = out.indexWhere((g) => (shares[g.id] ?? 0) > 0);
    if (i >= 0) {
      out[i] = out[i].copyWith(
        cycleSetAsideCents: out[i].cycleSetAsideCents! + rest,
      );
    }
  }
  return out;
}

/// What [after] holds back for the rest of this cycle once a goal is
/// started, paused, resumed, re-paced or topped up, with [daysLeft] days to
/// payday (today included).
///
/// Days already gone stay set aside (that money moves to the goal on
/// payday); only the days ahead change. Never more than the goal still
/// needs.
int cycleSetAsideAfterChange({
  required Goal? before,
  required Goal after,
  required int daysLeft,
}) {
  final held = before?.cycleSetAsideCents ?? 0;
  final ahead = before != null && before.isActive
      ? before.dailySetAsideCents * daysLeft
      : 0;
  final past = math.max(0, held - ahead);
  final next =
      past + (after.isActive ? after.dailySetAsideCents * daysLeft : 0);
  return math.min(next, after.remainingCents);
}

@immutable
class NewCycle {
  const NewCycle({
    required this.plan,
    required this.nextPayday,
    required this.goals,
    required this.movedToGoalsCents,
    required this.summary,
  });

  final CyclePlan plan;
  final CycleSummary summary;
  final LocalDate nextPayday;

  /// Goals after this cycle's set-asides were added to their saved amounts,
  /// each holding back its share of the new cycle.
  final List<Goal> goals;
  final int movedToGoalsCents;
}

/// What happened when a cycle ended, for the "New pay cycle" summary.
@immutable
class CycleSummary {
  const CycleSummary({
    required this.endedCycleStart,
    required this.start,
    required this.leftOverCents,
    required this.goalsAdded,
  });

  /// The cycle that just ended ran from here to the day before [start].
  final LocalDate endedCycleStart;
  final LocalDate start;

  /// Money left when it ended, before anything moved to goals. Negative if
  /// it ended overspent.
  final int leftOverCents;

  /// Goal name → amount added on payday, in goal order.
  final List<(String, int)> goalsAdded;

  int get movedToGoalsCents => goalsAdded.fold(0, (sum, g) => sum + g.$2);

  /// Carried into the new cycle.
  int get carriedOverCents => leftOverCents - movedToGoalsCents;
}

/// Ends the current cycle and starts a new one on [start] (payday, or the day
/// income was logged).
///
/// - The ending cycle's goal set-aside moves into the goals (each goal gets
///   its share, never more than it needs, and never more money than exists).
/// - The new cycle opens with the money at the start of [start], minus what
///   moved to goals.
/// - The next payday follows [frequency]; the new set-aside covers the new
///   cycle's length.
NewCycle startNewCycle({
  required LocalDate start,
  required CyclePlan current,
  required Iterable<Entry> entries,
  required List<Goal> goals,
  required PayFrequency frequency,
  LocalDate? lastPayday,
}) {
  final money = moneyAtStartOf(start, current, entries);

  // Each goal's share of the ending cycle's set-aside.
  final endingDays = math.max(1, current.startDate.daysUntil(start));
  final tracked = goals.every((g) => g.cycleSetAsideCents != null)
      ? goals
      : withCycleSetAsides(goals, current.goalSetAsideCents, endingDays);
  final shares = {
    for (final g in tracked)
      if (g.cycleSetAsideCents! > 0) g.id: g.cycleSetAsideCents!,
  };
  final planned = shares.values.fold(0, (a, b) => a + b);
  final available = math.min(current.goalSetAsideCents, math.max(0, money));
  // Scale down if overspending left less than was set aside.
  final scale = planned == 0 ? 0.0 : math.min(1.0, available / planned);

  var moved = 0;
  final saved = [
    for (final g in tracked)
      if (shares.containsKey(g.id))
        () {
          final add = (shares[g.id]! * scale).floor();
          moved += add;
          return g.copyWith(savedCents: g.savedCents + add);
        }()
      else
        g,
  ];

  // The new cycle holds back each goal's set-aside for its whole length.
  final next = nextPaydayAfter(start, frequency, lastPayday: lastPayday);
  final days = start.daysUntil(next);
  final newShares = goalSetAsides(saved, days);
  final updated = [
    for (final g in saved) g.copyWith(cycleSetAsideCents: newShares[g.id] ?? 0),
  ];
  final setAside = newShares.values.fold(0, (a, b) => a + b);

  return NewCycle(
    plan: CyclePlan(
      startDate: start,
      openingBalanceCents: money - moved,
      goalSetAsideCents: setAside,
    ),
    nextPayday: next,
    goals: updated,
    movedToGoalsCents: moved,
    summary: CycleSummary(
      endedCycleStart: current.startDate,
      start: start,
      leftOverCents: money,
      goalsAdded: [
        for (final (i, g) in saved.indexed)
          if (g.savedCents > goals[i].savedCents)
            (g.name, g.savedCents - goals[i].savedCents),
      ],
    ),
  );
}

/// Should a new cycle start because income was logged? Regular earners'
/// cycles start when their pay arrives on or after payday (Handoff 3: "next
/// cycle starts after income is logged").
bool incomeStartsCycle({
  required Entry entry,
  required LocalDate today,
  required LocalDate nextPayday,
  required PayFrequency frequency,
}) =>
    frequency != PayFrequency.varies &&
    entry.isIncome &&
    !entry.toVault &&
    !entry.fromVault &&
    entry.localDate == today &&
    !today.isBefore(nextPayday);

/// Regular earners whose payday has arrived without income get asked
/// "Did your payment arrive?" (V2).
bool awaitingPay({
  required LocalDate today,
  required LocalDate nextPayday,
  required PayFrequency frequency,
}) => frequency != PayFrequency.varies && !today.isBefore(nextPayday);

/// The Mondays in (lastRelease, today] on which the Vault releases steady pay.
List<LocalDate> releasesDue(Vault vault, LocalDate today) {
  final last = vault.lastReleaseDate;
  if (!vault.isActive || last == null) return const [];
  return [
    for (var d = mondayAfter(last); !d.isAfter(today); d = d.addDays(7)) d,
  ];
}
