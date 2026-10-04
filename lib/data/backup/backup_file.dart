import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../db/budget_repository.dart';
import 'backup_codec.dart';

/// The `.steady` backup file (Handoff 4): versioned JSON, encrypted with
/// AES-256-GCM under a key derived from the user's password with Argon2id.
///
/// The file is a small JSON envelope:
/// ```json
/// { "format": "steady-backup", "version": 1, "createdAt": "…",
///   "kdf":    { "name": "argon2id", "memoryKiB": 19456, "iterations": 2,
///               "parallelism": 1, "salt": "<base64>" },
///   "cipher": { "name": "aes-256-gcm", "nonce": "<base64>" },
///   "ciphertext": "<base64>", "mac": "<base64>" }
/// ```
/// Everything except `ciphertext` and `mac` is authenticated as associated
/// data, so tampering with the KDF settings or dates fails decryption.
abstract final class BackupFile {
  static const format = 'steady-backup';
  static const version = 1;
  static const extension = 'steady';

  /// OWASP's Argon2id baseline: 19 MiB, 2 passes, 1 lane.
  static const defaultKdf = KdfParams(
    memoryKiB: 19456,
    iterations: 2,
    parallelism: 1,
  );

  static const minPasswordLength = 8;

  /// Encrypts [snapshot] with [password]. Runs off the UI thread.
  static Future<Uint8List> create(
    BudgetSnapshot snapshot, {
    required String password,
    required DateTime createdAt,
    int databaseSchema = 2,
    KdfParams kdf = defaultKdf,
  }) {
    final plaintext = jsonEncode({
      'app': 'Steady',
      'databaseSchema': databaseSchema,
      'data': BackupCodec.encode(snapshot),
    });
    final created = createdAt.toUtc().toIso8601String();
    return Isolate.run(() => _encrypt(plaintext, password, created, kdf));
  }

  /// Decrypts and decodes a backup file. Runs off the UI thread.
  ///
  /// Throws [BackupNotRecognized], [BackupTooNew], [BackupWrongPassword] or
  /// [BackupDamaged].
  static Future<BackupContents> open(
    Uint8List bytes, {
    required String password,
  }) async {
    final envelope = _readEnvelope(bytes);
    final plaintext = await Isolate.run(() => _decrypt(envelope, password));
    try {
      final body = jsonDecode(plaintext) as Map<String, Object?>;
      return BackupContents(
        createdAt: DateTime.parse(envelope.header.createdAt),
        snapshot: BackupCodec.decode(body['data']! as Map<String, Object?>),
      );
    } catch (_) {
      throw const BackupDamaged();
    }
  }

  // ─── Internals (run in an isolate) ───────────────────────────────────────

  static Future<Uint8List> _encrypt(
    String plaintext,
    String password,
    String createdAt,
    KdfParams kdf,
  ) async {
    final rng = Random.secure();
    final salt = List<int>.generate(16, (_) => rng.nextInt(256));
    final nonce = List<int>.generate(12, (_) => rng.nextInt(256));
    final header = _Header(
      createdAt: createdAt,
      kdf: kdf,
      salt: salt,
      nonce: nonce,
    );
    final key = await _deriveKey(password, kdf, salt);
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
      aad: header.associatedData,
    );
    return utf8.encode(
      jsonEncode({
        ...header.toJson(),
        'ciphertext': base64.encode(box.cipherText),
        'mac': base64.encode(box.mac.bytes),
      }),
    );
  }

  static Future<String> _decrypt(_Envelope e, String password) async {
    final key = await _deriveKey(password, e.header.kdf, e.header.salt);
    try {
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(e.ciphertext, nonce: e.header.nonce, mac: Mac(e.mac)),
        secretKey: key,
        aad: e.header.associatedData,
      );
      return utf8.decode(clear);
    } on SecretBoxAuthenticationError {
      // AES-GCM can't tell a wrong password from a modified file.
      throw const BackupWrongPassword();
    }
  }

  static Future<SecretKey> _deriveKey(
    String password,
    KdfParams kdf,
    List<int> salt,
  ) => Argon2id(
    memory: kdf.memoryKiB,
    iterations: kdf.iterations,
    parallelism: kdf.parallelism,
    hashLength: 32,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  static _Envelope _readEnvelope(Uint8List bytes) {
    final Map<String, Object?> j;
    try {
      j = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    } catch (_) {
      throw const BackupNotRecognized();
    }
    if (j['format'] != format) throw const BackupNotRecognized();
    final v = j['version'];
    if (v is! int) throw const BackupNotRecognized();
    if (v > version) throw const BackupTooNew();
    try {
      final kdf = j['kdf']! as Map<String, Object?>;
      final cipher = j['cipher']! as Map<String, Object?>;
      if (kdf['name'] != 'argon2id' || cipher['name'] != 'aes-256-gcm') {
        throw const BackupNotRecognized();
      }
      final params = KdfParams(
        memoryKiB: kdf['memoryKiB']! as int,
        iterations: kdf['iterations']! as int,
        parallelism: kdf['parallelism']! as int,
      );
      // Refuse absurd settings in a hostile file (would hang or exhaust memory).
      if (params.memoryKiB > 1 << 20 ||
          params.iterations > 64 ||
          params.parallelism > 16) {
        throw const BackupDamaged();
      }
      return _Envelope(
        header: _Header(
          createdAt: j['createdAt']! as String,
          kdf: params,
          salt: base64.decode(kdf['salt']! as String),
          nonce: base64.decode(cipher['nonce']! as String),
        ),
        ciphertext: base64.decode(j['ciphertext']! as String),
        mac: base64.decode(j['mac']! as String),
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupDamaged();
    }
  }
}

@immutable
class KdfParams {
  const KdfParams({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
  });
  final int memoryKiB;
  final int iterations;
  final int parallelism;
}

/// What a backup file holds, after decryption.
@immutable
class BackupContents {
  const BackupContents({required this.createdAt, required this.snapshot});
  final DateTime createdAt;
  final BudgetSnapshot snapshot;
}

sealed class BackupException implements Exception {
  const BackupException();
  String get message;

  @override
  String toString() => message;
}

class BackupNotRecognized extends BackupException {
  const BackupNotRecognized();
  @override
  String get message => "This isn't a Steady backup file.";
}

class BackupTooNew extends BackupException {
  const BackupTooNew();
  @override
  String get message =>
      'This backup was made by a newer version of Steady. Update the app, then try again.';
}

class BackupWrongPassword extends BackupException {
  const BackupWrongPassword();
  @override
  String get message =>
      "That password doesn't open this file. Check it and try again.";
}

class BackupDamaged extends BackupException {
  const BackupDamaged();
  @override
  String get message => 'This backup file is damaged and can\'t be restored.';
}

class _Header {
  _Header({
    required this.createdAt,
    required this.kdf,
    required this.salt,
    required this.nonce,
  });
  final String createdAt;
  final KdfParams kdf;
  final List<int> salt;
  final List<int> nonce;

  Map<String, Object?> toJson() => {
    'format': BackupFile.format,
    'version': BackupFile.version,
    'createdAt': createdAt,
    'kdf': {
      'name': 'argon2id',
      'memoryKiB': kdf.memoryKiB,
      'iterations': kdf.iterations,
      'parallelism': kdf.parallelism,
      'salt': base64.encode(salt),
    },
    'cipher': {'name': 'aes-256-gcm', 'nonce': base64.encode(nonce)},
  };

  /// The header in a fixed key order, authenticated alongside the data.
  List<int> get associatedData => utf8.encode(jsonEncode(toJson()));
}

class _Envelope {
  _Envelope({
    required this.header,
    required this.ciphertext,
    required this.mac,
  });
  final _Header header;
  final List<int> ciphertext;
  final List<int> mac;
}
