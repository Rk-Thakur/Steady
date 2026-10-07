import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/vault_stats.dart';

void main() {
  // Friday Oct 2; this week started Monday Sep 28.
  const today = LocalDate(2026, 10, 2);
  Entry income(
    String id,
    int cents,
    LocalDate date, {
    bool toVault = false,
    bool fromVault = false,
  }) => Entry(
    id: id,
    type: EntryType.income,
    amountCents: cents,
    localDate: date,
    createdAtUtc: DateTime.utc(2026),
    timeZoneId: 'UTC',
    toVault: toVault,
    fromVault: fromVault,
  );

  test('8 Monday-to-Sunday weeks, oldest first, this week last', () {
    final weeks = weeklyIncome([
      income('a', 10000, const LocalDate(2026, 9, 28)), // this Monday
      income('b', 5000, today, toVault: true),
      income('c', 20000, const LocalDate(2026, 9, 27)), // last Sunday
      income('d', 7000, const LocalDate(2026, 8, 10)), // first week (Mon)
      income('old', 99900, const LocalDate(2026, 8, 9)), // too old
      income('future', 99900, const LocalDate(2026, 10, 3)),
    ], today);
    expect(weeks, [7000, 0, 0, 0, 0, 0, 20000, 15000]);
  });

  test("the Vault's own releases aren't counted again", () {
    final weeks = weeklyIncome([
      income('pay', 64000, today, toVault: true),
      income('release', 78000, const LocalDate(2026, 9, 28), fromVault: true),
    ], today);
    expect(weeks.last, 64000);
  });
}
