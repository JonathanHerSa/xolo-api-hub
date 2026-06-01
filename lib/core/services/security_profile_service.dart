import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/presentation/providers/database_providers.dart';

enum SecurityProfile { standard, hardened, paranoid }

class SecurityPolicy {
  const SecurityPolicy({
    required this.profile,
    required this.hideSensitiveValues,
    required this.autoLockOnResume,
    required this.recommendedLockDelaySeconds,
    required this.confirmBeforeExport,
  });

  final SecurityProfile profile;
  final bool hideSensitiveValues;
  final bool autoLockOnResume;
  final int recommendedLockDelaySeconds;
  final bool confirmBeforeExport;
}

class SecurityProfileService {
  static const String _profileSettingKey = 'security_profile';

  SecurityProfileService(this._ref);

  final Ref _ref;

  Future<SecurityProfile> getProfile() async {
    final db = _ref.read(xoloRepositoryProvider);
    final value = await db.getSetting(_profileSettingKey);
    return _parseProfile(value);
  }

  Future<void> setProfile(SecurityProfile profile) async {
    final db = _ref.read(xoloRepositoryProvider);
    await db.setSetting(_profileSettingKey, profile.name);
  }

  SecurityPolicy policyFor(SecurityProfile profile) {
    return switch (profile) {
      SecurityProfile.standard => const SecurityPolicy(
        profile: SecurityProfile.standard,
        hideSensitiveValues: false,
        autoLockOnResume: false,
        recommendedLockDelaySeconds: 30,
        confirmBeforeExport: false,
      ),
      SecurityProfile.hardened => const SecurityPolicy(
        profile: SecurityProfile.hardened,
        hideSensitiveValues: true,
        autoLockOnResume: true,
        recommendedLockDelaySeconds: 15,
        confirmBeforeExport: true,
      ),
      SecurityProfile.paranoid => const SecurityPolicy(
        profile: SecurityProfile.paranoid,
        hideSensitiveValues: true,
        autoLockOnResume: true,
        recommendedLockDelaySeconds: 0,
        confirmBeforeExport: true,
      ),
    };
  }

  SecurityProfile _parseProfile(String? value) {
    return switch (value) {
      'hardened' => SecurityProfile.hardened,
      'paranoid' => SecurityProfile.paranoid,
      _ => SecurityProfile.standard,
    };
  }
}

final securityProfileServiceProvider = Provider<SecurityProfileService>((ref) {
  return SecurityProfileService(ref);
});

final securityProfileProvider = FutureProvider<SecurityProfile>((ref) async {
  return ref.read(securityProfileServiceProvider).getProfile();
});

final securityPolicyProvider = FutureProvider<SecurityPolicy>((ref) async {
  final service = ref.read(securityProfileServiceProvider);
  final profile = await service.getProfile();
  return service.policyFor(profile);
});
