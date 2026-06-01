part of 'database.dart';

extension CollectionQueries on AppDatabase {
  // ---------------------------------------------------------------------------
  // COLLECTIONS (WORKSPACES)
  // ---------------------------------------------------------------------------

  /// Obtener colecciones raíz (Proyectos/Workspaces)
  Stream<List<Collection>> watchRootCollections() {
    return (select(collections)
          ..where((t) => t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<Collection>> watchSubCollections(int parentId) {
    return (select(collections)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Trae TODAS las colecciones para armar árbol en memoria
  Stream<List<Collection>> watchAllCollections() {
    return (select(
      collections,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Stream<List<SavedRequest>> watchRequestsInCollection(int collectionId) {
    return (select(savedRequests)
          ..where(
            (t) =>
                t.collectionId.equals(collectionId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<SavedRequest>> watchUnclassifiedRequests() {
    return (select(savedRequests)
          ..where((t) => t.collectionId.isNull() & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> createCollection({
    required String name,
    String? description,
    int? parentId,
    String? authType,
    String? authData,
  }) {
    return into(collections).insert(
      CollectionsCompanion.insert(
        name: name,
        description: Value(description),
        parentId: Value(parentId),
        authType: Value(authType),
        authData: Value(authData),
      ),
    );
  }

  Future<bool> updateCollection(
    int id,
    String name,
    String? description, {
    String? authType,
    String? authData,
  }) {
    return (update(collections)..where((t) => t.id.equals(id)))
        .write(
          CollectionsCompanion(
            name: Value(name),
            description: Value(description),
            authType: Value(authType),
            authData: Value(authData),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<List<Collection>> getCollectionsWithPlainAuthData() {
    return (select(collections)
          ..where((t) => t.authData.isNotNull() & t.authData.isNotValue('')))
        .get()
        .then(
          (rows) => rows
              .where(
                (row) =>
                    row.authData != null &&
                    !row.authData!.startsWith('secure_auth_ref:'),
              )
              .toList(),
        );
  }

  Future<void> updateCollectionAuthDataById(int id, String? authData) async {
    await (update(collections)..where((t) => t.id.equals(id))).write(
      CollectionsCompanion(authData: Value(authData)),
    );
  }

  Future<void> deleteCollection(int id) async {
    await transaction(() async {
      final children = await (select(
        collections,
      )..where((t) => t.parentId.equals(id))).get();

      for (final child in children) {
        await deleteCollection(child.id);
      }

      await (update(
        savedRequests,
      )..where((t) => t.collectionId.equals(id))).write(
        const SavedRequestsCompanion(
          isDeleted: Value(true),
          collectionId: Value(null),
        ),
      );

      // Eliminar Entornos asociados al Workspace (si es root)
      await (delete(
        environments,
      )..where((t) => t.collectionId.equals(id))).go();

      await (delete(collections)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<bool> moveRequest(int requestId, int? collectionId) async {
    final count =
        await (update(savedRequests)..where((t) => t.id.equals(requestId)))
            .write(SavedRequestsCompanion(collectionId: Value(collectionId)));
    return count > 0;
  }

  Future<bool> moveCollection(int collectionId, int? newParentId) async {
    if (collectionId == newParentId) return false;
    final count =
        await (update(collections)..where((t) => t.id.equals(collectionId)))
            .write(CollectionsCompanion(parentId: Value(newParentId)));
    return count > 0;
  }

  Future<List<Collection>> getCollectionPath(int collectionId) async {
    final path = <Collection>[];
    int? currentId = collectionId;

    while (currentId != null) {
      final collection = await (select(
        collections,
      )..where((t) => t.id.equals(currentId!))).getSingleOrNull();

      if (collection != null) {
        path.insert(0, collection);
        currentId = collection.parentId;
      } else {
        break;
      }
    }
    return path;
  }

  // ---------------------------------------------------------------------------
  // SAVED REQUESTS QUERIES
  // ---------------------------------------------------------------------------

  Stream<List<SavedRequest>> watchSavedRequests() {
    return (select(savedRequests)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  // RENAMED: createRequest matches UI
  Future<int> createRequest({
    required String name,
    required String method,
    required String url,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? collectionId,
    String? schemaJson,
  }) {
    return into(savedRequests).insert(
      SavedRequestsCompanion.insert(
        name: name,
        method: method,
        url: url,
        headersJson: Value(headersJson),
        paramsJson: Value(paramsJson),
        body: Value(body),
        collectionId: Value(collectionId),
        schemaJson: Value(schemaJson),
      ),
    );
  }

  Future<bool> softDeleteRequest(int id) async {
    final count = await (update(savedRequests)..where((t) => t.id.equals(id)))
        .write(
          SavedRequestsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  Future<bool> restoreRequest(int id) async {
    final count = await (update(savedRequests)..where((t) => t.id.equals(id)))
        .write(
          SavedRequestsCompanion(
            isDeleted: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // IMPORT HELPERS (Merge Logic)
  // ---------------------------------------------------------------------------

  Future<Collection?> findCollectionByName(String name, int? parentId) {
    return (select(collections)..where(
          (t) =>
              t.name.equals(name) &
              (parentId == null
                  ? t.parentId.isNull()
                  : t.parentId.equals(parentId)),
        ))
        .getSingleOrNull();
  }

  Future<SavedRequest?> findRequestInCollection({
    required int collectionId,
    required String method,
    required String url,
  }) {
    return (select(savedRequests)..where(
          (t) =>
              t.collectionId.equals(collectionId) &
              t.method.equals(method) &
              t.url.equals(url) &
              t.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  Future<int> updateRequestContent({
    required int id,
    required String name,
    String? headersJson,
    String? paramsJson,
    String? body,
    String? schemaJson,
  }) {
    return (update(savedRequests)..where((t) => t.id.equals(id))).write(
      SavedRequestsCompanion(
        name: Value(name),
        headersJson: Value(headersJson),
        paramsJson: Value(paramsJson),
        body: Value(body),
        schemaJson: Value(schemaJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
