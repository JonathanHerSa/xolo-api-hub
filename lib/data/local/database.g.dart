// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authDataMeta = const VerificationMeta(
    'authData',
  );
  @override
  late final GeneratedColumn<String> authData = GeneratedColumn<String>(
    'auth_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    parentId,
    createdAt,
    authType,
    authData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('auth_data')) {
      context.handle(
        _authDataMeta,
        authData.isAcceptableOrUnknown(data['auth_data']!, _authDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      ),
      authData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_data'],
      ),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final DateTime createdAt;
  final String? authType;
  final String? authData;
  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.createdAt,
    this.authType,
    this.authData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || authType != null) {
      map['auth_type'] = Variable<String>(authType);
    }
    if (!nullToAbsent || authData != null) {
      map['auth_data'] = Variable<String>(authData);
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
      authType: authType == null && nullToAbsent
          ? const Value.absent()
          : Value(authType),
      authData: authData == null && nullToAbsent
          ? const Value.absent()
          : Value(authData),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      authType: serializer.fromJson<String?>(json['authType']),
      authData: serializer.fromJson<String?>(json['authData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'parentId': serializer.toJson<int?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'authType': serializer.toJson<String?>(authType),
      'authData': serializer.toJson<String?>(authData),
    };
  }

  Collection copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> parentId = const Value.absent(),
    DateTime? createdAt,
    Value<String?> authType = const Value.absent(),
    Value<String?> authData = const Value.absent(),
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
    authType: authType.present ? authType.value : this.authType,
    authData: authData.present ? authData.value : this.authData,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      authType: data.authType.present ? data.authType.value : this.authType,
      authData: data.authData.present ? data.authData.value : this.authData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    parentId,
    createdAt,
    authType,
    authData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt &&
          other.authType == this.authType &&
          other.authData == this.authData);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> parentId;
  final Value<DateTime> createdAt;
  final Value<String?> authType;
  final Value<String?> authData;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? parentId,
    Expression<DateTime>? createdAt,
    Expression<String>? authType,
    Expression<String>? authData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (authType != null) 'auth_type': authType,
      if (authData != null) 'auth_data': authData,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? parentId,
    Value<DateTime>? createdAt,
    Value<String?>? authType,
    Value<String?>? authData,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (authData.present) {
      map['auth_data'] = Variable<String>(authData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData')
          ..write(')'))
        .toString();
  }
}

class $SavedRequestsTable extends SavedRequests
    with TableInfo<$SavedRequestsTable, SavedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authDataMeta = const VerificationMeta(
    'authData',
  );
  @override
  late final GeneratedColumn<String> authData = GeneratedColumn<String>(
    'auth_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaJsonMeta = const VerificationMeta(
    'schemaJson',
  );
  @override
  late final GeneratedColumn<String> schemaJson = GeneratedColumn<String>(
    'schema_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preScriptsJsonMeta = const VerificationMeta(
    'preScriptsJson',
  );
  @override
  late final GeneratedColumn<String> preScriptsJson = GeneratedColumn<String>(
    'pre_scripts_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptsJsonMeta = const VerificationMeta(
    'scriptsJson',
  );
  @override
  late final GeneratedColumn<String> scriptsJson = GeneratedColumn<String>(
    'scripts_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assertionsJsonMeta = const VerificationMeta(
    'assertionsJson',
  );
  @override
  late final GeneratedColumn<String> assertionsJson = GeneratedColumn<String>(
    'assertions_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    method,
    url,
    headersJson,
    paramsJson,
    body,
    authType,
    authData,
    schemaJson,
    preScriptsJson,
    scriptsJson,
    assertionsJson,
    collectionId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('auth_data')) {
      context.handle(
        _authDataMeta,
        authData.isAcceptableOrUnknown(data['auth_data']!, _authDataMeta),
      );
    }
    if (data.containsKey('schema_json')) {
      context.handle(
        _schemaJsonMeta,
        schemaJson.isAcceptableOrUnknown(data['schema_json']!, _schemaJsonMeta),
      );
    }
    if (data.containsKey('pre_scripts_json')) {
      context.handle(
        _preScriptsJsonMeta,
        preScriptsJson.isAcceptableOrUnknown(
          data['pre_scripts_json']!,
          _preScriptsJsonMeta,
        ),
      );
    }
    if (data.containsKey('scripts_json')) {
      context.handle(
        _scriptsJsonMeta,
        scriptsJson.isAcceptableOrUnknown(
          data['scripts_json']!,
          _scriptsJsonMeta,
        ),
      );
    }
    if (data.containsKey('assertions_json')) {
      context.handle(
        _assertionsJsonMeta,
        assertionsJson.isAcceptableOrUnknown(
          data['assertions_json']!,
          _assertionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      ),
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      ),
      authData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_data'],
      ),
      schemaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_json'],
      ),
      preScriptsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pre_scripts_json'],
      ),
      scriptsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scripts_json'],
      ),
      assertionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assertions_json'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $SavedRequestsTable createAlias(String alias) {
    return $SavedRequestsTable(attachedDatabase, alias);
  }
}

class SavedRequest extends DataClass implements Insertable<SavedRequest> {
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
  final String? assertionsJson;
  final int? collectionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const SavedRequest({
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
    this.assertionsJson,
    this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || headersJson != null) {
      map['headers_json'] = Variable<String>(headersJson);
    }
    if (!nullToAbsent || paramsJson != null) {
      map['params_json'] = Variable<String>(paramsJson);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || authType != null) {
      map['auth_type'] = Variable<String>(authType);
    }
    if (!nullToAbsent || authData != null) {
      map['auth_data'] = Variable<String>(authData);
    }
    if (!nullToAbsent || schemaJson != null) {
      map['schema_json'] = Variable<String>(schemaJson);
    }
    if (!nullToAbsent || preScriptsJson != null) {
      map['pre_scripts_json'] = Variable<String>(preScriptsJson);
    }
    if (!nullToAbsent || scriptsJson != null) {
      map['scripts_json'] = Variable<String>(scriptsJson);
    }
    if (!nullToAbsent || assertionsJson != null) {
      map['assertions_json'] = Variable<String>(assertionsJson);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SavedRequestsCompanion toCompanion(bool nullToAbsent) {
    return SavedRequestsCompanion(
      id: Value(id),
      name: Value(name),
      method: Value(method),
      url: Value(url),
      headersJson: headersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(headersJson),
      paramsJson: paramsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(paramsJson),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      authType: authType == null && nullToAbsent
          ? const Value.absent()
          : Value(authType),
      authData: authData == null && nullToAbsent
          ? const Value.absent()
          : Value(authData),
      schemaJson: schemaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(schemaJson),
      preScriptsJson: preScriptsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(preScriptsJson),
      scriptsJson: scriptsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptsJson),
      assertionsJson: assertionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(assertionsJson),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory SavedRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedRequest(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      headersJson: serializer.fromJson<String?>(json['headersJson']),
      paramsJson: serializer.fromJson<String?>(json['paramsJson']),
      body: serializer.fromJson<String?>(json['body']),
      authType: serializer.fromJson<String?>(json['authType']),
      authData: serializer.fromJson<String?>(json['authData']),
      schemaJson: serializer.fromJson<String?>(json['schemaJson']),
      preScriptsJson: serializer.fromJson<String?>(json['preScriptsJson']),
      scriptsJson: serializer.fromJson<String?>(json['scriptsJson']),
      assertionsJson: serializer.fromJson<String?>(json['assertionsJson']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'headersJson': serializer.toJson<String?>(headersJson),
      'paramsJson': serializer.toJson<String?>(paramsJson),
      'body': serializer.toJson<String?>(body),
      'authType': serializer.toJson<String?>(authType),
      'authData': serializer.toJson<String?>(authData),
      'schemaJson': serializer.toJson<String?>(schemaJson),
      'preScriptsJson': serializer.toJson<String?>(preScriptsJson),
      'scriptsJson': serializer.toJson<String?>(scriptsJson),
      'assertionsJson': serializer.toJson<String?>(assertionsJson),
      'collectionId': serializer.toJson<int?>(collectionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SavedRequest copyWith({
    int? id,
    String? name,
    String? method,
    String? url,
    Value<String?> headersJson = const Value.absent(),
    Value<String?> paramsJson = const Value.absent(),
    Value<String?> body = const Value.absent(),
    Value<String?> authType = const Value.absent(),
    Value<String?> authData = const Value.absent(),
    Value<String?> schemaJson = const Value.absent(),
    Value<String?> preScriptsJson = const Value.absent(),
    Value<String?> scriptsJson = const Value.absent(),
    Value<String?> assertionsJson = const Value.absent(),
    Value<int?> collectionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => SavedRequest(
    id: id ?? this.id,
    name: name ?? this.name,
    method: method ?? this.method,
    url: url ?? this.url,
    headersJson: headersJson.present ? headersJson.value : this.headersJson,
    paramsJson: paramsJson.present ? paramsJson.value : this.paramsJson,
    body: body.present ? body.value : this.body,
    authType: authType.present ? authType.value : this.authType,
    authData: authData.present ? authData.value : this.authData,
    schemaJson: schemaJson.present ? schemaJson.value : this.schemaJson,
    preScriptsJson: preScriptsJson.present
        ? preScriptsJson.value
        : this.preScriptsJson,
    scriptsJson: scriptsJson.present ? scriptsJson.value : this.scriptsJson,
    assertionsJson: assertionsJson.present
        ? assertionsJson.value
        : this.assertionsJson,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  SavedRequest copyWithCompanion(SavedRequestsCompanion data) {
    return SavedRequest(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      body: data.body.present ? data.body.value : this.body,
      authType: data.authType.present ? data.authType.value : this.authType,
      authData: data.authData.present ? data.authData.value : this.authData,
      schemaJson: data.schemaJson.present
          ? data.schemaJson.value
          : this.schemaJson,
      preScriptsJson: data.preScriptsJson.present
          ? data.preScriptsJson.value
          : this.preScriptsJson,
      scriptsJson: data.scriptsJson.present
          ? data.scriptsJson.value
          : this.scriptsJson,
      assertionsJson: data.assertionsJson.present
          ? data.assertionsJson.value
          : this.assertionsJson,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedRequest(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('headersJson: $headersJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('body: $body, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData, ')
          ..write('schemaJson: $schemaJson, ')
          ..write('preScriptsJson: $preScriptsJson, ')
          ..write('scriptsJson: $scriptsJson, ')
          ..write('assertionsJson: $assertionsJson, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    method,
    url,
    headersJson,
    paramsJson,
    body,
    authType,
    authData,
    schemaJson,
    preScriptsJson,
    scriptsJson,
    assertionsJson,
    collectionId,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedRequest &&
          other.id == this.id &&
          other.name == this.name &&
          other.method == this.method &&
          other.url == this.url &&
          other.headersJson == this.headersJson &&
          other.paramsJson == this.paramsJson &&
          other.body == this.body &&
          other.authType == this.authType &&
          other.authData == this.authData &&
          other.schemaJson == this.schemaJson &&
          other.preScriptsJson == this.preScriptsJson &&
          other.scriptsJson == this.scriptsJson &&
          other.assertionsJson == this.assertionsJson &&
          other.collectionId == this.collectionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class SavedRequestsCompanion extends UpdateCompanion<SavedRequest> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> method;
  final Value<String> url;
  final Value<String?> headersJson;
  final Value<String?> paramsJson;
  final Value<String?> body;
  final Value<String?> authType;
  final Value<String?> authData;
  final Value<String?> schemaJson;
  final Value<String?> preScriptsJson;
  final Value<String?> scriptsJson;
  final Value<String?> assertionsJson;
  final Value<int?> collectionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  const SavedRequestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.body = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
    this.schemaJson = const Value.absent(),
    this.preScriptsJson = const Value.absent(),
    this.scriptsJson = const Value.absent(),
    this.assertionsJson = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  SavedRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String method,
    required String url,
    this.headersJson = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.body = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
    this.schemaJson = const Value.absent(),
    this.preScriptsJson = const Value.absent(),
    this.scriptsJson = const Value.absent(),
    this.assertionsJson = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : name = Value(name),
       method = Value(method),
       url = Value(url);
  static Insertable<SavedRequest> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? headersJson,
    Expression<String>? paramsJson,
    Expression<String>? body,
    Expression<String>? authType,
    Expression<String>? authData,
    Expression<String>? schemaJson,
    Expression<String>? preScriptsJson,
    Expression<String>? scriptsJson,
    Expression<String>? assertionsJson,
    Expression<int>? collectionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (headersJson != null) 'headers_json': headersJson,
      if (paramsJson != null) 'params_json': paramsJson,
      if (body != null) 'body': body,
      if (authType != null) 'auth_type': authType,
      if (authData != null) 'auth_data': authData,
      if (schemaJson != null) 'schema_json': schemaJson,
      if (preScriptsJson != null) 'pre_scripts_json': preScriptsJson,
      if (scriptsJson != null) 'scripts_json': scriptsJson,
      if (assertionsJson != null) 'assertions_json': assertionsJson,
      if (collectionId != null) 'collection_id': collectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  SavedRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? method,
    Value<String>? url,
    Value<String?>? headersJson,
    Value<String?>? paramsJson,
    Value<String?>? body,
    Value<String?>? authType,
    Value<String?>? authData,
    Value<String?>? schemaJson,
    Value<String?>? preScriptsJson,
    Value<String?>? scriptsJson,
    Value<String?>? assertionsJson,
    Value<int?>? collectionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
  }) {
    return SavedRequestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      headersJson: headersJson ?? this.headersJson,
      paramsJson: paramsJson ?? this.paramsJson,
      body: body ?? this.body,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
      schemaJson: schemaJson ?? this.schemaJson,
      preScriptsJson: preScriptsJson ?? this.preScriptsJson,
      scriptsJson: scriptsJson ?? this.scriptsJson,
      assertionsJson: assertionsJson ?? this.assertionsJson,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (authData.present) {
      map['auth_data'] = Variable<String>(authData.value);
    }
    if (schemaJson.present) {
      map['schema_json'] = Variable<String>(schemaJson.value);
    }
    if (preScriptsJson.present) {
      map['pre_scripts_json'] = Variable<String>(preScriptsJson.value);
    }
    if (scriptsJson.present) {
      map['scripts_json'] = Variable<String>(scriptsJson.value);
    }
    if (assertionsJson.present) {
      map['assertions_json'] = Variable<String>(assertionsJson.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedRequestsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('headersJson: $headersJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('body: $body, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData, ')
          ..write('schemaJson: $schemaJson, ')
          ..write('preScriptsJson: $preScriptsJson, ')
          ..write('scriptsJson: $scriptsJson, ')
          ..write('assertionsJson: $assertionsJson, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _savedRequestIdMeta = const VerificationMeta(
    'savedRequestId',
  );
  @override
  late final GeneratedColumn<int> savedRequestId = GeneratedColumn<int>(
    'saved_request_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_requests (id)',
    ),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalUrlMeta = const VerificationMeta(
    'originalUrl',
  );
  @override
  late final GeneratedColumn<String> originalUrl = GeneratedColumn<String>(
    'original_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authDataMeta = const VerificationMeta(
    'authData',
  );
  @override
  late final GeneratedColumn<String> authData = GeneratedColumn<String>(
    'auth_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseBodyMeta = const VerificationMeta(
    'responseBody',
  );
  @override
  late final GeneratedColumn<String> responseBody = GeneratedColumn<String>(
    'response_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _executedAtMeta = const VerificationMeta(
    'executedAt',
  );
  @override
  late final GeneratedColumn<DateTime> executedAt = GeneratedColumn<DateTime>(
    'executed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    savedRequestId,
    workspaceId,
    method,
    url,
    originalUrl,
    headersJson,
    paramsJson,
    body,
    authType,
    authData,
    statusCode,
    responseBody,
    durationMs,
    executedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('saved_request_id')) {
      context.handle(
        _savedRequestIdMeta,
        savedRequestId.isAcceptableOrUnknown(
          data['saved_request_id']!,
          _savedRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('original_url')) {
      context.handle(
        _originalUrlMeta,
        originalUrl.isAcceptableOrUnknown(
          data['original_url']!,
          _originalUrlMeta,
        ),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('auth_data')) {
      context.handle(
        _authDataMeta,
        authData.isAcceptableOrUnknown(data['auth_data']!, _authDataMeta),
      );
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    }
    if (data.containsKey('response_body')) {
      context.handle(
        _responseBodyMeta,
        responseBody.isAcceptableOrUnknown(
          data['response_body']!,
          _responseBodyMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('executed_at')) {
      context.handle(
        _executedAtMeta,
        executedAt.isAcceptableOrUnknown(data['executed_at']!, _executedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      savedRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_request_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      originalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_url'],
      ),
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      ),
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      ),
      authData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_data'],
      ),
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      responseBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_body'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      executedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}executed_at'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final int? savedRequestId;
  final int? workspaceId;
  final String method;
  final String url;
  final String? originalUrl;
  final String? headersJson;
  final String? paramsJson;
  final String? body;
  final String? authType;
  final String? authData;
  final int? statusCode;
  final String? responseBody;
  final int? durationMs;
  final DateTime executedAt;
  const HistoryEntry({
    required this.id,
    this.savedRequestId,
    this.workspaceId,
    required this.method,
    required this.url,
    this.originalUrl,
    this.headersJson,
    this.paramsJson,
    this.body,
    this.authType,
    this.authData,
    this.statusCode,
    this.responseBody,
    this.durationMs,
    required this.executedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || savedRequestId != null) {
      map['saved_request_id'] = Variable<int>(savedRequestId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<int>(workspaceId);
    }
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || originalUrl != null) {
      map['original_url'] = Variable<String>(originalUrl);
    }
    if (!nullToAbsent || headersJson != null) {
      map['headers_json'] = Variable<String>(headersJson);
    }
    if (!nullToAbsent || paramsJson != null) {
      map['params_json'] = Variable<String>(paramsJson);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || authType != null) {
      map['auth_type'] = Variable<String>(authType);
    }
    if (!nullToAbsent || authData != null) {
      map['auth_data'] = Variable<String>(authData);
    }
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    if (!nullToAbsent || responseBody != null) {
      map['response_body'] = Variable<String>(responseBody);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['executed_at'] = Variable<DateTime>(executedAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      savedRequestId: savedRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(savedRequestId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      method: Value(method),
      url: Value(url),
      originalUrl: originalUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(originalUrl),
      headersJson: headersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(headersJson),
      paramsJson: paramsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(paramsJson),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      authType: authType == null && nullToAbsent
          ? const Value.absent()
          : Value(authType),
      authData: authData == null && nullToAbsent
          ? const Value.absent()
          : Value(authData),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      responseBody: responseBody == null && nullToAbsent
          ? const Value.absent()
          : Value(responseBody),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      executedAt: Value(executedAt),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      savedRequestId: serializer.fromJson<int?>(json['savedRequestId']),
      workspaceId: serializer.fromJson<int?>(json['workspaceId']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      originalUrl: serializer.fromJson<String?>(json['originalUrl']),
      headersJson: serializer.fromJson<String?>(json['headersJson']),
      paramsJson: serializer.fromJson<String?>(json['paramsJson']),
      body: serializer.fromJson<String?>(json['body']),
      authType: serializer.fromJson<String?>(json['authType']),
      authData: serializer.fromJson<String?>(json['authData']),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      responseBody: serializer.fromJson<String?>(json['responseBody']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      executedAt: serializer.fromJson<DateTime>(json['executedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'savedRequestId': serializer.toJson<int?>(savedRequestId),
      'workspaceId': serializer.toJson<int?>(workspaceId),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'originalUrl': serializer.toJson<String?>(originalUrl),
      'headersJson': serializer.toJson<String?>(headersJson),
      'paramsJson': serializer.toJson<String?>(paramsJson),
      'body': serializer.toJson<String?>(body),
      'authType': serializer.toJson<String?>(authType),
      'authData': serializer.toJson<String?>(authData),
      'statusCode': serializer.toJson<int?>(statusCode),
      'responseBody': serializer.toJson<String?>(responseBody),
      'durationMs': serializer.toJson<int?>(durationMs),
      'executedAt': serializer.toJson<DateTime>(executedAt),
    };
  }

  HistoryEntry copyWith({
    int? id,
    Value<int?> savedRequestId = const Value.absent(),
    Value<int?> workspaceId = const Value.absent(),
    String? method,
    String? url,
    Value<String?> originalUrl = const Value.absent(),
    Value<String?> headersJson = const Value.absent(),
    Value<String?> paramsJson = const Value.absent(),
    Value<String?> body = const Value.absent(),
    Value<String?> authType = const Value.absent(),
    Value<String?> authData = const Value.absent(),
    Value<int?> statusCode = const Value.absent(),
    Value<String?> responseBody = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    DateTime? executedAt,
  }) => HistoryEntry(
    id: id ?? this.id,
    savedRequestId: savedRequestId.present
        ? savedRequestId.value
        : this.savedRequestId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
    method: method ?? this.method,
    url: url ?? this.url,
    originalUrl: originalUrl.present ? originalUrl.value : this.originalUrl,
    headersJson: headersJson.present ? headersJson.value : this.headersJson,
    paramsJson: paramsJson.present ? paramsJson.value : this.paramsJson,
    body: body.present ? body.value : this.body,
    authType: authType.present ? authType.value : this.authType,
    authData: authData.present ? authData.value : this.authData,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    responseBody: responseBody.present ? responseBody.value : this.responseBody,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    executedAt: executedAt ?? this.executedAt,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      savedRequestId: data.savedRequestId.present
          ? data.savedRequestId.value
          : this.savedRequestId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      originalUrl: data.originalUrl.present
          ? data.originalUrl.value
          : this.originalUrl,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      body: data.body.present ? data.body.value : this.body,
      authType: data.authType.present ? data.authType.value : this.authType,
      authData: data.authData.present ? data.authData.value : this.authData,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      responseBody: data.responseBody.present
          ? data.responseBody.value
          : this.responseBody,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      executedAt: data.executedAt.present
          ? data.executedAt.value
          : this.executedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('headersJson: $headersJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('body: $body, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData, ')
          ..write('statusCode: $statusCode, ')
          ..write('responseBody: $responseBody, ')
          ..write('durationMs: $durationMs, ')
          ..write('executedAt: $executedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    savedRequestId,
    workspaceId,
    method,
    url,
    originalUrl,
    headersJson,
    paramsJson,
    body,
    authType,
    authData,
    statusCode,
    responseBody,
    durationMs,
    executedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.savedRequestId == this.savedRequestId &&
          other.workspaceId == this.workspaceId &&
          other.method == this.method &&
          other.url == this.url &&
          other.originalUrl == this.originalUrl &&
          other.headersJson == this.headersJson &&
          other.paramsJson == this.paramsJson &&
          other.body == this.body &&
          other.authType == this.authType &&
          other.authData == this.authData &&
          other.statusCode == this.statusCode &&
          other.responseBody == this.responseBody &&
          other.durationMs == this.durationMs &&
          other.executedAt == this.executedAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<int?> savedRequestId;
  final Value<int?> workspaceId;
  final Value<String> method;
  final Value<String> url;
  final Value<String?> originalUrl;
  final Value<String?> headersJson;
  final Value<String?> paramsJson;
  final Value<String?> body;
  final Value<String?> authType;
  final Value<String?> authData;
  final Value<int?> statusCode;
  final Value<String?> responseBody;
  final Value<int?> durationMs;
  final Value<DateTime> executedAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.savedRequestId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.body = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.responseBody = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.executedAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.savedRequestId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String method,
    required String url,
    this.originalUrl = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.body = const Value.absent(),
    this.authType = const Value.absent(),
    this.authData = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.responseBody = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.executedAt = const Value.absent(),
  }) : method = Value(method),
       url = Value(url);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? savedRequestId,
    Expression<int>? workspaceId,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? originalUrl,
    Expression<String>? headersJson,
    Expression<String>? paramsJson,
    Expression<String>? body,
    Expression<String>? authType,
    Expression<String>? authData,
    Expression<int>? statusCode,
    Expression<String>? responseBody,
    Expression<int>? durationMs,
    Expression<DateTime>? executedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (savedRequestId != null) 'saved_request_id': savedRequestId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (originalUrl != null) 'original_url': originalUrl,
      if (headersJson != null) 'headers_json': headersJson,
      if (paramsJson != null) 'params_json': paramsJson,
      if (body != null) 'body': body,
      if (authType != null) 'auth_type': authType,
      if (authData != null) 'auth_data': authData,
      if (statusCode != null) 'status_code': statusCode,
      if (responseBody != null) 'response_body': responseBody,
      if (durationMs != null) 'duration_ms': durationMs,
      if (executedAt != null) 'executed_at': executedAt,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int?>? savedRequestId,
    Value<int?>? workspaceId,
    Value<String>? method,
    Value<String>? url,
    Value<String?>? originalUrl,
    Value<String?>? headersJson,
    Value<String?>? paramsJson,
    Value<String?>? body,
    Value<String?>? authType,
    Value<String?>? authData,
    Value<int?>? statusCode,
    Value<String?>? responseBody,
    Value<int?>? durationMs,
    Value<DateTime>? executedAt,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      savedRequestId: savedRequestId ?? this.savedRequestId,
      workspaceId: workspaceId ?? this.workspaceId,
      method: method ?? this.method,
      url: url ?? this.url,
      originalUrl: originalUrl ?? this.originalUrl,
      headersJson: headersJson ?? this.headersJson,
      paramsJson: paramsJson ?? this.paramsJson,
      body: body ?? this.body,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      durationMs: durationMs ?? this.durationMs,
      executedAt: executedAt ?? this.executedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (savedRequestId.present) {
      map['saved_request_id'] = Variable<int>(savedRequestId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (originalUrl.present) {
      map['original_url'] = Variable<String>(originalUrl.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (authData.present) {
      map['auth_data'] = Variable<String>(authData.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (responseBody.present) {
      map['response_body'] = Variable<String>(responseBody.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<DateTime>(executedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('headersJson: $headersJson, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('body: $body, ')
          ..write('authType: $authType, ')
          ..write('authData: $authData, ')
          ..write('statusCode: $statusCode, ')
          ..write('responseBody: $responseBody, ')
          ..write('durationMs: $durationMs, ')
          ..write('executedAt: $executedAt')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentsTable extends Environments
    with TableInfo<$EnvironmentsTable, Environment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    collectionId,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Environment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Environment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Environment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EnvironmentsTable createAlias(String alias) {
    return $EnvironmentsTable(attachedDatabase, alias);
  }
}

class Environment extends DataClass implements Insertable<Environment> {
  final int id;
  final String name;
  final int? collectionId;
  final bool isActive;
  final DateTime createdAt;
  const Environment({
    required this.id,
    required this.name,
    this.collectionId,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EnvironmentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentsCompanion(
      id: Value(id),
      name: Value(name),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Environment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Environment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'collectionId': serializer.toJson<int?>(collectionId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Environment copyWith({
    int? id,
    String? name,
    Value<int?> collectionId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Environment(
    id: id ?? this.id,
    name: name ?? this.name,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Environment copyWithCompanion(EnvironmentsCompanion data) {
    return Environment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Environment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('collectionId: $collectionId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, collectionId, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Environment &&
          other.id == this.id &&
          other.name == this.name &&
          other.collectionId == this.collectionId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class EnvironmentsCompanion extends UpdateCompanion<Environment> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> collectionId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const EnvironmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EnvironmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.collectionId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Environment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? collectionId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (collectionId != null) 'collection_id': collectionId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EnvironmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? collectionId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return EnvironmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      collectionId: collectionId ?? this.collectionId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('collectionId: $collectionId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EnvVariablesTable extends EnvVariables
    with TableInfo<$EnvVariablesTable, EnvVariable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvVariablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<int> environmentId = GeneratedColumn<int>(
    'environment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES environments (id)',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('global'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    value,
    environmentId,
    collectionId,
    scope,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'env_variables';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvVariable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvVariable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvVariable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}environment_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EnvVariablesTable createAlias(String alias) {
    return $EnvVariablesTable(attachedDatabase, alias);
  }
}

class EnvVariable extends DataClass implements Insertable<EnvVariable> {
  final int id;
  final String key;
  final String value;
  final int? environmentId;
  final int? collectionId;
  final String scope;
  final DateTime createdAt;
  const EnvVariable({
    required this.id,
    required this.key,
    required this.value,
    this.environmentId,
    this.collectionId,
    required this.scope,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || environmentId != null) {
      map['environment_id'] = Variable<int>(environmentId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['scope'] = Variable<String>(scope);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EnvVariablesCompanion toCompanion(bool nullToAbsent) {
    return EnvVariablesCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      environmentId: environmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(environmentId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      scope: Value(scope),
      createdAt: Value(createdAt),
    );
  }

  factory EnvVariable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvVariable(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      environmentId: serializer.fromJson<int?>(json['environmentId']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'environmentId': serializer.toJson<int?>(environmentId),
      'collectionId': serializer.toJson<int?>(collectionId),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EnvVariable copyWith({
    int? id,
    String? key,
    String? value,
    Value<int?> environmentId = const Value.absent(),
    Value<int?> collectionId = const Value.absent(),
    String? scope,
    DateTime? createdAt,
  }) => EnvVariable(
    id: id ?? this.id,
    key: key ?? this.key,
    value: value ?? this.value,
    environmentId: environmentId.present
        ? environmentId.value
        : this.environmentId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    scope: scope ?? this.scope,
    createdAt: createdAt ?? this.createdAt,
  );
  EnvVariable copyWithCompanion(EnvVariablesCompanion data) {
    return EnvVariable(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvVariable(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('environmentId: $environmentId, ')
          ..write('collectionId: $collectionId, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    key,
    value,
    environmentId,
    collectionId,
    scope,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvVariable &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.environmentId == this.environmentId &&
          other.collectionId == this.collectionId &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt);
}

class EnvVariablesCompanion extends UpdateCompanion<EnvVariable> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<int?> environmentId;
  final Value<int?> collectionId;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  const EnvVariablesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EnvVariablesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
    this.environmentId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<EnvVariable> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? environmentId,
    Expression<int>? collectionId,
    Expression<String>? scope,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (environmentId != null) 'environment_id': environmentId,
      if (collectionId != null) 'collection_id': collectionId,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EnvVariablesCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? value,
    Value<int?>? environmentId,
    Value<int?>? collectionId,
    Value<String>? scope,
    Value<DateTime>? createdAt,
  }) {
    return EnvVariablesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      environmentId: environmentId ?? this.environmentId,
      collectionId: collectionId ?? this.collectionId,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<int>(environmentId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvVariablesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('environmentId: $environmentId, ')
          ..write('collectionId: $collectionId, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionRunsTable extends CollectionRuns
    with TableInfo<$CollectionRunsTable, CollectionRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<int> environmentId = GeneratedColumn<int>(
    'environment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES environments (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalStepsMeta = const VerificationMeta(
    'totalSteps',
  );
  @override
  late final GeneratedColumn<int> totalSteps = GeneratedColumn<int>(
    'total_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passedStepsMeta = const VerificationMeta(
    'passedSteps',
  );
  @override
  late final GeneratedColumn<int> passedSteps = GeneratedColumn<int>(
    'passed_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedStepsMeta = const VerificationMeta(
    'failedSteps',
  );
  @override
  late final GeneratedColumn<int> failedSteps = GeneratedColumn<int>(
    'failed_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedStepsMeta = const VerificationMeta(
    'skippedSteps',
  );
  @override
  late final GeneratedColumn<int> skippedSteps = GeneratedColumn<int>(
    'skipped_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stopOnFailureMeta = const VerificationMeta(
    'stopOnFailure',
  );
  @override
  late final GeneratedColumn<bool> stopOnFailure = GeneratedColumn<bool>(
    'stop_on_failure',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stop_on_failure" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _runOptionsJsonMeta = const VerificationMeta(
    'runOptionsJson',
  );
  @override
  late final GeneratedColumn<String> runOptionsJson = GeneratedColumn<String>(
    'run_options_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variablesSnapshotJsonMeta =
      const VerificationMeta('variablesSnapshotJson');
  @override
  late final GeneratedColumn<String> variablesSnapshotJson =
      GeneratedColumn<String>(
        'variables_snapshot_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    workspaceId,
    environmentId,
    status,
    totalSteps,
    passedSteps,
    failedSteps,
    skippedSteps,
    stopOnFailure,
    runOptionsJson,
    variablesSnapshotJson,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_steps')) {
      context.handle(
        _totalStepsMeta,
        totalSteps.isAcceptableOrUnknown(data['total_steps']!, _totalStepsMeta),
      );
    }
    if (data.containsKey('passed_steps')) {
      context.handle(
        _passedStepsMeta,
        passedSteps.isAcceptableOrUnknown(
          data['passed_steps']!,
          _passedStepsMeta,
        ),
      );
    }
    if (data.containsKey('failed_steps')) {
      context.handle(
        _failedStepsMeta,
        failedSteps.isAcceptableOrUnknown(
          data['failed_steps']!,
          _failedStepsMeta,
        ),
      );
    }
    if (data.containsKey('skipped_steps')) {
      context.handle(
        _skippedStepsMeta,
        skippedSteps.isAcceptableOrUnknown(
          data['skipped_steps']!,
          _skippedStepsMeta,
        ),
      );
    }
    if (data.containsKey('stop_on_failure')) {
      context.handle(
        _stopOnFailureMeta,
        stopOnFailure.isAcceptableOrUnknown(
          data['stop_on_failure']!,
          _stopOnFailureMeta,
        ),
      );
    }
    if (data.containsKey('run_options_json')) {
      context.handle(
        _runOptionsJsonMeta,
        runOptionsJson.isAcceptableOrUnknown(
          data['run_options_json']!,
          _runOptionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('variables_snapshot_json')) {
      context.handle(
        _variablesSnapshotJsonMeta,
        variablesSnapshotJson.isAcceptableOrUnknown(
          data['variables_snapshot_json']!,
          _variablesSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      ),
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}environment_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_steps'],
      )!,
      passedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passed_steps'],
      )!,
      failedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_steps'],
      )!,
      skippedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_steps'],
      )!,
      stopOnFailure: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stop_on_failure'],
      )!,
      runOptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_options_json'],
      ),
      variablesSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables_snapshot_json'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $CollectionRunsTable createAlias(String alias) {
    return $CollectionRunsTable(attachedDatabase, alias);
  }
}

class CollectionRun extends DataClass implements Insertable<CollectionRun> {
  final int id;
  final int collectionId;
  final int? workspaceId;
  final int? environmentId;
  final String status;
  final int totalSteps;
  final int passedSteps;
  final int failedSteps;
  final int skippedSteps;
  final bool stopOnFailure;
  final String? runOptionsJson;
  final String? variablesSnapshotJson;
  final DateTime startedAt;
  final DateTime? finishedAt;
  const CollectionRun({
    required this.id,
    required this.collectionId,
    this.workspaceId,
    this.environmentId,
    required this.status,
    required this.totalSteps,
    required this.passedSteps,
    required this.failedSteps,
    required this.skippedSteps,
    required this.stopOnFailure,
    this.runOptionsJson,
    this.variablesSnapshotJson,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['collection_id'] = Variable<int>(collectionId);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<int>(workspaceId);
    }
    if (!nullToAbsent || environmentId != null) {
      map['environment_id'] = Variable<int>(environmentId);
    }
    map['status'] = Variable<String>(status);
    map['total_steps'] = Variable<int>(totalSteps);
    map['passed_steps'] = Variable<int>(passedSteps);
    map['failed_steps'] = Variable<int>(failedSteps);
    map['skipped_steps'] = Variable<int>(skippedSteps);
    map['stop_on_failure'] = Variable<bool>(stopOnFailure);
    if (!nullToAbsent || runOptionsJson != null) {
      map['run_options_json'] = Variable<String>(runOptionsJson);
    }
    if (!nullToAbsent || variablesSnapshotJson != null) {
      map['variables_snapshot_json'] = Variable<String>(variablesSnapshotJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  CollectionRunsCompanion toCompanion(bool nullToAbsent) {
    return CollectionRunsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      environmentId: environmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(environmentId),
      status: Value(status),
      totalSteps: Value(totalSteps),
      passedSteps: Value(passedSteps),
      failedSteps: Value(failedSteps),
      skippedSteps: Value(skippedSteps),
      stopOnFailure: Value(stopOnFailure),
      runOptionsJson: runOptionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(runOptionsJson),
      variablesSnapshotJson: variablesSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(variablesSnapshotJson),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory CollectionRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRun(
      id: serializer.fromJson<int>(json['id']),
      collectionId: serializer.fromJson<int>(json['collectionId']),
      workspaceId: serializer.fromJson<int?>(json['workspaceId']),
      environmentId: serializer.fromJson<int?>(json['environmentId']),
      status: serializer.fromJson<String>(json['status']),
      totalSteps: serializer.fromJson<int>(json['totalSteps']),
      passedSteps: serializer.fromJson<int>(json['passedSteps']),
      failedSteps: serializer.fromJson<int>(json['failedSteps']),
      skippedSteps: serializer.fromJson<int>(json['skippedSteps']),
      stopOnFailure: serializer.fromJson<bool>(json['stopOnFailure']),
      runOptionsJson: serializer.fromJson<String?>(json['runOptionsJson']),
      variablesSnapshotJson: serializer.fromJson<String?>(
        json['variablesSnapshotJson'],
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collectionId': serializer.toJson<int>(collectionId),
      'workspaceId': serializer.toJson<int?>(workspaceId),
      'environmentId': serializer.toJson<int?>(environmentId),
      'status': serializer.toJson<String>(status),
      'totalSteps': serializer.toJson<int>(totalSteps),
      'passedSteps': serializer.toJson<int>(passedSteps),
      'failedSteps': serializer.toJson<int>(failedSteps),
      'skippedSteps': serializer.toJson<int>(skippedSteps),
      'stopOnFailure': serializer.toJson<bool>(stopOnFailure),
      'runOptionsJson': serializer.toJson<String?>(runOptionsJson),
      'variablesSnapshotJson': serializer.toJson<String?>(
        variablesSnapshotJson,
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  CollectionRun copyWith({
    int? id,
    int? collectionId,
    Value<int?> workspaceId = const Value.absent(),
    Value<int?> environmentId = const Value.absent(),
    String? status,
    int? totalSteps,
    int? passedSteps,
    int? failedSteps,
    int? skippedSteps,
    bool? stopOnFailure,
    Value<String?> runOptionsJson = const Value.absent(),
    Value<String?> variablesSnapshotJson = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => CollectionRun(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
    environmentId: environmentId.present
        ? environmentId.value
        : this.environmentId,
    status: status ?? this.status,
    totalSteps: totalSteps ?? this.totalSteps,
    passedSteps: passedSteps ?? this.passedSteps,
    failedSteps: failedSteps ?? this.failedSteps,
    skippedSteps: skippedSteps ?? this.skippedSteps,
    stopOnFailure: stopOnFailure ?? this.stopOnFailure,
    runOptionsJson: runOptionsJson.present
        ? runOptionsJson.value
        : this.runOptionsJson,
    variablesSnapshotJson: variablesSnapshotJson.present
        ? variablesSnapshotJson.value
        : this.variablesSnapshotJson,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  CollectionRun copyWithCompanion(CollectionRunsCompanion data) {
    return CollectionRun(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      status: data.status.present ? data.status.value : this.status,
      totalSteps: data.totalSteps.present
          ? data.totalSteps.value
          : this.totalSteps,
      passedSteps: data.passedSteps.present
          ? data.passedSteps.value
          : this.passedSteps,
      failedSteps: data.failedSteps.present
          ? data.failedSteps.value
          : this.failedSteps,
      skippedSteps: data.skippedSteps.present
          ? data.skippedSteps.value
          : this.skippedSteps,
      stopOnFailure: data.stopOnFailure.present
          ? data.stopOnFailure.value
          : this.stopOnFailure,
      runOptionsJson: data.runOptionsJson.present
          ? data.runOptionsJson.value
          : this.runOptionsJson,
      variablesSnapshotJson: data.variablesSnapshotJson.present
          ? data.variablesSnapshotJson.value
          : this.variablesSnapshotJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRun(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('environmentId: $environmentId, ')
          ..write('status: $status, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('passedSteps: $passedSteps, ')
          ..write('failedSteps: $failedSteps, ')
          ..write('skippedSteps: $skippedSteps, ')
          ..write('stopOnFailure: $stopOnFailure, ')
          ..write('runOptionsJson: $runOptionsJson, ')
          ..write('variablesSnapshotJson: $variablesSnapshotJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    workspaceId,
    environmentId,
    status,
    totalSteps,
    passedSteps,
    failedSteps,
    skippedSteps,
    stopOnFailure,
    runOptionsJson,
    variablesSnapshotJson,
    startedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRun &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.workspaceId == this.workspaceId &&
          other.environmentId == this.environmentId &&
          other.status == this.status &&
          other.totalSteps == this.totalSteps &&
          other.passedSteps == this.passedSteps &&
          other.failedSteps == this.failedSteps &&
          other.skippedSteps == this.skippedSteps &&
          other.stopOnFailure == this.stopOnFailure &&
          other.runOptionsJson == this.runOptionsJson &&
          other.variablesSnapshotJson == this.variablesSnapshotJson &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class CollectionRunsCompanion extends UpdateCompanion<CollectionRun> {
  final Value<int> id;
  final Value<int> collectionId;
  final Value<int?> workspaceId;
  final Value<int?> environmentId;
  final Value<String> status;
  final Value<int> totalSteps;
  final Value<int> passedSteps;
  final Value<int> failedSteps;
  final Value<int> skippedSteps;
  final Value<bool> stopOnFailure;
  final Value<String?> runOptionsJson;
  final Value<String?> variablesSnapshotJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  const CollectionRunsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.status = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.passedSteps = const Value.absent(),
    this.failedSteps = const Value.absent(),
    this.skippedSteps = const Value.absent(),
    this.stopOnFailure = const Value.absent(),
    this.runOptionsJson = const Value.absent(),
    this.variablesSnapshotJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  CollectionRunsCompanion.insert({
    this.id = const Value.absent(),
    required int collectionId,
    this.workspaceId = const Value.absent(),
    this.environmentId = const Value.absent(),
    required String status,
    this.totalSteps = const Value.absent(),
    this.passedSteps = const Value.absent(),
    this.failedSteps = const Value.absent(),
    this.skippedSteps = const Value.absent(),
    this.stopOnFailure = const Value.absent(),
    this.runOptionsJson = const Value.absent(),
    this.variablesSnapshotJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  }) : collectionId = Value(collectionId),
       status = Value(status);
  static Insertable<CollectionRun> custom({
    Expression<int>? id,
    Expression<int>? collectionId,
    Expression<int>? workspaceId,
    Expression<int>? environmentId,
    Expression<String>? status,
    Expression<int>? totalSteps,
    Expression<int>? passedSteps,
    Expression<int>? failedSteps,
    Expression<int>? skippedSteps,
    Expression<bool>? stopOnFailure,
    Expression<String>? runOptionsJson,
    Expression<String>? variablesSnapshotJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (environmentId != null) 'environment_id': environmentId,
      if (status != null) 'status': status,
      if (totalSteps != null) 'total_steps': totalSteps,
      if (passedSteps != null) 'passed_steps': passedSteps,
      if (failedSteps != null) 'failed_steps': failedSteps,
      if (skippedSteps != null) 'skipped_steps': skippedSteps,
      if (stopOnFailure != null) 'stop_on_failure': stopOnFailure,
      if (runOptionsJson != null) 'run_options_json': runOptionsJson,
      if (variablesSnapshotJson != null)
        'variables_snapshot_json': variablesSnapshotJson,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  CollectionRunsCompanion copyWith({
    Value<int>? id,
    Value<int>? collectionId,
    Value<int?>? workspaceId,
    Value<int?>? environmentId,
    Value<String>? status,
    Value<int>? totalSteps,
    Value<int>? passedSteps,
    Value<int>? failedSteps,
    Value<int>? skippedSteps,
    Value<bool>? stopOnFailure,
    Value<String?>? runOptionsJson,
    Value<String?>? variablesSnapshotJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
  }) {
    return CollectionRunsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      workspaceId: workspaceId ?? this.workspaceId,
      environmentId: environmentId ?? this.environmentId,
      status: status ?? this.status,
      totalSteps: totalSteps ?? this.totalSteps,
      passedSteps: passedSteps ?? this.passedSteps,
      failedSteps: failedSteps ?? this.failedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
      stopOnFailure: stopOnFailure ?? this.stopOnFailure,
      runOptionsJson: runOptionsJson ?? this.runOptionsJson,
      variablesSnapshotJson:
          variablesSnapshotJson ?? this.variablesSnapshotJson,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<int>(environmentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalSteps.present) {
      map['total_steps'] = Variable<int>(totalSteps.value);
    }
    if (passedSteps.present) {
      map['passed_steps'] = Variable<int>(passedSteps.value);
    }
    if (failedSteps.present) {
      map['failed_steps'] = Variable<int>(failedSteps.value);
    }
    if (skippedSteps.present) {
      map['skipped_steps'] = Variable<int>(skippedSteps.value);
    }
    if (stopOnFailure.present) {
      map['stop_on_failure'] = Variable<bool>(stopOnFailure.value);
    }
    if (runOptionsJson.present) {
      map['run_options_json'] = Variable<String>(runOptionsJson.value);
    }
    if (variablesSnapshotJson.present) {
      map['variables_snapshot_json'] = Variable<String>(
        variablesSnapshotJson.value,
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRunsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('environmentId: $environmentId, ')
          ..write('status: $status, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('passedSteps: $passedSteps, ')
          ..write('failedSteps: $failedSteps, ')
          ..write('skippedSteps: $skippedSteps, ')
          ..write('stopOnFailure: $stopOnFailure, ')
          ..write('runOptionsJson: $runOptionsJson, ')
          ..write('variablesSnapshotJson: $variablesSnapshotJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $RunStepResultsTable extends RunStepResults
    with TableInfo<$RunStepResultsTable, RunStepResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunStepResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collection_runs (id)',
    ),
  );
  static const VerificationMeta _savedRequestIdMeta = const VerificationMeta(
    'savedRequestId',
  );
  @override
  late final GeneratedColumn<int> savedRequestId = GeneratedColumn<int>(
    'saved_request_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_requests (id)',
    ),
  );
  static const VerificationMeta _stepIndexMeta = const VerificationMeta(
    'stepIndex',
  );
  @override
  late final GeneratedColumn<int> stepIndex = GeneratedColumn<int>(
    'step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepStatusMeta = const VerificationMeta(
    'stepStatus',
  );
  @override
  late final GeneratedColumn<String> stepStatus = GeneratedColumn<String>(
    'step_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _assertionResultsJsonMeta =
      const VerificationMeta('assertionResultsJson');
  @override
  late final GeneratedColumn<String> assertionResultsJson =
      GeneratedColumn<String>(
        'assertion_results_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseBodySnippetMeta =
      const VerificationMeta('responseBodySnippet');
  @override
  late final GeneratedColumn<String> responseBodySnippet =
      GeneratedColumn<String>(
        'response_body_snippet',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    savedRequestId,
    stepIndex,
    name,
    method,
    url,
    stepStatus,
    statusCode,
    durationMs,
    passed,
    assertionResultsJson,
    errorMessage,
    responseBodySnippet,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_step_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunStepResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('saved_request_id')) {
      context.handle(
        _savedRequestIdMeta,
        savedRequestId.isAcceptableOrUnknown(
          data['saved_request_id']!,
          _savedRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('step_index')) {
      context.handle(
        _stepIndexMeta,
        stepIndex.isAcceptableOrUnknown(data['step_index']!, _stepIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_stepIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('step_status')) {
      context.handle(
        _stepStatusMeta,
        stepStatus.isAcceptableOrUnknown(data['step_status']!, _stepStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_stepStatusMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    }
    if (data.containsKey('assertion_results_json')) {
      context.handle(
        _assertionResultsJsonMeta,
        assertionResultsJson.isAcceptableOrUnknown(
          data['assertion_results_json']!,
          _assertionResultsJsonMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('response_body_snippet')) {
      context.handle(
        _responseBodySnippetMeta,
        responseBodySnippet.isAcceptableOrUnknown(
          data['response_body_snippet']!,
          _responseBodySnippetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunStepResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunStepResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      savedRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_request_id'],
      ),
      stepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      stepStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_status'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      )!,
      assertionResultsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assertion_results_json'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      responseBodySnippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_body_snippet'],
      ),
    );
  }

  @override
  $RunStepResultsTable createAlias(String alias) {
    return $RunStepResultsTable(attachedDatabase, alias);
  }
}

class RunStepResult extends DataClass implements Insertable<RunStepResult> {
  final int id;
  final int runId;
  final int? savedRequestId;
  final int stepIndex;
  final String name;
  final String method;
  final String url;
  final String stepStatus;
  final int? statusCode;
  final int? durationMs;
  final bool passed;
  final String? assertionResultsJson;
  final String? errorMessage;
  final String? responseBodySnippet;
  const RunStepResult({
    required this.id,
    required this.runId,
    this.savedRequestId,
    required this.stepIndex,
    required this.name,
    required this.method,
    required this.url,
    required this.stepStatus,
    this.statusCode,
    this.durationMs,
    required this.passed,
    this.assertionResultsJson,
    this.errorMessage,
    this.responseBodySnippet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    if (!nullToAbsent || savedRequestId != null) {
      map['saved_request_id'] = Variable<int>(savedRequestId);
    }
    map['step_index'] = Variable<int>(stepIndex);
    map['name'] = Variable<String>(name);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    map['step_status'] = Variable<String>(stepStatus);
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['passed'] = Variable<bool>(passed);
    if (!nullToAbsent || assertionResultsJson != null) {
      map['assertion_results_json'] = Variable<String>(assertionResultsJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || responseBodySnippet != null) {
      map['response_body_snippet'] = Variable<String>(responseBodySnippet);
    }
    return map;
  }

  RunStepResultsCompanion toCompanion(bool nullToAbsent) {
    return RunStepResultsCompanion(
      id: Value(id),
      runId: Value(runId),
      savedRequestId: savedRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(savedRequestId),
      stepIndex: Value(stepIndex),
      name: Value(name),
      method: Value(method),
      url: Value(url),
      stepStatus: Value(stepStatus),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      passed: Value(passed),
      assertionResultsJson: assertionResultsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(assertionResultsJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      responseBodySnippet: responseBodySnippet == null && nullToAbsent
          ? const Value.absent()
          : Value(responseBodySnippet),
    );
  }

  factory RunStepResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunStepResult(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      savedRequestId: serializer.fromJson<int?>(json['savedRequestId']),
      stepIndex: serializer.fromJson<int>(json['stepIndex']),
      name: serializer.fromJson<String>(json['name']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      stepStatus: serializer.fromJson<String>(json['stepStatus']),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      passed: serializer.fromJson<bool>(json['passed']),
      assertionResultsJson: serializer.fromJson<String?>(
        json['assertionResultsJson'],
      ),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      responseBodySnippet: serializer.fromJson<String?>(
        json['responseBodySnippet'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'savedRequestId': serializer.toJson<int?>(savedRequestId),
      'stepIndex': serializer.toJson<int>(stepIndex),
      'name': serializer.toJson<String>(name),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'stepStatus': serializer.toJson<String>(stepStatus),
      'statusCode': serializer.toJson<int?>(statusCode),
      'durationMs': serializer.toJson<int?>(durationMs),
      'passed': serializer.toJson<bool>(passed),
      'assertionResultsJson': serializer.toJson<String?>(assertionResultsJson),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'responseBodySnippet': serializer.toJson<String?>(responseBodySnippet),
    };
  }

  RunStepResult copyWith({
    int? id,
    int? runId,
    Value<int?> savedRequestId = const Value.absent(),
    int? stepIndex,
    String? name,
    String? method,
    String? url,
    String? stepStatus,
    Value<int?> statusCode = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    bool? passed,
    Value<String?> assertionResultsJson = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> responseBodySnippet = const Value.absent(),
  }) => RunStepResult(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    savedRequestId: savedRequestId.present
        ? savedRequestId.value
        : this.savedRequestId,
    stepIndex: stepIndex ?? this.stepIndex,
    name: name ?? this.name,
    method: method ?? this.method,
    url: url ?? this.url,
    stepStatus: stepStatus ?? this.stepStatus,
    statusCode: statusCode.present ? statusCode.value : this.statusCode,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    passed: passed ?? this.passed,
    assertionResultsJson: assertionResultsJson.present
        ? assertionResultsJson.value
        : this.assertionResultsJson,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    responseBodySnippet: responseBodySnippet.present
        ? responseBodySnippet.value
        : this.responseBodySnippet,
  );
  RunStepResult copyWithCompanion(RunStepResultsCompanion data) {
    return RunStepResult(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      savedRequestId: data.savedRequestId.present
          ? data.savedRequestId.value
          : this.savedRequestId,
      stepIndex: data.stepIndex.present ? data.stepIndex.value : this.stepIndex,
      name: data.name.present ? data.name.value : this.name,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      stepStatus: data.stepStatus.present
          ? data.stepStatus.value
          : this.stepStatus,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      passed: data.passed.present ? data.passed.value : this.passed,
      assertionResultsJson: data.assertionResultsJson.present
          ? data.assertionResultsJson.value
          : this.assertionResultsJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      responseBodySnippet: data.responseBodySnippet.present
          ? data.responseBodySnippet.value
          : this.responseBodySnippet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunStepResult(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('stepStatus: $stepStatus, ')
          ..write('statusCode: $statusCode, ')
          ..write('durationMs: $durationMs, ')
          ..write('passed: $passed, ')
          ..write('assertionResultsJson: $assertionResultsJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('responseBodySnippet: $responseBodySnippet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    savedRequestId,
    stepIndex,
    name,
    method,
    url,
    stepStatus,
    statusCode,
    durationMs,
    passed,
    assertionResultsJson,
    errorMessage,
    responseBodySnippet,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunStepResult &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.savedRequestId == this.savedRequestId &&
          other.stepIndex == this.stepIndex &&
          other.name == this.name &&
          other.method == this.method &&
          other.url == this.url &&
          other.stepStatus == this.stepStatus &&
          other.statusCode == this.statusCode &&
          other.durationMs == this.durationMs &&
          other.passed == this.passed &&
          other.assertionResultsJson == this.assertionResultsJson &&
          other.errorMessage == this.errorMessage &&
          other.responseBodySnippet == this.responseBodySnippet);
}

class RunStepResultsCompanion extends UpdateCompanion<RunStepResult> {
  final Value<int> id;
  final Value<int> runId;
  final Value<int?> savedRequestId;
  final Value<int> stepIndex;
  final Value<String> name;
  final Value<String> method;
  final Value<String> url;
  final Value<String> stepStatus;
  final Value<int?> statusCode;
  final Value<int?> durationMs;
  final Value<bool> passed;
  final Value<String?> assertionResultsJson;
  final Value<String?> errorMessage;
  final Value<String?> responseBodySnippet;
  const RunStepResultsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.savedRequestId = const Value.absent(),
    this.stepIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.stepStatus = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.passed = const Value.absent(),
    this.assertionResultsJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.responseBodySnippet = const Value.absent(),
  });
  RunStepResultsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    this.savedRequestId = const Value.absent(),
    required int stepIndex,
    required String name,
    required String method,
    required String url,
    required String stepStatus,
    this.statusCode = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.passed = const Value.absent(),
    this.assertionResultsJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.responseBodySnippet = const Value.absent(),
  }) : runId = Value(runId),
       stepIndex = Value(stepIndex),
       name = Value(name),
       method = Value(method),
       url = Value(url),
       stepStatus = Value(stepStatus);
  static Insertable<RunStepResult> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<int>? savedRequestId,
    Expression<int>? stepIndex,
    Expression<String>? name,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? stepStatus,
    Expression<int>? statusCode,
    Expression<int>? durationMs,
    Expression<bool>? passed,
    Expression<String>? assertionResultsJson,
    Expression<String>? errorMessage,
    Expression<String>? responseBodySnippet,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (savedRequestId != null) 'saved_request_id': savedRequestId,
      if (stepIndex != null) 'step_index': stepIndex,
      if (name != null) 'name': name,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (stepStatus != null) 'step_status': stepStatus,
      if (statusCode != null) 'status_code': statusCode,
      if (durationMs != null) 'duration_ms': durationMs,
      if (passed != null) 'passed': passed,
      if (assertionResultsJson != null)
        'assertion_results_json': assertionResultsJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (responseBodySnippet != null)
        'response_body_snippet': responseBodySnippet,
    });
  }

  RunStepResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<int?>? savedRequestId,
    Value<int>? stepIndex,
    Value<String>? name,
    Value<String>? method,
    Value<String>? url,
    Value<String>? stepStatus,
    Value<int?>? statusCode,
    Value<int?>? durationMs,
    Value<bool>? passed,
    Value<String?>? assertionResultsJson,
    Value<String?>? errorMessage,
    Value<String?>? responseBodySnippet,
  }) {
    return RunStepResultsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      savedRequestId: savedRequestId ?? this.savedRequestId,
      stepIndex: stepIndex ?? this.stepIndex,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      stepStatus: stepStatus ?? this.stepStatus,
      statusCode: statusCode ?? this.statusCode,
      durationMs: durationMs ?? this.durationMs,
      passed: passed ?? this.passed,
      assertionResultsJson: assertionResultsJson ?? this.assertionResultsJson,
      errorMessage: errorMessage ?? this.errorMessage,
      responseBodySnippet: responseBodySnippet ?? this.responseBodySnippet,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (savedRequestId.present) {
      map['saved_request_id'] = Variable<int>(savedRequestId.value);
    }
    if (stepIndex.present) {
      map['step_index'] = Variable<int>(stepIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (stepStatus.present) {
      map['step_status'] = Variable<String>(stepStatus.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (assertionResultsJson.present) {
      map['assertion_results_json'] = Variable<String>(
        assertionResultsJson.value,
      );
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (responseBodySnippet.present) {
      map['response_body_snippet'] = Variable<String>(
        responseBodySnippet.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunStepResultsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('savedRequestId: $savedRequestId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('stepStatus: $stepStatus, ')
          ..write('statusCode: $statusCode, ')
          ..write('durationMs: $durationMs, ')
          ..write('passed: $passed, ')
          ..write('assertionResultsJson: $assertionResultsJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('responseBodySnippet: $responseBodySnippet')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $SavedRequestsTable savedRequests = $SavedRequestsTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $EnvironmentsTable environments = $EnvironmentsTable(this);
  late final $EnvVariablesTable envVariables = $EnvVariablesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CollectionRunsTable collectionRuns = $CollectionRunsTable(this);
  late final $RunStepResultsTable runStepResults = $RunStepResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collections,
    savedRequests,
    historyEntries,
    environments,
    envVariables,
    appSettings,
    collectionRuns,
    runStepResults,
  ];
}

typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int?> parentId,
      Value<DateTime> createdAt,
      Value<String?> authType,
      Value<String?> authData,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int?> parentId,
      Value<DateTime> createdAt,
      Value<String?> authType,
      Value<String?> authData,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _parentIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.collections.parentId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SavedRequestsTable, List<SavedRequest>>
  _savedRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedRequests,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.savedRequests.collectionId,
    ),
  );

  $$SavedRequestsTableProcessedTableManager get savedRequestsRefs {
    final manager = $$SavedRequestsTableTableManager(
      $_db,
      $_db.savedRequests,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedRequestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistoryEntriesTable, List<HistoryEntry>>
  _historyEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historyEntries,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.historyEntries.workspaceId,
    ),
  );

  $$HistoryEntriesTableProcessedTableManager get historyEntriesRefs {
    final manager = $$HistoryEntriesTableTableManager(
      $_db,
      $_db.historyEntries,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnvironmentsTable, List<Environment>>
  _environmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.environments,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.environments.collectionId,
    ),
  );

  $$EnvironmentsTableProcessedTableManager get environmentsRefs {
    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_environmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnvVariablesTable, List<EnvVariable>>
  _envVariablesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.envVariables,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.envVariables.collectionId,
    ),
  );

  $$EnvVariablesTableProcessedTableManager get envVariablesRefs {
    final manager = $$EnvVariablesTableTableManager(
      $_db,
      $_db.envVariables,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_envVariablesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get parentId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> savedRequestsRefs(
    Expression<bool> Function($$SavedRequestsTableFilterComposer f) f,
  ) {
    final $$SavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> historyEntriesRefs(
    Expression<bool> Function($$HistoryEntriesTableFilterComposer f) f,
  ) {
    final $$HistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> environmentsRefs(
    Expression<bool> Function($$EnvironmentsTableFilterComposer f) f,
  ) {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> envVariablesRefs(
    Expression<bool> Function($$EnvVariablesTableFilterComposer f) f,
  ) {
    final $$EnvVariablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envVariables,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvVariablesTableFilterComposer(
            $db: $db,
            $table: $db.envVariables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get parentId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get authData =>
      $composableBuilder(column: $table.authData, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get parentId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> savedRequestsRefs<T extends Object>(
    Expression<T> Function($$SavedRequestsTableAnnotationComposer a) f,
  ) {
    final $$SavedRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> historyEntriesRefs<T extends Object>(
    Expression<T> Function($$HistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$HistoryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> environmentsRefs<T extends Object>(
    Expression<T> Function($$EnvironmentsTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> envVariablesRefs<T extends Object>(
    Expression<T> Function($$EnvVariablesTableAnnotationComposer a) f,
  ) {
    final $$EnvVariablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envVariables,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvVariablesTableAnnotationComposer(
            $db: $db,
            $table: $db.envVariables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({
            bool parentId,
            bool savedRequestsRefs,
            bool historyEntriesRefs,
            bool environmentsRefs,
            bool envVariablesRefs,
          })
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                description: description,
                parentId: parentId,
                createdAt: createdAt,
                authType: authType,
                authData: authData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                parentId: parentId,
                createdAt: createdAt,
                authType: authType,
                authData: authData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                savedRequestsRefs = false,
                historyEntriesRefs = false,
                environmentsRefs = false,
                envVariablesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (savedRequestsRefs) db.savedRequests,
                    if (historyEntriesRefs) db.historyEntries,
                    if (environmentsRefs) db.environments,
                    if (envVariablesRefs) db.envVariables,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable:
                                        $$CollectionsTableReferences
                                            ._parentIdTable(db),
                                    referencedColumn:
                                        $$CollectionsTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (savedRequestsRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          SavedRequest
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._savedRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).savedRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (historyEntriesRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          HistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._historyEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).historyEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (environmentsRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          Environment
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._environmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).environmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (envVariablesRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          EnvVariable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._envVariablesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).envVariablesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({
        bool parentId,
        bool savedRequestsRefs,
        bool historyEntriesRefs,
        bool environmentsRefs,
        bool envVariablesRefs,
      })
    >;
typedef $$SavedRequestsTableCreateCompanionBuilder =
    SavedRequestsCompanion Function({
      Value<int> id,
      required String name,
      required String method,
      required String url,
      Value<String?> headersJson,
      Value<String?> paramsJson,
      Value<String?> body,
      Value<String?> authType,
      Value<String?> authData,
      Value<String?> schemaJson,
      Value<String?> preScriptsJson,
      Value<String?> scriptsJson,
      Value<String?> assertionsJson,
      Value<int?> collectionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
    });
typedef $$SavedRequestsTableUpdateCompanionBuilder =
    SavedRequestsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> method,
      Value<String> url,
      Value<String?> headersJson,
      Value<String?> paramsJson,
      Value<String?> body,
      Value<String?> authType,
      Value<String?> authData,
      Value<String?> schemaJson,
      Value<String?> preScriptsJson,
      Value<String?> scriptsJson,
      Value<String?> assertionsJson,
      Value<int?> collectionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
    });

final class $$SavedRequestsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedRequestsTable, SavedRequest> {
  $$SavedRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.savedRequests.collectionId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HistoryEntriesTable, List<HistoryEntry>>
  _historyEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historyEntries,
    aliasName: $_aliasNameGenerator(
      db.savedRequests.id,
      db.historyEntries.savedRequestId,
    ),
  );

  $$HistoryEntriesTableProcessedTableManager get historyEntriesRefs {
    final manager = $$HistoryEntriesTableTableManager(
      $_db,
      $_db.historyEntries,
    ).filter((f) => f.savedRequestId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RunStepResultsTable, List<RunStepResult>>
  _runStepResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runStepResults,
    aliasName: $_aliasNameGenerator(
      db.savedRequests.id,
      db.runStepResults.savedRequestId,
    ),
  );

  $$RunStepResultsTableProcessedTableManager get runStepResultsRefs {
    final manager = $$RunStepResultsTableTableManager(
      $_db,
      $_db.runStepResults,
    ).filter((f) => f.savedRequestId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runStepResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavedRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preScriptsJson => $composableBuilder(
    column: $table.preScriptsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scriptsJson => $composableBuilder(
    column: $table.scriptsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assertionsJson => $composableBuilder(
    column: $table.assertionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historyEntriesRefs(
    Expression<bool> Function($$HistoryEntriesTableFilterComposer f) f,
  ) {
    final $$HistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.savedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> runStepResultsRefs(
    Expression<bool> Function($$RunStepResultsTableFilterComposer f) f,
  ) {
    final $$RunStepResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runStepResults,
      getReferencedColumn: (t) => t.savedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunStepResultsTableFilterComposer(
            $db: $db,
            $table: $db.runStepResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preScriptsJson => $composableBuilder(
    column: $table.preScriptsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scriptsJson => $composableBuilder(
    column: $table.scriptsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assertionsJson => $composableBuilder(
    column: $table.assertionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get authData =>
      $composableBuilder(column: $table.authData, builder: (column) => column);

  GeneratedColumn<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preScriptsJson => $composableBuilder(
    column: $table.preScriptsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scriptsJson => $composableBuilder(
    column: $table.scriptsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assertionsJson => $composableBuilder(
    column: $table.assertionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historyEntriesRefs<T extends Object>(
    Expression<T> Function($$HistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$HistoryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEntries,
      getReferencedColumn: (t) => t.savedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.historyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> runStepResultsRefs<T extends Object>(
    Expression<T> Function($$RunStepResultsTableAnnotationComposer a) f,
  ) {
    final $$RunStepResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runStepResults,
      getReferencedColumn: (t) => t.savedRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunStepResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.runStepResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedRequestsTable,
          SavedRequest,
          $$SavedRequestsTableFilterComposer,
          $$SavedRequestsTableOrderingComposer,
          $$SavedRequestsTableAnnotationComposer,
          $$SavedRequestsTableCreateCompanionBuilder,
          $$SavedRequestsTableUpdateCompanionBuilder,
          (SavedRequest, $$SavedRequestsTableReferences),
          SavedRequest,
          PrefetchHooks Function({
            bool collectionId,
            bool historyEntriesRefs,
            bool runStepResultsRefs,
          })
        > {
  $$SavedRequestsTableTableManager(_$AppDatabase db, $SavedRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> headersJson = const Value.absent(),
                Value<String?> paramsJson = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
                Value<String?> schemaJson = const Value.absent(),
                Value<String?> preScriptsJson = const Value.absent(),
                Value<String?> scriptsJson = const Value.absent(),
                Value<String?> assertionsJson = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => SavedRequestsCompanion(
                id: id,
                name: name,
                method: method,
                url: url,
                headersJson: headersJson,
                paramsJson: paramsJson,
                body: body,
                authType: authType,
                authData: authData,
                schemaJson: schemaJson,
                preScriptsJson: preScriptsJson,
                scriptsJson: scriptsJson,
                assertionsJson: assertionsJson,
                collectionId: collectionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String method,
                required String url,
                Value<String?> headersJson = const Value.absent(),
                Value<String?> paramsJson = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
                Value<String?> schemaJson = const Value.absent(),
                Value<String?> preScriptsJson = const Value.absent(),
                Value<String?> scriptsJson = const Value.absent(),
                Value<String?> assertionsJson = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => SavedRequestsCompanion.insert(
                id: id,
                name: name,
                method: method,
                url: url,
                headersJson: headersJson,
                paramsJson: paramsJson,
                body: body,
                authType: authType,
                authData: authData,
                schemaJson: schemaJson,
                preScriptsJson: preScriptsJson,
                scriptsJson: scriptsJson,
                assertionsJson: assertionsJson,
                collectionId: collectionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                historyEntriesRefs = false,
                runStepResultsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historyEntriesRefs) db.historyEntries,
                    if (runStepResultsRefs) db.runStepResults,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$SavedRequestsTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$SavedRequestsTableReferences
                                            ._collectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historyEntriesRefs)
                        await $_getPrefetchedData<
                          SavedRequest,
                          $SavedRequestsTable,
                          HistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SavedRequestsTableReferences
                              ._historyEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).historyEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (runStepResultsRefs)
                        await $_getPrefetchedData<
                          SavedRequest,
                          $SavedRequestsTable,
                          RunStepResult
                        >(
                          currentTable: table,
                          referencedTable: $$SavedRequestsTableReferences
                              ._runStepResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).runStepResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SavedRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedRequestsTable,
      SavedRequest,
      $$SavedRequestsTableFilterComposer,
      $$SavedRequestsTableOrderingComposer,
      $$SavedRequestsTableAnnotationComposer,
      $$SavedRequestsTableCreateCompanionBuilder,
      $$SavedRequestsTableUpdateCompanionBuilder,
      (SavedRequest, $$SavedRequestsTableReferences),
      SavedRequest,
      PrefetchHooks Function({
        bool collectionId,
        bool historyEntriesRefs,
        bool runStepResultsRefs,
      })
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<int?> savedRequestId,
      Value<int?> workspaceId,
      required String method,
      required String url,
      Value<String?> originalUrl,
      Value<String?> headersJson,
      Value<String?> paramsJson,
      Value<String?> body,
      Value<String?> authType,
      Value<String?> authData,
      Value<int?> statusCode,
      Value<String?> responseBody,
      Value<int?> durationMs,
      Value<DateTime> executedAt,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<int?> savedRequestId,
      Value<int?> workspaceId,
      Value<String> method,
      Value<String> url,
      Value<String?> originalUrl,
      Value<String?> headersJson,
      Value<String?> paramsJson,
      Value<String?> body,
      Value<String?> authType,
      Value<String?> authData,
      Value<int?> statusCode,
      Value<String?> responseBody,
      Value<int?> durationMs,
      Value<DateTime> executedAt,
    });

final class $$HistoryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry> {
  $$HistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavedRequestsTable _savedRequestIdTable(_$AppDatabase db) =>
      db.savedRequests.createAlias(
        $_aliasNameGenerator(
          db.historyEntries.savedRequestId,
          db.savedRequests.id,
        ),
      );

  $$SavedRequestsTableProcessedTableManager? get savedRequestId {
    final $_column = $_itemColumn<int>('saved_request_id');
    if ($_column == null) return null;
    final manager = $$SavedRequestsTableTableManager(
      $_db,
      $_db.savedRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedRequestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CollectionsTable _workspaceIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.historyEntries.workspaceId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseBody => $composableBuilder(
    column: $table.responseBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SavedRequestsTableFilterComposer get savedRequestId {
    final $$SavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableFilterComposer get workspaceId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authData => $composableBuilder(
    column: $table.authData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseBody => $composableBuilder(
    column: $table.responseBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavedRequestsTableOrderingComposer get savedRequestId {
    final $$SavedRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableOrderingComposer get workspaceId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get authData =>
      $composableBuilder(column: $table.authData, builder: (column) => column);

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseBody => $composableBuilder(
    column: $table.responseBody,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => column,
  );

  $$SavedRequestsTableAnnotationComposer get savedRequestId {
    final $$SavedRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableAnnotationComposer get workspaceId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (HistoryEntry, $$HistoryEntriesTableReferences),
          HistoryEntry,
          PrefetchHooks Function({bool savedRequestId, bool workspaceId})
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> savedRequestId = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> originalUrl = const Value.absent(),
                Value<String?> headersJson = const Value.absent(),
                Value<String?> paramsJson = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String?> responseBody = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> executedAt = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                savedRequestId: savedRequestId,
                workspaceId: workspaceId,
                method: method,
                url: url,
                originalUrl: originalUrl,
                headersJson: headersJson,
                paramsJson: paramsJson,
                body: body,
                authType: authType,
                authData: authData,
                statusCode: statusCode,
                responseBody: responseBody,
                durationMs: durationMs,
                executedAt: executedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> savedRequestId = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                required String method,
                required String url,
                Value<String?> originalUrl = const Value.absent(),
                Value<String?> headersJson = const Value.absent(),
                Value<String?> paramsJson = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> authType = const Value.absent(),
                Value<String?> authData = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<String?> responseBody = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> executedAt = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                savedRequestId: savedRequestId,
                workspaceId: workspaceId,
                method: method,
                url: url,
                originalUrl: originalUrl,
                headersJson: headersJson,
                paramsJson: paramsJson,
                body: body,
                authType: authType,
                authData: authData,
                statusCode: statusCode,
                responseBody: responseBody,
                durationMs: durationMs,
                executedAt: executedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({savedRequestId = false, workspaceId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (savedRequestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.savedRequestId,
                                    referencedTable:
                                        $$HistoryEntriesTableReferences
                                            ._savedRequestIdTable(db),
                                    referencedColumn:
                                        $$HistoryEntriesTableReferences
                                            ._savedRequestIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$HistoryEntriesTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$HistoryEntriesTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (HistoryEntry, $$HistoryEntriesTableReferences),
      HistoryEntry,
      PrefetchHooks Function({bool savedRequestId, bool workspaceId})
    >;
typedef $$EnvironmentsTableCreateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> collectionId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$EnvironmentsTableUpdateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> collectionId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$EnvironmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment> {
  $$EnvironmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.environments.collectionId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EnvVariablesTable, List<EnvVariable>>
  _envVariablesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.envVariables,
    aliasName: $_aliasNameGenerator(
      db.environments.id,
      db.envVariables.environmentId,
    ),
  );

  $$EnvVariablesTableProcessedTableManager get envVariablesRefs {
    final manager = $$EnvVariablesTableTableManager(
      $_db,
      $_db.envVariables,
    ).filter((f) => f.environmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_envVariablesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionRunsTable, List<CollectionRun>>
  _collectionRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionRuns,
    aliasName: $_aliasNameGenerator(
      db.environments.id,
      db.collectionRuns.environmentId,
    ),
  );

  $$CollectionRunsTableProcessedTableManager get collectionRunsRefs {
    final manager = $$CollectionRunsTableTableManager(
      $_db,
      $_db.collectionRuns,
    ).filter((f) => f.environmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_collectionRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EnvironmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> envVariablesRefs(
    Expression<bool> Function($$EnvVariablesTableFilterComposer f) f,
  ) {
    final $$EnvVariablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envVariables,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvVariablesTableFilterComposer(
            $db: $db,
            $table: $db.envVariables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionRunsRefs(
    Expression<bool> Function($$CollectionRunsTableFilterComposer f) f,
  ) {
    final $$CollectionRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionRuns,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionRunsTableFilterComposer(
            $db: $db,
            $table: $db.collectionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnvironmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> envVariablesRefs<T extends Object>(
    Expression<T> Function($$EnvVariablesTableAnnotationComposer a) f,
  ) {
    final $$EnvVariablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envVariables,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvVariablesTableAnnotationComposer(
            $db: $db,
            $table: $db.envVariables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionRunsRefs<T extends Object>(
    Expression<T> Function($$CollectionRunsTableAnnotationComposer a) f,
  ) {
    final $$CollectionRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionRuns,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnvironmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentsTable,
          Environment,
          $$EnvironmentsTableFilterComposer,
          $$EnvironmentsTableOrderingComposer,
          $$EnvironmentsTableAnnotationComposer,
          $$EnvironmentsTableCreateCompanionBuilder,
          $$EnvironmentsTableUpdateCompanionBuilder,
          (Environment, $$EnvironmentsTableReferences),
          Environment,
          PrefetchHooks Function({
            bool collectionId,
            bool envVariablesRefs,
            bool collectionRunsRefs,
          })
        > {
  $$EnvironmentsTableTableManager(_$AppDatabase db, $EnvironmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EnvironmentsCompanion(
                id: id,
                name: name,
                collectionId: collectionId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> collectionId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EnvironmentsCompanion.insert(
                id: id,
                name: name,
                collectionId: collectionId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvironmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                envVariablesRefs = false,
                collectionRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (envVariablesRefs) db.envVariables,
                    if (collectionRunsRefs) db.collectionRuns,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$EnvironmentsTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentsTableReferences
                                            ._collectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (envVariablesRefs)
                        await $_getPrefetchedData<
                          Environment,
                          $EnvironmentsTable,
                          EnvVariable
                        >(
                          currentTable: table,
                          referencedTable: $$EnvironmentsTableReferences
                              ._envVariablesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvironmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).envVariablesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.environmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionRunsRefs)
                        await $_getPrefetchedData<
                          Environment,
                          $EnvironmentsTable,
                          CollectionRun
                        >(
                          currentTable: table,
                          referencedTable: $$EnvironmentsTableReferences
                              ._collectionRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvironmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.environmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EnvironmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentsTable,
      Environment,
      $$EnvironmentsTableFilterComposer,
      $$EnvironmentsTableOrderingComposer,
      $$EnvironmentsTableAnnotationComposer,
      $$EnvironmentsTableCreateCompanionBuilder,
      $$EnvironmentsTableUpdateCompanionBuilder,
      (Environment, $$EnvironmentsTableReferences),
      Environment,
      PrefetchHooks Function({
        bool collectionId,
        bool envVariablesRefs,
        bool collectionRunsRefs,
      })
    >;
typedef $$EnvVariablesTableCreateCompanionBuilder =
    EnvVariablesCompanion Function({
      Value<int> id,
      required String key,
      required String value,
      Value<int?> environmentId,
      Value<int?> collectionId,
      Value<String> scope,
      Value<DateTime> createdAt,
    });
typedef $$EnvVariablesTableUpdateCompanionBuilder =
    EnvVariablesCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> value,
      Value<int?> environmentId,
      Value<int?> collectionId,
      Value<String> scope,
      Value<DateTime> createdAt,
    });

final class $$EnvVariablesTableReferences
    extends BaseReferences<_$AppDatabase, $EnvVariablesTable, EnvVariable> {
  $$EnvVariablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EnvironmentsTable _environmentIdTable(_$AppDatabase db) =>
      db.environments.createAlias(
        $_aliasNameGenerator(db.envVariables.environmentId, db.environments.id),
      );

  $$EnvironmentsTableProcessedTableManager? get environmentId {
    final $_column = $_itemColumn<int>('environment_id');
    if ($_column == null) return null;
    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_environmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.envVariables.collectionId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnvVariablesTableFilterComposer
    extends Composer<_$AppDatabase, $EnvVariablesTable> {
  $$EnvVariablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvironmentsTableFilterComposer get environmentId {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvVariablesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvVariablesTable> {
  $$EnvVariablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvironmentsTableOrderingComposer get environmentId {
    final $$EnvironmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableOrderingComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvVariablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvVariablesTable> {
  $$EnvVariablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EnvironmentsTableAnnotationComposer get environmentId {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvVariablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvVariablesTable,
          EnvVariable,
          $$EnvVariablesTableFilterComposer,
          $$EnvVariablesTableOrderingComposer,
          $$EnvVariablesTableAnnotationComposer,
          $$EnvVariablesTableCreateCompanionBuilder,
          $$EnvVariablesTableUpdateCompanionBuilder,
          (EnvVariable, $$EnvVariablesTableReferences),
          EnvVariable,
          PrefetchHooks Function({bool environmentId, bool collectionId})
        > {
  $$EnvVariablesTableTableManager(_$AppDatabase db, $EnvVariablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvVariablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvVariablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvVariablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int?> environmentId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EnvVariablesCompanion(
                id: id,
                key: key,
                value: value,
                environmentId: environmentId,
                collectionId: collectionId,
                scope: scope,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String value,
                Value<int?> environmentId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EnvVariablesCompanion.insert(
                id: id,
                key: key,
                value: value,
                environmentId: environmentId,
                collectionId: collectionId,
                scope: scope,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvVariablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({environmentId = false, collectionId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (environmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.environmentId,
                                    referencedTable:
                                        $$EnvVariablesTableReferences
                                            ._environmentIdTable(db),
                                    referencedColumn:
                                        $$EnvVariablesTableReferences
                                            ._environmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$EnvVariablesTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$EnvVariablesTableReferences
                                            ._collectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$EnvVariablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvVariablesTable,
      EnvVariable,
      $$EnvVariablesTableFilterComposer,
      $$EnvVariablesTableOrderingComposer,
      $$EnvVariablesTableAnnotationComposer,
      $$EnvVariablesTableCreateCompanionBuilder,
      $$EnvVariablesTableUpdateCompanionBuilder,
      (EnvVariable, $$EnvVariablesTableReferences),
      EnvVariable,
      PrefetchHooks Function({bool environmentId, bool collectionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CollectionRunsTableCreateCompanionBuilder =
    CollectionRunsCompanion Function({
      Value<int> id,
      required int collectionId,
      Value<int?> workspaceId,
      Value<int?> environmentId,
      required String status,
      Value<int> totalSteps,
      Value<int> passedSteps,
      Value<int> failedSteps,
      Value<int> skippedSteps,
      Value<bool> stopOnFailure,
      Value<String?> runOptionsJson,
      Value<String?> variablesSnapshotJson,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
    });
typedef $$CollectionRunsTableUpdateCompanionBuilder =
    CollectionRunsCompanion Function({
      Value<int> id,
      Value<int> collectionId,
      Value<int?> workspaceId,
      Value<int?> environmentId,
      Value<String> status,
      Value<int> totalSteps,
      Value<int> passedSteps,
      Value<int> failedSteps,
      Value<int> skippedSteps,
      Value<bool> stopOnFailure,
      Value<String?> runOptionsJson,
      Value<String?> variablesSnapshotJson,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
    });

final class $$CollectionRunsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionRunsTable, CollectionRun> {
  $$CollectionRunsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.collectionRuns.collectionId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CollectionsTable _workspaceIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.collectionRuns.workspaceId, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EnvironmentsTable _environmentIdTable(_$AppDatabase db) =>
      db.environments.createAlias(
        $_aliasNameGenerator(
          db.collectionRuns.environmentId,
          db.environments.id,
        ),
      );

  $$EnvironmentsTableProcessedTableManager? get environmentId {
    final $_column = $_itemColumn<int>('environment_id');
    if ($_column == null) return null;
    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_environmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RunStepResultsTable, List<RunStepResult>>
  _runStepResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runStepResults,
    aliasName: $_aliasNameGenerator(
      db.collectionRuns.id,
      db.runStepResults.runId,
    ),
  );

  $$RunStepResultsTableProcessedTableManager get runStepResultsRefs {
    final manager = $$RunStepResultsTableTableManager(
      $_db,
      $_db.runStepResults,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runStepResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionRunsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionRunsTable> {
  $$CollectionRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passedSteps => $composableBuilder(
    column: $table.passedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedSteps => $composableBuilder(
    column: $table.failedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedSteps => $composableBuilder(
    column: $table.skippedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stopOnFailure => $composableBuilder(
    column: $table.stopOnFailure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runOptionsJson => $composableBuilder(
    column: $table.runOptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variablesSnapshotJson => $composableBuilder(
    column: $table.variablesSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableFilterComposer get workspaceId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvironmentsTableFilterComposer get environmentId {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> runStepResultsRefs(
    Expression<bool> Function($$RunStepResultsTableFilterComposer f) f,
  ) {
    final $$RunStepResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runStepResults,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunStepResultsTableFilterComposer(
            $db: $db,
            $table: $db.runStepResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionRunsTable> {
  $$CollectionRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passedSteps => $composableBuilder(
    column: $table.passedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedSteps => $composableBuilder(
    column: $table.failedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedSteps => $composableBuilder(
    column: $table.skippedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stopOnFailure => $composableBuilder(
    column: $table.stopOnFailure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runOptionsJson => $composableBuilder(
    column: $table.runOptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variablesSnapshotJson => $composableBuilder(
    column: $table.variablesSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableOrderingComposer get workspaceId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvironmentsTableOrderingComposer get environmentId {
    final $$EnvironmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableOrderingComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionRunsTable> {
  $$CollectionRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passedSteps => $composableBuilder(
    column: $table.passedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedSteps => $composableBuilder(
    column: $table.failedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedSteps => $composableBuilder(
    column: $table.skippedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get stopOnFailure => $composableBuilder(
    column: $table.stopOnFailure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runOptionsJson => $composableBuilder(
    column: $table.runOptionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variablesSnapshotJson => $composableBuilder(
    column: $table.variablesSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CollectionsTableAnnotationComposer get workspaceId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvironmentsTableAnnotationComposer get environmentId {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> runStepResultsRefs<T extends Object>(
    Expression<T> Function($$RunStepResultsTableAnnotationComposer a) f,
  ) {
    final $$RunStepResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runStepResults,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunStepResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.runStepResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionRunsTable,
          CollectionRun,
          $$CollectionRunsTableFilterComposer,
          $$CollectionRunsTableOrderingComposer,
          $$CollectionRunsTableAnnotationComposer,
          $$CollectionRunsTableCreateCompanionBuilder,
          $$CollectionRunsTableUpdateCompanionBuilder,
          (CollectionRun, $$CollectionRunsTableReferences),
          CollectionRun,
          PrefetchHooks Function({
            bool collectionId,
            bool workspaceId,
            bool environmentId,
            bool runStepResultsRefs,
          })
        > {
  $$CollectionRunsTableTableManager(
    _$AppDatabase db,
    $CollectionRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> collectionId = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                Value<int?> environmentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalSteps = const Value.absent(),
                Value<int> passedSteps = const Value.absent(),
                Value<int> failedSteps = const Value.absent(),
                Value<int> skippedSteps = const Value.absent(),
                Value<bool> stopOnFailure = const Value.absent(),
                Value<String?> runOptionsJson = const Value.absent(),
                Value<String?> variablesSnapshotJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => CollectionRunsCompanion(
                id: id,
                collectionId: collectionId,
                workspaceId: workspaceId,
                environmentId: environmentId,
                status: status,
                totalSteps: totalSteps,
                passedSteps: passedSteps,
                failedSteps: failedSteps,
                skippedSteps: skippedSteps,
                stopOnFailure: stopOnFailure,
                runOptionsJson: runOptionsJson,
                variablesSnapshotJson: variablesSnapshotJson,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int collectionId,
                Value<int?> workspaceId = const Value.absent(),
                Value<int?> environmentId = const Value.absent(),
                required String status,
                Value<int> totalSteps = const Value.absent(),
                Value<int> passedSteps = const Value.absent(),
                Value<int> failedSteps = const Value.absent(),
                Value<int> skippedSteps = const Value.absent(),
                Value<bool> stopOnFailure = const Value.absent(),
                Value<String?> runOptionsJson = const Value.absent(),
                Value<String?> variablesSnapshotJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => CollectionRunsCompanion.insert(
                id: id,
                collectionId: collectionId,
                workspaceId: workspaceId,
                environmentId: environmentId,
                status: status,
                totalSteps: totalSteps,
                passedSteps: passedSteps,
                failedSteps: failedSteps,
                skippedSteps: skippedSteps,
                stopOnFailure: stopOnFailure,
                runOptionsJson: runOptionsJson,
                variablesSnapshotJson: variablesSnapshotJson,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                workspaceId = false,
                environmentId = false,
                runStepResultsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (runStepResultsRefs) db.runStepResults,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$CollectionRunsTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$CollectionRunsTableReferences
                                            ._collectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$CollectionRunsTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$CollectionRunsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (environmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.environmentId,
                                    referencedTable:
                                        $$CollectionRunsTableReferences
                                            ._environmentIdTable(db),
                                    referencedColumn:
                                        $$CollectionRunsTableReferences
                                            ._environmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (runStepResultsRefs)
                        await $_getPrefetchedData<
                          CollectionRun,
                          $CollectionRunsTable,
                          RunStepResult
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionRunsTableReferences
                              ._runStepResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).runStepResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CollectionRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionRunsTable,
      CollectionRun,
      $$CollectionRunsTableFilterComposer,
      $$CollectionRunsTableOrderingComposer,
      $$CollectionRunsTableAnnotationComposer,
      $$CollectionRunsTableCreateCompanionBuilder,
      $$CollectionRunsTableUpdateCompanionBuilder,
      (CollectionRun, $$CollectionRunsTableReferences),
      CollectionRun,
      PrefetchHooks Function({
        bool collectionId,
        bool workspaceId,
        bool environmentId,
        bool runStepResultsRefs,
      })
    >;
typedef $$RunStepResultsTableCreateCompanionBuilder =
    RunStepResultsCompanion Function({
      Value<int> id,
      required int runId,
      Value<int?> savedRequestId,
      required int stepIndex,
      required String name,
      required String method,
      required String url,
      required String stepStatus,
      Value<int?> statusCode,
      Value<int?> durationMs,
      Value<bool> passed,
      Value<String?> assertionResultsJson,
      Value<String?> errorMessage,
      Value<String?> responseBodySnippet,
    });
typedef $$RunStepResultsTableUpdateCompanionBuilder =
    RunStepResultsCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<int?> savedRequestId,
      Value<int> stepIndex,
      Value<String> name,
      Value<String> method,
      Value<String> url,
      Value<String> stepStatus,
      Value<int?> statusCode,
      Value<int?> durationMs,
      Value<bool> passed,
      Value<String?> assertionResultsJson,
      Value<String?> errorMessage,
      Value<String?> responseBodySnippet,
    });

final class $$RunStepResultsTableReferences
    extends BaseReferences<_$AppDatabase, $RunStepResultsTable, RunStepResult> {
  $$RunStepResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionRunsTable _runIdTable(_$AppDatabase db) =>
      db.collectionRuns.createAlias(
        $_aliasNameGenerator(db.runStepResults.runId, db.collectionRuns.id),
      );

  $$CollectionRunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$CollectionRunsTableTableManager(
      $_db,
      $_db.collectionRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SavedRequestsTable _savedRequestIdTable(_$AppDatabase db) =>
      db.savedRequests.createAlias(
        $_aliasNameGenerator(
          db.runStepResults.savedRequestId,
          db.savedRequests.id,
        ),
      );

  $$SavedRequestsTableProcessedTableManager? get savedRequestId {
    final $_column = $_itemColumn<int>('saved_request_id');
    if ($_column == null) return null;
    final manager = $$SavedRequestsTableTableManager(
      $_db,
      $_db.savedRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedRequestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RunStepResultsTableFilterComposer
    extends Composer<_$AppDatabase, $RunStepResultsTable> {
  $$RunStepResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepStatus => $composableBuilder(
    column: $table.stepStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assertionResultsJson => $composableBuilder(
    column: $table.assertionResultsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseBodySnippet => $composableBuilder(
    column: $table.responseBodySnippet,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionRunsTableFilterComposer get runId {
    final $$CollectionRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.collectionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionRunsTableFilterComposer(
            $db: $db,
            $table: $db.collectionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedRequestsTableFilterComposer get savedRequestId {
    final $$SavedRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableFilterComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunStepResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunStepResultsTable> {
  $$RunStepResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepStatus => $composableBuilder(
    column: $table.stepStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assertionResultsJson => $composableBuilder(
    column: $table.assertionResultsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseBodySnippet => $composableBuilder(
    column: $table.responseBodySnippet,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionRunsTableOrderingComposer get runId {
    final $$CollectionRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.collectionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionRunsTableOrderingComposer(
            $db: $db,
            $table: $db.collectionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedRequestsTableOrderingComposer get savedRequestId {
    final $$SavedRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunStepResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunStepResultsTable> {
  $$RunStepResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stepIndex =>
      $composableBuilder(column: $table.stepIndex, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get stepStatus => $composableBuilder(
    column: $table.stepStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<String> get assertionResultsJson => $composableBuilder(
    column: $table.assertionResultsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseBodySnippet => $composableBuilder(
    column: $table.responseBodySnippet,
    builder: (column) => column,
  );

  $$CollectionRunsTableAnnotationComposer get runId {
    final $$CollectionRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.collectionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedRequestsTableAnnotationComposer get savedRequestId {
    final $$SavedRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedRequestId,
      referencedTable: $db.savedRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunStepResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunStepResultsTable,
          RunStepResult,
          $$RunStepResultsTableFilterComposer,
          $$RunStepResultsTableOrderingComposer,
          $$RunStepResultsTableAnnotationComposer,
          $$RunStepResultsTableCreateCompanionBuilder,
          $$RunStepResultsTableUpdateCompanionBuilder,
          (RunStepResult, $$RunStepResultsTableReferences),
          RunStepResult,
          PrefetchHooks Function({bool runId, bool savedRequestId})
        > {
  $$RunStepResultsTableTableManager(
    _$AppDatabase db,
    $RunStepResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunStepResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunStepResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunStepResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<int?> savedRequestId = const Value.absent(),
                Value<int> stepIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> stepStatus = const Value.absent(),
                Value<int?> statusCode = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<String?> assertionResultsJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> responseBodySnippet = const Value.absent(),
              }) => RunStepResultsCompanion(
                id: id,
                runId: runId,
                savedRequestId: savedRequestId,
                stepIndex: stepIndex,
                name: name,
                method: method,
                url: url,
                stepStatus: stepStatus,
                statusCode: statusCode,
                durationMs: durationMs,
                passed: passed,
                assertionResultsJson: assertionResultsJson,
                errorMessage: errorMessage,
                responseBodySnippet: responseBodySnippet,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                Value<int?> savedRequestId = const Value.absent(),
                required int stepIndex,
                required String name,
                required String method,
                required String url,
                required String stepStatus,
                Value<int?> statusCode = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<String?> assertionResultsJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> responseBodySnippet = const Value.absent(),
              }) => RunStepResultsCompanion.insert(
                id: id,
                runId: runId,
                savedRequestId: savedRequestId,
                stepIndex: stepIndex,
                name: name,
                method: method,
                url: url,
                stepStatus: stepStatus,
                statusCode: statusCode,
                durationMs: durationMs,
                passed: passed,
                assertionResultsJson: assertionResultsJson,
                errorMessage: errorMessage,
                responseBodySnippet: responseBodySnippet,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunStepResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false, savedRequestId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runId,
                                referencedTable: $$RunStepResultsTableReferences
                                    ._runIdTable(db),
                                referencedColumn:
                                    $$RunStepResultsTableReferences
                                        ._runIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (savedRequestId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.savedRequestId,
                                referencedTable: $$RunStepResultsTableReferences
                                    ._savedRequestIdTable(db),
                                referencedColumn:
                                    $$RunStepResultsTableReferences
                                        ._savedRequestIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RunStepResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunStepResultsTable,
      RunStepResult,
      $$RunStepResultsTableFilterComposer,
      $$RunStepResultsTableOrderingComposer,
      $$RunStepResultsTableAnnotationComposer,
      $$RunStepResultsTableCreateCompanionBuilder,
      $$RunStepResultsTableUpdateCompanionBuilder,
      (RunStepResult, $$RunStepResultsTableReferences),
      RunStepResult,
      PrefetchHooks Function({bool runId, bool savedRequestId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$SavedRequestsTableTableManager get savedRequests =>
      $$SavedRequestsTableTableManager(_db, _db.savedRequests);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$EnvironmentsTableTableManager get environments =>
      $$EnvironmentsTableTableManager(_db, _db.environments);
  $$EnvVariablesTableTableManager get envVariables =>
      $$EnvVariablesTableTableManager(_db, _db.envVariables);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CollectionRunsTableTableManager get collectionRuns =>
      $$CollectionRunsTableTableManager(_db, _db.collectionRuns);
  $$RunStepResultsTableTableManager get runStepResults =>
      $$RunStepResultsTableTableManager(_db, _db.runStepResults);
}
