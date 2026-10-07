import '../core/local_date.dart';
import 'models/models.dart';

/// Monthly and yearly bills due on payday or in the [days] after it.
///
/// They aren't set aside from this cycle (only bills due *before* payday
/// are), so they don't lower today's number. They'll come out of the next
/// pay, which is easy to miss when rent is due the day after payday and the
/// pay is late. Weekly and fortnightly bills fall in every cycle anyway, so
/// they're left out. Soonest first.
List<Bill> billsRightAfterPayday(
  Iterable<Bill> bills,
  LocalDate payday, {
  int days = 7,
}) {
  final end = payday.addDays(days);
  return [
    for (final b in bills)
      if ((b.recurrence == Recurrence.monthly ||
              b.recurrence == Recurrence.yearly) &&
          !b.dueDate.isBefore(payday) &&
          b.dueDate.isBefore(end))
        b,
  ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}

/// "on payday", "the day after payday", "3 days after payday".
String afterPaydayLabel(LocalDate due, LocalDate payday) {
  final n = payday.daysUntil(due);
  return switch (n) {
    0 => 'on payday',
    1 => 'the day after payday',
    _ => '$n days after payday',
  };
}
