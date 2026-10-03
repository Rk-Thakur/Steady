import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/data/db/budget_repository.dart';
import 'package:steady/data/db/database_key.dart';
import 'package:steady/data/db/open_database.dart';

/// Runs on a real simulator/device: the real Keychain/Keystore and the
/// bundled SQLCipher library.
///   `flutter test integration_test/encryption_on_device_test.dart -d DEVICE_ID`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('encrypted database with its key in secure storage', (
    tester,
  ) async {
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'steady_it'),
    );
    final vault = SecureKeyVault();
    await resetSteadyDatabase(vault: vault, directory: dir);

    // First launch: key is created in the Keychain/Keystore.
    var db = await openSteadyDatabase(vault: vault, directory: dir);
    final key = await vault.read();
    expect(key, isNotNull);
    expect(isValidDatabaseKey(key!), isTrue);
    await BudgetRepository(db).replaceAll(
      BudgetStore.sample(clock: () => const LocalDate(2026, 10, 2))
          .toSnapshot(),
    );
    await db.close();

    // The file on disk is ciphertext.
    final bytes = File(p.join(dir.path, databaseFileName)).readAsBytesSync();
    expect(
      ascii.decode(bytes.sublist(0, 15), allowInvalid: true),
      isNot('SQLite format 3'),
    );
    expect(latin1.decode(bytes).contains('Corner coffee'), isFalse);

    // Next launch: same key from secure storage opens it.
    db = await openSteadyDatabase(vault: vault, directory: dir);
    final s = await BudgetRepository(db).load();
    expect(s.entries.map((e) => e.merchant), contains('Corner coffee'));
    await db.close();

    await resetSteadyDatabase(vault: vault, directory: dir);
    expect(await vault.read(), isNull);
  });
}
