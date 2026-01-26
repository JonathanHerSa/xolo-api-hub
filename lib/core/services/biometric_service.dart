import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/boolean_notifier.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isAvailable async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // options parameter seems to cause issues or requires specific version match.
        // Using defaults for now.
      );
    } on PlatformException catch (e) {
      // Handle error or return false
      print('Biometric error: $e');
      return false;
    }
  }

  Future<void> cancelAuthentication() async {
    await _auth.stopAuthentication();
  }

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _kBiometricEnabledKey = 'biometric_enabled';

  Future<bool> getBiometricEnabled() async {
    final val = await _storage.read(key: _kBiometricEnabledKey);
    return val == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _kBiometricEnabledKey, value: enabled.toString());
  }

  // --- Lock Delay Logic ---
  static const _kLockDelayKey = 'lock_delay';
  DateTime? _backgroundedTime;

  /// Called when app goes to background (Paused/Inactive)
  void markAppBackgrounded() {
    _backgroundedTime = DateTime.now();
  }

  /// Called when app resumes. Returns true if we should lock.
  Future<bool> shouldLockApp() async {
    final enabled = await getBiometricEnabled();
    if (!enabled) return false;

    // specific logic: if _backgroundedTime is null, it might be first launch or logic error.
    // But Cold Start is handled in main.dart manually.
    // This is for Resume. If null, maybe we shouldn't lock? Or secure default?
    // If null, it means we didn't track pause. Assume no lock needed (or user didn't pause).
    if (_backgroundedTime == null) return false;

    final diff = DateTime.now().difference(_backgroundedTime!);
    final delaySecondsStr = await _storage.read(key: _kLockDelayKey);
    final delaySeconds =
        int.tryParse(delaySecondsStr ?? '30') ?? 30; // Default 30s

    return diff.inSeconds >= delaySeconds;
  }

  Future<void> setLockDelay(int seconds) async {
    await _storage.write(key: _kLockDelayKey, value: seconds.toString());
  }

  Future<int> getLockDelay() async {
    final val = await _storage.read(key: _kLockDelayKey);
    return int.tryParse(val ?? '30') ?? 30;
  }
}

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.getBiometricEnabled();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

// State provider to track if the app is currently locked
final isAppLockedProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
