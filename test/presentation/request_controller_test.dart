import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/utils/script_executor.dart';
import 'package:xolo/presentation/providers/request_provider.dart';

void main() {
  group('RequestController script delegation', () {
    late ProviderContainer container;
    late RequestController controller;

    setUp(() {
      container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(Dio())],
      );
      controller = container.read(requestControllerProvider('test-tab'));
    });

    tearDown(() {
      container.dispose();
    });

    test('testScripts delegates to ScriptExecutor.testPostScripts', () {
      const scriptsJson = r'[{"key":"id","path":"$.data.id"}]';
      final response = {
        'data': {'id': 42},
      };

      final viaController = controller.testScripts(response, scriptsJson);
      final viaExecutor = ScriptExecutor.testPostScripts(response, scriptsJson);

      expect(viaController, viaExecutor);
      expect(viaController, {'id': '42'});
    });

    test('testScripts returns empty map for empty scripts json', () {
      expect(controller.testScripts({'ok': true}, ''), isEmpty);
    });
  });
}
