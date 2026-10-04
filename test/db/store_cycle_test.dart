import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/schedule.dart';

/// Stage 5 end to end: bills, paydays and the Vault over a moving clock,
/// persisted and reloaded like an app restart.
void main() {
  late BudgetRepository repo;
  late LocalDate now;
  LocalDate clock() => now;

  setUp(() {
    repo = BudgetRepository(SteadyDatabase(NativeDatabase.memory()));
    now = const LocalDate(2026, 10, 2);
  });
  tearDown(() => repo.close());

  Future<BudgetStore> launch() async => BudgetStore.fromSnapshot(
    await repo.load(),
    clock: clock,
    repository: repo,
  );

  Future<BudgetStore> restart(BudgetStore old) async {
    await old.flush();
    expect(old.saveError, isNull);
    return launch();
  }

  /// Demo data on a regular monthly payday (Oct 15).
  Future<BudgetStore> monthlyUser() async {
    final store = await launch();
    store.loadSample();
    store.updateSettings(
      store.settings.copyWith(payFrequency: PayFrequency.monthly),
    );
    return restart(store);
  }

  Entry pay(int cents) => Entry(
    id: 'pay-${now.toIso()}',
    type: EntryType.income,
    amountCents: cents,
    localDate: now,
    createdAtUtc: DateTime.utc(2026),
    timeZoneId: 'UTC',
    merchant: 'Employer',
  );

  group('paying bills', () {
    test(
      'marking a reserved bill paid leaves the daily number unchanged',
      () async {
        var store = await monthlyUser();
        final before = store.dailyNumber.safeToSpendCents;
        final car = store.bills.firstWhere((b) => b.id == 'car');

        store.payBill(car, amountCents: car.amountCents);
        expect(store.dailyNumber.safeToSpendCents, before);
        expect(store.dailyNumber.spentTodayCents, 1780); // not counted as spent
        expect(store.todayEntries.any((e) => e.billId == 'car'), isTrue);

        store = await restart(store);
        final paid = store.bills.firstWhere((b) => b.id == 'car');
        expect(paid.dueDate, nextOccurrence(car.dueDate, Recurrence.monthly));
        expect(paid.lastPaidOn, now);
        expect(store.dailyNumber.safeToSpendCents, before);
      },
    );

    test(
      'paying more than reserved lowers the number by the difference',
      () async {
        final store = await monthlyUser();
        final before = store.dailyNumber.safeToSpendCents;
        final electric = store.bills.firstWhere((b) => b.id == 'electric');
        store.payBill(
          electric,
          amountCents: electric.amountCents + 1300,
        ); // $13 over the estimate
        expect(store.dailyNumber.safeToSpendCents, lessThan(before));
        expect(
          store.bills.firstWhere((b) => b.id == 'electric').amountCents,
          10900,
        );
      },
    );

    test('paid bills show as paid this cycle on Today', () async {
      final store = await monthlyUser();
      final paidBefore = store.billsThisCycle.where((b) => b.paid).length;
      store.payBill(
        store.bills.firstWhere((b) => b.id == 'internet'),
        amountCents: 6000,
      );
      expect(store.billsThisCycle.where((b) => b.paid).length, paidBefore + 1);
    });
  });

  group('payday (regular pay)', () {
    test('asks "Did your payment arrive?" from payday on', () async {
      final store = await monthlyUser();
      expect(store.isAwaitingPay, isFalse);
      now = store.nextPayday;
      expect(store.isAwaitingPay, isTrue);
      store.snoozePayPrompt();
      expect(store.isAwaitingPay, isFalse); // "Not yet": ask again tomorrow
      now = now.addDays(1);
      expect(store.isAwaitingPay, isTrue);
    });

    test(
      'logging the pay starts the next cycle and moves goal savings',
      () async {
        var store = await monthlyUser();
        final payday = store.nextPayday;
        final savedBefore = store.goals.fold(0, (s, g) => s + g.savedCents);
        now = payday;

        store.addEntry(pay(300000));
        expect(store.plan.startDate, payday);
        expect(store.nextPayday, addMonths(payday, 1));
        expect(store.isAwaitingPay, isFalse);
        expect(store.newCycleStartedOn, payday);
        expect(
          store.goals.fold(0, (s, g) => s + g.savedCents),
          greaterThan(savedBefore),
        );
        expect(
          store.dailyNumber.daysLeft,
          payday.daysUntil(addMonths(payday, 1)),
        );

        store = await restart(store);
        expect(store.plan.startDate, payday);
        expect(store.nextPayday, addMonths(payday, 1));
      },
    );

    test('"It won\'t come" starts the next cycle without pay', () async {
      final store = await monthlyUser();
      now = store.nextPayday.addDays(2);
      store.payWontCome();
      expect(store.plan.startDate, now);
      expect(store.nextPayday.isAfter(now), isTrue);
      expect(store.isAwaitingPay, isFalse);
    });
  });

  test(
    'pay that varies rolls weekly by itself, catching up missed weeks',
    () async {
      var store = await launch();
      store.loadSample(); // the sample's pay varies; payday is 13 days away
      store = await restart(store);
      final payday = store.nextPayday;

      now = payday.addDays(9); // two automatic cycles: payday and payday + 7
      store.onClockTick();
      expect(store.plan.startDate, payday.addDays(7));
      expect(store.nextPayday, payday.addDays(14));
      expect(store.nextPayday.isAfter(now), isTrue);

      store = await restart(store);
      expect(store.plan.startDate, payday.addDays(7));
    },
  );

  group('Paycheck Vault', () {
    test('releases steady pay every Monday into the daily number', () async {
      var store = await launch();
      store.loadSample(); // $780 a week, last released this Monday
      store = await restart(store);
      final balance = store.vaultBalanceCents;
      final firstMonday = mondayAfter(now);

      now = firstMonday.addDays(7); // two Mondays later
      store.onClockTick();
      final releases = store.entries.where((e) => e.fromVault).toList();
      expect(releases.map((e) => e.localDate), [
        firstMonday,
        firstMonday.addDays(7),
      ]);
      expect(releases.every((e) => e.amountCents == 78000), isTrue);
      expect(store.vaultBalanceCents, balance - 2 * 78000);

      store = await restart(store);
      expect(store.entries.where((e) => e.fromVault).length, 2);
      expect(store.vault.lastReleaseDate, firstMonday.addDays(7));
    });

    test('never releases more than the Vault holds', () async {
      var store = await launch();
      store.updateVault(
        const Vault(openingBalanceCents: 50000, steadyPayWeeklyCents: 78000),
      );
      store = await restart(store);
      now = mondayAfter(now).addDays(7);
      store.onClockTick();
      expect(
        store.entries.where((e) => e.fromVault).map((e) => e.amountCents),
        [50000],
      );
      expect(store.vaultBalanceCents, 0);
    });

    test(
      'setting steady pay schedules the first release for next Monday',
      () async {
        final store = await launch();
        expect(store.vault.isActive, isFalse);
        store.updateVault(store.vault.copyWith(steadyPayWeeklyCents: 40000));
        expect(store.vault.lastReleaseDate, mondayOnOrBefore(now));
        store.onClockTick();
        expect(
          store.entries.where((e) => e.fromVault),
          isEmpty,
        ); // not this week
      },
    );

    test(
      'a Vault upgraded from an older version starts releasing next Monday',
      () async {
        await (await launch()).flush(); // an existing install
        // As migrated from schema v1: active, but no release date yet.
        await repo.saveVault(
          const Vault(openingBalanceCents: 300000, steadyPayWeeklyCents: 50000),
        );
        var store = await launch();
        expect(store.vault.lastReleaseDate, mondayOnOrBefore(now));
        expect(store.entries.where((e) => e.fromVault), isEmpty);

        store = await restart(store);
        now = mondayAfter(now);
        store.onClockTick();
        expect(
          store.entries.where((e) => e.fromVault).map((e) => e.localDate),
          [now],
        );
      },
    );
  });
}
