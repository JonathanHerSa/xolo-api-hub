import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/presentation/providers/database_providers.dart';

class AppConfig {
  const AppConfig({
    required this.schemaVersion,
    required this.themeModeDefault,
    required this.allowAbsoluteUrl,
    required this.featureFlags,
  });

  final int schemaVersion;
  final ThemeMode themeModeDefault;
  final bool allowAbsoluteUrl;
  final Map<String, bool> featureFlags;

  factory AppConfig.defaults() {
    return const AppConfig(
      schemaVersion: 1,
      themeModeDefault: ThemeMode.dark,
      allowAbsoluteUrl: true,
      featureFlags: {'oauth_pkce': true, 'secure_backup_v2': true},
    );
  }

  AppConfig merge(AppConfig override) {
    return AppConfig(
      schemaVersion: override.schemaVersion,
      themeModeDefault: override.themeModeDefault,
      allowAbsoluteUrl: override.allowAbsoluteUrl,
      featureFlags: {...featureFlags, ...override.featureFlags},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'themeModeDefault': themeModeDefault.name,
      'allowAbsoluteUrl': allowAbsoluteUrl,
      'featureFlags': featureFlags,
    };
  }

  static AppConfig fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    final themeModeDefault = json['themeModeDefault'];
    final allowAbsoluteUrl = json['allowAbsoluteUrl'];
    final featureFlags = json['featureFlags'];

    if (schemaVersion is! int ||
        themeModeDefault is! String ||
        allowAbsoluteUrl is! bool ||
        featureFlags is! Map<String, dynamic>) {
      throw const FormatException('Invalid AppConfig payload');
    }

    return AppConfig(
      schemaVersion: schemaVersion,
      themeModeDefault: _themeModeFromString(themeModeDefault),
      allowAbsoluteUrl: allowAbsoluteUrl,
      featureFlags: featureFlags.map(
        (key, value) => MapEntry(key, value == true),
      ),
    );
  }

  static ThemeMode _themeModeFromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}

const appConfigSettingKey = 'app_config_runtime';
const appConfigUserOverrideSettingKey = 'app_config_user_override';

final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  final db = ref.read(xoloRepositoryProvider);
  final defaults = AppConfig.defaults();

  final runtimeJson = await db.getSetting(appConfigSettingKey);
  final userJson = await db.getSetting(appConfigUserOverrideSettingKey);

  AppConfig effective = defaults;
  if (runtimeJson != null && runtimeJson.isNotEmpty) {
    effective = effective.merge(
      AppConfig.fromJson(jsonDecode(runtimeJson) as Map<String, dynamic>),
    );
  }
  if (userJson != null && userJson.isNotEmpty) {
    effective = effective.merge(
      AppConfig.fromJson(jsonDecode(userJson) as Map<String, dynamic>),
    );
  }
  return effective;
});
