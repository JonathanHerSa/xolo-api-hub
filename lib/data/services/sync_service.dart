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

    // Fetch Environments for this Collection
    final envs = await (db.select(
      db.environments,
    )..where((t) => t.collectionId.equals(root.id))).get();

    final syncEnvs = <SyncEnvironment>[];
    for (final env in envs) {
      final vars = await (db.select(
        db.envVariables,
      )..where((t) => t.environmentId.equals(env.id))).get();
      syncEnvs.add(
        SyncEnvironment(
          name: env.name,
          variables: vars
              .map((v) => SyncVariable(key: v.key, value: v.value))
              .toList(),
        ),
      );
    }

    return SyncCollection(
      info: SyncInfo(name: root.name, description: root.description),
      items: items,
      environments: syncEnvs.isNotEmpty ? syncEnvs : null,
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

  Future<File> exportFullBackup({
    required String directoryPath,
    required AppDatabase db,
  }) async {
    // 1. Fetch All Root Collections (Workspaces)
    final roots = await (db.select(
      db.collections,
    )..where((t) => t.parentId.isNull())).get();

    final workspaces = <SyncCollection>[];
    for (final root in roots) {
      workspaces.add(await _buildSyncCollection(root, db));
    }

    // 2. Fetch Global Environments & Variables
    // Environments without collectionId are global (or "Unclassified") - though usually Envs belong to a workspace.
    // If we have global envs, fetch them.
    final globalEnvs = await (db.select(
      db.environments,
    )..where((t) => t.collectionId.isNull())).get();

    final syncGlobalEnvs = <SyncEnvironment>[];
    for (final env in globalEnvs) {
      final vars = await (db.select(
        db.envVariables,
      )..where((t) => t.environmentId.equals(env.id))).get();

      syncGlobalEnvs.add(
        SyncEnvironment(
          name: env.name,
          variables: vars
              .map((v) => SyncVariable(key: v.key, value: v.value))
              .toList(),
        ),
      );
    }

    // 3. Construct Backup Object
    final backup = SyncBackup(
      version: 1,
      createdAt: DateTime.now().toIso8601String(),
      workspaces: workspaces,
      globalEnvironments: syncGlobalEnvs,
    );

    // 4. Write
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(backup.toJson());
    final filename =
        'xolo_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final filePath = p.join(directoryPath, filename);
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return file;
  }

  Future<void> importFullBackup({
    required File file,
    required AppDatabase db,
  }) async {
    try {
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString);
      final backup = SyncBackup.fromJson(jsonMap);

      // Import Workspaces
      for (final ws in backup.workspaces) {
        // Create/Find Root
        final rootId = await _upsertCollection(
          name: ws.info.name,
          description: ws.info.description,
          parentId: null,
          db: db,
        );
        // Recursively import children
        await _importItems(ws.items, rootId, db);

        // Import Workspace Enviroments?
        // SyncCollection currently doesn't hold environments.
        // IF we want to sync envs per workspace, we need to update SyncCollection.
        // For now, let's assume Envs are important.
        if (ws.environments != null) {
          for (final env in ws.environments!) {
            final envId = await _upsertEnvironment(env.name, rootId, db);
            await _upsertVariables(env.variables, envId, null, db);
          }
        }
      }

      // Import Global Envs
      if (backup.globalEnvironments != null) {
        for (final env in backup.globalEnvironments!) {
          final envId = await _upsertEnvironment(env.name, null, db);
          await _upsertVariables(env.variables, envId, null, db);
        }
      }
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  Future<int> _upsertEnvironment(
    String name,
    int? collectionId,
    AppDatabase db,
  ) async {
    final existing =
        await (db.select(db.environments)..where(
              (t) =>
                  t.name.equals(name) &
                  (collectionId == null
                      ? t.collectionId.isNull()
                      : t.collectionId.equals(collectionId)),
            ))
            .getSingleOrNull();

    if (existing != null) return existing.id;
    return db.createEnvironment(name, collectionId);
  }

  Future<void> _upsertVariables(
    List<SyncVariable> vars,
    int? envId,
    int? collectionId,
    AppDatabase db,
  ) async {
    for (final v in vars) {
      // Check existing variable
      final existing =
          await (db.select(db.envVariables)..where(
                (t) =>
                    t.key.equals(v.key) &
                    (envId == null
                        ? t.environmentId.isNull()
                        : t.environmentId.equals(envId)) &
                    (collectionId == null
                        ? t.collectionId.isNull()
                        : t.collectionId.equals(collectionId)),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.envVariables)
              ..where((t) => t.id.equals(existing.id)))
            .write(EnvVariablesCompanion(value: Value(v.value)));
      } else {
        await db.upsertVariable(
          key: v.key,
          value: v.value,
          environmentId: envId,
          workspaceId: collectionId,
        );
      }
    }
  }
}

// =============================================================================
// DTO Models
// =============================================================================

class SyncCollection {
  final SyncInfo info;
  final List<SyncItem> items;
  final List<SyncEnvironment>? environments;

  SyncCollection({required this.info, required this.items, this.environments});

  factory SyncCollection.fromJson(Map<String, dynamic> json) {
    return SyncCollection(
      info: SyncInfo.fromJson(json['info']),
      items: (json['items'] as List).map((i) => SyncItem.fromJson(i)).toList(),
      environments: json['environments'] != null
          ? (json['environments'] as List)
                .map((e) => SyncEnvironment.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'info': info.toJson(),
    'items': items.map((i) => i.toJson()).toList(),
    if (environments != null)
      'environments': environments!.map((e) => e.toJson()).toList(),
  };
}

class SyncBackup {
  final int version;
  final String createdAt;
  final List<SyncCollection> workspaces;
  final List<SyncEnvironment>? globalEnvironments;

  SyncBackup({
    required this.version,
    required this.createdAt,
    required this.workspaces,
    this.globalEnvironments,
  });

  factory SyncBackup.fromJson(Map<String, dynamic> json) {
    return SyncBackup(
      version: json['version'] ?? 1,
      createdAt: json['createdAt'] ?? '',
      workspaces: (json['workspaces'] as List)
          .map((e) => SyncCollection.fromJson(e))
          .toList(),
      globalEnvironments: json['globalEnvironments'] != null
          ? (json['globalEnvironments'] as List)
                .map((e) => SyncEnvironment.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt,
    'workspaces': workspaces.map((e) => e.toJson()).toList(),
    if (globalEnvironments != null)
      'globalEnvironments': globalEnvironments!.map((e) => e.toJson()).toList(),
  };
}

class SyncEnvironment {
  final String name;
  final List<SyncVariable> variables;

  SyncEnvironment({required this.name, required this.variables});

  factory SyncEnvironment.fromJson(Map<String, dynamic> json) {
    return SyncEnvironment(
      name: json['name'],
      variables:
          (json['variables'] as List?)
              ?.map((v) => SyncVariable.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'variables': variables.map((v) => v.toJson()).toList(),
  };
}

class SyncVariable {
  final String key;
  final String value;

  SyncVariable({required this.key, required this.value});

  factory SyncVariable.fromJson(Map<String, dynamic> json) {
    return SyncVariable(key: json['key'], value: json['value']);
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
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
