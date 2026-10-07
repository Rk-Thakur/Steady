import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/bill_match.dart';
import 'package:steady/domain/models/models.dart';

void main() {
  const today = LocalDate(2026, 10, 2);
  Bill bill(String name, int cents, LocalDate due, {bool estimate = false}) =>
      Bill(
        id: name.toLowerCase(),
        name: name,
        amountCents: cents,
        recurrence: Recurrence.monthly,
        dueDate: due,
        isEstimate: estimate,
      );
  final bills = [
    bill('Rent', 145000, const LocalDate(2026, 10, 5)),
    bill('Phone plan', 4500, const LocalDate(2026, 10, 12)),
    bill('Electric', 9600, const LocalDate(2026, 10, 6), estimate: true),
  ];
  Bill? match(String? merchant, int cents) => likelyBillFor(
    merchant: merchant,
    amountCents: cents,
    reservedBills: bills,
    today: today,
  );

  test('a matching name, whatever the amount', () {
    expect(match('Rent', 100000)?.name, 'Rent');
    expect(match('rent payment', 145000)?.name, 'Rent');
    expect(match('PHONE', 4000)?.name, 'Phone plan');
  });

  test('the exact amount of a bill due within a week', () {
    expect(match(null, 145000)?.name, 'Rent');
    expect(match('Landlord', 145000)?.name, 'Rent');
    // Phone is due in 10 days: an amount alone isn't enough.
    expect(match(null, 4500), isNull);
  });

  test('estimates match within 20%', () {
    expect(match(null, 10500)?.name, 'Electric'); // +9%
    expect(match(null, 12000), isNull); // +25%
  });

  test('ordinary spends are left alone', () {
    expect(match('Corner coffee', 540), isNull);
    expect(match('Groceries', 3000), isNull);
    expect(match('re', 145000 + 1), isNull); // too short to compare names
  });
}
