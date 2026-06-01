import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/postman_assertion_mapper.dart';

final postmanServiceProvider = Provider((ref) => PostmanService());

class PostmanService {
  Future<void> importFromJson(
    Map<String, dynamic> json,
    int? parentId,
    AppDatabase db, {
    int? targetCollectionId,
  }) async {
    try {
      final info = json['info'] as Map<String, dynamic>?;
      final title = info?['name'] as String? ?? 'Imported Postman Collection';
      final description = info?['description'] as String?;

      int rootId;
      if (targetCollectionId != null) {
        rootId = targetCollectionId;
      } else {
        final existingRoot = await db.findCollectionByName(title, parentId);
        if (existingRoot != null) {
          rootId = existingRoot.id;
        } else {
          rootId = await db.createCollection(
            name: title,
            description: description,
            parentId: parentId,
          );
        }
      }

      final items = json['item'] as List<dynamic>?;
      if (items != null) {
        await _parseItems(items, rootId, db);
      }
    } catch (e) {
      throw Exception('Failed to import Postman: $e');
    }
  }

  Future<void> _parseItems(
    List<dynamic> items,
    int parentId,
    AppDatabase db,
  ) async {
    for (final item in items) {
      final it = item as Map<String, dynamic>;
      final name = it['name'] as String;
      final request = it['request'];
      final children = it['item'] as List<dynamic>?;

      if (children != null) {
        // It's a Folder
        final existingFolder = await db.findCollectionByName(name, parentId);
        int folderId;
        if (existingFolder != null) {
          folderId = existingFolder.id;
        } else {
          folderId = await db.createCollection(
            name: name,
            parentId: parentId,
            description: it['description'] as String?,
          );
        }
        await _parseItems(children, folderId, db);
      } else if (request != null) {
        // It's a Request
        await _parseRequest(it, parentId, db);
      }
    }
  }

  Future<void> _parseRequest(
    Map<String, dynamic> item,
    int collectionId,
    AppDatabase db,
  ) async {
    final name = item['name'] as String;
    final req = item['request'] as Map<String, dynamic>;
    final method = req['method'] as String? ?? 'GET';

    // URL resolution
    String url = '';
    final rawUrl = req['url'];
    if (rawUrl is String) {
      url = rawUrl;
    } else if (rawUrl is Map<String, dynamic>) {
      url = rawUrl['raw'] as String? ?? '';

      // If raw is missing, reconstruct from host/path
      if (url.isEmpty) {
        final host = (rawUrl['host'] as List<dynamic>?)?.join('.') ?? '';
        final path = (rawUrl['path'] as List<dynamic>?)?.join('/') ?? '';
        url = host.isNotEmpty ? '$host/$path' : path;
      }
    }

    // Query Params from URL object
    final paramsList = <Map<String, dynamic>>[];
    if (rawUrl is Map<String, dynamic>) {
      final query = rawUrl['query'] as List<dynamic>?;
      if (query != null) {
        for (final q in query) {
          final key = q['key'] as String?;
          final value = q['value'] as String?;
          if (key != null) {
            paramsList.add({
              'key': key,
              'value': value ?? '',
              'isActive': true,
            });
          }
        }
      }
    }

    // Headers
    final headers = req['header'] as List<dynamic>?;
    final headersList = <Map<String, dynamic>>[];
    if (headers != null) {
      for (final h in headers) {
        final key = h['key'] as String?;
        final value = h['value'] as String?;
        if (key != null) {
          headersList.add({'key': key, 'value': value ?? '', 'isActive': true});
        }
      }
    }

    // Body
    String? body;
    final reqBody = req['body'] as Map<String, dynamic>?;
    if (reqBody != null) {
      final mode = reqBody['mode'] as String?;
      if (mode == 'raw') {
        body = reqBody['raw'] as String?;
      } else if (mode == 'urlencoded') {
        final data = reqBody['urlencoded'] as List<dynamic>?;
        if (data != null) {
          final map = {for (var e in data) e['key']: e['value']};
          body = const JsonEncoder.withIndent('  ').convert(map);
        }
      }
    }

    final String? headersJson = headersList.isNotEmpty
        ? jsonEncode(headersList)
        : null;
    final String? paramsJson = paramsList.isNotEmpty
        ? jsonEncode(paramsList)
        : null;

    final assertionRules = PostmanAssertionMapper.fromPostmanEvents(
      item['event'] as List<dynamic>?,
    );
    final assertionsJson = PostmanAssertionMapper.encodeRules(assertionRules);

    // Update or Create
    final existing = await db.findRequestInCollection(
      collectionId: collectionId,
      method: method.toUpperCase(),
      url: url,
    );

    if (existing != null) {
      await db.updateRequestContent(
        id: existing.id,
        name: name,
        headersJson: headersJson,
        paramsJson: paramsJson,
        body: body,
      );
      if (assertionsJson != null) {
        await db.updateRequestAssertions(existing.id, assertionsJson);
      }
    } else {
      final id = await db.createRequest(
        name: name,
        method: method.toUpperCase(),
        url: url,
        collectionId: collectionId,
        headersJson: headersJson,
        paramsJson: paramsJson,
        body: body,
      );
      if (assertionsJson != null) {
        await db.updateRequestAssertions(id, assertionsJson);
      }
    }
  }
}
