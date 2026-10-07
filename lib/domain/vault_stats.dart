import '../core/local_date.dart';
import 'models/models.dart';
import 'schedule.dart';

/// Income logged in each of the last [weeks] weeks (Monday to Sunday),
/// oldest first; the last is this week so far. Counts pay that went to the
/// Vault and pay that went straight to the daily number, but not the Vault's
/// own weekly releases (that would count the same money twice).
List<int> weeklyIncome(
  Iterable<Entry> entries,
  LocalDate today, {
  int weeks = 8,
}) {
  final thisWeek = mondayOnOrBefore(today);
  final first = thisWeek.addDays(-7 * (weeks - 1));
  final totals = List.filled(weeks, 0);
  for (final e in entries) {
    if (!e.isIncome || e.fromVault) continue;
    if (e.localDate.isBefore(first) || e.localDate.isAfter(today)) continue;
    totals[first.daysUntil(e.localDate) ~/ 7] += e.amountCents;
  }
  return totals;
}
