import '../core/local_date.dart';
import 'models/models.dart';

/// Calendar rules for recurring bills, paydays and Vault releases.
/// All calendar days (no 24 h arithmetic), so DST never shifts a date.

int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

bool isLastDayOfMonth(LocalDate d) => d.day == daysInMonth(d.year, d.month);

/// Same day [months] later, clamped to the month's length. A date on the last
/// day of its month stays on the last day (Jan 31 → Feb 28 → Mar 31), so
/// month-end bills and paydays don't drift earlier.
LocalDate addMonths(LocalDate d, int months) {
  final index = d.year * 12 + (d.month - 1) + months;
  final year = index ~/ 12;
  final month = index % 12 + 1;
  final last = daysInMonth(year, month);
  final day = isLastDayOfMonth(d) ? last : (d.day > last ? last : d.day);
  return LocalDate(year, month, day);
}

/// The occurrence after [due] for a bill repeating on [r].
LocalDate nextOccurrence(LocalDate due, Recurrence r) => switch (r) {
  Recurrence.weekly => due.addDays(7),
  Recurrence.everyTwoWeeks => due.addDays(14),
  Recurrence.monthly => addMonths(due, 1),
  Recurrence.yearly => addMonths(due, 12),
};

/// The first payday strictly after [from].
///
/// - Twice a month pays on the 15th and the last day of the month.
/// - Varies uses a rolling 7-day window (Handoff 4).
LocalDate nextPaydayAfter(
  LocalDate from,
  PayFrequency f, {
  LocalDate? lastPayday,
}) {
  switch (f) {
    case PayFrequency.weekly:
      return (lastPayday ?? from).addDays(7)._atLeastAfter(from, 7);
    case PayFrequency.everyTwoWeeks:
      return (lastPayday ?? from).addDays(14)._atLeastAfter(from, 14);
    case PayFrequency.varies:
      return from.addDays(7);
    case PayFrequency.twiceAMonth:
      final last = daysInMonth(from.year, from.month);
      if (from.day < 15) return LocalDate(from.year, from.month, 15);
      if (from.day < last) return LocalDate(from.year, from.month, last);
      final next = addMonths(LocalDate(from.year, from.month, 1), 1);
      return LocalDate(next.year, next.month, 15);
    case PayFrequency.monthly:
      var next = addMonths(lastPayday ?? from, 1);
      while (!next.isAfter(from)) {
        next = addMonths(next, 1);
      }
      return next;
  }
}

extension on LocalDate {
  /// Steps forward by [step] days until strictly after [from].
  LocalDate _atLeastAfter(LocalDate from, int step) {
    var d = this;
    while (!d.isAfter(from)) {
      d = d.addDays(step);
    }
    return d;
  }
}

/// The Monday on or before [d] (Vault releases happen on Mondays).
LocalDate mondayOnOrBefore(LocalDate d) =>
    d.addDays(-(d.weekday - DateTime.monday));

/// The first Monday strictly after [d].
LocalDate mondayAfter(LocalDate d) => mondayOnOrBefore(d).addDays(7);
