import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/split_math.dart';

/// Split groups through the store: what reaches your money, and what's
/// remembered after a restart.
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  late BudgetRepository repo;

  setUp(() => repo = BudgetRepository(SteadyDatabase(NativeDatabase.memory())));
  tearDown(() => repo.close());

  Future<BudgetStore> launch() async => BudgetStore.fromSnapshot(
    await repo.load(),
    clock: () => oct2,
    repository: repo,
  );
  Future<BudgetStore> restart(BudgetStore s) async {
    await s.flush();
    expect(s.saveError, isNull);
    return launch();
  }

  /// A trip with Sam and Priya, starting from the sample data.
  Future<(BudgetStore, String sam, String priya, String trip)> setUpTrip() async {
    final store = await launch();
    store.loadSample();
    final sam = store.splits.people.firstWhere((p) => p.name == 'Sam').id;
    final priya = store.splits.people.firstWhere((p) => p.name == 'Priya').id;
    store.saveSplitGroup(
      SplitGroup(id: 'trip', name: 'Goa trip', memberIds: [sam, priya]),
    );
    return (store, sam, priya, 'trip');
  }

  test('your payment is logged once, in full; others\' aren\'t', () async {
    final (store, sam, priya, trip) = await setUpTrip();
    final before = store.dailyNumber.safeToSpendCents;
    store.addGroupExpense(
      groupId: trip,
      name: 'Dinner',
      amountCents: 9000,
      date: oct2,
      paidBy: youId,
      shares: splitShares(
        amountCents: 9000,
        participants: [youId, sam, priya],
        paidBy: youId,
      ),
      categoryId: 'food',
    );
    final logged = store.entries.where((e) => e.merchant == 'Dinner').single;
    expect(logged.amountCents, 9000);
    expect(logged.splitId, trip);
    expect(logged.categoryId, 'food');
    expect(store.dailyNumber.safeToSpendCents, before - 9000);

    store.addGroupExpense(
      groupId: trip,
      name: 'Taxi',
      amountCents: 3000,
      date: oct2,
      paidBy: sam,
      shares: splitShares(
        amountCents: 3000,
        participants: [youId, sam, priya],
        paidBy: sam,
      ),
    );
    expect(store.entries.where((e) => e.merchant == 'Taxi'), isEmpty);
    expect(store.dailyNumber.safeToSpendCents, before - 9000);
    await store.flush();
  });

  test('settling up logs money in, and clears every group', () async {
    final (store, sam, priya, trip) = await setUpTrip();
    store.addGroupExpense(
      groupId: trip,
      name: 'Hotel',
      amountCents: 12000,
      date: oct2,
      paidBy: youId,
      shares: splitShares(
        amountCents: 12000,
        participants: [youId, sam, priya],
        paidBy: youId,
      ),
    );
    final samOwes = store.splitBalances.firstWhere((b) => b.personId == sam);
    // Flat 4B simplifies: Priya pays you 28, Sam pays you 4 (internet 20,
    // less cleaning 8 he paid for you, less Priya's 8 routed through him).
    // Trip: 40.
    expect(samOwes.owesYou, 400 + 4000);
    expect(samOwes.youOwe, 0);
    expect(samOwes.transfers.map((t) => t.groupId).toSet(), {'flat', trip});

    final before = store.dailyNumber.dailyAllowanceCents;
    store.settleUpWith(sam);
    expect(store.splitBalances.where((b) => b.personId == sam), isEmpty);
    // Money in from Sam raises today's number.
    expect(store.dailyNumber.dailyAllowanceCents, greaterThan(before));
    expect(
      store.entries.where((e) => e.merchant == 'Sam paid you back'),
      isNotEmpty,
    );

    final reloaded = await restart(store);
    expect(reloaded.splitBalances.where((b) => b.personId == sam), isEmpty);
    expect(reloaded.splits.settlements, isNotEmpty);
  });

  test('settling without logging leaves your money alone', () async {
    final (store, sam, _, _) = await setUpTrip();
    final entries = store.entries.length;
    store.settleUpWith(sam, logMoney: false);
    expect(store.entries.length, entries);
    await store.flush();
  });

  test('deleting your expense removes the spend it logged', () async {
    final (store, sam, priya, trip) = await setUpTrip();
    final e = store.addGroupExpense(
      groupId: trip,
      name: 'Fuel',
      amountCents: 6000,
      date: oct2,
      paidBy: youId,
      shares: splitShares(
        amountCents: 6000,
        participants: [youId, sam, priya],
        paidBy: youId,
      ),
    );
    expect(store.entries.where((x) => x.id == e.entryId), hasLength(1));
    store.deleteGroupExpense(e.id);
    expect(store.entries.where((x) => x.id == e.entryId), isEmpty);
    expect(store.splits.expenses.where((x) => x.id == e.id), isEmpty);
    await store.flush();
  });

  test('a person snoozed or muted is remembered', () async {
    var store = await launch();
    final p = store.addSplitPerson('Rahul');
    store.updateSplitPerson(
      p.copyWith(remindMuted: true, remindSnoozedUntil: () => oct2),
    );
    store = await restart(store);
    final back = store.splits.person(p.id)!;
    expect(back.remindMuted, isTrue);
    expect(back.remindSnoozedUntil, oct2);
  });
}
