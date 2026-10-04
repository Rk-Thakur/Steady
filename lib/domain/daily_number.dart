import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import '../core/money.dart';
import 'models/models.dart';

/// Everything the daily number depends on, already reduced to totals.
@immutable
class DailyNumberInput {
  const DailyNumberInput({
    required this.today,
    required this.nextPayday,
    required this.moneyAtStartOfDayCents,
    required this.unpaidBillsBeforePaydayCents,
    required this.goalSetAsidesCents,
    this.incomeTodayCents = 0,
    this.spentTodayCents = 0,
    this.billPaymentsTodayCents = 0,
    this.coveredCents = 0,
  });

  final LocalDate today;
  final LocalDate nextPayday;

  /// Spendable money at local midnight, after every earlier day's entries.
  final int moneyAtStartOfDayCents;
  final int unpaidBillsBeforePaydayCents;
  final int goalSetAsidesCents;

  /// Income logged today that went straight to today (not to the Vault).
  final int incomeTodayCents;
  final int spentTodayCents;

  /// Bills paid today. They were already reserved, so they leave the pool
  /// together with their reservation instead of counting as spent today.
  final int billPaymentsTodayCents;

  /// Earlier overspends a category's unspent budget is covering ("Take it
  /// from Fun money"), so they aren't spread over the coming days.
  final int coveredCents;
}

@immutable
class DailyNumber {
  const DailyNumber({
    required this.input,
    required this.daysLeft,
    required this.poolCents,
    required this.dailyAllowanceCents,
  });

  final DailyNumberInput input;

  /// Days until payday including today. Never below 1.
  final int daysLeft;

  /// Money now − unpaid bills before payday − goal set-asides.
  final int poolCents;

  /// What today was allowed before any spending: "of $64.00".
  final int dailyAllowanceCents;

  int get spentTodayCents => input.spentTodayCents;

  /// The hero number: "Safe to spend today".
  int get safeToSpendCents => dailyAllowanceCents - spentTodayCents;

  bool get isOverspent => safeToSpendCents < 0;
  int get overspentByCents => isOverspent ? -safeToSpendCents : 0;

  /// Share of today's allowance already spent, 0–1, for the progress bar.
  double get spentFraction {
    if (dailyAllowanceCents <= 0) return spentTodayCents > 0 ? 1 : 0;
    return (spentTodayCents / dailyAllowanceCents).clamp(0.0, 1.0);
  }
}

/// The daily-number rule (Handoff 3 & 4):
///
/// (money now − unpaid bills due before payday − goal set-asides this cycle)
/// ÷ days left including today, minus spent today.
///
/// Calculated in cents and rounded down so it never overstates what is safe.
/// Overspending is spread evenly over the remaining days automatically: the
/// excess lowers tomorrow's money-at-start-of-day.
abstract final class DailyNumberCalculator {
  static int daysLeft(LocalDate today, LocalDate nextPayday) =>
      math.max(1, today.daysUntil(nextPayday));

  static DailyNumber calculate(DailyNumberInput input) {
    final days = daysLeft(input.today, input.nextPayday);
    final pool =
        input.moneyAtStartOfDayCents +
        input.coveredCents +
        input.incomeTodayCents -
        input.billPaymentsTodayCents -
        input.unpaidBillsBeforePaydayCents -
        input.goalSetAsidesCents;
    return DailyNumber(
      input: input,
      daysLeft: days,
      poolCents: pool,
      dailyAllowanceCents: floorDiv(pool, days),
    );
  }

  /// Reduces the raw ledger to a [DailyNumberInput] for [today].
  ///
  /// Entries dated before the cycle start or after [today] are ignored.
  static DailyNumberInput inputFromLedger({
    required LocalDate today,
    required LocalDate nextPayday,
    required CyclePlan plan,
    required Iterable<Entry> entries,
    required Iterable<Bill> bills,
    int coveredCents = 0,
  }) {
    var moneyAtStartOfDay = plan.openingBalanceCents;
    var incomeToday = 0;
    var spentToday = 0;
    var billPaymentsToday = 0;

    for (final e in entries) {
      if (e.localDate.isBefore(plan.startDate) || e.localDate.isAfter(today)) {
        continue;
      }
      if (e.localDate == today) {
        if (e.isBillPayment) {
          billPaymentsToday += e.amountCents;
        } else if (e.isSpend) {
          spentToday += e.amountCents;
        } else if (!e.toVault) {
          incomeToday += e.amountCents;
        }
      } else {
        moneyAtStartOfDay += e.spendableDeltaCents;
      }
    }

    // Every unpaid occurrence before payday (a weekly bill can be due twice).
    final reservedBills = bills.fold<int>(
      0,
      (sum, b) => sum + b.reservedBefore(nextPayday),
    );

    return DailyNumberInput(
      today: today,
      nextPayday: nextPayday,
      moneyAtStartOfDayCents: moneyAtStartOfDay,
      unpaidBillsBeforePaydayCents: reservedBills,
      goalSetAsidesCents: plan.goalSetAsideCents,
      incomeTodayCents: incomeToday,
      spentTodayCents: spentToday,
      billPaymentsTodayCents: billPaymentsToday,
      coveredCents: coveredCents,
    );
  }

  /// What tomorrow's number will be if nothing else changes. Used by the
  /// overspent state ("Tomorrow's number: $62.96").
  ///
  /// [newCoverCents]: an overspend covered by a category from tomorrow on.
  static DailyNumber tomorrow(DailyNumber today, {int newCoverCents = 0}) {
    final i = today.input;
    return calculate(
      DailyNumberInput(
        today: i.today.addDays(1),
        nextPayday: i.nextPayday,
        moneyAtStartOfDayCents:
            i.moneyAtStartOfDayCents +
            i.incomeTodayCents -
            i.spentTodayCents -
            i.billPaymentsTodayCents,
        unpaidBillsBeforePaydayCents: i.unpaidBillsBeforePaydayCents,
        goalSetAsidesCents: i.goalSetAsidesCents,
        coveredCents: i.coveredCents + newCoverCents,
      ),
    );
  }
}
