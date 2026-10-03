// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:steady/data/db/database.dart';
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
}
