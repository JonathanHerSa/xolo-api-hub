import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/openapi_service.dart';
import 'package:xolo/data/services/postman_service.dart';

enum ImportFormat { openApi, postman, auto }

final importManagerProvider = Provider((ref) {
  return ImportManager(
    ref.watch(dioProvider),
    ref.watch(openApiServiceProvider),
    ref.watch(postmanServiceProvider),
  );
});

class ImportManager {
  final Dio _dio;
  final OpenApiService _openApi;
  final PostmanService _postman;

  ImportManager(this._dio, this._openApi, this._postman);

  Future<void> importFromUrl(
    String url,
    AppDatabase db, {
    int? parentId,
    int? targetCollectionId,
    ImportFormat format = ImportFormat.auto,
  }) async {
    final response = await _dio.get(url);
    final payload = _normalizePayload(response.data);
    final detectedFormat = detectFormat(payload, format);

    if (detectedFormat == ImportFormat.postman) {
      await _postman.importFromJson(
        payload,
        parentId,
        db,
        targetCollectionId: targetCollectionId,
      );
      return;
    }

    await _openApi.importFromJson(
      payload,
      parentId,
      db,
      targetCollectionId: targetCollectionId,
    );
  }

  Future<void> importFromContent(
    String content,
    AppDatabase db, {
    int? parentId,
    int? targetCollectionId,
    ImportFormat format = ImportFormat.auto,
  }) async {
    final json = jsonDecode(content);
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON format');
    }

    final detectedFormat = detectFormat(json, format);

    if (detectedFormat == ImportFormat.postman) {
      await _postman.importFromJson(
        json,
        parentId,
        db,
        targetCollectionId: targetCollectionId,
      );
    } else {
      await _openApi.importFromJson(
        json,
        parentId,
        db,
        targetCollectionId: targetCollectionId,
      );
    }
  }

  @visibleForTesting
  ImportFormat detectFormat(Map<String, dynamic> json, ImportFormat preferred) {
    if (preferred != ImportFormat.auto) return preferred;

    // Postman usually has 'info' and 'item'
    if (json.containsKey('info') &&
        json['info'] is Map &&
        (json['info'] as Map).containsKey('_postman_id')) {
      return ImportFormat.postman;
    }

    // OpenAPI usually has 'openapi' or 'swagger' keys
    if (json.containsKey('openapi') || json.containsKey('swagger')) {
      return ImportFormat.openApi;
    }

    // Fallback based on structure
    if (json.containsKey('item')) return ImportFormat.postman;
    if (json.containsKey('paths')) return ImportFormat.openApi;

    return ImportFormat.openApi; // Default
  }

  Map<String, dynamic> _normalizePayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    throw Exception('Unsupported import payload format. Expected JSON object.');
  }
}
