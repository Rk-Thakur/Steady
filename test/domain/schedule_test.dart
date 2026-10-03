import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/schedule.dart';

void main() {
  LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

  group('addMonths', () {
    test(
      'same day next month',
      () => expect(addMonths(d(2026, 10, 15), 1), d(2026, 11, 15)),
    );
    test(
      'clamps to a shorter month',
      () => expect(addMonths(d(2026, 1, 30), 1), d(2026, 2, 28)),
    );
    test('month-end stays month-end (no drift)', () {
      expect(addMonths(d(2026, 1, 31), 1), d(2026, 2, 28));
      expect(addMonths(d(2026, 2, 28), 1), d(2026, 3, 31));
      expect(addMonths(d(2026, 4, 30), 1), d(2026, 5, 31));
    });
    test(
      'crosses the year',
      () => expect(addMonths(d(2026, 12, 10), 1), d(2027, 1, 10)),
    );
    test(
      'leap day a year later',
      () => expect(addMonths(d(2028, 2, 29), 12), d(2029, 2, 28)),
    );
  });

  group('nextOccurrence', () {
    test(
      'weekly',
      () => expect(
        nextOccurrence(d(2026, 10, 4), Recurrence.weekly),
        d(2026, 10, 11),
      ),
    );
    test(
      'every two weeks',
      () => expect(
        nextOccurrence(d(2026, 10, 4), Recurrence.everyTwoWeeks),
        d(2026, 10, 18),
      ),
    );
    test(
      'monthly',
      () => expect(
        nextOccurrence(d(2026, 10, 8), Recurrence.monthly),
        d(2026, 11, 8),
      ),
    );
    test(
      'yearly',
      () => expect(
        nextOccurrence(d(2026, 10, 8), Recurrence.yearly),
        d(2027, 10, 8),
      ),
    );
    test('across DST (US Nov 1) keeps calendar days', () {
      expect(
        nextOccurrence(d(2026, 10, 29), Recurrence.weekly),
        d(2026, 11, 5),
      );
    });
  });

  group('nextPaydayAfter', () {
    test('monthly keeps the pay day, even when pay is logged late', () {
      expect(
        nextPaydayAfter(
          d(2026, 10, 15),
          PayFrequency.monthly,
          lastPayday: d(2026, 10, 15),
        ),
        d(2026, 11, 15),
      );
      expect(
        nextPaydayAfter(
          d(2026, 10, 17),
          PayFrequency.monthly,
          lastPayday: d(2026, 10, 15),
        ),
        d(2026, 11, 15),
      );
    });
    test('weekly and every two weeks keep the weekday', () {
      expect(
        nextPaydayAfter(
          d(2026, 10, 2),
          PayFrequency.weekly,
          lastPayday: d(2026, 10, 2),
        ),
        d(2026, 10, 9),
      );
      expect(
        nextPaydayAfter(
          d(2026, 10, 4),
          PayFrequency.weekly,
          lastPayday: d(2026, 10, 2),
        ),
        d(2026, 10, 9),
      );
      expect(
        nextPaydayAfter(
          d(2026, 10, 2),
          PayFrequency.everyTwoWeeks,
          lastPayday: d(2026, 10, 2),
        ),
        d(2026, 10, 16),
      );
    });
    test('a long absence skips to the next future payday', () {
      expect(
        nextPaydayAfter(
          d(2026, 11, 20),
          PayFrequency.weekly,
          lastPayday: d(2026, 10, 2),
        ),
        d(2026, 11, 27),
      );
    });
    test('twice a month: the 15th and the last day', () {
      expect(
        nextPaydayAfter(d(2026, 10, 3), PayFrequency.twiceAMonth),
        d(2026, 10, 15),
      );
      expect(
        nextPaydayAfter(d(2026, 10, 15), PayFrequency.twiceAMonth),
        d(2026, 10, 31),
      );
      expect(
        nextPaydayAfter(d(2026, 10, 31), PayFrequency.twiceAMonth),
        d(2026, 11, 15),
      );
      expect(
        nextPaydayAfter(d(2026, 2, 20), PayFrequency.twiceAMonth),
        d(2026, 2, 28),
      );
    });
    test('varies: a rolling 7-day window', () {
      expect(
        nextPaydayAfter(d(2026, 10, 2), PayFrequency.varies),
        d(2026, 10, 9),
      );
    });
  });

  test('Mondays (Oct 2 2026 is a Friday)', () {
    expect(mondayOnOrBefore(d(2026, 10, 2)), d(2026, 9, 28));
    expect(mondayOnOrBefore(d(2026, 10, 5)), d(2026, 10, 5));
    expect(mondayAfter(d(2026, 10, 2)), d(2026, 10, 5));
    expect(mondayAfter(d(2026, 10, 5)), d(2026, 10, 12));
  });
}
