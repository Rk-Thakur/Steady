import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/domain/models/split.dart';
import 'package:steady/domain/split_math.dart';

void main() {
  const oct1 = LocalDate(2026, 10, 1);
  const sam = 'sam', priya = 'priya', rahul = 'rahul';

  GroupExpense expense(
    String paidBy,
    int cents,
    List<String> between, {
    String id = 'e',
    LocalDate date = oct1,
    String group = 'trip',
  }) => GroupExpense(
    id: id,
    groupId: group,
    name: 'x',
    amountCents: cents,
    date: date,
    paidBy: paidBy,
    shares: splitShares(
      amountCents: cents,
      participants: between,
      paidBy: paidBy,
    ),
  );

  group('splitting an expense', () {
    test('equal: leftover cents stay with the payer', () {
      final s = splitShares(
        amountCents: 10000,
        participants: [youId, sam, priya],
        paidBy: youId,
      );
      expect(s, {youId: 3334, sam: 3333, priya: 3333});
    });

    test("equal when the payer isn't included: first people get the cents", () {
      final s = splitShares(
        amountCents: 1001,
        participants: [sam, priya],
        paidBy: youId,
      );
      expect(s, {sam: 501, priya: 500});
    });

    test('by income: percentages, rescaled to who is included', () {
      final w = {youId: 60, sam: 30, priya: 10};
      expect(
        splitShares(
          amountCents: 10000,
          participants: [youId, sam, priya],
          paidBy: sam,
          method: SplitMethod.byIncome,
          weights: w,
        ),
        {youId: 6000, sam: 3000, priya: 1000},
      );
      // Only you and Sam: 60 / 30 → 2/3 and 1/3.
      expect(
        splitShares(
          amountCents: 9000,
          participants: [youId, sam],
          paidBy: youId,
          method: SplitMethod.byIncome,
          weights: w,
        ),
        {youId: 6000, sam: 3000},
      );
    });

    test('exact amounts must add up', () {
      expect(
        splitShares(
          amountCents: 5000,
          participants: [youId, sam],
          paidBy: youId,
          method: SplitMethod.exact,
          exact: {youId: 1500, sam: 3500},
        ),
        {youId: 1500, sam: 3500},
      );
      expect(
        () => splitShares(
          amountCents: 5000,
          participants: [youId, sam],
          paidBy: youId,
          method: SplitMethod.exact,
          exact: {youId: 1000, sam: 3500},
        ),
        throwsArgumentError,
      );
    });

    test('shares always add up exactly (random amounts and groups)', () {
      final rnd = Random(7);
      final people = [youId, sam, priya, rahul, 'kim', 'lee'];
      for (var i = 0; i < 500; i++) {
        final n = 1 + rnd.nextInt(people.length);
        final between = (people.toList()..shuffle(rnd)).take(n).toList();
        final amount = 1 + rnd.nextInt(1000000);
        for (final method in [SplitMethod.equal, SplitMethod.byIncome]) {
          final s = splitShares(
            amountCents: amount,
            participants: between,
            paidBy: people[rnd.nextInt(people.length)],
            method: method,
            weights: {for (final p in people) p: rnd.nextInt(100)},
          );
          expect(s.values.fold(0, (a, b) => a + b), amount);
          expect(s.values.every((v) => v >= 0), isTrue);
        }
      }
    });
  });

  group('who owes whom', () {
    // Goa trip: you paid dinner $90 for 3; Sam paid the taxi $30 for 3;
    // Priya paid the museum $60 for Priya and Sam.
    final trip = [
      expense(youId, 9000, [youId, sam, priya], id: 'dinner'),
      expense(sam, 3000, [youId, sam, priya], id: 'taxi'),
      expense(priya, 6000, [priya, sam], id: 'museum'),
    ];

    test('net positions add up to zero', () {
      final net = netBalances(trip, const []);
      expect(net, {youId: 5000, sam: -4000, priya: -1000});
      expect(net.values.fold(0, (a, b) => a + b), 0);
    });

    test('every IOU, netted per pair', () {
      final debts = pairwiseDebts(trip, const []);
      int owed(String from, String to) => debts
          .where((t) => t.fromId == from && t.toId == to)
          .fold(0, (a, t) => a + t.amountCents);
      expect(owed(sam, youId), 2000); // dinner 3000 − taxi 1000
      expect(owed(priya, youId), 3000); // dinner
      expect(owed(sam, priya), 2000); // museum 3000 − taxi 1000
      expect(debts, hasLength(3));
    });

    test('simplified: fewest payments, same totals', () {
      final simple = simplifyDebts(netBalances(trip, const []));
      expect(simple, [
        const Transfer(sam, youId, 4000),
        const Transfer(priya, youId, 1000),
      ]);
    });

    test('settlements reduce what is owed', () {
      final paid = [
        const Settlement(
          id: 's1',
          groupId: 'trip',
          fromId: sam,
          toId: youId,
          amountCents: 3000,
          date: oct1,
        ),
      ];
      // Sam paid you $30 of the $40: $10 left each.
      expect(simplifyDebts(netBalances(trip, paid)), [
        const Transfer(priya, youId, 1000),
        const Transfer(sam, youId, 1000),
      ]);
    });

    test('simplification keeps every balance and uses at most n − 1 '
        'payments (random groups)', () {
      final rnd = Random(11);
      final people = [youId, sam, priya, rahul, 'kim', 'lee', 'max'];
      for (var round = 0; round < 300; round++) {
        final expenses = [
          for (var i = 0; i < 1 + rnd.nextInt(12); i++)
            expense(
              people[rnd.nextInt(people.length)],
              1 + rnd.nextInt(50000),
              (people.toList()..shuffle(rnd))
                  .take(1 + rnd.nextInt(people.length))
                  .toList(),
              id: 'e$i',
            ),
        ];
        final net = netBalances(expenses, const []);
        final simple = simplifyDebts(net);
        final after = <String, int>{};
        for (final t in simple) {
          after[t.fromId] = (after[t.fromId] ?? 0) - t.amountCents;
          after[t.toId] = (after[t.toId] ?? 0) + t.amountCents;
        }
        after.removeWhere((_, v) => v == 0);
        expect(after, net, reason: 'round $round');
        expect(simple.length, lessThanOrEqualTo(max(0, net.length - 1)));
        expect(simple.every((t) => t.amountCents > 0), isTrue);
        // Pairwise debts settle the same positions too.
        final pairNet = <String, int>{};
        for (final t in pairwiseDebts(expenses, const [])) {
          pairNet[t.fromId] = (pairNet[t.fromId] ?? 0) - t.amountCents;
          pairNet[t.toId] = (pairNet[t.toId] ?? 0) + t.amountCents;
        }
        pairNet.removeWhere((_, v) => v == 0);
        expect(pairNet, net);
      }
    });
  });

  group('per person, across groups', () {
    final book = SplitBook(
      people: const [
        SplitPerson(id: sam, name: 'Sam'),
        SplitPerson(id: priya, name: 'Priya'),
      ],
      groups: const [
        SplitGroup(id: 'flat', name: 'Flat 4B', memberIds: [sam, priya]),
        SplitGroup(id: 'trip', name: 'Goa trip', memberIds: [sam]),
      ],
      expenses: [
        expense(
          youId,
          6000,
          [youId, sam, priya],
          id: 'internet',
          group: 'flat',
          date: const LocalDate(2026, 9, 20),
        ),
        expense(sam, 4000, [youId, sam], id: 'fuel', group: 'trip'),
        expense(youId, 10000, [youId, sam], id: 'hotel', group: 'trip'),
      ],
    );

    test('adds up what each person owes you in every group', () {
      final balances = {for (final b in personBalances(book)) b.personId: b};
      // Flat: Sam owes 20, Priya owes 20. Trip: Sam owes 50 − 20 = 30.
      expect(balances[sam]!.owesYou, 5000);
      expect(balances[sam]!.youOwe, 0);
      expect(balances[sam]!.transfers, hasLength(2));
      expect(balances[priya]!.owesYou, 2000);
      expect(balances[sam]!.since, const LocalDate(2026, 9, 20));
    });

    test('settling in a group moves "since" past it', () {
      final settled = SplitBook(
        people: book.people,
        groups: book.groups,
        expenses: book.expenses,
        settlements: const [
          Settlement(
            id: 's',
            groupId: 'flat',
            fromId: sam,
            toId: youId,
            amountCents: 2000,
            date: oct1,
          ),
        ],
      );
      final s = personBalances(settled).firstWhere((b) => b.personId == sam);
      expect(s.owesYou, 3000); // only the trip now
      expect(s.since, oct1);
    });
  });

  test('the old one-person split converts exactly', () {
    final book = SplitBook.fromLegacy(
      splitId: 'split',
      personName: 'Alex',
      yourSharePercent: 60,
      legacyMethod: 'byIncome',
      expenses: const [
        (
          id: 'g',
          name: 'Groceries',
          amountCents: 11240,
          date: oct1,
          paidByYou: true,
        ),
        (
          id: 'e',
          name: 'Electric',
          amountCents: 9150,
          date: oct1,
          paidByYou: false,
        ),
      ],
    );
    final g = book.groups.single;
    expect(g.name, 'You & Alex');
    expect(g.method, SplitMethod.byIncome);
    // Old balance: Alex owes floor(112.40 × 40%) − floor(91.50 × 60%)
    // = 44.96 − 54.90 = −9.94 (you owe Alex 9.94).
    final net = netBalances(book.expenses, const []);
    expect(net[youId], 4496 - 5490);
  });
}
