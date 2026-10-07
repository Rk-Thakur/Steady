import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import 'daily_number.dart';

/// Why today's number differs from yesterday's ("Up $4.25: you spent less
/// yesterday").
///
/// Leftover money is spread over the days left, so if yesterday's number
/// was A and you spent S, today's number moves by about (A − S) ÷ days left.
/// Income logged today spreads the same way. Anything else (a bill or goal
/// edited, a balance corrected, a new payday) is [otherCents].
@immutable
class NumberChange {
  const NumberChange({
    required this.yesterdayCents,
    required this.totalCents,
    required this.spendingCents,
    required this.incomeCents,
    required this.otherCents,
  });

  /// Yesterday's number, as it was at the end of the day.
  final int yesterdayCents;

  /// Today's number − yesterday's.
  final int totalCents;

  /// From spending less (positive) or more (negative) than yesterday's number.
  final int spendingCents;

  /// From income logged today.
  final int incomeCents;

  /// From bills, goals, balance or payday changes.
  final int otherCents;

  bool get isUnchanged => totalCents == 0;

  /// The part that explains most of the change, in its direction.
  NumberChangeReason get mainReason {
    final parts = {
      NumberChangeReason.spending: spendingCents,
      NumberChangeReason.income: incomeCents,
      NumberChangeReason.other: otherCents,
    };
    var best = NumberChangeReason.other;
    var bestCents = 0;
    for (final MapEntry(:key, :value) in parts.entries) {
      if (value.sign != totalCents.sign) continue;
      if (value.abs() > bestCents) {
        best = key;
        bestCents = value.abs();
      }
    }
    return best;
  }
}

enum NumberChangeReason { spending, income, other }

/// Null when there's nothing fair to compare with: no number recorded for
/// yesterday, or today is the first day of a pay cycle.
NumberChange? numberChangeSinceYesterday({
  required DailyNumber today,
  required int? yesterdayCents,
  required int yesterdaySpentCents,
  required LocalDate cycleStart,
}) {
  if (yesterdayCents == null) return null;
  if (!today.input.today.isAfter(cycleStart)) return null;

  final days = today.daysLeft;
  final total = today.dailyAllowanceCents - yesterdayCents;
  var spending = ((yesterdayCents - yesterdaySpentCents) / days).round();
  final income = (today.input.incomeTodayCents / days).round();
  var other = total - spending - income;
  // A cent or two is just rounding, not a change worth naming.
  if (other.abs() <= 2) {
    spending += other;
    other = 0;
  }
  return NumberChange(
    yesterdayCents: yesterdayCents,
    totalCents: total,
    spendingCents: spending,
    incomeCents: income,
    otherCents: other,
  );
}
