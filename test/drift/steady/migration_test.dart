// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/domain/models/split.dart';
import 'package:steady/domain/split_math.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = SteadyDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // v1 → v2 changes the meaning of a bill's due date, so check real rows.
  test(
    'v1 → v2: paid bills move to their next due date, nothing else changes',
    () async {
      const paidBill = v1.BillsData(
        id: 'rent',
        name: 'Rent',
        amountCents: 145000,
        recurrence: 'monthly',
        dueDate: '2026-10-01',
        isEstimate: 0,
        isSubscription: 0,
        needsReview: 0,
        paidOn: '2026-09-30',
      );
      const unpaidBill = v1.BillsData(
        id: 'car',
        name: 'Car insurance',
        amountCents: 12800,
        recurrence: 'monthly',
        dueDate: '2026-10-08',
        isEstimate: 0,
        isSubscription: 0,
        needsReview: 0,
      );
      const weeklyPaid = v1.BillsData(
        id: 'cleaner',
        name: 'Cleaner',
        amountCents: 4000,
        recurrence: 'weekly',
        dueDate: '2026-10-02',
        isEstimate: 0,
        isSubscription: 0,
        needsReview: 0,
        paidOn: '2026-10-02',
      );
      const oldEntry = v1.EntriesData(
        id: 'coffee',
        type: 'spend',
        amountCents: 540,
        localDate: '2026-10-02',
        createdAtUtc: 1790000000,
        timeZoneId: 'UTC',
        merchant: 'Corner coffee',
        toVault: 0,
      );
      const oldVault = v1.VaultsData(
        id: 1,
        openingBalanceCents: 194000,
        steadyPayWeeklyCents: 78000,
        targetWeeks: 4,
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: SteadyDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.bills, [paidBill, unpaidBill, weeklyPaid]);
          batch.insert(oldDb.entries, oldEntry);
          batch.insert(oldDb.vaults, oldVault);
        },
        validateItems: (newDb) async {
          final bills = {
            for (final b in await newDb.select(newDb.bills).get()) b.id: b,
          };
          expect(bills['rent']!.dueDate, '2026-11-01');
          expect(bills['rent']!.lastPaidOn, '2026-09-30');
          expect(bills['cleaner']!.dueDate, '2026-10-09');
          expect(bills['car']!.dueDate, '2026-10-08');
          expect(bills['car']!.lastPaidOn, isNull);

          final entry = await newDb.select(newDb.entries).getSingle();
          expect(entry.merchant, 'Corner coffee');
          expect(entry.fromVault, 0);
          expect(entry.billId, isNull);

          final vault = await newDb.select(newDb.vaults).getSingle();
          expect(vault.openingBalanceCents, 194000);
          expect(vault.lastReleaseDate, isNull);
        },
      );
    },
  );

  // A development build briefly shipped a v4 without goals.created_on (and
  // the reminder columns were then added to v4 in place); v5 repairs both.
  test('a v4 database missing goals.created_on still upgrades to v5', () async {
    final schema = await verifier.schemaAt(4);
    schema.rawDatabase.execute('ALTER TABLE goals DROP COLUMN created_on');
    final db = SteadyDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 5);
    await db.close();
  });

  test(
    'a v4 database that already has the reminder columns upgrades',
    () async {
      final schema = await verifier.schemaAt(4);
      for (final sql in [
        'ALTER TABLE settings_rows ADD COLUMN remind_log_spends INTEGER NOT NULL DEFAULT 1',
        'ALTER TABLE settings_rows ADD COLUMN remind_log_at INTEGER NOT NULL DEFAULT 1230',
        'ALTER TABLE settings_rows ADD COLUMN remind_bills INTEGER NOT NULL DEFAULT 1',
        'ALTER TABLE settings_rows ADD COLUMN remind_late_pause INTEGER NOT NULL DEFAULT 1',
        'ALTER TABLE settings_rows ADD COLUMN remind_recaps INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE settings_rows ADD COLUMN remind_backup INTEGER NOT NULL DEFAULT 1',
        'ALTER TABLE settings_rows ADD COLUMN quiet_from INTEGER NOT NULL DEFAULT 1380',
      ]) {
        schema.rawDatabase.execute(sql);
      }
      final db = SteadyDatabase(schema.newConnection());
      await db.customSelect('SELECT 1').get(); // runs the migration
      await db.close();
    },
  );

  test(
    'v7 → v8: the payday reminder starts as "Log your spends" was',
    () async {
      final schema = await verifier.schemaAt(7);
      schema.rawDatabase.execute(
        "INSERT INTO settings_rows (id, currency, pay_frequency, next_payday, "
        "income_type, theme, overspend_strategy, remind_log_spends) "
        "VALUES (1, 'usd', 'monthly', '2026-10-15', 'salary', 'system', "
        "'spreadEvenly', 0)",
      );
      final db = SteadyDatabase(schema.newConnection());
      final row = await db.select(db.settingsRows).getSingle();
      expect(row.remindLogSpends, isFalse);
      expect(row.remindPayday, isFalse); // followed "Log your spends"
      expect(row.remindPaydayAt, 540); // 9:00 AM
      await db.close();
    },
  );

  test('v8 → v9: the one-person split becomes a group, balances intact', () async {
    final schema = await verifier.schemaAt(8);
    final raw = schema.rawDatabase;
    raw.execute(
      "INSERT INTO splits (id, person_name, your_share_percent, method, "
      "last_settled) VALUES ('split', 'Alex', 60, 'byIncome', '2026-09-15')",
    );
    raw.execute(
      "INSERT INTO shared_expenses (id, name, amount_cents, date, paid_by_you) "
      "VALUES ('s1', 'Groceries', 11240, '2026-09-30', 1), "
      "('s4', 'Electric', 9150, '2026-09-26', 0)",
    );
    final db = SteadyDatabase(schema.newConnection());
    final book = (await BudgetRepository(db).load()).splits;
    expect(book.people.single.name, 'Alex');
    final g = book.groups.single;
    expect(g.id, 'split'); // entries tagged with the old split id still match
    expect(g.name, 'You & Alex');
    expect(g.weights, {youId: 60, 'person-split': 40});
    expect(book.expenses.map((e) => e.id), ['s4', 's1']);
    // Same balance as before: Alex owes 44.96, you owe 54.90.
    expect(personBalances(book).single.net, 4496 - 5490);
    // The old tables are gone.
    expect(
      await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE name IN "
            "('splits', 'shared_expenses')",
          )
          .get(),
      isEmpty,
    );
    await db.close();
  });

  test(
    'v9 → v10: goals keep everything; per-cycle amount starts unknown',
    () async {
      final schema = await verifier.schemaAt(9);
      schema.rawDatabase.execute(
        "INSERT INTO goals (id, name, kind, target_cents, saved_cents, "
        "daily_set_aside_cents, paused, sort_order, created_on) "
        "VALUES ('fund', 'Emergency fund', 'safety', 300000, 186000, 1538, 0, "
        "0, '2026-09-01')",
      );
      final db = SteadyDatabase(schema.newConnection());
      final goal = (await BudgetRepository(db).load()).goals.single;
      expect(goal.savedCents, 186000);
      expect(goal.dailySetAsideCents, 1538);
      // The store fills this in from the cycle's total when it loads.
      expect(goal.cycleSetAsideCents, isNull);
      await db.close();
    },
  );

  test('v10 → v11: settings keep everything; catch-up starts unset', () async {
    final schema = await verifier.schemaAt(10);
    schema.rawDatabase.execute(
      "INSERT INTO settings_rows (id, currency, pay_frequency, next_payday, "
      "income_type, theme, overspend_strategy, last_backup_on) "
      "VALUES (1, 'usd', 'monthly', '2026-10-15', 'salary', 'system', "
      "'spreadEvenly', '2026-09-30')",
    );
    final db = SteadyDatabase(schema.newConnection());
    final row = await db.select(db.settingsRows).getSingle();
    expect(row.lastBackupOn.toString(), '2026-09-30');
    expect(row.caughtUpThrough, isNull);
    await db.close();
  });
}
