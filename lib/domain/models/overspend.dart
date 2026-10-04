import 'package:flutter/foundation.dart';

import 'settings.dart';

/// S4: how one day's overspend was handled.
@immutable
class OverspendDecision {
  const OverspendDecision(
    this.strategy, {
    this.categoryId,
    this.amountCents = 0,
  });

  final OverspendStrategy strategy;

  /// "Take it from Fun money": the category whose unspent money this month
  /// covers [amountCents], so the overspend isn't spread over the next days.
  final String? categoryId;
  final int amountCents;

  bool get takesFromCategory =>
      strategy == OverspendStrategy.takeFromCategory &&
      categoryId != null &&
      amountCents > 0;

  @override
  bool operator ==(Object other) =>
      other is OverspendDecision &&
      other.strategy == strategy &&
      other.categoryId == categoryId &&
      other.amountCents == amountCents;

  @override
  int get hashCode => Object.hash(strategy, categoryId, amountCents);
}
