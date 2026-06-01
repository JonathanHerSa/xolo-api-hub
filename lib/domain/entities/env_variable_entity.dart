class EnvVariableEntity {
  const EnvVariableEntity({
    required this.id,
    required this.key,
    required this.value,
    this.environmentId,
    this.collectionId,
    required this.scope,
    required this.createdAt,
  });

  final int id;
  final String key;
  final String value;
  final int? environmentId;
  final int? collectionId;
  final String scope;
  final DateTime createdAt;
}
