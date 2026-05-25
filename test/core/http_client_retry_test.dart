import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/network/http_client_provider.dart';

class _FlakyAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls == 1) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'simulated network glitch',
      );
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  test('dio provider retries transient GET errors', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);
    final adapter = _FlakyAdapter();
    dio.httpClientAdapter = adapter;

    final response = await dio.get('https://example.com/ping');

    expect(response.statusCode, 200);
    expect(adapter.calls, 2);
  });
}
