import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import '../local/database.dart';

final syncServiceProvider = Provider((ref) => SyncService());

class SyncService {
  /// Export a collection (and all its children) to a JSON file in the target directory.
  /// Returns the created file.
  Future<File> exportCollection({
    required Collection collection,
    required String directoryPath,
    required AppDatabase db,
  }) async {
    // 1. Build the Sync Model Tree
    final syncCollection = await _buildSyncCollection(collection, db);

    // 2. Serialize to JSON
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(syncCollection.toJson());

    // 3. Write to File
    final filename = '${_sanitizeFilename(collection.name)}.xolo.json';
    final filePath = p.join(directoryPath, filename);
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return file;
  }

  Future<SyncCollection> _buildSyncCollection(
    Collection root,
    AppDatabase db,
  ) async {
    final items = await _buildChildren(root.id, db);

    return SyncCollection(
      info: SyncInfo(name: root.name, description: root.description),
      items: items,
    );
  }

  Future<List<SyncItem>> _buildChildren(int parentId, AppDatabase db) async {
    final items = <SyncItem>[];

    // Fetch Sub-folders
    final subFolders = await (db.select(
      db.collections,
    )..where((t) => t.parentId.equals(parentId))).get();
    for (final folder in subFolders) {
      final children = await _buildChildren(folder.id, db);
      items.add(
        SyncItem(
          type: 'folder',
          name: folder.name,
          description: folder.description,
          items: children,
        ),
      );
    }

    // Fetch Requests
    final requests =
        await (db.select(db.savedRequests)..where(
              (t) =>
                  t.collectionId.equals(parentId) & t.isDeleted.equals(false),
            ))
            .get();

    for (final req in requests) {
      items.add(
        SyncItem(
          type: 'request',
          name: req.name,
          method: req.method,
          url: req.url,
          headers: req.headersJson,
          params: req.paramsJson,
          body: req.body,
        ),
      );
    }

    return items;
  }

  String _sanitizeFilename(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Import sync collection from file.
  /// Strategy: Smart Upsert. Match by Name within Parent.
  Future<void> importCollection({
    required File file,
    required AppDatabase db,
  }) async {
    try {
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString);

      // Simple validation
      if (jsonMap['info'] == null || jsonMap['items'] == null) {
        throw Exception('Invalid Xolo JSON format');
      }

      final importData = SyncCollection.fromJson(jsonMap);

      // Create/Find Root Collection
      final rootId = await _upsertCollection(
        name: importData.info.name,
        description: importData.info.description,
        parentId: null, // Always imports as a new/existing Root Project
        db: db,
      );

      // Import Children recursively
      await _importItems(importData.items, rootId, db);
    } catch (e) {
      throw Exception('Failed to import: $e');
    }
  }

  Future<void> _importItems(
    List<SyncItem> items,
    int parentId,
    AppDatabase db,
  ) async {
    for (final item in items) {
      if (item.type == 'folder') {
        final folderId = await _upsertCollection(
          name: item.name,
          description: item.description,
          parentId: parentId,
          db: db,
        );
        if (item.items != null) {
          await _importItems(item.items!, folderId, db);
        }
      } else {
        await _upsertRequest(item, parentId, db);
      }
    }
  }

  Future<int> _upsertCollection({
    required String name,
    String? description,
    required int? parentId,
    required AppDatabase db,
  }) async {
    // Check if exists
    final existing =
        await (db.select(db.collections)..where(
              (t) =>
                  t.name.equals(name) &
                  (parentId == null
                      ? t.parentId.isNull()
                      : t.parentId.equals(parentId)),
            ))
            .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    } else {
      return db.createCollection(
        name: name,
        description: description,
        parentId: parentId,
      );
    }
  }

  Future<void> _upsertRequest(
    SyncItem item,
    int parentId,
    AppDatabase db,
  ) async {
    // Check if exists
    final existing =
        await (db.select(db.savedRequests)..where(
              (t) =>
                  t.name.equals(item.name) &
                  t.collectionId.equals(parentId) &
                  t.isDeleted.equals(false),
            ))
            .getSingleOrNull();

    // Prepare Data
    final headersJson = item.headers != null ? jsonEncode(item.headers) : null;
    final paramsJson = item.params != null ? jsonEncode(item.params) : null;
    final bodyStr = item.body is Map || item.body is List
        ? const JsonEncoder.withIndent('  ').convert(item.body)
        : item.body as String?;

    if (existing != null) {
      // Update
      await (db.update(
        db.savedRequests,
      )..where((t) => t.id.equals(existing.id))).write(
        SavedRequestsCompanion(
          method: Value(item.method ?? 'GET'),
          url: Value(item.url ?? ''),
          headersJson: Value(headersJson),
          paramsJson: Value(paramsJson),
          body: Value(bodyStr),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // Insert
      await db.createRequest(
        name: item.name,
        method: item.method ?? 'GET',
        url: item.url ?? '',
        collectionId: parentId,
        headersJson: headersJson,
        paramsJson: paramsJson,
        body: bodyStr,
      );
    }
  }
}

// =============================================================================
// DTO Models
// =============================================================================

class SyncCollection {
  final SyncInfo info;
  final List<SyncItem> items;

  SyncCollection({required this.info, required this.items});

  factory SyncCollection.fromJson(Map<String, dynamic> json) {
    return SyncCollection(
      info: SyncInfo.fromJson(json['info']),
      items: (json['items'] as List).map((i) => SyncItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'info': info.toJson(),
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class SyncInfo {
  final String name;
  final String? description;
  final String schema;

  SyncInfo({required this.name, this.description, this.schema = '1.0'});

  factory SyncInfo.fromJson(Map<String, dynamic> json) {
    return SyncInfo(
      name: json['name'],
      description: json['description'],
      schema: json['schema'] ?? '1.0',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'schema': schema,
  };
}

class SyncItem {
  final String type; // 'folder' | 'request'
  final String name;
  final String? description;
  final List<SyncItem>? items; // Only for folder

  // Request fields
  final String? method;
  final String? url;
  final dynamic
  headers; // Can be Map or String in transit but mapped to Map/String
  final dynamic params;
  final dynamic body;

  SyncItem({
    required this.type,
    required this.name,
    this.description,
    this.items,
    this.method,
    this.url,
    this.headers,
    this.params,
    this.body,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      type: json['type'],
      name: json['name'],
      description: json['description'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => SyncItem.fromJson(i)).toList()
          : null,
      method: json['method'],
      url: json['url'],
      headers: json['headers'],
      params: json['params'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type, 'name': name};
    if (description != null) map['description'] = description;

    if (type == 'folder') {
      if (items != null) map['items'] = items!.map((i) => i.toJson()).toList();
    } else {
      if (method != null) map['method'] = method;
      if (url != null) map['url'] = url;

      // Parse JSON strings to Objects to make the export file pretty
      if (headers != null && headers is String && headers.isNotEmpty) {
        try {
          map['headers'] = jsonDecode(headers);
        } catch (_) {
          map['headers'] = headers; // Fallback
        }
      } else if (headers != null) {
        map['headers'] = headers;
      }

      if (params != null && params is String && params.isNotEmpty) {
        try {
          map['params'] = jsonDecode(params);
        } catch (_) {
          map['params'] = params;
        }
      } else if (params != null) {
        map['params'] = params;
      }

      if (body != null && body is String && body.isNotEmpty) {
        try {
          // Primitive heuristic: if start with { or [ try parse
          final trimmed = body.trim();
          if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
            map['body'] = jsonDecode(trimmed);
          } else {
            map['body'] = body;
          }
        } catch (_) {
          map['body'] = body;
        }
      } else if (body != null) {
        map['body'] = body;
      }
    }
    return map;
  }
}
