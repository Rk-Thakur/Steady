import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// App lock: unlock with Face ID / Touch ID / fingerprint. The OS does the
/// matching; Steady only learns yes or no. Replaceable in tests; reports
/// "unavailable" until [main] installs [DeviceBiometrics].
abstract class Biometrics {
  static Biometrics instance = const _NoBiometrics();

  /// "Face ID", "Touch ID", "fingerprint" or "face unlock"; null when the
  /// phone has none set up.
  Future<String?> availableName();

  /// True when the phone could unlock with biometrics but none are set up
  /// yet (so Settings can say where to set them up).
  Future<bool> canBeSetUp();

  /// Shows the system prompt. True only if the user was recognised.
  Future<bool> authenticate(String reason);
}

class _NoBiometrics implements Biometrics {
  const _NoBiometrics();

  @override
  Future<String?> availableName() async => null;

  @override
  Future<bool> canBeSetUp() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

class DeviceBiometrics implements Biometrics {
  final _auth = LocalAuthentication();

  @override
  Future<String?> availableName() async {
    try {
      if (!await _auth.isDeviceSupported()) return null;
      final types = await _auth.getAvailableBiometrics();
      if (types.isEmpty) return null;
      final face = types.contains(BiometricType.face);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return face ? 'Face ID' : 'Touch ID';
      }
      final finger =
          types.contains(BiometricType.fingerprint) ||
          types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak);
      return finger ? 'fingerprint' : 'face unlock';
    } catch (e) {
      debugPrint('Steady: biometrics unavailable: $e');
      return null;
    }
  }

  @override
  Future<bool> canBeSetUp() async {
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // The PIN is the fallback, inside Steady; not the phone's passcode.
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      // Cancelled, locked out after too many tries, not enrolled…: the PIN
      // still works, so just say no.
      debugPrint('Steady: biometric unlock failed: ${e.code}');
      return false;
    }
  }
}
