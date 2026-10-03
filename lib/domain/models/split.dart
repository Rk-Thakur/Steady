import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';
import '../../core/money.dart';

enum SplitMethod { even, byIncome, perExpense }

/// Split expenses with one other person, on this phone only.
@immutable
class ExpenseSplit {
  const ExpenseSplit({
    required this.id,
    required this.personName,
    required this.yourSharePercent,
    this.method = SplitMethod.byIncome,
    this.lastSettled,
  }) : assert(yourSharePercent >= 0 && yourSharePercent <= 100);

  final String id;
  final String personName;

  /// e.g. 60 for a 60 / 40 split by income.
  final int yourSharePercent;
  final SplitMethod method;
  final LocalDate? lastSettled;

  int get theirSharePercent => 100 - yourSharePercent;
}

/// One shared expense since the last settle-up.
@immutable
class SharedExpense {
  const SharedExpense({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.date,
    required this.paidByYou,
  });

  final String id;
  final String name;
  final int amountCents;
  final LocalDate date;
  final bool paidByYou;

  /// What this expense moves between you: positive = they owe you.
  /// Rounded down so the app never overstates what you're owed.
  int balanceEffectCents(ExpenseSplit split) => paidByYou
      ? floorDiv(amountCents * split.theirSharePercent, 100)
      : -floorDiv(amountCents * split.yourSharePercent, 100);
}
