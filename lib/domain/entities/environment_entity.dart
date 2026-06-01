class EnvironmentEntity {
  const EnvironmentEntity({
    required this.id,
    required this.name,
    this.collectionId,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int? collectionId;
  final bool isActive;
  final DateTime createdAt;
}
