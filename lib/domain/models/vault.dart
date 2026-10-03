import 'package:flutter/foundation.dart';

import 'entry.dart';

/// Paycheck Vault: a reserve inside Steady that smooths uneven income into a
/// steady weekly pay. No real money moves.
@immutable
class Vault {
  const Vault({
    required this.openingBalanceCents,
    required this.steadyPayWeeklyCents,
    this.targetWeeks = 4,
  });

  final int openingBalanceCents;
  final int steadyPayWeeklyCents;
  final int targetWeeks;

  int get targetCents => steadyPayWeeklyCents * targetWeeks;

  /// Opening balance plus every income entry marked [Entry.toVault].
  /// Weekly releases into the daily number are not modelled yet.
  int balanceCents(Iterable<Entry> entries) {
    var balance = openingBalanceCents;
    for (final e in entries) {
      if (e.isIncome && e.toVault) balance += e.amountCents;
    }
    return balance;
  }

  Vault copyWith({int? steadyPayWeeklyCents, int? openingBalanceCents}) =>
      Vault(
        openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
        steadyPayWeeklyCents: steadyPayWeeklyCents ?? this.steadyPayWeeklyCents,
        targetWeeks: targetWeeks,
      );
}
