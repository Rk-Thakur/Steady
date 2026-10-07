import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/after_payday.dart';
import 'package:steady/domain/models/models.dart';

void main() {
  const payday = LocalDate(2026, 10, 15);
  Bill bill(String name, LocalDate due, [Recurrence r = Recurrence.monthly]) =>
      Bill(
        id: name,
        name: name,
        amountCents: 1000,
        recurrence: r,
        dueDate: due,
      );

  test('monthly and yearly bills from payday to a week after', () {
    final found = billsRightAfterPayday([
      bill('Before', const LocalDate(2026, 10, 14)), // reserved this cycle
      bill('Rent', const LocalDate(2026, 10, 16)),
      bill('On payday', payday),
      bill('Insurance', const LocalDate(2026, 10, 21), Recurrence.yearly),
      bill('Too late', const LocalDate(2026, 10, 22)),
      bill('Gym', const LocalDate(2026, 10, 16), Recurrence.weekly),
      bill('Sitter', const LocalDate(2026, 10, 16), Recurrence.everyTwoWeeks),
    ], payday);
    expect(found.map((b) => b.name), ['On payday', 'Rent', 'Insurance']);
  });

  test('labels', () {
    expect(afterPaydayLabel(payday, payday), 'on payday');
    expect(
      afterPaydayLabel(const LocalDate(2026, 10, 16), payday),
      'the day after payday',
    );
    expect(
      afterPaydayLabel(const LocalDate(2026, 10, 18), payday),
      '3 days after payday',
    );
  });
}
