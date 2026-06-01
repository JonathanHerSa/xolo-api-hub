class SavedRequestEntity {
  const SavedRequestEntity({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    this.headersJson,
    this.paramsJson,
    this.body,
    this.authType,
    this.authData,
    this.schemaJson,
    this.preScriptsJson,
    this.scriptsJson,
    this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final int id;
  final String name;
  final String method;
  final String url;
  final String? headersJson;
  final String? paramsJson;
  final String? body;
  final String? authType;
  final String? authData;
  final String? schemaJson;
  final String? preScriptsJson;
  final String? scriptsJson;
  final int? collectionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
