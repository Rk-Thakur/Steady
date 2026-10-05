import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/domain/daily_number.dart';
import 'package:steady/domain/models/models.dart';

void main() {
  const oct2 = LocalDate(2026, 10, 2);
  late SteadyDatabase db;
  late BudgetRepository repo;

  setUp(() {
    db = SteadyDatabase(NativeDatabase.memory());
    repo = BudgetRepository(db);
  });
  tearDown(() => repo.close());

  BudgetSnapshot sample() => BudgetStore.sample(clock: () => oct2).toSnapshot();

  test('a fresh database is empty and marked fresh', () async {
    final s = await repo.load();
    expect(s.isFresh, isTrue);
    expect(s.entries, isEmpty);
    expect(s.plan, isNull);
  });

  test('round trip: the sample data survives save → load intact', () async {
    final original = sample();
    await repo.replaceAll(original);
    final loaded = await repo.load();

    expect(loaded.isFresh, isFalse);
    expect(loaded.settings!.nextPayday, original.settings!.nextPayday);
    expect(loaded.settings!.currency, Currency.usd);
    expect(
      loaded.plan!.openingBalanceCents,
      original.plan!.openingBalanceCents,
    );
    expect(
      loaded.categories.map((c) => c.id),
      original.categories.map((c) => c.id),
    );
    expect(loaded.categories.first.monthlyLimitCents, 42000);
    expect(loaded.entries.length, original.entries.length);
    expect(loaded.bills.length, original.bills.length);
    expect(loaded.goals.map((g) => g.name), original.goals.map((g) => g.name));
    expect(loaded.vault!.steadyPayWeeklyCents, 78000);
    // Split groups round-trip whole: people, groups, expenses with shares.
    expect(loaded.splits.people.map((p) => p.name), ['Alex', 'Sam', 'Priya']);
    expect(loaded.splits.groups.map((g) => g.name), ['You & Alex', 'Flat 4B']);
    expect(loaded.splits.expenses.length, original.splits.expenses.length);
    final internet = loaded.splits.expenses.firstWhere((e) => e.id == 'f1');
    expect(internet.shares, {
      youId: 2000,
      'person-sam': 2000,
      'person-priya': 2000,
    });
    expect(loaded.splits.groups.first.weights, {youId: 60, 'person-split': 40});

    final client = loaded.entries.firstWhere((e) => e.id == 'client');
    expect(client.type, EntryType.income);
    expect(client.toVault, isTrue);
    final taco = loaded.entries.firstWhere((e) => e.id == 'taco');
    expect(taco.mood, Mood.tired);
    expect(taco.planned, isFalse);
    expect(taco.localDate, oct2.addDays(-1));

    final streamly = loaded.bills.firstWhere((b) => b.id == 'streamly');
    expect(streamly.previousAmountCents, 1599);
    expect(streamly.needsReview, isTrue);
  });

  test('the daily number from loaded data is still \$46.20', () async {
    await repo.replaceAll(sample());
    final s = await repo.load();
    final n = DailyNumberCalculator.calculate(
      DailyNumberCalculator.inputFromLedger(
        today: oct2,
        nextPayday: s.settings!.nextPayday,
        plan: s.plan!,
        entries: s.entries,
        bills: s.bills,
      ),
    );
    expect(n.safeToSpendCents, 4620);
  });

  test('entries: insert, edit, delete', () async {
    final e = Entry(
      id: 'e1',
      type: EntryType.spend,
      amountCents: 2340,
      localDate: oct2,
      createdAtUtc: DateTime.utc(2026, 10, 2, 21, 42),
      timeZoneId: 'America/New_York',
      merchant: 'Taco place',
      categoryId: 'food',
      mood: Mood.tired,
      planned: false,
    );
    await repo.upsertEntry(e);
    await repo.upsertEntry(e.copyWith(amountCents: 2500, note: 'with tip'));
    var loaded = (await repo.load()).entries.single;
    expect(loaded.amountCents, 2500);
    expect(loaded.note, 'with tip');
    expect(loaded.createdAtUtc, DateTime.utc(2026, 10, 2, 21, 42));
    expect(loaded.createdAtUtc.isUtc, isTrue);

    await repo.deleteEntry('e1');
    expect((await repo.load()).entries, isEmpty);
  });

  test(
    'stores enums by name and dates as ISO text (safe to reorder enums)',
    () async {
      await repo.replaceAll(sample());
      final row = await db
          .customSelect(
            "SELECT type, mood, local_date FROM entries WHERE id = 'taco'",
          )
          .getSingle();
      expect(row.read<String>('type'), 'spend');
      expect(row.read<String>('mood'), 'tired');
      expect(row.read<String>('local_date'), '2026-10-01');
    },
  );

  test('rejects a zero amount at the database level', () async {
    expect(
      () => db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: 'bad',
              type: EntryType.spend,
              amountCents: 0,
              localDate: oct2,
              createdAtUtc: DateTime.utc(2026),
              timeZoneId: 'UTC',
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a category keeps its entries', () async {
    await repo.replaceAll(sample());
    await repo.deleteCategory('food');
    final s = await repo.load();
    expect(s.categories.any((c) => c.id == 'food'), isFalse);
    expect(s.entries.where((e) => e.categoryId == 'food'), isNotEmpty);
  });

  test(
    'settlements persist; deleting a group removes everything in it',
    () async {
      await repo.replaceAll(sample());
      await repo.addSettlement(
        const Settlement(
          id: 'st',
          groupId: 'flat',
          fromId: 'person-sam',
          toId: youId,
          amountCents: 2000,
          date: oct2,
        ),
      );
      var loaded = await repo.load();
      expect(loaded.splits.settlements.single.amountCents, 2000);

      await repo.deleteSplitGroup('flat');
      loaded = await repo.load();
      expect(loaded.splits.groups.map((g) => g.id), ['split']);
      expect(loaded.splits.expenses.where((e) => e.groupId == 'flat'), isEmpty);
      expect(loaded.splits.settlements, isEmpty);
      // People stay: they may be in other groups.
      expect(loaded.splits.people.length, 3);
    },
  );

  test('overspend decisions persist per day', () async {
    const decision = OverspendDecision(
      OverspendStrategy.takeFromCategory,
      categoryId: 'fun',
      amountCents: 1240,
    );
    await repo.saveOverspendDecision(oct2, decision);
    expect((await repo.load()).overspendDecisions[oct2], decision);
  });

  test('delete all my data empties every table', () async {
    await repo.replaceAll(sample());
    await repo.deleteEverything();
    final s = await repo.load();
    expect(s.isFresh, isTrue);
    expect(s.entries, isEmpty);
    expect(s.bills, isEmpty);
    expect(s.splits.isEmpty, isTrue);
  });

  test(
    'data survives closing and reopening the file (an app restart)',
    () async {
      final dir = await Directory.systemTemp.createTemp('steady_db_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/steady.db');

      final first = BudgetRepository(SteadyDatabase(NativeDatabase(file)));
      await first.replaceAll(sample());
      await first.close();

      final second = BudgetRepository(SteadyDatabase(NativeDatabase(file)));
      final s = await second.load();
      expect(s.entries.length, sample().entries.length);
      expect(s.settings!.onboarded, isTrue);
      await second.close();
    },
  );
}
