import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import '../../core/utils/schema_helper.dart';

final openApiServiceProvider = Provider((ref) => OpenApiService(Dio()));

class OpenApiService {
  final Dio _dio;

  OpenApiService(this._dio);

  Future<void> importFromUrl(
    String url,
    String? workspaceId,
    AppDatabase db,
  ) async {
    try {
      final response = await _dio.get(url);
      final json = response.data;

      if (json is! Map<String, dynamic>) {
        throw Exception('Invalid JSON format');
      }

      int? parentId;
      if (workspaceId != null && workspaceId.isNotEmpty) {
        parentId = int.tryParse(workspaceId);
      }

      await _parseAndSave(json, parentId, db);
    } catch (e) {
      throw Exception('Failed to import OpenAPI: $e');
    }
  }

  Future<void> _parseAndSave(
    Map<String, dynamic> json,
    int? parentId,
    AppDatabase db,
  ) async {
    final info = json['info'] as Map<String, dynamic>?;
    final title = info?['title'] as String? ?? 'Imported Collection';
    final description = info?['description'] as String?;

    // 1. Resolve Root Collection (Find or Create)
    int rootId;
    final existingRoot = await db.findCollectionByName(title, parentId);
    if (existingRoot != null) {
      rootId = existingRoot.id;
      // Optional: Update description?
    } else {
      rootId = await db.createCollection(
        name: title,
        description: description,
        parentId: parentId,
      );
    }

    // Base URL resolution
    String baseUrl = '';
    final servers = json['servers'] as List<dynamic>?;
    if (servers != null && servers.isNotEmpty) {
      baseUrl = (servers[0] as Map<String, dynamic>)['url'] as String? ?? '';
    } else {
      final host = json['host'] as String?;
      final basePath = json['basePath'] as String?;
      final schemes = json['schemes'] as List<dynamic>?;
      final scheme = (schemes != null && schemes.isNotEmpty)
          ? schemes[0] as String
          : 'https';

      if (host != null) {
        baseUrl = '$scheme://$host${basePath ?? ''}';
      }
    }

    final paths = json['paths'] as Map<String, dynamic>?;
    if (paths == null) return;

    final tagFolders = <String, int>{};

    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final methods = pathEntry.value as Map<String, dynamic>;

      for (final methodEntry in methods.entries) {
        final method = methodEntry.key;
        if (['parameters', 'summary', 'description'].contains(method)) continue;

        final operation = methodEntry.value as Map<String, dynamic>;
        final summary = operation['summary'] as String?;
        final operationId = operation['operationId'] as String?;
        final requestName = summary ?? operationId ?? '$method $path';

        // Handle tags (Sub-collections)
        final tags = operation['tags'] as List<dynamic>?;
        int collectionId = rootId;
        if (tags != null && tags.isNotEmpty) {
          final tagName = tags[0] as String;

          if (tagFolders.containsKey(tagName)) {
            collectionId = tagFolders[tagName]!;
          } else {
            // Check DB
            final existingTag = await db.findCollectionByName(tagName, rootId);
            if (existingTag != null) {
              collectionId = existingTag.id;
              tagFolders[tagName] = collectionId;
            } else {
              final folderId = await db.createCollection(
                name: tagName,
                parentId: rootId,
              );
              tagFolders[tagName] = folderId;
              collectionId = folderId;
            }
          }
        }

        // Variable syntax replacement in URL
        final cleanPath = path.replaceAllMapped(
          RegExp(r'\{([^}]+)\}'),
          (match) => '{{${match.group(1)}}}',
        );
        final fullUrl = '$baseUrl$cleanPath';

        // Parse Params & Headers
        final paramsList = <Map<String, dynamic>>[];
        final headersList = <Map<String, dynamic>>[];

        final parameters = operation['parameters'] as List<dynamic>?;
        if (parameters != null) {
          for (final param in parameters) {
            final p = param as Map<String, dynamic>;
            final name = p['name'] as String;
            final inType = p['in'] as String;

            if (inType == 'query') {
              paramsList.add({'key': name, 'value': '', 'isActive': true});
            } else if (inType == 'header') {
              headersList.add({'key': name, 'value': '', 'isActive': true});
            }
          }
        }

        String? headersJson;
        String? paramsJson;
        if (headersList.isNotEmpty) {
          headersJson = jsonEncode(headersList);
        }
        if (paramsList.isNotEmpty) {
          paramsJson = jsonEncode(paramsList);
        }

        // Parse Body (Smart Gen)
        String? body;
        String? schemaJsonStr;

        final requestBody = operation['requestBody'] as Map<String, dynamic>?;
        if (requestBody != null) {
          final content = requestBody['content'] as Map<String, dynamic>?;
          final jsonContent =
              content?['application/json'] as Map<String, dynamic>?;
          if (jsonContent != null) {
            final schema = jsonContent['schema'] as Map<String, dynamic>?;
            if (schema != null) {
              // 1. Resolve Schema (Self-contained)
              final resolvedSchema = SchemaHelper.resolveSchema(schema, json);
              schemaJsonStr = jsonEncode(resolvedSchema);

              // 2. Generate Sample
              final sample = SchemaHelper.generateSample(resolvedSchema);
              if (sample != null) {
                body = const JsonEncoder.withIndent('  ').convert(sample);
              }
            }
          }
        }

        // Swagger 2.0: parameters in body
        if (body == null && parameters != null) {
          final bodyParam = parameters.firstWhere(
            (p) => p['in'] == 'body',
            orElse: () => null,
          );
          if (bodyParam != null) {
            final schema = bodyParam['schema'] as Map<String, dynamic>?;
            if (schema != null) {
              final resolvedSchema = SchemaHelper.resolveSchema(schema, json);
              schemaJsonStr = jsonEncode(resolvedSchema);

              final sample = SchemaHelper.generateSample(resolvedSchema);
              if (sample != null) {
                body = const JsonEncoder.withIndent('  ').convert(sample);
              }
            }
          }
        }

        // Update or Create
        final existingRequest = await db.findRequestInCollection(
          collectionId: collectionId,
          method: method.toUpperCase(),
          url: fullUrl,
        );

        if (existingRequest != null) {
          // Update
          await db.updateRequestContent(
            id: existingRequest.id,
            name: requestName,
            headersJson: headersJson,
            paramsJson: paramsJson,
            body: body,
            schemaJson: schemaJsonStr,
          );
        } else {
          // Create
          await db.createRequest(
            name: requestName,
            method: method.toUpperCase(),
            url: fullUrl,
            collectionId: collectionId,
            paramsJson: paramsJson,
            headersJson: headersJson,
            body: body,
            schemaJson: schemaJsonStr,
          );
        }
      }
    }
  }

  // Methods moved to SchemaHelper
}
