import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/data/db/database_key.dart';
import 'package:steady/domain/models/models.dart';

/// The store writes through to the database; a "restart" (a new store built
/// from what the database holds) sees every change.
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  late BudgetRepository repo;
  late MemoryKeyVault pins;

  setUp(() {
    repo = BudgetRepository(SteadyDatabase(NativeDatabase.memory()));
    pins = MemoryKeyVault();
  });
  tearDown(() => repo.close());

  Future<BudgetStore> launch() async => BudgetStore.fromSnapshot(
    await repo.load(),
    clock: () => oct2,
    repository: repo,
    pinVault: pins,
    pin: await pins.read(),
  );

  /// Flush the old store, then launch again from the database.
  Future<BudgetStore> restart(BudgetStore old) async {
    await old.flush();
    expect(old.saveError, isNull);
    return launch();
  }

  Future<BudgetStore> launchWithSample() async {
    final store = await launch();
    store.loadSample();
    return restart(store);
  }

  Entry spend(String id, int cents, {String merchant = 'Bakery'}) => Entry(
    id: id,
    type: EntryType.spend,
    amountCents: cents,
    localDate: oct2,
    createdAtUtc: DateTime.utc(2026, 10, 2, 12),
    timeZoneId: 'UTC',
    merchant: merchant,
    categoryId: 'food',
  );

  test(
    'first launch: empty defaults, not onboarded, and saved right away',
    () async {
      final store = await launch();
      expect(store.settings.onboarded, isFalse);
      expect(store.entries, isEmpty);
      expect(store.categories.map((c) => c.name), contains('Food'));
      expect(store.isNewUser, isTrue);

      final again = await restart(store);
      expect((await repo.load()).isFresh, isFalse);
      expect(again.categories.length, store.categories.length);
    },
  );

  test(
    'sample data loads and survives a restart with the same daily number',
    () async {
      final store = await launchWithSample();
      expect(store.settings.onboarded, isTrue);
      expect(store.dailyNumber.safeToSpendCents, 4620);
    },
  );

  test('entries: add, edit and delete survive a restart', () async {
    var store = await launch();
    store.addEntry(spend('a', 500));
    store.addEntry(spend('b', 700));
    store.updateEntry(spend('a', 650, merchant: 'Bakery (edited)'));
    store.removeEntry('b');
    store = await restart(store);
    expect(store.entries.single.amountCents, 650);
    expect(store.entries.single.merchant, 'Bakery (edited)');
  });

  test('writes land in order even when made back to back', () async {
    var store = await launch();
    for (var i = 1; i <= 20; i++) {
      store.updateVault(store.vault.copyWith(steadyPayWeeklyCents: i * 1000));
    }
    store.addEntry(spend('x', 100));
    store.removeEntry('x');
    store = await restart(store);
    expect(store.vault.steadyPayWeeklyCents, 20000);
    expect(store.entries, isEmpty);
  });

  test(
    'settings, onboarding cycle, bills, goals, categories persist',
    () async {
      var store = await launch();
      store.updateSettings(
        store.settings.copyWith(
          displayName: () => 'Sam',
          currency: Currency.eur,
          onboarded: true,
        ),
      );
      store.startCycle(balanceCents: 150000, payday: oct2.addDays(10));
      store.addBill(
        Bill(
          id: 'phone',
          name: 'Phone',
          amountCents: 4500,
          recurrence: Recurrence.monthly,
          dueDate: oct2.addDays(3),
        ),
      );
      store.addGoal(
        const Goal(
          id: 'g',
          name: 'Trip',
          targetCents: 90000,
          savedCents: 0,
          dailySetAsideCents: 500,
        ),
      );
      store.updateGoal(
        store.goals.single.copyWith(savedCents: 1000, paused: true),
      );
      store.upsertCategory(
        const BudgetCategory(id: 'pets', name: 'Pets', monthlyLimitCents: 5000),
      );
      store.removeCategory('health');

      store = await restart(store);
      expect(store.settings.displayName, 'Sam');
      expect(store.settings.currency, Currency.eur);
      expect(store.settings.onboarded, isTrue);
      expect(store.nextPayday, oct2.addDays(10));
      expect(store.plan.openingBalanceCents, 150000);
      expect(store.bills.single.name, 'Phone');
      expect(store.goals.single.savedCents, 1000);
      expect(store.goals.single.paused, isTrue);
      expect(store.categories.map((c) => c.id), contains('pets'));
      expect(store.categories.map((c) => c.id), isNot(contains('health')));
      // Daily number from reloaded data: (1500 − 45) ÷ 10 days.
      expect(store.dailyNumber.dailyAllowanceCents, 14550);
    },
  );

  test('splits: shared expenses and settle-up persist', () async {
    var store = await launchWithSample();
    expect(store.splitBalanceCents, 6450);
    store.addSharedExpense(
      SharedExpense(
        id: 'new',
        name: 'Pizza',
        amountCents: 3000,
        date: oct2,
        paidByYou: true,
      ),
    );
    store = await restart(store);
    expect(store.sharedExpenses.length, 5);

    store.settleUp();
    store = await restart(store);
    expect(store.sharedExpenses, isEmpty);
    expect(store.split!.lastSettled, oct2);
  });

  test('an overspend decision persists', () async {
    var store = await launchWithSample();
    store.handleOverspend(OverspendStrategy.spreadEvenly);
    store = await restart(store);
    expect(store.overspendHandledOn(oct2), OverspendStrategy.spreadEvenly);
  });

  group('App lock PIN', () {
    test('lives in the PIN vault, not the database, and turns the lock on after restart', () async {
      var store = await launch();
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '2468'),
      );
      await store.flush();
      expect(pins.value, '2468');

      store = await restart(store);
      expect(store.settings.pin, '2468');
      expect(store.settings.appLockEnabled, isTrue);
    });

    test('turning App lock off removes the PIN', () async {
      var store = await launch();
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '2468'),
      );
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: false, pin: () => null),
      );
      store = await restart(store);
      expect(pins.value, isNull);
      expect(store.settings.appLockEnabled, isFalse);
    });

    test('App lock without a stored PIN is treated as off', () async {
      var store = await launch();
      store.updateSettings(
        store.settings.copyWith(appLockEnabled: true, pin: () => '2468'),
      );
      await store.flush();
      await pins.delete(); // e.g. Keychain item removed
      store = await launch();
      expect(store.settings.appLockEnabled, isFalse);
    });
  });

  test('Delete all my data: back to a fresh, empty setup and no PIN', () async {
    var store = await launchWithSample();
    store.updateSettings(
      store.settings.copyWith(appLockEnabled: true, pin: () => '1111'),
    );
    store.deleteAll();
    store = await restart(store);
    expect(store.settings.onboarded, isFalse);
    expect(store.entries, isEmpty);
    expect(store.bills, isEmpty);
    expect(store.goals, isEmpty);
    expect(store.split, isNull);
    expect(pins.value, isNull);
  });

  test(
    'merchant names longer than 40 characters are trimmed, not lost',
    () async {
      var store = await launch();
      store.addEntry(spend('long', 100, merchant: 'M' * 60));
      store = await restart(store);
      expect(store.entries.single.merchant!.length, Entry.maxMerchantLength);
    },
  );

  test('a failed save is reported instead of lost', () async {
    final store = await launch();
    await store.flush();
    await repo.close(); // simulate the database going away
    store.addEntry(spend('a', 100));
    await store.flush();
    expect(store.saveError, isNotNull);
    expect(store.entries, isNotEmpty); // the user's change is still on screen
    repo = BudgetRepository(
      SteadyDatabase(NativeDatabase.memory()),
    ); // for tearDown
  });
}
