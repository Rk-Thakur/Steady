import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the database key is kept. The real one is the iOS Keychain /
/// Android Keystore; tests use [MemoryKeyVault].
abstract interface class KeyVault {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

/// The database key in the platform's secure storage (Handoff 4: "Key stored
/// in iOS Keychain / Android Keystore").
class SecureKeyVault implements KeyVault {
  /// The database key.
  SecureKeyVault([FlutterSecureStorage? storage])
    : this._(_databaseKey, storage);

  /// The App lock PIN (kept out of the database, Handoff 4).
  SecureKeyVault.pin([FlutterSecureStorage? storage])
    : this._(_pinKey, storage);

  SecureKeyVault._(this._name, FlutterSecureStorage? storage)
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Never synced to iCloud Keychain and never restored to another
            // device: moving data is what the .steady backup file is for.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
            // The plugin's standard mode: AES-GCM data, key wrapped by the
            // hardware Keystore. Not the AES-GCM *key* cipher: in v11 that
            // mode goes through BiometricPrompt, which fails without
            // USE_BIOMETRIC and would ask for a fingerprint on every launch.
            // Don't silently wipe keys on a read error: that would make the
            // database unreadable for good.
            aOptions: AndroidOptions(resetOnError: false),
          );

  static const _databaseKey = 'steady.database_key.v1';
  static const _pinKey = 'steady.app_lock_pin.v1';
  final String _name;
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String value) => _storage.write(key: _name, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _name);
}

class MemoryKeyVault implements KeyVault {
  MemoryKeyVault([this.value]);
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

/// The database exists but its key is gone (e.g. the app's data was restored
/// to a new phone from a device backup, which never carries the key). The
/// data can't be decrypted; the user can restore a .steady file or start over.
class DatabaseKeyLostException implements Exception {
  const DatabaseKeyLostException();

  @override
  String toString() =>
      'DatabaseKeyLostException: the database key is missing from secure storage';
}

/// A 256-bit key as 64 lowercase hex characters (SQLCipher raw key format).
String generateDatabaseKey([Random? random]) {
  final r = random ?? Random.secure();
  return List.generate(
    32,
    (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

final _hexKey = RegExp(r'^[0-9a-f]{64}$');
bool isValidDatabaseKey(String key) => _hexKey.hasMatch(key);

/// Returns the database key, creating and storing one on first launch.
///
/// If a database file already exists but no key is stored, throws
/// [DatabaseKeyLostException] instead of creating a new key, which would never
/// open the existing file.
Future<String> obtainDatabaseKey(
  KeyVault vault, {
  required bool databaseExists,
}) async {
  final existing = await vault.read();
  if (existing != null) {
    if (!isValidDatabaseKey(existing)) {
      throw StateError('Stored database key is malformed');
    }
    return existing;
  }
  if (databaseExists) throw const DatabaseKeyLostException();

  final key = generateDatabaseKey();
  await vault.write(key);
  // Read it back: never create a database with a key we failed to store.
  if (await vault.read() != key) {
    throw StateError('Could not save the database key to secure storage');
  }
  return key;
}
