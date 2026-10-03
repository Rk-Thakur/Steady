import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';
import 'database_key.dart';

/// File name of the encrypted database inside the app's support directory.
const databaseFileName = 'steady.sqlite';

/// Opens [file] as an SQLCipher database with a raw 256-bit [hexKey].
///
/// Raw keys (`x'…'`) skip SQLCipher's password-stretching, which is right for
/// a random key from secure storage and keeps app launch fast.
QueryExecutor openEncryptedExecutor(
  File file,
  String hexKey, {
  bool background = true,
}) {
  if (!isValidDatabaseKey(hexKey)) {
    throw ArgumentError('Database key must be 64 hex characters');
  }
  void setup(Database raw) => applyDatabaseKey(raw, hexKey);
  return background
      ? NativeDatabase.createInBackground(file, setup: setup)
      : NativeDatabase(file, setup: setup);
}

/// Keys a freshly opened connection and fails fast if something is wrong.
void applyDatabaseKey(Database raw, String hexKey) {
  // Refuse to run on plain SQLite: the key pragma would be silently ignored
  // and data written unencrypted.
  final cipher = raw.select('PRAGMA cipher_version');
  if (cipher.isEmpty ||
      (cipher.first.values.first as String?)?.isEmpty != false) {
    throw StateError(
      'SQLCipher is not available; refusing to open an unencrypted database',
    );
  }
  raw.execute("PRAGMA key = \"x'$hexKey'\"");
  // Touch the schema so a wrong key fails here ("file is not a database")
  // rather than on some later query.
  raw.select('SELECT count(*) FROM sqlite_master');
}

/// Opens Steady's database on the device: finds (or creates) the key in
/// secure storage, then opens the encrypted file.
///
/// Throws [DatabaseKeyLostException] if the file exists but the key doesn't.
Future<SteadyDatabase> openSteadyDatabase({
  KeyVault? vault,
  Directory? directory,
}) async {
  final dir = directory ?? await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final file = File(p.join(dir.path, databaseFileName));
  final key = await obtainDatabaseKey(
    vault ?? SecureKeyVault(),
    databaseExists: file.existsSync(),
  );
  final db = SteadyDatabase(openEncryptedExecutor(file, key));
  // Open now, so a bad key or missing SQLCipher surfaces at launch.
  await db.customSelect('SELECT 1').get();
  return db;
}

/// "Start over" after [DatabaseKeyLostException]: removes the unreadable file
/// and its key so the next [openSteadyDatabase] creates a fresh one.
Future<void> resetSteadyDatabase({
  KeyVault? vault,
  Directory? directory,
}) async {
  final dir = directory ?? await getApplicationSupportDirectory();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File(p.join(dir.path, '$databaseFileName$suffix'));
    if (f.existsSync()) await f.delete();
  }
  await (vault ?? SecureKeyVault()).delete();
}
