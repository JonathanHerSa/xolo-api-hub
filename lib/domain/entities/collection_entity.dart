class CollectionEntity {
  const CollectionEntity({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.authType,
    this.authData,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final String? authType;
  final String? authData;
  final DateTime createdAt;

  bool get isRoot => parentId == null;
}
