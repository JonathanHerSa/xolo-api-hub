import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
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
}
