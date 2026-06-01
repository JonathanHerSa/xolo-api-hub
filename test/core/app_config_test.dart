import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/config/app_config.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

void main() {
  group('AppConfig', () {
    test('defaults has expected baseline', () {
      final config = AppConfig.defaults();
      expect(config.schemaVersion, 1);
      expect(config.themeModeDefault, ThemeMode.dark);
      expect(config.allowAbsoluteUrl, isTrue);
      expect(config.featureFlags['oauth_pkce'], isTrue);
    });

    test('parses valid config payload', () {
      final config = AppConfig.fromJson({
        'schemaVersion': 1,
        'themeModeDefault': 'system',
        'allowAbsoluteUrl': false,
        'featureFlags': {'test_flag': true},
      });

      expect(config.schemaVersion, 1);
      expect(config.themeModeDefault, ThemeMode.system);
      expect(config.allowAbsoluteUrl, isFalse);
      expect(config.featureFlags['test_flag'], isTrue);
    });

    test('parses light and dark theme modes', () {
      expect(
        AppConfig.fromJson({
          'schemaVersion': 1,
          'themeModeDefault': 'light',
          'allowAbsoluteUrl': true,
          'featureFlags': <String, dynamic>{},
        }).themeModeDefault,
        ThemeMode.light,
      );
      expect(
        AppConfig.fromJson({
          'schemaVersion': 1,
          'themeModeDefault': 'unknown',
          'allowAbsoluteUrl': true,
          'featureFlags': <String, dynamic>{},
        }).themeModeDefault,
        ThemeMode.dark,
      );
    });

    test('throws on invalid payload', () {
      expect(
        () => AppConfig.fromJson({'schemaVersion': 'bad'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips core fields', () {
      final config = AppConfig.fromJson({
        'schemaVersion': 2,
        'themeModeDefault': 'light',
        'allowAbsoluteUrl': false,
        'featureFlags': {'flag': false},
      });
      final json = config.toJson();
      expect(json['schemaVersion'], 2);
      expect(json['themeModeDefault'], 'light');
      expect(json['allowAbsoluteUrl'], isFalse);
      expect(json['featureFlags'], {'flag': false});
    });

    test('merge overrides base values', () {
      final base = AppConfig.defaults();
      final override = AppConfig.fromJson({
        'schemaVersion': 1,
        'themeModeDefault': 'light',
        'allowAbsoluteUrl': true,
        'featureFlags': {'oauth_pkce': false, 'new_feature': true},
      });

      final merged = base.merge(override);
      expect(merged.themeModeDefault, ThemeMode.light);
      expect(merged.featureFlags['oauth_pkce'], isFalse);
      expect(merged.featureFlags['new_feature'], isTrue);
    });
  });

  group('appConfigProvider', () {
    test('merges runtime and user overrides from settings', () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final repo = DriftXoloRepository(db);

      await repo.setSetting(
        appConfigSettingKey,
        jsonEncode({
          'schemaVersion': 1,
          'themeModeDefault': 'system',
          'allowAbsoluteUrl': false,
          'featureFlags': {'runtime_flag': true},
        }),
      );
      await repo.setSetting(
        appConfigUserOverrideSettingKey,
        jsonEncode({
          'schemaVersion': 1,
          'themeModeDefault': 'light',
          'allowAbsoluteUrl': true,
          'featureFlags': {'user_flag': true},
        }),
      );

      final container = ProviderContainer(
        overrides: [xoloRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final config = await container.read(appConfigProvider.future);
      expect(config.themeModeDefault, ThemeMode.light);
      expect(config.allowAbsoluteUrl, isTrue);
      expect(config.featureFlags['runtime_flag'], isTrue);
      expect(config.featureFlags['user_flag'], isTrue);
      expect(config.featureFlags['oauth_pkce'], isTrue);
    });
  });
}
