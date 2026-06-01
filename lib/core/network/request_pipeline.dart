import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/services/oauth2_service.dart';
import 'package:xolo/core/utils/variable_parser.dart';

/// Result of a single HTTP request execution.
class RequestOutput {
  const RequestOutput({
    required this.resolvedUrl,
    required this.durationMs,
    this.data,
    this.statusCode,
    this.error,
    this.cancelled = false,
  });

  final dynamic data;
  final int? statusCode;
  final int durationMs;
  final String resolvedUrl;
  final String? error;
  final bool cancelled;
}

/// Shared HTTP execution path for composer and collection runner.
class RequestPipeline {
  RequestPipeline(this._dio, this._oauth2);

  final Dio _dio;
  final OAuth2Service _oauth2;

  Future<RequestOutput> send({
    required String method,
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    Object? body,
    String? authType,
    String? authData,
    int? collectionId,
    required Map<String, String> variables,
    required AuthResolverService authResolver,
    CancelToken? cancelToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    var resolvedUrl = url;

    try {
      final parsedHeaders = <String, dynamic>{};
      if (headers != null) {
        for (final entry in headers.entries) {
          parsedHeaders[VariableParser.parse(entry.key, variables)] =
              VariableParser.parse(entry.value.toString(), variables);
        }
      }

      final resolvedAuth = await authResolver.resolveAuth(
        requestAuthType: authType,
        requestAuthData: authData,
        collectionId: collectionId,
      );

      var effectiveAuthType = resolvedAuth.type;
      var effectiveAuthData = resolvedAuth.data;
      if (effectiveAuthType == 'oauth2' && effectiveAuthData != null) {
        final refreshed = await _oauth2.maybeRefreshOAuth2AuthData(
          effectiveAuthData,
        );
        if (refreshed != null) effectiveAuthData = refreshed;
      }

      _injectAuthHeaders(
        parsedHeaders,
        effectiveAuthType,
        effectiveAuthData,
        variables,
      );

      final parsedParams = <String, dynamic>{};
      if (queryParams != null) {
        for (final entry in queryParams.entries) {
          parsedParams[VariableParser.parse(entry.key, variables)] =
              VariableParser.parse(entry.value.toString(), variables);
        }
      }

      _injectAuthQueryParams(
        parsedParams,
        effectiveAuthType,
        effectiveAuthData,
        variables,
      );

      resolvedUrl = VariableParser.parse(url, variables);
      Object? finalBody = body;
      if (body is String && body.isNotEmpty) {
        finalBody = VariableParser.parse(body, variables);
      }

      final response = await _dio.request(
        resolvedUrl,
        data: finalBody,
        queryParameters: parsedParams.isEmpty ? null : parsedParams,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          headers: parsedHeaders.isEmpty ? null : parsedHeaders,
          validateStatus: (status) => true,
        ),
      );

      stopwatch.stop();
      return RequestOutput(
        data: response.data,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        resolvedUrl: resolvedUrl,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      if (CancelToken.isCancel(e)) {
        return RequestOutput(
          resolvedUrl: resolvedUrl,
          durationMs: stopwatch.elapsedMilliseconds,
          cancelled: true,
        );
      }
      return RequestOutput(
        statusCode: e.response?.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        resolvedUrl: resolvedUrl,
        error: '${e.message ?? 'Network error'} (URL: $resolvedUrl)',
        data: e.response?.data,
      );
    } catch (e) {
      stopwatch.stop();
      return RequestOutput(
        durationMs: stopwatch.elapsedMilliseconds,
        resolvedUrl: resolvedUrl,
        error: e.toString(),
      );
    }
  }

  void _injectAuthHeaders(
    Map<String, dynamic> headers,
    String? authType,
    String? authData,
    Map<String, String> variables,
  ) {
    if (authType == null || authData == null) return;
    try {
      final authMap = jsonDecode(authData) as Map<String, dynamic>;
      switch (authType) {
        case 'bearer':
          final token = VariableParser.parse(
            authMap['token']?.toString() ?? '',
            variables,
          );
          if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
        case 'oauth2':
          final token = VariableParser.parse(
            authMap['accessToken']?.toString() ?? '',
            variables,
          );
          if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
        case 'basic':
          final user = VariableParser.parse(
            authMap['username']?.toString() ?? '',
            variables,
          );
          final pass = VariableParser.parse(
            authMap['password']?.toString() ?? '',
            variables,
          );
          if (user.isNotEmpty || pass.isNotEmpty) {
            final encoded = base64Encode(utf8.encode('$user:$pass'));
            headers['Authorization'] = 'Basic $encoded';
          }
        case 'api_key':
          if ((authMap['in'] ?? 'header') == 'header') {
            final key = VariableParser.parse(
              authMap['key']?.toString() ?? '',
              variables,
            );
            final val = VariableParser.parse(
              authMap['value']?.toString() ?? '',
              variables,
            );
            if (key.isNotEmpty && val.isNotEmpty) headers[key] = val;
          }
        default:
          break;
      }
    } catch (e) {
      AppLogger.warn('Auth header injection error');
    }
  }

  void _injectAuthQueryParams(
    Map<String, dynamic> params,
    String? authType,
    String? authData,
    Map<String, String> variables,
  ) {
    if (authType != 'api_key' || authData == null) return;
    try {
      final authMap = jsonDecode(authData) as Map<String, dynamic>;
      if ((authMap['in'] ?? 'header') != 'query') return;
      final key = VariableParser.parse(
        authMap['key']?.toString() ?? '',
        variables,
      );
      final val = VariableParser.parse(
        authMap['value']?.toString() ?? '',
        variables,
      );
      if (key.isNotEmpty && val.isNotEmpty) params[key] = val;
    } catch (_) {}
  }
}

final requestPipelineProvider = Provider<RequestPipeline>((ref) {
  return RequestPipeline(
    ref.watch(dioProvider),
    ref.watch(oauth2ServiceProvider),
  );
});
