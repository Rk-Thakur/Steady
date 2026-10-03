import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database.dart';
import 'package:steady/data/db/database_key.dart';
import 'package:steady/data/db/open_database.dart';

/// Handoff 4: "Local database on the device, encrypted at rest (SQLite with
/// SQLCipher). Key stored in iOS Keychain / Android Keystore."
void main() {
  late Directory dir;
  late File file;
  final key = generateDatabaseKey();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('steady_enc');
    file = File('${dir.path}/$databaseFileName');
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> writeSample(String hexKey) async {
    final repo = BudgetRepository(
      SteadyDatabase(openEncryptedExecutor(file, hexKey, background: false)),
    );
    await repo.replaceAll(
      BudgetStore.sample(clock: () => const LocalDate(2026, 10, 2))
          .toSnapshot(),
    );
    await repo.close();
  }

  test('the file on disk has no SQLite header and no readable text', () async {
    await writeSample(key);
    final bytes = file.readAsBytesSync();
    expect(bytes.length, greaterThan(4096));
    // Plain SQLite files start with "SQLite format 3\0".
    expect(
      ascii.decode(bytes.sublist(0, 15), allowInvalid: true),
      isNot('SQLite format 3'),
    );
    // Merchant names and amounts from the sample must not appear in clear.
    final text = latin1.decode(bytes);
    for (final secret in [
      'Corner coffee',
      'Gas station',
      'Emergency fund',
      'Alex',
      'entries',
    ]) {
      expect(
        text.contains(secret),
        isFalse,
        reason: '"$secret" is readable in the file',
      );
    }
  });

  test('control: the same data in a plain SQLite file IS readable', () async {
    // Proves the check above would catch plaintext.
    final plain = sqlite3.open('${dir.path}/plain.db');
    plain.execute(
      "CREATE TABLE t(x TEXT); INSERT INTO t VALUES ('Corner coffee')",
    );
    plain.close();
    final bytes = File('${dir.path}/plain.db').readAsBytesSync();
    expect(ascii.decode(bytes.sublist(0, 15)), 'SQLite format 3');
    expect(latin1.decode(bytes).contains('Corner coffee'), isTrue);
  });

  test('without the key the file cannot be read', () async {
    await writeSample(key);
    final raw = sqlite3.open(file.path);
    addTearDown(raw.close);
    expect(
      () => raw.select('SELECT * FROM entries'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a wrong key is rejected when opening', () async {
    await writeSample(key);
    final raw = sqlite3.open(file.path);
    addTearDown(raw.close);
    expect(
      () => applyDatabaseKey(raw, generateDatabaseKey()),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the right key reads everything back', () async {
    await writeSample(key);
    final repo = BudgetRepository(
      SteadyDatabase(openEncryptedExecutor(file, key, background: false)),
    );
    addTearDown(repo.close);
    final s = await repo.load();
    expect(s.entries.map((e) => e.merchant), contains('Corner coffee'));
  });

  test('rejects keys that are not 64 hex characters', () {
    expect(
      () => openEncryptedExecutor(file, 'password123'),
      throwsArgumentError,
    );
    expect(() => openEncryptedExecutor(file, 'G' * 64), throwsArgumentError);
  });

  group('key management', () {
    test('first launch creates a random 256-bit key and stores it', () async {
      final vault = MemoryKeyVault();
      final k = await obtainDatabaseKey(vault, databaseExists: false);
      expect(isValidDatabaseKey(k), isTrue);
      expect(vault.value, k);
    });

    test('later launches reuse the stored key', () async {
      final vault = MemoryKeyVault();
      final first = await obtainDatabaseKey(vault, databaseExists: false);
      final second = await obtainDatabaseKey(vault, databaseExists: true);
      expect(second, first);
    });

    test('keys are random', () {
      expect(generateDatabaseKey(), isNot(generateDatabaseKey()));
    });

    test(
      'a database without its key is reported, not silently replaced',
      () async {
        expect(
          () => obtainDatabaseKey(MemoryKeyVault(), databaseExists: true),
          throwsA(isA<DatabaseKeyLostException>()),
        );
      },
    );

    test('openSteadyDatabase: create, reopen, then lose the key', () async {
      final vault = MemoryKeyVault();
      var db = await openSteadyDatabase(vault: vault, directory: dir);
      await BudgetRepository(db).replaceAll(
        BudgetStore.sample(clock: () => const LocalDate(2026, 10, 2))
            .toSnapshot(),
      );
      await db.close();

      db = await openSteadyDatabase(vault: vault, directory: dir);
      expect((await BudgetRepository(db).load()).entries, isNotEmpty);
      await db.close();

      await vault.delete();
      expect(
        () => openSteadyDatabase(vault: vault, directory: dir),
        throwsA(isA<DatabaseKeyLostException>()),
      );
    });

    test('start over after a lost key gives a fresh, empty database', () async {
      final vault = MemoryKeyVault();
      final db = await openSteadyDatabase(vault: vault, directory: dir);
      await BudgetRepository(db).replaceAll(
        BudgetStore.sample(clock: () => const LocalDate(2026, 10, 2))
            .toSnapshot(),
      );
      await db.close();
      await vault.delete();

      await resetSteadyDatabase(vault: vault, directory: dir);
      final fresh = await openSteadyDatabase(vault: vault, directory: dir);
      addTearDown(fresh.close);
      expect((await BudgetRepository(fresh).load()).isFresh, isTrue);
    });
  });
}
