import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';
import 'entry.dart';

/// Paycheck Vault: a reserve inside Steady that smooths uneven income into a
/// steady weekly pay. No real money moves.
///
/// Income marked [Entry.toVault] fills it; every Monday it releases
/// [steadyPayWeeklyCents] into the daily number as an [Entry.fromVault]
/// income entry.
@immutable
class Vault {
  const Vault({
    required this.openingBalanceCents,
    required this.steadyPayWeeklyCents,
    this.targetWeeks = 4,
    this.lastReleaseDate,
  });

  final int openingBalanceCents;
  final int steadyPayWeeklyCents;
  final int targetWeeks;

  /// The Monday of the most recent release (or the Monday releases were set
  /// up, so the first release is the following one).
  final LocalDate? lastReleaseDate;

  int get targetCents => steadyPayWeeklyCents * targetWeeks;

  bool get isActive => steadyPayWeeklyCents > 0;

  /// Opening balance, plus deposits, minus releases.
  int balanceCents(Iterable<Entry> entries) {
    var balance = openingBalanceCents;
    for (final e in entries) {
      if (!e.isIncome) continue;
      if (e.toVault) balance += e.amountCents;
      if (e.fromVault) balance -= e.amountCents;
    }
    return balance;
  }

  Vault copyWith({
    int? steadyPayWeeklyCents,
    int? openingBalanceCents,
    LocalDate? Function()? lastReleaseDate,
  }) => Vault(
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    steadyPayWeeklyCents: steadyPayWeeklyCents ?? this.steadyPayWeeklyCents,
    targetWeeks: targetWeeks,
    lastReleaseDate: lastReleaseDate != null
        ? lastReleaseDate()
        : this.lastReleaseDate,
  );
}
