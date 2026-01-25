class SchemaHelper {
  /// Generates a sample JSON object/value from a schema.
  static dynamic generateSample(Map<String, dynamic> schema) {
    // 0. Priorities: Example > Default > Nullable
    if (schema.containsKey('example')) return schema['example'];
    if (schema.containsKey('default')) return schema['default'];

    if (schema['nullable'] == true) {
      return null;
    }

    // 1. Handle Composition (allOf, oneOf, anyOf)
    if (schema.containsKey('allOf')) {
      final list = schema['allOf'] as List<dynamic>;
      final merged = <String, dynamic>{};
      for (final item in list) {
        final part = generateSample(item as Map<String, dynamic>);
        if (part is Map<String, dynamic>) {
          merged.addAll(part);
        }
      }
      return merged.isNotEmpty ? merged : {};
    }

    if (schema.containsKey('oneOf')) {
      final list = schema['oneOf'] as List<dynamic>;
      if (list.isNotEmpty) {
        return generateSample(list.first as Map<String, dynamic>);
      }
    }

    if (schema.containsKey('anyOf')) {
      final list = schema['anyOf'] as List<dynamic>;
      if (list.isNotEmpty) {
        return generateSample(list.first as Map<String, dynamic>);
      }
    }

    // 2. Handle Enums
    if (schema.containsKey('enum')) {
      final enums = schema['enum'] as List<dynamic>;
      if (enums.isNotEmpty) return enums.first;
    }

    final type = schema['type'] as String?;

    // 3. Handle Object
    if (type == 'object' || schema.containsKey('properties')) {
      final properties = schema['properties'] as Map<String, dynamic>?;
      final obj = <String, dynamic>{};
      if (properties != null) {
        for (final entry in properties.entries) {
          final key = entry.key;
          final propSchema = entry.value as Map<String, dynamic>;
          final val = generateSample(propSchema);
          // Allowed nulls
          obj[key] = val;
        }
      }
      return obj;
    }

    // 4. Handle Array
    if (type == 'array') {
      final items = schema['items'] as Map<String, dynamic>?;
      if (items != null) {
        final itemSample = generateSample(items);
        return itemSample != null ? [itemSample] : [];
      }
      return [];
    }

    // 5. Handle Primitives
    if (type == 'string') {
      if (schema['format'] == 'date-time') {
        return DateTime.now().toIso8601String();
      }
      if (schema['format'] == 'date') return '2025-01-01';
      return schema['example'] ?? 'string';
    }
    if (type == 'integer' || type == 'number') {
      return schema['example'] ?? 0;
    }
    if (type == 'boolean') {
      return schema['example'] ?? true;
    }

    return schema['example'];
  }

  /// Resolves all $ref in a schema against the root document, returning a fully dereferenced schema.
  /// This is important so we can save a self-contained schema to the DB.
  static Map<String, dynamic> resolveSchema(
    Map<String, dynamic> schema,
    Map<String, dynamic> root, {
    Set<String>? visitedRefs,
  }) {
    final visited = visitedRefs ?? {};

    // Deep copy to avoid mutating original if needed,
    // but we are constructing a new map mostly.
    // For simplicity, we'll iterate and rebuild.

    if (schema.containsKey(r'$ref')) {
      final refPath = schema[r'$ref'] as String;
      if (visited.contains(refPath)) {
        return {}; // Cycle detected/break
      }
      final resolved = _resolveRef(refPath, root);
      if (resolved != null) {
        final newVisited = Set<String>.from(visited)..add(refPath);
        // Merge resolved with current (current might have other props overriding ref?)
        // Usually ref is standalone.
        return resolveSchema(resolved, root, visitedRefs: newVisited);
      }
      return schema; // Keep as is if unresolvable
    }

    final newSchema = Map<String, dynamic>.from(schema);

    // Recurse properties
    if (newSchema.containsKey('properties')) {
      final props = newSchema['properties'] as Map<String, dynamic>;
      final newProps = <String, dynamic>{};
      for (final entry in props.entries) {
        newProps[entry.key] = resolveSchema(
          entry.value as Map<String, dynamic>,
          root,
          visitedRefs: visited,
        );
      }
      newSchema['properties'] = newProps;
    }

    // Recurse items
    if (newSchema.containsKey('items')) {
      newSchema['items'] = resolveSchema(
        newSchema['items'] as Map<String, dynamic>,
        root,
        visitedRefs: visited,
      );
    }

    // Recurse allOf/oneOf/anyOf
    for (final key in ['allOf', 'oneOf', 'anyOf']) {
      if (newSchema.containsKey(key)) {
        final list = newSchema[key] as List<dynamic>;
        final newList = list
            .map(
              (item) => resolveSchema(
                item as Map<String, dynamic>,
                root,
                visitedRefs: visited,
              ),
            )
            .toList();
        newSchema[key] = newList;
      }
    }

    return newSchema;
  }

  static Map<String, dynamic>? _resolveRef(
    String ref,
    Map<String, dynamic> root,
  ) {
    if (!ref.startsWith('#/')) return null;
    final parts = ref.split('/');
    // #, components, schemas, User

    dynamic current = root;
    for (int i = 1; i < parts.length; i++) {
      final key = parts[i];
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current as Map<String, dynamic>?;
  }
}
