import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/backup/backup_codec.dart';
import 'package:steady/data/backup/backup_file.dart';
import 'package:steady/data/backup/csv_export.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/data/db/database_key.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/domain/split_math.dart';

/// Handoff 4: ".steady file = versioned JSON, AES-256-GCM, key derived from
/// the user's password (Argon2id). Never written anywhere automatically."
void main() {
  const oct2 = LocalDate(2026, 10, 2);
  // Small Argon2 settings so tests are fast; the file records what was used.
  const fastKdf = KdfParams(memoryKiB: 64, iterations: 1, parallelism: 1);
  final created = DateTime.utc(2026, 10, 4, 9, 30);

  BudgetSnapshot sample() => BudgetStore.sample(clock: () => oct2).toSnapshot();

  Future<Uint8List> make(
    BudgetSnapshot s, {
    String password = 'correct horse',
  }) => BackupFile.create(
    s,
    password: password,
    createdAt: created,
    kdf: fastKdf,
  );

  group('codec', () {
    test('every field survives encode → JSON → decode', () {
      final original = sample();
      final json = jsonDecode(
        jsonEncode(BackupCodec.encode(original)),
      ) as Map<String, Object?>;
      final back = BackupCodec.decode(json);

      // Re-encoding the decoded snapshot gives identical JSON: nothing lost.
      expect(
        jsonEncode(BackupCodec.encode(back)),
        jsonEncode(BackupCodec.encode(original)),
      );
      expect(back.entries.length, original.entries.length);
      expect(back.splits.groups.map((g) => g.name), ['You & Alex', 'Flat 4B']);
      expect(back.splits.expenses.length, original.splits.expenses.length);
      expect(back.vault!.lastReleaseDate, original.vault!.lastReleaseDate);
    });

    test('a backup from before split groups restores into a group', () {
      final json =
          jsonDecode(jsonEncode(BackupCodec.encode(sample())))
                as Map<String, Object?>
            ..remove('splits')
            ..['split'] = {
              'id': 'split',
              'personName': 'Alex',
              'yourSharePercent': 60,
              'method': 'byIncome',
              'lastSettled': '2026-09-15',
            }
            ..['sharedExpenses'] = [
              {
                'id': 's1',
                'name': 'Groceries',
                'amountCents': 11240,
                'date': '2026-09-30',
                'paidByYou': true,
              },
              {
                'id': 's4',
                'name': 'Electric',
                'amountCents': 9150,
                'date': '2026-09-26',
                'paidByYou': false,
              },
            ];
      final back = BackupCodec.decode(json);
      expect(back.splits.groups.single.name, 'You & Alex');
      expect(back.splits.people.single.name, 'Alex');
      // Same rule as before: Alex owes 44.96, you owe 54.90.
      final alex = personBalances(back.splits).single;
      expect(alex.net, 4496 - 5490);
    });

    test('never contains the App lock PIN', () {
      final s = BudgetStore.sample(clock: () => oct2);
      s.updateSettings(
        s.settings.copyWith(appLockEnabled: true, pin: () => '4826'),
      );
      final text = jsonEncode(BackupCodec.encode(s.toSnapshot()));
      expect(text.contains('4826'), isFalse);
      expect(text.contains('"pin"'), isFalse);
      expect(text.contains('appLock'), isFalse);
    });

    test('rejects malformed data with a FormatException', () {
      final json = BackupCodec.encode(sample());
      (json['entries']! as List).add({'id': 'x', 'type': 'teleport'});
      expect(
        () => BackupCodec.decode(
          jsonDecode(jsonEncode(json)) as Map<String, Object?>,
        ),
        throwsFormatException,
      );
    });
  });

  group('encrypted file', () {
    test('round trip with the right password', () async {
      final bytes = await make(sample());
      final contents = await BackupFile.open(bytes, password: 'correct horse');
      expect(contents.createdAt, created);
      expect(
        contents.snapshot.entries.map((e) => e.merchant),
        contains('Corner coffee'),
      );
    });

    test('the file reveals nothing in clear text', () async {
      final text = utf8.decode(await make(sample()));
      for (final secret in [
        'Corner coffee',
        'Alex',
        'Emergency fund',
        '139200',
      ]) {
        expect(
          text.contains(secret),
          isFalse,
          reason: '"$secret" readable in the backup',
        );
      }
      final envelope = jsonDecode(text) as Map<String, Object?>;
      expect(envelope['format'], 'steady-backup');
      expect(envelope['version'], 1);
      expect((envelope['kdf']! as Map)['name'], 'argon2id');
      expect((envelope['cipher']! as Map)['name'], 'aes-256-gcm');
    });

    test(
      'the same data encrypts differently each time (fresh salt and nonce)',
      () async {
        final a = await make(sample());
        final b = await make(sample());
        expect(base64.encode(a), isNot(base64.encode(b)));
      },
    );

    test('wrong password is rejected', () async {
      final bytes = await make(sample());
      expect(
        () => BackupFile.open(bytes, password: 'wrong horse'),
        throwsA(isA<BackupWrongPassword>()),
      );
    });

    test('tampering with the header (e.g. its date) is detected', () async {
      final envelope =
          jsonDecode(utf8.decode(await make(sample()))) as Map<String, Object?>;
      envelope['createdAt'] = '2020-01-01T00:00:00.000Z';
      final tampered = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
      expect(
        () => BackupFile.open(tampered, password: 'correct horse'),
        throwsA(isA<BackupWrongPassword>()),
      );
    });

    test('tampering with the ciphertext is detected', () async {
      final envelope =
          jsonDecode(utf8.decode(await make(sample()))) as Map<String, Object?>;
      final ct = base64.decode(envelope['ciphertext']! as String);
      ct[10] ^= 0x01;
      envelope['ciphertext'] = base64.encode(ct);
      final tampered = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
      expect(
        () => BackupFile.open(tampered, password: 'correct horse'),
        throwsA(isA<BackupWrongPassword>()),
      );
    });

    test('other files are not recognised', () async {
      expect(
        () => BackupFile.open(
          Uint8List.fromList(utf8.encode('Date,Amount\n')),
          password: 'x',
        ),
        throwsA(isA<BackupNotRecognized>()),
      );
      expect(
        () => BackupFile.open(
          Uint8List.fromList(utf8.encode('{"format":"zip"}')),
          password: 'x',
        ),
        throwsA(isA<BackupNotRecognized>()),
      );
    });

    test('a file from a newer app version asks to update', () async {
      final envelope =
          jsonDecode(utf8.decode(await make(sample()))) as Map<String, Object?>;
      envelope['version'] = 99;
      expect(
        () => BackupFile.open(
          Uint8List.fromList(utf8.encode(jsonEncode(envelope))),
          password: 'correct horse',
        ),
        throwsA(isA<BackupTooNew>()),
      );
    });

    test('refuses hostile Argon2 settings instead of hanging', () async {
      final envelope =
          jsonDecode(utf8.decode(await make(sample()))) as Map<String, Object?>;
      (envelope['kdf']! as Map)['memoryKiB'] = 1 << 30;
      expect(
        () => BackupFile.open(
          Uint8List.fromList(utf8.encode(jsonEncode(envelope))),
          password: 'correct horse',
        ),
        throwsA(isA<BackupDamaged>()),
      );
    });

    test('the real default uses the OWASP Argon2id baseline', () {
      expect(BackupFile.defaultKdf.memoryKiB, 19456);
      expect(BackupFile.defaultKdf.iterations, 2);
      expect(BackupFile.defaultKdf.parallelism, 1);
    });
  });

  group('restore', () {
    test(
      'restoring replaces everything, turns App lock off, and persists',
      () async {
        final backup = await make(sample());

        final repo = BudgetRepository(SteadyDatabase(NativeDatabase.memory()));
        addTearDown(repo.close);
        final pins = MemoryKeyVault('1111');
        final store = BudgetStore.fromSnapshot(
          await repo.load(),
          clock: () => oct2,
          repository: repo,
          pinVault: pins,
          pin: '1111',
        );
        store.addEntry(
          Entry(
            id: 'mine',
            type: EntryType.spend,
            amountCents: 999,
            localDate: oct2,
            createdAtUtc: DateTime.utc(2026),
            timeZoneId: 'UTC',
            merchant: 'Before restore',
          ),
        );

        final contents = await BackupFile.open(
          backup,
          password: 'correct horse',
        );
        store.restoreFrom(contents.snapshot);
        await store.flush();

        expect(store.entries.any((e) => e.id == 'mine'), isFalse);
        expect(store.dailyNumber.safeToSpendCents, 4620);
        expect(store.settings.appLockEnabled, isFalse);
        expect(pins.value, isNull);

        final reloaded = BudgetStore.fromSnapshot(
          await repo.load(),
          clock: () => oct2,
          repository: repo,
        );
        expect(reloaded.entries.length, contents.snapshot.entries.length);
        expect(reloaded.dailyNumber.safeToSpendCents, 4620);
      },
    );
  });

  group('CSV export', () {
    test('one row per entry, signed amounts, newest first', () {
      final csv = entriesToCsv(sample());
      final lines = csv.trimRight().split('\r\n');
      expect(lines.first, startsWith('Date,Type,Amount,Currency'));
      expect(lines.length, sample().entries.length + 1);
      expect(lines[1], startsWith('2026-10-02,'));
      expect(csv, contains('Spend,-5.40,USD,Corner coffee,Food,Tired'));
      expect(csv, contains('Income,640.00,USD,Client payment,,,,,,Deposit,'));
      expect(csv, contains(',Rent,Bills & subs,,Yes,,,,Rent'));
    });

    test('quotes commas and quotes, and neutralises spreadsheet formulas', () {
      final s = sample();
      final tricky = BudgetSnapshot(
        settings: s.settings,
        plan: s.plan,
        categories: s.categories,
        entries: [
          Entry(
            id: 'x',
            type: EntryType.spend,
            amountCents: 100,
            localDate: oct2,
            createdAtUtc: DateTime.utc(2026),
            timeZoneId: 'UTC',
            merchant: '=HYPERLINK("http://evil","click")',
            note: 'Tea, "the good one"',
          ),
        ],
        bills: const [],
        goals: const [],
        vault: s.vault,
        overspendDecisions: const {},
      );
      final row = entriesToCsv(tricky).split('\r\n')[1];
      expect(row, contains('"\'=HYPERLINK(""http://evil"",""click"")"'));
      expect(row, contains('"Tea, ""the good one"""'));
      expect(row, contains(',-1.00,')); // numbers are left alone
    });
  });
}
