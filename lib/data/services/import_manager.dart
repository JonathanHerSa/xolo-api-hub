import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import 'openapi_service.dart';
import 'postman_service.dart';

enum ImportFormat { openApi, postman, auto }

final importManagerProvider = Provider((ref) {
  return ImportManager(
    ref.watch(openApiServiceProvider),
    ref.watch(postmanServiceProvider),
  );
});

class ImportManager {
  final OpenApiService _openApi;
  final PostmanService _postman;

  ImportManager(this._openApi, this._postman);

  Future<void> importFromUrl(
    String url,
    AppDatabase db, {
    int? parentId,
    int? targetCollectionId,
    ImportFormat format = ImportFormat.auto,
  }) async {
    // For now URL only supports OpenAPI as it's the common case for Swagger URLs
    // Postman usually share via JSON files unless using their API
    await _openApi.importFromUrl(
      url,
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

    final detectedFormat = _detectFormat(json, format);

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

  ImportFormat _detectFormat(
    Map<String, dynamic> json,
    ImportFormat preferred,
  ) {
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
}
