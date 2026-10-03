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

@immutable
class NewCycle {
  const NewCycle({
    required this.plan,
    required this.nextPayday,
    required this.goals,
    required this.movedToGoalsCents,
  });

  final CyclePlan plan;
  final LocalDate nextPayday;

  /// Goals after this cycle's set-asides were added to their saved amounts.
  final List<Goal> goals;
  final int movedToGoalsCents;
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
  final shares = goalSetAsides(goals, endingDays);
  final planned = shares.values.fold(0, (a, b) => a + b);
  final available = math.min(current.goalSetAsideCents, math.max(0, money));
  // Scale down if overspending left less than was set aside.
  final scale = planned == 0 ? 0.0 : math.min(1.0, available / planned);

  var moved = 0;
  final updated = [
    for (final g in goals)
      if (shares.containsKey(g.id))
        () {
          final add = (shares[g.id]! * scale).floor();
          moved += add;
          return g.copyWith(savedCents: g.savedCents + add);
        }()
      else
        g,
  ];

  final next = nextPaydayAfter(start, frequency, lastPayday: lastPayday);
  final days = start.daysUntil(next);
  final setAside = goalSetAsides(updated, days).values.fold(0, (a, b) => a + b);

  return NewCycle(
    plan: CyclePlan(
      startDate: start,
      openingBalanceCents: money - moved,
      goalSetAsideCents: setAside,
    ),
    nextPayday: next,
    goals: updated,
    movedToGoalsCents: moved,
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
