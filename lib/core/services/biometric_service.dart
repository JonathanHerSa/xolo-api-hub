import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:xolo/core/config/secure_storage.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/utils/boolean_notifier.dart';

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

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    if (_isAuthenticating) return false;

    try {
      if (!await isAvailable) {
        AppLogger.warn('Biometric auth unavailable on this device');
        return false;
      }

      _isAuthenticating = true;
      final result = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
      return result;
    } on PlatformException catch (e) {
      AppLogger.warn('Biometric error: $e');
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> cancelAuthentication() async {
    await _auth.stopAuthentication();
    _isAuthenticating = false;
  }

  final _storage = kSecureStorage;
  static const _kBiometricEnabledKey = 'biometric_enabled';

  Future<bool> getBiometricEnabled() async {
    final val = await _storage.read(key: _kBiometricEnabledKey);
    return val == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _kBiometricEnabledKey, value: enabled.toString());
  }

  /// Disables lock when the device cannot run local auth (e.g. Linux desktop).
  Future<bool> disableIfUnavailable() async {
    if (await isAvailable) return false;
    if (!await getBiometricEnabled()) return false;
    await setBiometricEnabled(false);
    AppLogger.warn('Biometric lock disabled: device auth unavailable');
    return true;
  }

  /// Whether the app should show the lock overlay on cold start.
  Future<bool> shouldLockOnColdStart() async {
    if (!await getBiometricEnabled()) return false;
    if (!await isAvailable) {
      await setBiometricEnabled(false);
      return false;
    }
    return true;
  }

  static const _kLockDelayKey = 'lock_delay';
  DateTime? _backgroundedTime;

  void markAppBackgrounded() {
    _backgroundedTime = DateTime.now();
  }

  Future<bool> shouldLockApp({int? forceDelaySeconds}) async {
    final enabled = await getBiometricEnabled();
    if (!enabled) return false;
    if (!await isAvailable) {
      await setBiometricEnabled(false);
      return false;
    }
    if (_backgroundedTime == null) return false;

    final diff = DateTime.now().difference(_backgroundedTime!);
    final delaySeconds = forceDelaySeconds ?? await getLockDelay();
    final result = diff.inSeconds >= delaySeconds;
    _backgroundedTime = null;
    return result;
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

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isAvailable;
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final isAppLockedProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
