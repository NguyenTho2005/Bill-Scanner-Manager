// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSystemMeta =
      const VerificationMeta('isSystem');
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
      'is_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        parentId,
        name,
        icon,
        colorValue,
        isSystem,
        sortOrder,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(_isSystemMeta,
          isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      isSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  /// Unique identifier (e.g. "food_drinks", "cat_123").
  final String id;

  /// Parent category ID for hierarchical categories (optional).
  final String? parentId;

  /// Display name (e.g. "Ăn uống").
  final String name;

  /// Icon name or emoji (e.g. "restaurant", "🍔").
  final String icon;

  /// Color hex code as integer (e.g. 0xFFFF6B35).
  final int colorValue;

  /// Whether this is a predefined system category (cannot be deleted).
  final bool isSystem;

  /// Sort display order.
  final int sortOrder;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;
  const CategoryRow(
      {required this.id,
      this.parentId,
      required this.name,
      required this.icon,
      required this.colorValue,
      required this.isSystem,
      required this.sortOrder,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_value'] = Variable<int>(colorValue);
    map['is_system'] = Variable<bool>(isSystem);
    map['sort_order'] = Variable<int>(sortOrder);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      icon: Value(icon),
      colorValue: Value(colorValue),
      isSystem: Value(isSystem),
      sortOrder: Value(sortOrder),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorValue': serializer.toJson<int>(colorValue),
      'isSystem': serializer.toJson<bool>(isSystem),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  CategoryRow copyWith(
          {String? id,
          Value<String?> parentId = const Value.absent(),
          String? name,
          String? icon,
          int? colorValue,
          bool? isSystem,
          int? sortOrder,
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      CategoryRow(
        id: id ?? this.id,
        parentId: parentId.present ? parentId.value : this.parentId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorValue: colorValue ?? this.colorValue,
        isSystem: isSystem ?? this.isSystem,
        sortOrder: sortOrder ?? this.sortOrder,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, parentId, name, icon, colorValue,
      isSystem, sortOrder, revision, deletedAt, syncState, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorValue == this.colorValue &&
          other.isSystem == this.isSystem &&
          other.sortOrder == this.sortOrder &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> colorValue;
  final Value<bool> isSystem;
  final Value<int> sortOrder;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    required String icon,
    required int colorValue,
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        icon = Value(icon),
        colorValue = Value(colorValue);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? colorValue,
    Expression<bool>? isSystem,
    Expression<int>? sortOrder,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorValue != null) 'color_value': colorValue,
      if (isSystem != null) 'is_system': isSystem,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? parentId,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? colorValue,
      Value<bool>? isSystem,
      Value<int>? sortOrder,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('VND'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
      paymentMethod = GeneratedColumn<String>(
              'payment_method', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PaymentMethod?>(
              $TransactionsTable.$converterpaymentMethodn);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionSource, String>
      source = GeneratedColumn<String>('source', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionSource>(
              $TransactionsTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionStatus, String>
      status = GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionStatus>(
              $TransactionsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSharedMeta =
      const VerificationMeta('isShared');
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
      'is_shared', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_shared" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByUserIdMeta =
      const VerificationMeta('createdByUserId');
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
      'created_by_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByNameMeta =
      const VerificationMeta('createdByName');
  @override
  late final GeneratedColumn<String> createdByName = GeneratedColumn<String>(
      'created_by_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        currency,
        categoryId,
        merchant,
        occurredAt,
        note,
        paymentMethod,
        source,
        status,
        createdAt,
        updatedAt,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt,
        isShared,
        householdId,
        createdByUserId,
        createdByName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('is_shared')) {
      context.handle(_isSharedMeta,
          isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta));
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
          _createdByUserIdMeta,
          createdByUserId.isAcceptableOrUnknown(
              data['created_by_user_id']!, _createdByUserIdMeta));
    }
    if (data.containsKey('created_by_name')) {
      context.handle(
          _createdByNameMeta,
          createdByName.isAcceptableOrUnknown(
              data['created_by_name']!, _createdByNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: $TransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant']),
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      paymentMethod: $TransactionsTable.$converterpaymentMethodn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_method'])),
      source: $TransactionsTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!),
      status: $TransactionsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      isShared: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_shared'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id']),
      createdByUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}created_by_user_id']),
      createdByName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by_name']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<TransactionType, String> $convertertype =
      const TransactionTypeConverter();
  static TypeConverter<PaymentMethod, String> $converterpaymentMethod =
      const PaymentMethodConverter();
  static TypeConverter<PaymentMethod?, String?> $converterpaymentMethodn =
      NullAwareTypeConverter.wrap($converterpaymentMethod);
  static TypeConverter<TransactionSource, String> $convertersource =
      const TransactionSourceConverter();
  static TypeConverter<TransactionStatus, String> $converterstatus =
      const TransactionStatusConverter();
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  /// Unique identifier (ULID / UUID v7).
  final String id;

  /// Transaction type: 'expense' or 'income' (snake_case via converter, A.1.1).
  final TransactionType type;

  /// Monetary amount.
  final double amount;

  /// Currency code (e.g. 'VND').
  final String currency;

  /// Foreign key to Categories.id.
  final String categoryId;

  /// Merchant or store name (e.g. "Highlands Coffee").
  final String? merchant;

  /// Timestamp when the transaction took place.
  final DateTime occurredAt;

  /// Optional user notes.
  final String? note;

  /// Payment method (snake_case via converter, A.1.1).
  final PaymentMethod? paymentMethod;

  /// Source (snake_case via converter, A.1.1).
  final TransactionSource source;

  /// Status (snake_case via converter, A.1.1).
  final TransactionStatus status;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;

  /// Privacy opt-in flag: only shared transactions are visible to household.
  final bool isShared;

  /// Optional household ID when [isShared] is true.
  final String? householdId;

  /// Creator user ID populated by server for shared transactions.
  final String? createdByUserId;

  /// Creator display name populated for shared transactions.
  final String? createdByName;
  const TransactionRow(
      {required this.id,
      required this.type,
      required this.amount,
      required this.currency,
      required this.categoryId,
      this.merchant,
      required this.occurredAt,
      this.note,
      this.paymentMethod,
      required this.source,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt,
      required this.isShared,
      this.householdId,
      this.createdByUserId,
      this.createdByName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] =
          Variable<String>($TransactionsTable.$convertertype.toSql(type));
    }
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(
          $TransactionsTable.$converterpaymentMethodn.toSql(paymentMethod));
    }
    {
      map['source'] =
          Variable<String>($TransactionsTable.$convertersource.toSql(source));
    }
    {
      map['status'] =
          Variable<String>($TransactionsTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['is_shared'] = Variable<bool>(isShared);
    if (!nullToAbsent || householdId != null) {
      map['household_id'] = Variable<String>(householdId);
    }
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<String>(createdByUserId);
    }
    if (!nullToAbsent || createdByName != null) {
      map['created_by_name'] = Variable<String>(createdByName);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      currency: Value(currency),
      categoryId: Value(categoryId),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      occurredAt: Value(occurredAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      source: Value(source),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      isShared: Value(isShared),
      householdId: householdId == null && nullToAbsent
          ? const Value.absent()
          : Value(householdId),
      createdByUserId: createdByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByUserId),
      createdByName: createdByName == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByName),
    );
  }

  factory TransactionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<TransactionType>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      note: serializer.fromJson<String?>(json['note']),
      paymentMethod: serializer.fromJson<PaymentMethod?>(json['paymentMethod']),
      source: serializer.fromJson<TransactionSource>(json['source']),
      status: serializer.fromJson<TransactionStatus>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      householdId: serializer.fromJson<String?>(json['householdId']),
      createdByUserId: serializer.fromJson<String?>(json['createdByUserId']),
      createdByName: serializer.fromJson<String?>(json['createdByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<TransactionType>(type),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<String>(categoryId),
      'merchant': serializer.toJson<String?>(merchant),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'note': serializer.toJson<String?>(note),
      'paymentMethod': serializer.toJson<PaymentMethod?>(paymentMethod),
      'source': serializer.toJson<TransactionSource>(source),
      'status': serializer.toJson<TransactionStatus>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'isShared': serializer.toJson<bool>(isShared),
      'householdId': serializer.toJson<String?>(householdId),
      'createdByUserId': serializer.toJson<String?>(createdByUserId),
      'createdByName': serializer.toJson<String?>(createdByName),
    };
  }

  TransactionRow copyWith(
          {String? id,
          TransactionType? type,
          double? amount,
          String? currency,
          String? categoryId,
          Value<String?> merchant = const Value.absent(),
          DateTime? occurredAt,
          Value<String?> note = const Value.absent(),
          Value<PaymentMethod?> paymentMethod = const Value.absent(),
          TransactionSource? source,
          TransactionStatus? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? isShared,
          Value<String?> householdId = const Value.absent(),
          Value<String?> createdByUserId = const Value.absent(),
          Value<String?> createdByName = const Value.absent()}) =>
      TransactionRow(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        categoryId: categoryId ?? this.categoryId,
        merchant: merchant.present ? merchant.value : this.merchant,
        occurredAt: occurredAt ?? this.occurredAt,
        note: note.present ? note.value : this.note,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        source: source ?? this.source,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        isShared: isShared ?? this.isShared,
        householdId: householdId.present ? householdId.value : this.householdId,
        createdByUserId: createdByUserId.present
            ? createdByUserId.value
            : this.createdByUserId,
        createdByName:
            createdByName.present ? createdByName.value : this.createdByName,
      );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      note: data.note.present ? data.note.value : this.note,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdByName: data.createdByName.present
          ? data.createdByName.value
          : this.createdByName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isShared: $isShared, ')
          ..write('householdId: $householdId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdByName: $createdByName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        type,
        amount,
        currency,
        categoryId,
        merchant,
        occurredAt,
        note,
        paymentMethod,
        source,
        status,
        createdAt,
        updatedAt,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt,
        isShared,
        householdId,
        createdByUserId,
        createdByName
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.merchant == this.merchant &&
          other.occurredAt == this.occurredAt &&
          other.note == this.note &&
          other.paymentMethod == this.paymentMethod &&
          other.source == this.source &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.isShared == this.isShared &&
          other.householdId == this.householdId &&
          other.createdByUserId == this.createdByUserId &&
          other.createdByName == this.createdByName);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<TransactionType> type;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> categoryId;
  final Value<String?> merchant;
  final Value<DateTime> occurredAt;
  final Value<String?> note;
  final Value<PaymentMethod?> paymentMethod;
  final Value<TransactionSource> source;
  final Value<TransactionStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> isShared;
  final Value<String?> householdId;
  final Value<String?> createdByUserId;
  final Value<String?> createdByName;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isShared = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required TransactionType type,
    required double amount,
    this.currency = const Value.absent(),
    required String categoryId,
    this.merchant = const Value.absent(),
    required DateTime occurredAt,
    this.note = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    required TransactionSource source,
    required TransactionStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isShared = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        amount = Value(amount),
        categoryId = Value(categoryId),
        occurredAt = Value(occurredAt),
        source = Value(source),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? categoryId,
    Expression<String>? merchant,
    Expression<DateTime>? occurredAt,
    Expression<String>? note,
    Expression<String>? paymentMethod,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? isShared,
    Expression<String>? householdId,
    Expression<String>? createdByUserId,
    Expression<String>? createdByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (merchant != null) 'merchant': merchant,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (note != null) 'note': note,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (isShared != null) 'is_shared': isShared,
      if (householdId != null) 'household_id': householdId,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdByName != null) 'created_by_name': createdByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<TransactionType>? type,
      Value<double>? amount,
      Value<String>? currency,
      Value<String>? categoryId,
      Value<String?>? merchant,
      Value<DateTime>? occurredAt,
      Value<String?>? note,
      Value<PaymentMethod?>? paymentMethod,
      Value<TransactionSource>? source,
      Value<TransactionStatus>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? isShared,
      Value<String?>? householdId,
      Value<String?>? createdByUserId,
      Value<String?>? createdByName,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      merchant: merchant ?? this.merchant,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isShared: isShared ?? this.isShared,
      householdId: householdId ?? this.householdId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByName: createdByName ?? this.createdByName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($TransactionsTable.$convertertype.toSql(type.value));
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>($TransactionsTable
          .$converterpaymentMethodn
          .toSql(paymentMethod.value));
    }
    if (source.present) {
      map['source'] = Variable<String>(
          $TransactionsTable.$convertersource.toSql(source.value));
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $TransactionsTable.$converterstatus.toSql(status.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdByName.present) {
      map['created_by_name'] = Variable<String>(createdByName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isShared: $isShared, ')
          ..write('householdId: $householdId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdByName: $createdByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionMediasTable extends TransactionMedias
    with TableInfo<$TransactionMediasTable, TransactionMediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionMediasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MediaType>($TransactionMediasTable.$convertertype);
  static const VerificationMeta _originalPathMeta =
      const VerificationMeta('originalPath');
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
      'original_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _compressedPathMeta =
      const VerificationMeta('compressedPath');
  @override
  late final GeneratedColumn<String> compressedPath = GeneratedColumn<String>(
      'compressed_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        type,
        originalPath,
        compressedPath,
        thumbnailPath,
        hash,
        width,
        height,
        fileSizeBytes,
        capturedAt,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_medias';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionMediaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('original_path')) {
      context.handle(
          _originalPathMeta,
          originalPath.isAcceptableOrUnknown(
              data['original_path']!, _originalPathMeta));
    }
    if (data.containsKey('compressed_path')) {
      context.handle(
          _compressedPathMeta,
          compressedPath.isAcceptableOrUnknown(
              data['compressed_path']!, _compressedPathMeta));
    } else if (isInserting) {
      context.missing(_compressedPathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    } else if (isInserting) {
      context.missing(_thumbnailPathMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionMediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionMediaRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      type: $TransactionMediasTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      originalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_path']),
      compressedPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}compressed_path'])!,
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $TransactionMediasTable createAlias(String alias) {
    return $TransactionMediasTable(attachedDatabase, alias);
  }

  static TypeConverter<MediaType, String> $convertertype =
      const MediaTypeConverter();
}

class TransactionMediaRow extends DataClass
    implements Insertable<TransactionMediaRow> {
  /// Unique identifier.
  final String id;

  /// Foreign key to Transactions.id.
  final String transactionId;

  /// Media type (snake_case via converter, A.1.1).
  final MediaType type;

  /// Local path to original image (nullable if user chose not to keep original).
  final String? originalPath;

  /// Local path to compressed image (max 2048px).
  final String compressedPath;

  /// Local path to 200x200 square thumbnail.
  final String thumbnailPath;

  /// SHA-256 hash of the image content for deduplication.
  final String hash;

  /// Image width in pixels.
  final int? width;

  /// Image height in pixels.
  final int? height;

  /// File size in bytes.
  final int? fileSizeBytes;

  /// Timestamp when photo was captured.
  final DateTime? capturedAt;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;
  const TransactionMediaRow(
      {required this.id,
      required this.transactionId,
      required this.type,
      this.originalPath,
      required this.compressedPath,
      required this.thumbnailPath,
      required this.hash,
      this.width,
      this.height,
      this.fileSizeBytes,
      this.capturedAt,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    {
      map['type'] =
          Variable<String>($TransactionMediasTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || originalPath != null) {
      map['original_path'] = Variable<String>(originalPath);
    }
    map['compressed_path'] = Variable<String>(compressedPath);
    map['thumbnail_path'] = Variable<String>(thumbnailPath);
    map['hash'] = Variable<String>(hash);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  TransactionMediasCompanion toCompanion(bool nullToAbsent) {
    return TransactionMediasCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      type: Value(type),
      originalPath: originalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(originalPath),
      compressedPath: Value(compressedPath),
      thumbnailPath: Value(thumbnailPath),
      hash: Value(hash),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory TransactionMediaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionMediaRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      type: serializer.fromJson<MediaType>(json['type']),
      originalPath: serializer.fromJson<String?>(json['originalPath']),
      compressedPath: serializer.fromJson<String>(json['compressedPath']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
      hash: serializer.fromJson<String>(json['hash']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'type': serializer.toJson<MediaType>(type),
      'originalPath': serializer.toJson<String?>(originalPath),
      'compressedPath': serializer.toJson<String>(compressedPath),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
      'hash': serializer.toJson<String>(hash),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  TransactionMediaRow copyWith(
          {String? id,
          String? transactionId,
          MediaType? type,
          Value<String?> originalPath = const Value.absent(),
          String? compressedPath,
          String? thumbnailPath,
          String? hash,
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          Value<int?> fileSizeBytes = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent(),
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      TransactionMediaRow(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        type: type ?? this.type,
        originalPath:
            originalPath.present ? originalPath.value : this.originalPath,
        compressedPath: compressedPath ?? this.compressedPath,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
        hash: hash ?? this.hash,
        width: width.present ? width.value : this.width,
        height: height.present ? height.value : this.height,
        fileSizeBytes:
            fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
        capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  TransactionMediaRow copyWithCompanion(TransactionMediasCompanion data) {
    return TransactionMediaRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      type: data.type.present ? data.type.value : this.type,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      compressedPath: data.compressedPath.present
          ? data.compressedPath.value
          : this.compressedPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      hash: data.hash.present ? data.hash.value : this.hash,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionMediaRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('type: $type, ')
          ..write('originalPath: $originalPath, ')
          ..write('compressedPath: $compressedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('hash: $hash, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      type,
      originalPath,
      compressedPath,
      thumbnailPath,
      hash,
      width,
      height,
      fileSizeBytes,
      capturedAt,
      revision,
      deletedAt,
      syncState,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionMediaRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.type == this.type &&
          other.originalPath == this.originalPath &&
          other.compressedPath == this.compressedPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.hash == this.hash &&
          other.width == this.width &&
          other.height == this.height &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.capturedAt == this.capturedAt &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TransactionMediasCompanion extends UpdateCompanion<TransactionMediaRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<MediaType> type;
  final Value<String?> originalPath;
  final Value<String> compressedPath;
  final Value<String> thumbnailPath;
  final Value<String> hash;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> fileSizeBytes;
  final Value<DateTime?> capturedAt;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const TransactionMediasCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.type = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.compressedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.hash = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionMediasCompanion.insert({
    required String id,
    required String transactionId,
    required MediaType type,
    this.originalPath = const Value.absent(),
    required String compressedPath,
    required String thumbnailPath,
    required String hash,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionId = Value(transactionId),
        type = Value(type),
        compressedPath = Value(compressedPath),
        thumbnailPath = Value(thumbnailPath),
        hash = Value(hash);
  static Insertable<TransactionMediaRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? type,
    Expression<String>? originalPath,
    Expression<String>? compressedPath,
    Expression<String>? thumbnailPath,
    Expression<String>? hash,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? fileSizeBytes,
    Expression<DateTime>? capturedAt,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (type != null) 'type': type,
      if (originalPath != null) 'original_path': originalPath,
      if (compressedPath != null) 'compressed_path': compressedPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (hash != null) 'hash': hash,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionMediasCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<MediaType>? type,
      Value<String?>? originalPath,
      Value<String>? compressedPath,
      Value<String>? thumbnailPath,
      Value<String>? hash,
      Value<int?>? width,
      Value<int?>? height,
      Value<int?>? fileSizeBytes,
      Value<DateTime?>? capturedAt,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return TransactionMediasCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      originalPath: originalPath ?? this.originalPath,
      compressedPath: compressedPath ?? this.compressedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      hash: hash ?? this.hash,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $TransactionMediasTable.$convertertype.toSql(type.value));
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (compressedPath.present) {
      map['compressed_path'] = Variable<String>(compressedPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionMediasCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('type: $type, ')
          ..write('originalPath: $originalPath, ')
          ..write('compressedPath: $compressedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('hash: $hash, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _amountLimitMeta =
      const VerificationMeta('amountLimit');
  @override
  late final GeneratedColumn<double> amountLimit = GeneratedColumn<double>(
      'amount_limit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _alertThresholdsMeta =
      const VerificationMeta('alertThresholds');
  @override
  late final GeneratedColumn<String> alertThresholds = GeneratedColumn<String>(
      'alert_thresholds', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('0.8,1.0,1.2'));
  static const VerificationMeta _alertSentAt80Meta =
      const VerificationMeta('alertSentAt80');
  @override
  late final GeneratedColumn<bool> alertSentAt80 = GeneratedColumn<bool>(
      'alert_sent_at80', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("alert_sent_at80" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _alertSentAt100Meta =
      const VerificationMeta('alertSentAt100');
  @override
  late final GeneratedColumn<bool> alertSentAt100 = GeneratedColumn<bool>(
      'alert_sent_at100', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("alert_sent_at100" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _alertSentAt120Meta =
      const VerificationMeta('alertSentAt120');
  @override
  late final GeneratedColumn<bool> alertSentAt120 = GeneratedColumn<bool>(
      'alert_sent_at120', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("alert_sent_at120" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
      'period_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        householdId,
        period,
        amountLimit,
        alertThresholds,
        alertSentAt80,
        alertSentAt100,
        alertSentAt120,
        periodStart,
        periodEnd,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('amount_limit')) {
      context.handle(
          _amountLimitMeta,
          amountLimit.isAcceptableOrUnknown(
              data['amount_limit']!, _amountLimitMeta));
    } else if (isInserting) {
      context.missing(_amountLimitMeta);
    }
    if (data.containsKey('alert_thresholds')) {
      context.handle(
          _alertThresholdsMeta,
          alertThresholds.isAcceptableOrUnknown(
              data['alert_thresholds']!, _alertThresholdsMeta));
    }
    if (data.containsKey('alert_sent_at80')) {
      context.handle(
          _alertSentAt80Meta,
          alertSentAt80.isAcceptableOrUnknown(
              data['alert_sent_at80']!, _alertSentAt80Meta));
    }
    if (data.containsKey('alert_sent_at100')) {
      context.handle(
          _alertSentAt100Meta,
          alertSentAt100.isAcceptableOrUnknown(
              data['alert_sent_at100']!, _alertSentAt100Meta));
    }
    if (data.containsKey('alert_sent_at120')) {
      context.handle(
          _alertSentAt120Meta,
          alertSentAt120.isAcceptableOrUnknown(
              data['alert_sent_at120']!, _alertSentAt120Meta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id']),
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      amountLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_limit'])!,
      alertThresholds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}alert_thresholds'])!,
      alertSentAt80: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_sent_at80'])!,
      alertSentAt100: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_sent_at100'])!,
      alertSentAt120: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_sent_at120'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  /// Unique identifier.
  final String id;

  /// Foreign key to Categories.id.
  final String categoryId;

  /// Optional household ID for shared family budgets.
  final String? householdId;

  /// Budget period: 'monthly', 'weekly', 'custom'.
  final String period;

  /// Spending limit amount.
  final double amountLimit;

  /// Comma-separated list of alert thresholds (e.g. "0.8,1.0,1.2").
  final String alertThresholds;

  /// Whether the 80% alert has already been sent for this cycle.
  final bool alertSentAt80;

  /// Whether the 100% alert has already been sent for this cycle.
  final bool alertSentAt100;

  /// Whether the 120% critical alert has already been sent for this cycle
  /// (§4.6 #16).
  final bool alertSentAt120;

  /// Start timestamp of current budget period.
  final DateTime periodStart;

  /// End timestamp of current budget period.
  final DateTime periodEnd;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;
  const BudgetRow(
      {required this.id,
      required this.categoryId,
      this.householdId,
      required this.period,
      required this.amountLimit,
      required this.alertThresholds,
      required this.alertSentAt80,
      required this.alertSentAt100,
      required this.alertSentAt120,
      required this.periodStart,
      required this.periodEnd,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || householdId != null) {
      map['household_id'] = Variable<String>(householdId);
    }
    map['period'] = Variable<String>(period);
    map['amount_limit'] = Variable<double>(amountLimit);
    map['alert_thresholds'] = Variable<String>(alertThresholds);
    map['alert_sent_at80'] = Variable<bool>(alertSentAt80);
    map['alert_sent_at100'] = Variable<bool>(alertSentAt100);
    map['alert_sent_at120'] = Variable<bool>(alertSentAt120);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      householdId: householdId == null && nullToAbsent
          ? const Value.absent()
          : Value(householdId),
      period: Value(period),
      amountLimit: Value(amountLimit),
      alertThresholds: Value(alertThresholds),
      alertSentAt80: Value(alertSentAt80),
      alertSentAt100: Value(alertSentAt100),
      alertSentAt120: Value(alertSentAt120),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory BudgetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      householdId: serializer.fromJson<String?>(json['householdId']),
      period: serializer.fromJson<String>(json['period']),
      amountLimit: serializer.fromJson<double>(json['amountLimit']),
      alertThresholds: serializer.fromJson<String>(json['alertThresholds']),
      alertSentAt80: serializer.fromJson<bool>(json['alertSentAt80']),
      alertSentAt100: serializer.fromJson<bool>(json['alertSentAt100']),
      alertSentAt120: serializer.fromJson<bool>(json['alertSentAt120']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'householdId': serializer.toJson<String?>(householdId),
      'period': serializer.toJson<String>(period),
      'amountLimit': serializer.toJson<double>(amountLimit),
      'alertThresholds': serializer.toJson<String>(alertThresholds),
      'alertSentAt80': serializer.toJson<bool>(alertSentAt80),
      'alertSentAt100': serializer.toJson<bool>(alertSentAt100),
      'alertSentAt120': serializer.toJson<bool>(alertSentAt120),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  BudgetRow copyWith(
          {String? id,
          String? categoryId,
          Value<String?> householdId = const Value.absent(),
          String? period,
          double? amountLimit,
          String? alertThresholds,
          bool? alertSentAt80,
          bool? alertSentAt100,
          bool? alertSentAt120,
          DateTime? periodStart,
          DateTime? periodEnd,
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      BudgetRow(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        householdId: householdId.present ? householdId.value : this.householdId,
        period: period ?? this.period,
        amountLimit: amountLimit ?? this.amountLimit,
        alertThresholds: alertThresholds ?? this.alertThresholds,
        alertSentAt80: alertSentAt80 ?? this.alertSentAt80,
        alertSentAt100: alertSentAt100 ?? this.alertSentAt100,
        alertSentAt120: alertSentAt120 ?? this.alertSentAt120,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      period: data.period.present ? data.period.value : this.period,
      amountLimit:
          data.amountLimit.present ? data.amountLimit.value : this.amountLimit,
      alertThresholds: data.alertThresholds.present
          ? data.alertThresholds.value
          : this.alertThresholds,
      alertSentAt80: data.alertSentAt80.present
          ? data.alertSentAt80.value
          : this.alertSentAt80,
      alertSentAt100: data.alertSentAt100.present
          ? data.alertSentAt100.value
          : this.alertSentAt100,
      alertSentAt120: data.alertSentAt120.present
          ? data.alertSentAt120.value
          : this.alertSentAt120,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('householdId: $householdId, ')
          ..write('period: $period, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('alertThresholds: $alertThresholds, ')
          ..write('alertSentAt80: $alertSentAt80, ')
          ..write('alertSentAt100: $alertSentAt100, ')
          ..write('alertSentAt120: $alertSentAt120, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      categoryId,
      householdId,
      period,
      amountLimit,
      alertThresholds,
      alertSentAt80,
      alertSentAt100,
      alertSentAt120,
      periodStart,
      periodEnd,
      revision,
      deletedAt,
      syncState,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.householdId == this.householdId &&
          other.period == this.period &&
          other.amountLimit == this.amountLimit &&
          other.alertThresholds == this.alertThresholds &&
          other.alertSentAt80 == this.alertSentAt80 &&
          other.alertSentAt100 == this.alertSentAt100 &&
          other.alertSentAt120 == this.alertSentAt120 &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String?> householdId;
  final Value<String> period;
  final Value<double> amountLimit;
  final Value<String> alertThresholds;
  final Value<bool> alertSentAt80;
  final Value<bool> alertSentAt100;
  final Value<bool> alertSentAt120;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.period = const Value.absent(),
    this.amountLimit = const Value.absent(),
    this.alertThresholds = const Value.absent(),
    this.alertSentAt80 = const Value.absent(),
    this.alertSentAt100 = const Value.absent(),
    this.alertSentAt120 = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    this.householdId = const Value.absent(),
    this.period = const Value.absent(),
    required double amountLimit,
    this.alertThresholds = const Value.absent(),
    this.alertSentAt80 = const Value.absent(),
    this.alertSentAt100 = const Value.absent(),
    this.alertSentAt120 = const Value.absent(),
    required DateTime periodStart,
    required DateTime periodEnd,
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        amountLimit = Value(amountLimit),
        periodStart = Value(periodStart),
        periodEnd = Value(periodEnd);
  static Insertable<BudgetRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? householdId,
    Expression<String>? period,
    Expression<double>? amountLimit,
    Expression<String>? alertThresholds,
    Expression<bool>? alertSentAt80,
    Expression<bool>? alertSentAt100,
    Expression<bool>? alertSentAt120,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (householdId != null) 'household_id': householdId,
      if (period != null) 'period': period,
      if (amountLimit != null) 'amount_limit': amountLimit,
      if (alertThresholds != null) 'alert_thresholds': alertThresholds,
      if (alertSentAt80 != null) 'alert_sent_at80': alertSentAt80,
      if (alertSentAt100 != null) 'alert_sent_at100': alertSentAt100,
      if (alertSentAt120 != null) 'alert_sent_at120': alertSentAt120,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String?>? householdId,
      Value<String>? period,
      Value<double>? amountLimit,
      Value<String>? alertThresholds,
      Value<bool>? alertSentAt80,
      Value<bool>? alertSentAt100,
      Value<bool>? alertSentAt120,
      Value<DateTime>? periodStart,
      Value<DateTime>? periodEnd,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      householdId: householdId ?? this.householdId,
      period: period ?? this.period,
      amountLimit: amountLimit ?? this.amountLimit,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      alertSentAt80: alertSentAt80 ?? this.alertSentAt80,
      alertSentAt100: alertSentAt100 ?? this.alertSentAt100,
      alertSentAt120: alertSentAt120 ?? this.alertSentAt120,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (amountLimit.present) {
      map['amount_limit'] = Variable<double>(amountLimit.value);
    }
    if (alertThresholds.present) {
      map['alert_thresholds'] = Variable<String>(alertThresholds.value);
    }
    if (alertSentAt80.present) {
      map['alert_sent_at80'] = Variable<bool>(alertSentAt80.value);
    }
    if (alertSentAt100.present) {
      map['alert_sent_at100'] = Variable<bool>(alertSentAt100.value);
    }
    if (alertSentAt120.present) {
      map['alert_sent_at120'] = Variable<bool>(alertSentAt120.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('householdId: $householdId, ')
          ..write('period: $period, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('alertThresholds: $alertThresholds, ')
          ..write('alertSentAt80: $alertSentAt80, ')
          ..write('alertSentAt100: $alertSentAt100, ')
          ..write('alertSentAt120: $alertSentAt120, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIInferencesTable extends AIInferences
    with TableInfo<$AIInferencesTable, AIInferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIInferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
      'media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelsJsonMeta =
      const VerificationMeta('labelsJson');
  @override
  late final GeneratedColumn<String> labelsJson = GeneratedColumn<String>(
      'labels_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _suggestedCategoryIdMeta =
      const VerificationMeta('suggestedCategoryId');
  @override
  late final GeneratedColumn<String> suggestedCategoryId =
      GeneratedColumn<String>('suggested_category_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _suggestedCategoryConfidenceMeta =
      const VerificationMeta('suggestedCategoryConfidence');
  @override
  late final GeneratedColumn<double> suggestedCategoryConfidence =
      GeneratedColumn<double>(
          'suggested_category_confidence', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _extractedAmountsJsonMeta =
      const VerificationMeta('extractedAmountsJson');
  @override
  late final GeneratedColumn<String> extractedAmountsJson =
      GeneratedColumn<String>('extracted_amounts_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _latencyMsMeta =
      const VerificationMeta('latencyMs');
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
      'latency_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('on_device'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mediaId,
        modelVersion,
        labelsJson,
        suggestedCategoryId,
        suggestedCategoryConfidence,
        extractedAmountsJson,
        confidence,
        latencyMs,
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'a_i_inferences';
  @override
  VerificationContext validateIntegrity(Insertable<AIInferenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('labels_json')) {
      context.handle(
          _labelsJsonMeta,
          labelsJson.isAcceptableOrUnknown(
              data['labels_json']!, _labelsJsonMeta));
    }
    if (data.containsKey('suggested_category_id')) {
      context.handle(
          _suggestedCategoryIdMeta,
          suggestedCategoryId.isAcceptableOrUnknown(
              data['suggested_category_id']!, _suggestedCategoryIdMeta));
    }
    if (data.containsKey('suggested_category_confidence')) {
      context.handle(
          _suggestedCategoryConfidenceMeta,
          suggestedCategoryConfidence.isAcceptableOrUnknown(
              data['suggested_category_confidence']!,
              _suggestedCategoryConfidenceMeta));
    }
    if (data.containsKey('extracted_amounts_json')) {
      context.handle(
          _extractedAmountsJsonMeta,
          extractedAmountsJson.isAcceptableOrUnknown(
              data['extracted_amounts_json']!, _extractedAmountsJsonMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('latency_ms')) {
      context.handle(_latencyMsMeta,
          latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta));
    } else if (isInserting) {
      context.missing(_latencyMsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIInferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIInferenceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version'])!,
      labelsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}labels_json'])!,
      suggestedCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggested_category_id']),
      suggestedCategoryConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}suggested_category_confidence']),
      extractedAmountsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extracted_amounts_json'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      latencyMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latency_ms'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $AIInferencesTable createAlias(String alias) {
    return $AIInferencesTable(attachedDatabase, alias);
  }
}

class AIInferenceRow extends DataClass implements Insertable<AIInferenceRow> {
  /// Unique identifier.
  final String id;

  /// Foreign key to TransactionMedias.id.
  final String mediaId;

  /// Model version string (e.g. "mlkit-image-labeling-v1").
  final String modelVersion;

  /// JSON string of detected labels [{name: "coffee", confidence: 0.94}].
  final String labelsJson;

  /// Suggested category ID if any.
  final String? suggestedCategoryId;

  /// Suggested category confidence (0.0 to 1.0).
  final double? suggestedCategoryConfidence;

  /// JSON string of detected amounts.
  final String extractedAmountsJson;

  /// Overall inference confidence.
  final double confidence;

  /// Latency in milliseconds.
  final int latencyMs;

  /// Inference source: 'on_device' or 'cloud'.
  final String source;
  const AIInferenceRow(
      {required this.id,
      required this.mediaId,
      required this.modelVersion,
      required this.labelsJson,
      this.suggestedCategoryId,
      this.suggestedCategoryConfidence,
      required this.extractedAmountsJson,
      required this.confidence,
      required this.latencyMs,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_id'] = Variable<String>(mediaId);
    map['model_version'] = Variable<String>(modelVersion);
    map['labels_json'] = Variable<String>(labelsJson);
    if (!nullToAbsent || suggestedCategoryId != null) {
      map['suggested_category_id'] = Variable<String>(suggestedCategoryId);
    }
    if (!nullToAbsent || suggestedCategoryConfidence != null) {
      map['suggested_category_confidence'] =
          Variable<double>(suggestedCategoryConfidence);
    }
    map['extracted_amounts_json'] = Variable<String>(extractedAmountsJson);
    map['confidence'] = Variable<double>(confidence);
    map['latency_ms'] = Variable<int>(latencyMs);
    map['source'] = Variable<String>(source);
    return map;
  }

  AIInferencesCompanion toCompanion(bool nullToAbsent) {
    return AIInferencesCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      modelVersion: Value(modelVersion),
      labelsJson: Value(labelsJson),
      suggestedCategoryId: suggestedCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedCategoryId),
      suggestedCategoryConfidence:
          suggestedCategoryConfidence == null && nullToAbsent
              ? const Value.absent()
              : Value(suggestedCategoryConfidence),
      extractedAmountsJson: Value(extractedAmountsJson),
      confidence: Value(confidence),
      latencyMs: Value(latencyMs),
      source: Value(source),
    );
  }

  factory AIInferenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIInferenceRow(
      id: serializer.fromJson<String>(json['id']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      labelsJson: serializer.fromJson<String>(json['labelsJson']),
      suggestedCategoryId:
          serializer.fromJson<String?>(json['suggestedCategoryId']),
      suggestedCategoryConfidence:
          serializer.fromJson<double?>(json['suggestedCategoryConfidence']),
      extractedAmountsJson:
          serializer.fromJson<String>(json['extractedAmountsJson']),
      confidence: serializer.fromJson<double>(json['confidence']),
      latencyMs: serializer.fromJson<int>(json['latencyMs']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaId': serializer.toJson<String>(mediaId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'labelsJson': serializer.toJson<String>(labelsJson),
      'suggestedCategoryId': serializer.toJson<String?>(suggestedCategoryId),
      'suggestedCategoryConfidence':
          serializer.toJson<double?>(suggestedCategoryConfidence),
      'extractedAmountsJson': serializer.toJson<String>(extractedAmountsJson),
      'confidence': serializer.toJson<double>(confidence),
      'latencyMs': serializer.toJson<int>(latencyMs),
      'source': serializer.toJson<String>(source),
    };
  }

  AIInferenceRow copyWith(
          {String? id,
          String? mediaId,
          String? modelVersion,
          String? labelsJson,
          Value<String?> suggestedCategoryId = const Value.absent(),
          Value<double?> suggestedCategoryConfidence = const Value.absent(),
          String? extractedAmountsJson,
          double? confidence,
          int? latencyMs,
          String? source}) =>
      AIInferenceRow(
        id: id ?? this.id,
        mediaId: mediaId ?? this.mediaId,
        modelVersion: modelVersion ?? this.modelVersion,
        labelsJson: labelsJson ?? this.labelsJson,
        suggestedCategoryId: suggestedCategoryId.present
            ? suggestedCategoryId.value
            : this.suggestedCategoryId,
        suggestedCategoryConfidence: suggestedCategoryConfidence.present
            ? suggestedCategoryConfidence.value
            : this.suggestedCategoryConfidence,
        extractedAmountsJson: extractedAmountsJson ?? this.extractedAmountsJson,
        confidence: confidence ?? this.confidence,
        latencyMs: latencyMs ?? this.latencyMs,
        source: source ?? this.source,
      );
  AIInferenceRow copyWithCompanion(AIInferencesCompanion data) {
    return AIInferenceRow(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      labelsJson:
          data.labelsJson.present ? data.labelsJson.value : this.labelsJson,
      suggestedCategoryId: data.suggestedCategoryId.present
          ? data.suggestedCategoryId.value
          : this.suggestedCategoryId,
      suggestedCategoryConfidence: data.suggestedCategoryConfidence.present
          ? data.suggestedCategoryConfidence.value
          : this.suggestedCategoryConfidence,
      extractedAmountsJson: data.extractedAmountsJson.present
          ? data.extractedAmountsJson.value
          : this.extractedAmountsJson,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIInferenceRow(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('labelsJson: $labelsJson, ')
          ..write('suggestedCategoryId: $suggestedCategoryId, ')
          ..write('suggestedCategoryConfidence: $suggestedCategoryConfidence, ')
          ..write('extractedAmountsJson: $extractedAmountsJson, ')
          ..write('confidence: $confidence, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mediaId,
      modelVersion,
      labelsJson,
      suggestedCategoryId,
      suggestedCategoryConfidence,
      extractedAmountsJson,
      confidence,
      latencyMs,
      source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIInferenceRow &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.modelVersion == this.modelVersion &&
          other.labelsJson == this.labelsJson &&
          other.suggestedCategoryId == this.suggestedCategoryId &&
          other.suggestedCategoryConfidence ==
              this.suggestedCategoryConfidence &&
          other.extractedAmountsJson == this.extractedAmountsJson &&
          other.confidence == this.confidence &&
          other.latencyMs == this.latencyMs &&
          other.source == this.source);
}

class AIInferencesCompanion extends UpdateCompanion<AIInferenceRow> {
  final Value<String> id;
  final Value<String> mediaId;
  final Value<String> modelVersion;
  final Value<String> labelsJson;
  final Value<String?> suggestedCategoryId;
  final Value<double?> suggestedCategoryConfidence;
  final Value<String> extractedAmountsJson;
  final Value<double> confidence;
  final Value<int> latencyMs;
  final Value<String> source;
  final Value<int> rowid;
  const AIInferencesCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.labelsJson = const Value.absent(),
    this.suggestedCategoryId = const Value.absent(),
    this.suggestedCategoryConfidence = const Value.absent(),
    this.extractedAmountsJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIInferencesCompanion.insert({
    required String id,
    required String mediaId,
    required String modelVersion,
    this.labelsJson = const Value.absent(),
    this.suggestedCategoryId = const Value.absent(),
    this.suggestedCategoryConfidence = const Value.absent(),
    this.extractedAmountsJson = const Value.absent(),
    required double confidence,
    required int latencyMs,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mediaId = Value(mediaId),
        modelVersion = Value(modelVersion),
        confidence = Value(confidence),
        latencyMs = Value(latencyMs);
  static Insertable<AIInferenceRow> custom({
    Expression<String>? id,
    Expression<String>? mediaId,
    Expression<String>? modelVersion,
    Expression<String>? labelsJson,
    Expression<String>? suggestedCategoryId,
    Expression<double>? suggestedCategoryConfidence,
    Expression<String>? extractedAmountsJson,
    Expression<double>? confidence,
    Expression<int>? latencyMs,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (labelsJson != null) 'labels_json': labelsJson,
      if (suggestedCategoryId != null)
        'suggested_category_id': suggestedCategoryId,
      if (suggestedCategoryConfidence != null)
        'suggested_category_confidence': suggestedCategoryConfidence,
      if (extractedAmountsJson != null)
        'extracted_amounts_json': extractedAmountsJson,
      if (confidence != null) 'confidence': confidence,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIInferencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? mediaId,
      Value<String>? modelVersion,
      Value<String>? labelsJson,
      Value<String?>? suggestedCategoryId,
      Value<double?>? suggestedCategoryConfidence,
      Value<String>? extractedAmountsJson,
      Value<double>? confidence,
      Value<int>? latencyMs,
      Value<String>? source,
      Value<int>? rowid}) {
    return AIInferencesCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      modelVersion: modelVersion ?? this.modelVersion,
      labelsJson: labelsJson ?? this.labelsJson,
      suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
      suggestedCategoryConfidence:
          suggestedCategoryConfidence ?? this.suggestedCategoryConfidence,
      extractedAmountsJson: extractedAmountsJson ?? this.extractedAmountsJson,
      confidence: confidence ?? this.confidence,
      latencyMs: latencyMs ?? this.latencyMs,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (labelsJson.present) {
      map['labels_json'] = Variable<String>(labelsJson.value);
    }
    if (suggestedCategoryId.present) {
      map['suggested_category_id'] =
          Variable<String>(suggestedCategoryId.value);
    }
    if (suggestedCategoryConfidence.present) {
      map['suggested_category_confidence'] =
          Variable<double>(suggestedCategoryConfidence.value);
    }
    if (extractedAmountsJson.present) {
      map['extracted_amounts_json'] =
          Variable<String>(extractedAmountsJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIInferencesCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('labelsJson: $labelsJson, ')
          ..write('suggestedCategoryId: $suggestedCategoryId, ')
          ..write('suggestedCategoryConfidence: $suggestedCategoryConfidence, ')
          ..write('extractedAmountsJson: $extractedAmountsJson, ')
          ..write('confidence: $confidence, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptExtractionsTable extends ReceiptExtractions
    with TableInfo<$ReceiptExtractionsTable, ReceiptExtractionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptExtractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _merchantConfidenceMeta =
      const VerificationMeta('merchantConfidence');
  @override
  late final GeneratedColumn<double> merchantConfidence =
      GeneratedColumn<double>('merchant_confidence', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _merchantUserEditedMeta =
      const VerificationMeta('merchantUserEdited');
  @override
  late final GeneratedColumn<bool> merchantUserEdited = GeneratedColumn<bool>(
      'merchant_user_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("merchant_user_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateConfidenceMeta =
      const VerificationMeta('dateConfidence');
  @override
  late final GeneratedColumn<double> dateConfidence = GeneratedColumn<double>(
      'date_confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalConfidenceMeta =
      const VerificationMeta('totalConfidence');
  @override
  late final GeneratedColumn<double> totalConfidence = GeneratedColumn<double>(
      'total_confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
      'tax', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
      paymentMethod = GeneratedColumn<String>(
              'payment_method', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PaymentMethod?>(
              $ReceiptExtractionsTable.$converterpaymentMethodn);
  static const VerificationMeta _overallConfidenceMeta =
      const VerificationMeta('overallConfidence');
  @override
  late final GeneratedColumn<double> overallConfidence =
      GeneratedColumn<double>('overall_confidence', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiresReviewMeta =
      const VerificationMeta('requiresReview');
  @override
  late final GeneratedColumn<bool> requiresReview = GeneratedColumn<bool>(
      'requires_review', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_review" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        transactionId,
        merchant,
        merchantConfidence,
        merchantUserEdited,
        transactionDate,
        dateConfidence,
        total,
        totalConfidence,
        subtotal,
        tax,
        paymentMethod,
        overallConfidence,
        rawText,
        requiresReview,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_extractions';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReceiptExtractionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    }
    if (data.containsKey('merchant_confidence')) {
      context.handle(
          _merchantConfidenceMeta,
          merchantConfidence.isAcceptableOrUnknown(
              data['merchant_confidence']!, _merchantConfidenceMeta));
    }
    if (data.containsKey('merchant_user_edited')) {
      context.handle(
          _merchantUserEditedMeta,
          merchantUserEdited.isAcceptableOrUnknown(
              data['merchant_user_edited']!, _merchantUserEditedMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    }
    if (data.containsKey('date_confidence')) {
      context.handle(
          _dateConfidenceMeta,
          dateConfidence.isAcceptableOrUnknown(
              data['date_confidence']!, _dateConfidenceMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('total_confidence')) {
      context.handle(
          _totalConfidenceMeta,
          totalConfidence.isAcceptableOrUnknown(
              data['total_confidence']!, _totalConfidenceMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('tax')) {
      context.handle(
          _taxMeta, tax.isAcceptableOrUnknown(data['tax']!, _taxMeta));
    }
    if (data.containsKey('overall_confidence')) {
      context.handle(
          _overallConfidenceMeta,
          overallConfidence.isAcceptableOrUnknown(
              data['overall_confidence']!, _overallConfidenceMeta));
    } else if (isInserting) {
      context.missing(_overallConfidenceMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    }
    if (data.containsKey('requires_review')) {
      context.handle(
          _requiresReviewMeta,
          requiresReview.isAcceptableOrUnknown(
              data['requires_review']!, _requiresReviewMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  ReceiptExtractionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptExtractionRow(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant']),
      merchantConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}merchant_confidence']),
      merchantUserEdited: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}merchant_user_edited'])!,
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date']),
      dateConfidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}date_confidence']),
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total']),
      totalConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_confidence']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal']),
      tax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax']),
      paymentMethod: $ReceiptExtractionsTable.$converterpaymentMethodn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_method'])),
      overallConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}overall_confidence'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text']),
      requiresReview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}requires_review'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ReceiptExtractionsTable createAlias(String alias) {
    return $ReceiptExtractionsTable(attachedDatabase, alias);
  }

  static TypeConverter<PaymentMethod, String> $converterpaymentMethod =
      const PaymentMethodConverter();
  static TypeConverter<PaymentMethod?, String?> $converterpaymentMethodn =
      NullAwareTypeConverter.wrap($converterpaymentMethod);
}

class ReceiptExtractionRow extends DataClass
    implements Insertable<ReceiptExtractionRow> {
  /// Foreign key to Transactions.id (1-to-1 relationship, acts as PK).
  final String transactionId;

  /// Extracted merchant name.
  final String? merchant;

  /// Confidence for merchant extraction.
  final double? merchantConfidence;

  /// Whether user manually edited the merchant field.
  final bool merchantUserEdited;

  /// Extracted transaction date.
  final DateTime? transactionDate;

  /// Confidence for transaction date extraction.
  final double? dateConfidence;

  /// Extracted total amount.
  final double? total;

  /// Confidence for total amount extraction.
  final double? totalConfidence;

  /// Subtotal if extracted.
  final double? subtotal;

  /// Tax amount if extracted.
  final double? tax;

  /// Detected payment method (snake_case via converter, A.1.1).
  final PaymentMethod? paymentMethod;

  /// Overall extraction confidence (0.0 to 1.0).
  final double overallConfidence;

  /// Full raw OCR text.
  final String? rawText;

  /// Whether the extraction was flagged for human review (confidence < 0.70).
  final bool requiresReview;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;
  const ReceiptExtractionRow(
      {required this.transactionId,
      this.merchant,
      this.merchantConfidence,
      required this.merchantUserEdited,
      this.transactionDate,
      this.dateConfidence,
      this.total,
      this.totalConfidence,
      this.subtotal,
      this.tax,
      this.paymentMethod,
      required this.overallConfidence,
      this.rawText,
      required this.requiresReview,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || merchantConfidence != null) {
      map['merchant_confidence'] = Variable<double>(merchantConfidence);
    }
    map['merchant_user_edited'] = Variable<bool>(merchantUserEdited);
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    if (!nullToAbsent || dateConfidence != null) {
      map['date_confidence'] = Variable<double>(dateConfidence);
    }
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<double>(total);
    }
    if (!nullToAbsent || totalConfidence != null) {
      map['total_confidence'] = Variable<double>(totalConfidence);
    }
    if (!nullToAbsent || subtotal != null) {
      map['subtotal'] = Variable<double>(subtotal);
    }
    if (!nullToAbsent || tax != null) {
      map['tax'] = Variable<double>(tax);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>($ReceiptExtractionsTable
          .$converterpaymentMethodn
          .toSql(paymentMethod));
    }
    map['overall_confidence'] = Variable<double>(overallConfidence);
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    map['requires_review'] = Variable<bool>(requiresReview);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ReceiptExtractionsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptExtractionsCompanion(
      transactionId: Value(transactionId),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      merchantConfidence: merchantConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantConfidence),
      merchantUserEdited: Value(merchantUserEdited),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      dateConfidence: dateConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(dateConfidence),
      total:
          total == null && nullToAbsent ? const Value.absent() : Value(total),
      totalConfidence: totalConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(totalConfidence),
      subtotal: subtotal == null && nullToAbsent
          ? const Value.absent()
          : Value(subtotal),
      tax: tax == null && nullToAbsent ? const Value.absent() : Value(tax),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      overallConfidence: Value(overallConfidence),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      requiresReview: Value(requiresReview),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ReceiptExtractionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptExtractionRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      merchantConfidence:
          serializer.fromJson<double?>(json['merchantConfidence']),
      merchantUserEdited: serializer.fromJson<bool>(json['merchantUserEdited']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      dateConfidence: serializer.fromJson<double?>(json['dateConfidence']),
      total: serializer.fromJson<double?>(json['total']),
      totalConfidence: serializer.fromJson<double?>(json['totalConfidence']),
      subtotal: serializer.fromJson<double?>(json['subtotal']),
      tax: serializer.fromJson<double?>(json['tax']),
      paymentMethod: serializer.fromJson<PaymentMethod?>(json['paymentMethod']),
      overallConfidence: serializer.fromJson<double>(json['overallConfidence']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      requiresReview: serializer.fromJson<bool>(json['requiresReview']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'merchant': serializer.toJson<String?>(merchant),
      'merchantConfidence': serializer.toJson<double?>(merchantConfidence),
      'merchantUserEdited': serializer.toJson<bool>(merchantUserEdited),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'dateConfidence': serializer.toJson<double?>(dateConfidence),
      'total': serializer.toJson<double?>(total),
      'totalConfidence': serializer.toJson<double?>(totalConfidence),
      'subtotal': serializer.toJson<double?>(subtotal),
      'tax': serializer.toJson<double?>(tax),
      'paymentMethod': serializer.toJson<PaymentMethod?>(paymentMethod),
      'overallConfidence': serializer.toJson<double>(overallConfidence),
      'rawText': serializer.toJson<String?>(rawText),
      'requiresReview': serializer.toJson<bool>(requiresReview),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ReceiptExtractionRow copyWith(
          {String? transactionId,
          Value<String?> merchant = const Value.absent(),
          Value<double?> merchantConfidence = const Value.absent(),
          bool? merchantUserEdited,
          Value<DateTime?> transactionDate = const Value.absent(),
          Value<double?> dateConfidence = const Value.absent(),
          Value<double?> total = const Value.absent(),
          Value<double?> totalConfidence = const Value.absent(),
          Value<double?> subtotal = const Value.absent(),
          Value<double?> tax = const Value.absent(),
          Value<PaymentMethod?> paymentMethod = const Value.absent(),
          double? overallConfidence,
          Value<String?> rawText = const Value.absent(),
          bool? requiresReview,
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ReceiptExtractionRow(
        transactionId: transactionId ?? this.transactionId,
        merchant: merchant.present ? merchant.value : this.merchant,
        merchantConfidence: merchantConfidence.present
            ? merchantConfidence.value
            : this.merchantConfidence,
        merchantUserEdited: merchantUserEdited ?? this.merchantUserEdited,
        transactionDate: transactionDate.present
            ? transactionDate.value
            : this.transactionDate,
        dateConfidence:
            dateConfidence.present ? dateConfidence.value : this.dateConfidence,
        total: total.present ? total.value : this.total,
        totalConfidence: totalConfidence.present
            ? totalConfidence.value
            : this.totalConfidence,
        subtotal: subtotal.present ? subtotal.value : this.subtotal,
        tax: tax.present ? tax.value : this.tax,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        overallConfidence: overallConfidence ?? this.overallConfidence,
        rawText: rawText.present ? rawText.value : this.rawText,
        requiresReview: requiresReview ?? this.requiresReview,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ReceiptExtractionRow copyWithCompanion(ReceiptExtractionsCompanion data) {
    return ReceiptExtractionRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      merchantConfidence: data.merchantConfidence.present
          ? data.merchantConfidence.value
          : this.merchantConfidence,
      merchantUserEdited: data.merchantUserEdited.present
          ? data.merchantUserEdited.value
          : this.merchantUserEdited,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      dateConfidence: data.dateConfidence.present
          ? data.dateConfidence.value
          : this.dateConfidence,
      total: data.total.present ? data.total.value : this.total,
      totalConfidence: data.totalConfidence.present
          ? data.totalConfidence.value
          : this.totalConfidence,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tax: data.tax.present ? data.tax.value : this.tax,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      overallConfidence: data.overallConfidence.present
          ? data.overallConfidence.value
          : this.overallConfidence,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      requiresReview: data.requiresReview.present
          ? data.requiresReview.value
          : this.requiresReview,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptExtractionRow(')
          ..write('transactionId: $transactionId, ')
          ..write('merchant: $merchant, ')
          ..write('merchantConfidence: $merchantConfidence, ')
          ..write('merchantUserEdited: $merchantUserEdited, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dateConfidence: $dateConfidence, ')
          ..write('total: $total, ')
          ..write('totalConfidence: $totalConfidence, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('overallConfidence: $overallConfidence, ')
          ..write('rawText: $rawText, ')
          ..write('requiresReview: $requiresReview, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      transactionId,
      merchant,
      merchantConfidence,
      merchantUserEdited,
      transactionDate,
      dateConfidence,
      total,
      totalConfidence,
      subtotal,
      tax,
      paymentMethod,
      overallConfidence,
      rawText,
      requiresReview,
      revision,
      deletedAt,
      syncState,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptExtractionRow &&
          other.transactionId == this.transactionId &&
          other.merchant == this.merchant &&
          other.merchantConfidence == this.merchantConfidence &&
          other.merchantUserEdited == this.merchantUserEdited &&
          other.transactionDate == this.transactionDate &&
          other.dateConfidence == this.dateConfidence &&
          other.total == this.total &&
          other.totalConfidence == this.totalConfidence &&
          other.subtotal == this.subtotal &&
          other.tax == this.tax &&
          other.paymentMethod == this.paymentMethod &&
          other.overallConfidence == this.overallConfidence &&
          other.rawText == this.rawText &&
          other.requiresReview == this.requiresReview &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ReceiptExtractionsCompanion
    extends UpdateCompanion<ReceiptExtractionRow> {
  final Value<String> transactionId;
  final Value<String?> merchant;
  final Value<double?> merchantConfidence;
  final Value<bool> merchantUserEdited;
  final Value<DateTime?> transactionDate;
  final Value<double?> dateConfidence;
  final Value<double?> total;
  final Value<double?> totalConfidence;
  final Value<double?> subtotal;
  final Value<double?> tax;
  final Value<PaymentMethod?> paymentMethod;
  final Value<double> overallConfidence;
  final Value<String?> rawText;
  final Value<bool> requiresReview;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ReceiptExtractionsCompanion({
    this.transactionId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.merchantConfidence = const Value.absent(),
    this.merchantUserEdited = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.dateConfidence = const Value.absent(),
    this.total = const Value.absent(),
    this.totalConfidence = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.overallConfidence = const Value.absent(),
    this.rawText = const Value.absent(),
    this.requiresReview = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptExtractionsCompanion.insert({
    required String transactionId,
    this.merchant = const Value.absent(),
    this.merchantConfidence = const Value.absent(),
    this.merchantUserEdited = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.dateConfidence = const Value.absent(),
    this.total = const Value.absent(),
    this.totalConfidence = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    required double overallConfidence,
    this.rawText = const Value.absent(),
    this.requiresReview = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : transactionId = Value(transactionId),
        overallConfidence = Value(overallConfidence);
  static Insertable<ReceiptExtractionRow> custom({
    Expression<String>? transactionId,
    Expression<String>? merchant,
    Expression<double>? merchantConfidence,
    Expression<bool>? merchantUserEdited,
    Expression<DateTime>? transactionDate,
    Expression<double>? dateConfidence,
    Expression<double>? total,
    Expression<double>? totalConfidence,
    Expression<double>? subtotal,
    Expression<double>? tax,
    Expression<String>? paymentMethod,
    Expression<double>? overallConfidence,
    Expression<String>? rawText,
    Expression<bool>? requiresReview,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (merchant != null) 'merchant': merchant,
      if (merchantConfidence != null) 'merchant_confidence': merchantConfidence,
      if (merchantUserEdited != null)
        'merchant_user_edited': merchantUserEdited,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (dateConfidence != null) 'date_confidence': dateConfidence,
      if (total != null) 'total': total,
      if (totalConfidence != null) 'total_confidence': totalConfidence,
      if (subtotal != null) 'subtotal': subtotal,
      if (tax != null) 'tax': tax,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (overallConfidence != null) 'overall_confidence': overallConfidence,
      if (rawText != null) 'raw_text': rawText,
      if (requiresReview != null) 'requires_review': requiresReview,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptExtractionsCompanion copyWith(
      {Value<String>? transactionId,
      Value<String?>? merchant,
      Value<double?>? merchantConfidence,
      Value<bool>? merchantUserEdited,
      Value<DateTime?>? transactionDate,
      Value<double?>? dateConfidence,
      Value<double?>? total,
      Value<double?>? totalConfidence,
      Value<double?>? subtotal,
      Value<double?>? tax,
      Value<PaymentMethod?>? paymentMethod,
      Value<double>? overallConfidence,
      Value<String?>? rawText,
      Value<bool>? requiresReview,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ReceiptExtractionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      merchant: merchant ?? this.merchant,
      merchantConfidence: merchantConfidence ?? this.merchantConfidence,
      merchantUserEdited: merchantUserEdited ?? this.merchantUserEdited,
      transactionDate: transactionDate ?? this.transactionDate,
      dateConfidence: dateConfidence ?? this.dateConfidence,
      total: total ?? this.total,
      totalConfidence: totalConfidence ?? this.totalConfidence,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      rawText: rawText ?? this.rawText,
      requiresReview: requiresReview ?? this.requiresReview,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (merchantConfidence.present) {
      map['merchant_confidence'] = Variable<double>(merchantConfidence.value);
    }
    if (merchantUserEdited.present) {
      map['merchant_user_edited'] = Variable<bool>(merchantUserEdited.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (dateConfidence.present) {
      map['date_confidence'] = Variable<double>(dateConfidence.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (totalConfidence.present) {
      map['total_confidence'] = Variable<double>(totalConfidence.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>($ReceiptExtractionsTable
          .$converterpaymentMethodn
          .toSql(paymentMethod.value));
    }
    if (overallConfidence.present) {
      map['overall_confidence'] = Variable<double>(overallConfidence.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (requiresReview.present) {
      map['requires_review'] = Variable<bool>(requiresReview.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptExtractionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('merchant: $merchant, ')
          ..write('merchantConfidence: $merchantConfidence, ')
          ..write('merchantUserEdited: $merchantUserEdited, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dateConfidence: $dateConfidence, ')
          ..write('total: $total, ')
          ..write('totalConfidence: $totalConfidence, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('overallConfidence: $overallConfidence, ')
          ..write('rawText: $rawText, ')
          ..write('requiresReview: $requiresReview, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptLineItemsTable extends ReceiptLineItems
    with TableInfo<$ReceiptLineItemsTable, ReceiptLineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptLineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categorySuggestionMeta =
      const VerificationMeta('categorySuggestion');
  @override
  late final GeneratedColumn<String> categorySuggestion =
      GeneratedColumn<String>('category_suggestion', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        name,
        quantity,
        unitPrice,
        total,
        categorySuggestion,
        confidence,
        revision,
        deletedAt,
        syncState,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_line_items';
  @override
  VerificationContext validateIntegrity(Insertable<ReceiptLineItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('category_suggestion')) {
      context.handle(
          _categorySuggestionMeta,
          categorySuggestion.isAcceptableOrUnknown(
              data['category_suggestion']!, _categorySuggestionMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptLineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptLineItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity']),
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price']),
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      categorySuggestion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}category_suggestion']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ReceiptLineItemsTable createAlias(String alias) {
    return $ReceiptLineItemsTable(attachedDatabase, alias);
  }
}

class ReceiptLineItemRow extends DataClass
    implements Insertable<ReceiptLineItemRow> {
  /// Unique identifier.
  final String id;

  /// Foreign key to Transactions.id.
  final String transactionId;

  /// Line item description / product name.
  final String name;

  /// Quantity purchased.
  final double? quantity;

  /// Price per unit.
  final double? unitPrice;

  /// Line item total amount.
  final double total;

  /// AI-suggested category ID for this line item.
  final String? categorySuggestion;

  /// OCR confidence for this line.
  final double confidence;

  /// Revision number used by the cloud sync protocol (B.1).
  final int revision;

  /// Soft-delete timestamp used by cloud sync (B.1).
  final DateTime? deletedAt;

  /// Sync state of this row (synced | pending | conflict, B.1).
  final String syncState;

  /// Last successful sync time (B.1).
  final DateTime? lastSyncedAt;
  const ReceiptLineItemRow(
      {required this.id,
      required this.transactionId,
      required this.name,
      this.quantity,
      this.unitPrice,
      required this.total,
      this.categorySuggestion,
      required this.confidence,
      required this.revision,
      this.deletedAt,
      required this.syncState,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<double>(unitPrice);
    }
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || categorySuggestion != null) {
      map['category_suggestion'] = Variable<String>(categorySuggestion);
    }
    map['confidence'] = Variable<double>(confidence);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ReceiptLineItemsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptLineItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      total: Value(total),
      categorySuggestion: categorySuggestion == null && nullToAbsent
          ? const Value.absent()
          : Value(categorySuggestion),
      confidence: Value(confidence),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ReceiptLineItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptLineItemRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unitPrice: serializer.fromJson<double?>(json['unitPrice']),
      total: serializer.fromJson<double>(json['total']),
      categorySuggestion:
          serializer.fromJson<String?>(json['categorySuggestion']),
      confidence: serializer.fromJson<double>(json['confidence']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unitPrice': serializer.toJson<double?>(unitPrice),
      'total': serializer.toJson<double>(total),
      'categorySuggestion': serializer.toJson<String?>(categorySuggestion),
      'confidence': serializer.toJson<double>(confidence),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ReceiptLineItemRow copyWith(
          {String? id,
          String? transactionId,
          String? name,
          Value<double?> quantity = const Value.absent(),
          Value<double?> unitPrice = const Value.absent(),
          double? total,
          Value<String?> categorySuggestion = const Value.absent(),
          double? confidence,
          int? revision,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ReceiptLineItemRow(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        name: name ?? this.name,
        quantity: quantity.present ? quantity.value : this.quantity,
        unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
        total: total ?? this.total,
        categorySuggestion: categorySuggestion.present
            ? categorySuggestion.value
            : this.categorySuggestion,
        confidence: confidence ?? this.confidence,
        revision: revision ?? this.revision,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ReceiptLineItemRow copyWithCompanion(ReceiptLineItemsCompanion data) {
    return ReceiptLineItemRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      total: data.total.present ? data.total.value : this.total,
      categorySuggestion: data.categorySuggestion.present
          ? data.categorySuggestion.value
          : this.categorySuggestion,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptLineItemRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('categorySuggestion: $categorySuggestion, ')
          ..write('confidence: $confidence, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      name,
      quantity,
      unitPrice,
      total,
      categorySuggestion,
      confidence,
      revision,
      deletedAt,
      syncState,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptLineItemRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.total == this.total &&
          other.categorySuggestion == this.categorySuggestion &&
          other.confidence == this.confidence &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ReceiptLineItemsCompanion extends UpdateCompanion<ReceiptLineItemRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<double?> unitPrice;
  final Value<double> total;
  final Value<String?> categorySuggestion;
  final Value<double> confidence;
  final Value<int> revision;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ReceiptLineItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.total = const Value.absent(),
    this.categorySuggestion = const Value.absent(),
    this.confidence = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptLineItemsCompanion.insert({
    required String id,
    required String transactionId,
    required String name,
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    required double total,
    this.categorySuggestion = const Value.absent(),
    this.confidence = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionId = Value(transactionId),
        name = Value(name),
        total = Value(total);
  static Insertable<ReceiptLineItemRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? total,
    Expression<String>? categorySuggestion,
    Expression<double>? confidence,
    Expression<int>? revision,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (total != null) 'total': total,
      if (categorySuggestion != null) 'category_suggestion': categorySuggestion,
      if (confidence != null) 'confidence': confidence,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptLineItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<String>? name,
      Value<double?>? quantity,
      Value<double?>? unitPrice,
      Value<double>? total,
      Value<String?>? categorySuggestion,
      Value<double>? confidence,
      Value<int>? revision,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ReceiptLineItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      categorySuggestion: categorySuggestion ?? this.categorySuggestion,
      confidence: confidence ?? this.confidence,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (categorySuggestion.present) {
      map['category_suggestion'] = Variable<String>(categorySuggestion.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('categorySuggestion: $categorySuggestion, ')
          ..write('confidence: $confidence, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _blocksJsonMeta =
      const VerificationMeta('blocksJson');
  @override
  late final GeneratedColumn<String> blocksJson = GeneratedColumn<String>(
      'blocks_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _suggestionsJsonMeta =
      const VerificationMeta('suggestionsJson');
  @override
  late final GeneratedColumn<String> suggestionsJson = GeneratedColumn<String>(
      'suggestions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isLocalMeta =
      const VerificationMeta('isLocal');
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
      'is_local', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_local" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isFeedbackMeta =
      const VerificationMeta('isFeedback');
  @override
  late final GeneratedColumn<bool> isFeedback = GeneratedColumn<bool>(
      'is_feedback', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_feedback" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        role,
        body,
        blocksJson,
        suggestionsJson,
        isLocal,
        isFeedback,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('blocks_json')) {
      context.handle(
          _blocksJsonMeta,
          blocksJson.isAcceptableOrUnknown(
              data['blocks_json']!, _blocksJsonMeta));
    }
    if (data.containsKey('suggestions_json')) {
      context.handle(
          _suggestionsJsonMeta,
          suggestionsJson.isAcceptableOrUnknown(
              data['suggestions_json']!, _suggestionsJsonMeta));
    }
    if (data.containsKey('is_local')) {
      context.handle(_isLocalMeta,
          isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta));
    }
    if (data.containsKey('is_feedback')) {
      context.handle(
          _isFeedbackMeta,
          isFeedback.isAcceptableOrUnknown(
              data['is_feedback']!, _isFeedbackMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      blocksJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blocks_json'])!,
      suggestionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggestions_json'])!,
      isLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_local'])!,
      isFeedback: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_feedback'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  /// Unique identifier (UUID v7).
  final String id;

  /// Message author: 'user' or 'assistant'.
  final String role;

  /// Plain text body of the message.
  final String body;

  /// JSON array of rich blocks (metrics, transactions, drafts, notes).
  final String blocksJson;

  /// Suggested follow-up prompts shown as chips.
  final String suggestionsJson;

  /// True when the reply was produced fully on-device.
  final bool isLocal;

  /// True when the user message was filed as support feedback.
  final bool isFeedback;

  /// Message timestamp.
  final DateTime createdAt;
  const ChatMessageRow(
      {required this.id,
      required this.role,
      required this.body,
      required this.blocksJson,
      required this.suggestionsJson,
      required this.isLocal,
      required this.isFeedback,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['body'] = Variable<String>(body);
    map['blocks_json'] = Variable<String>(blocksJson);
    map['suggestions_json'] = Variable<String>(suggestionsJson);
    map['is_local'] = Variable<bool>(isLocal);
    map['is_feedback'] = Variable<bool>(isFeedback);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      role: Value(role),
      body: Value(body),
      blocksJson: Value(blocksJson),
      suggestionsJson: Value(suggestionsJson),
      isLocal: Value(isLocal),
      isFeedback: Value(isFeedback),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      body: serializer.fromJson<String>(json['body']),
      blocksJson: serializer.fromJson<String>(json['blocksJson']),
      suggestionsJson: serializer.fromJson<String>(json['suggestionsJson']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      isFeedback: serializer.fromJson<bool>(json['isFeedback']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'body': serializer.toJson<String>(body),
      'blocksJson': serializer.toJson<String>(blocksJson),
      'suggestionsJson': serializer.toJson<String>(suggestionsJson),
      'isLocal': serializer.toJson<bool>(isLocal),
      'isFeedback': serializer.toJson<bool>(isFeedback),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessageRow copyWith(
          {String? id,
          String? role,
          String? body,
          String? blocksJson,
          String? suggestionsJson,
          bool? isLocal,
          bool? isFeedback,
          DateTime? createdAt}) =>
      ChatMessageRow(
        id: id ?? this.id,
        role: role ?? this.role,
        body: body ?? this.body,
        blocksJson: blocksJson ?? this.blocksJson,
        suggestionsJson: suggestionsJson ?? this.suggestionsJson,
        isLocal: isLocal ?? this.isLocal,
        isFeedback: isFeedback ?? this.isFeedback,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      body: data.body.present ? data.body.value : this.body,
      blocksJson:
          data.blocksJson.present ? data.blocksJson.value : this.blocksJson,
      suggestionsJson: data.suggestionsJson.present
          ? data.suggestionsJson.value
          : this.suggestionsJson,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      isFeedback:
          data.isFeedback.present ? data.isFeedback.value : this.isFeedback,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('blocksJson: $blocksJson, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('isLocal: $isLocal, ')
          ..write('isFeedback: $isFeedback, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, body, blocksJson, suggestionsJson,
      isLocal, isFeedback, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.role == this.role &&
          other.body == this.body &&
          other.blocksJson == this.blocksJson &&
          other.suggestionsJson == this.suggestionsJson &&
          other.isLocal == this.isLocal &&
          other.isFeedback == this.isFeedback &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> body;
  final Value<String> blocksJson;
  final Value<String> suggestionsJson;
  final Value<bool> isLocal;
  final Value<bool> isFeedback;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.body = const Value.absent(),
    this.blocksJson = const Value.absent(),
    this.suggestionsJson = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.isFeedback = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String role,
    required String body,
    this.blocksJson = const Value.absent(),
    this.suggestionsJson = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.isFeedback = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        role = Value(role),
        body = Value(body),
        createdAt = Value(createdAt);
  static Insertable<ChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? body,
    Expression<String>? blocksJson,
    Expression<String>? suggestionsJson,
    Expression<bool>? isLocal,
    Expression<bool>? isFeedback,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (body != null) 'body': body,
      if (blocksJson != null) 'blocks_json': blocksJson,
      if (suggestionsJson != null) 'suggestions_json': suggestionsJson,
      if (isLocal != null) 'is_local': isLocal,
      if (isFeedback != null) 'is_feedback': isFeedback,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? role,
      Value<String>? body,
      Value<String>? blocksJson,
      Value<String>? suggestionsJson,
      Value<bool>? isLocal,
      Value<bool>? isFeedback,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      body: body ?? this.body,
      blocksJson: blocksJson ?? this.blocksJson,
      suggestionsJson: suggestionsJson ?? this.suggestionsJson,
      isLocal: isLocal ?? this.isLocal,
      isFeedback: isFeedback ?? this.isFeedback,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (blocksJson.present) {
      map['blocks_json'] = Variable<String>(blocksJson.value);
    }
    if (suggestionsJson.present) {
      map['suggestions_json'] = Variable<String>(suggestionsJson.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (isFeedback.present) {
      map['is_feedback'] = Variable<bool>(isFeedback.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('blocksJson: $blocksJson, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('isLocal: $isLocal, ')
          ..write('isFeedback: $isFeedback, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, operation, payloadJson, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  /// Unique operation id (ULID) — immutable across retries.
  final String id;

  /// Entity type, e.g. 'transaction' (shared constants, see sync protocol).
  final String entityType;

  /// Entity primary key.
  final String entityId;

  /// 'upsert' or 'delete'.
  final String operation;

  /// Serialized JSON payload.
  final String payloadJson;

  /// Local time the row was queued.
  final DateTime createdAt;

  /// Retry counter; reset on successful push.
  final int retryCount;
  const SyncOutboxRow(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory SyncOutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncOutboxRow copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount}) =>
      SyncOutboxRow(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, operation, payloadJson, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        createdAt = Value(createdAt);
  static Insertable<SyncOutboxRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<int>? rowid}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadataRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  /// Key (e.g. 'server_cursor', 'device_id').
  final String key;

  /// Value as JSON string.
  final String value;
  const SyncMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SyncMetadataRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
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

  SyncMetadataRow copyWith({String? key, String? value}) => SyncMetadataRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SyncMetadataRow copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
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
      (other is SyncMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetadataRow> custom({
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

  SyncMetadataCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncMetadataCompanion(
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
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionType>($RecurringRulesTable.$convertertype);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('VND'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<RecurringFrequency, String>
      frequency = GeneratedColumn<String>('frequency', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<RecurringFrequency>(
              $RecurringRulesTable.$converterfrequency);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextRunAtMeta =
      const VerificationMeta('nextRunAt');
  @override
  late final GeneratedColumn<DateTime> nextRunAt = GeneratedColumn<DateTime>(
      'next_run_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        type,
        currency,
        categoryId,
        merchant,
        note,
        frequency,
        dayOfMonth,
        dayOfWeek,
        startDate,
        endDate,
        nextRunAt,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringRuleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
          _nextRunAtMeta,
          nextRunAt.isAcceptableOrUnknown(
              data['next_run_at']!, _nextRunAtMeta));
    } else if (isInserting) {
      context.missing(_nextRunAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRuleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: $RecurringRulesTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      frequency: $RecurringRulesTable.$converterfrequency.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!),
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month']),
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      nextRunAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_run_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<TransactionType, String> $convertertype =
      const TransactionTypeConverter();
  static TypeConverter<RecurringFrequency, String> $converterfrequency =
      const RecurringFrequencyConverter();
}

class RecurringRuleRow extends DataClass
    implements Insertable<RecurringRuleRow> {
  /// Unique identifier (ULID / UUID v7).
  final String id;

  /// Amount per occurrence (money).
  final double amount;

  /// Expense or income (snake_case via converter, A.1.1).
  final TransactionType type;

  /// Currency code.
  final String currency;

  /// Foreign key to Categories.id (template).
  final String categoryId;

  /// Optional merchant / store name.
  final String? merchant;

  /// Optional note / description.
  final String? note;

  /// Frequency: 'daily', 'weekly', 'monthly' (converter, domain enum).
  final RecurringFrequency frequency;

  /// Day of month for monthly rules (1-28/31).
  final int? dayOfMonth;

  /// Weekday for weekly rules (Dart DateTime.weekday, Monday=1).
  final int? dayOfWeek;

  /// First day the rule may fire.
  final DateTime startDate;

  /// Optional last day after which the rule stops.
  final DateTime? endDate;

  /// Next scheduled fire time.
  final DateTime nextRunAt;

  /// Active flag (toggle in UI).
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;
  const RecurringRuleRow(
      {required this.id,
      required this.amount,
      required this.type,
      required this.currency,
      required this.categoryId,
      this.merchant,
      this.note,
      required this.frequency,
      this.dayOfMonth,
      this.dayOfWeek,
      required this.startDate,
      this.endDate,
      required this.nextRunAt,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    {
      map['type'] =
          Variable<String>($RecurringRulesTable.$convertertype.toSql(type));
    }
    map['currency'] = Variable<String>(currency);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['frequency'] = Variable<String>(
          $RecurringRulesTable.$converterfrequency.toSql(frequency));
    }
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['next_run_at'] = Variable<DateTime>(nextRunAt);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      currency: Value(currency),
      categoryId: Value(categoryId),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      frequency: Value(frequency),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      nextRunAt: Value(nextRunAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringRuleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRuleRow(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<TransactionType>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      frequency: serializer.fromJson<RecurringFrequency>(json['frequency']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      nextRunAt: serializer.fromJson<DateTime>(json['nextRunAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<TransactionType>(type),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<String>(categoryId),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'frequency': serializer.toJson<RecurringFrequency>(frequency),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'nextRunAt': serializer.toJson<DateTime>(nextRunAt),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringRuleRow copyWith(
          {String? id,
          double? amount,
          TransactionType? type,
          String? currency,
          String? categoryId,
          Value<String?> merchant = const Value.absent(),
          Value<String?> note = const Value.absent(),
          RecurringFrequency? frequency,
          Value<int?> dayOfMonth = const Value.absent(),
          Value<int?> dayOfWeek = const Value.absent(),
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? nextRunAt,
          bool? isActive,
          DateTime? createdAt}) =>
      RecurringRuleRow(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        currency: currency ?? this.currency,
        categoryId: categoryId ?? this.categoryId,
        merchant: merchant.present ? merchant.value : this.merchant,
        note: note.present ? note.value : this.note,
        frequency: frequency ?? this.frequency,
        dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
        dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurringRuleRow copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRuleRow(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRuleRow(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      amount,
      type,
      currency,
      categoryId,
      merchant,
      note,
      frequency,
      dayOfMonth,
      dayOfWeek,
      startDate,
      endDate,
      nextRunAt,
      isActive,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRuleRow &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.frequency == this.frequency &&
          other.dayOfMonth == this.dayOfMonth &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.nextRunAt == this.nextRunAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRuleRow> {
  final Value<String> id;
  final Value<double> amount;
  final Value<TransactionType> type;
  final Value<String> currency;
  final Value<String> categoryId;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<RecurringFrequency> frequency;
  final Value<int?> dayOfMonth;
  final Value<int?> dayOfWeek;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> nextRunAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.frequency = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required double amount,
    required TransactionType type,
    this.currency = const Value.absent(),
    required String categoryId,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    required RecurringFrequency frequency,
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required DateTime nextRunAt,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        type = Value(type),
        categoryId = Value(categoryId),
        frequency = Value(frequency),
        startDate = Value(startDate),
        nextRunAt = Value(nextRunAt);
  static Insertable<RecurringRuleRow> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<String>? categoryId,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<String>? frequency,
    Expression<int>? dayOfMonth,
    Expression<int>? dayOfWeek,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? nextRunAt,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (frequency != null) 'frequency': frequency,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith(
      {Value<String>? id,
      Value<double>? amount,
      Value<TransactionType>? type,
      Value<String>? currency,
      Value<String>? categoryId,
      Value<String?>? merchant,
      Value<String?>? note,
      Value<RecurringFrequency>? frequency,
      Value<int?>? dayOfMonth,
      Value<int?>? dayOfWeek,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? nextRunAt,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $RecurringRulesTable.$convertertype.toSql(type.value));
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
          $RecurringRulesTable.$converterfrequency.toSql(frequency.value));
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HouseholdMembersTable extends HouseholdMembers
    with TableInfo<$HouseholdMembersTable, HouseholdMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HouseholdMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdNameMeta =
      const VerificationMeta('householdName');
  @override
  late final GeneratedColumn<String> householdName = GeneratedColumn<String>(
      'household_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [householdId, householdName, userId, role, displayName, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'household_members';
  @override
  VerificationContext validateIntegrity(Insertable<HouseholdMemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('household_name')) {
      context.handle(
          _householdNameMeta,
          householdName.isAcceptableOrUnknown(
              data['household_name']!, _householdNameMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {householdId, userId};
  @override
  HouseholdMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HouseholdMemberRow(
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      householdName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_name'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $HouseholdMembersTable createAlias(String alias) {
    return $HouseholdMembersTable(attachedDatabase, alias);
  }
}

class HouseholdMemberRow extends DataClass
    implements Insertable<HouseholdMemberRow> {
  /// Household identifier.
  final String householdId;

  /// Household display name (denormalized for offline display).
  final String householdName;

  /// Member user ID.
  final String userId;

  /// Role within household: 'owner' or 'member'.
  final String role;

  /// Member display name shown on shared transactions.
  final String? displayName;

  /// Timestamp when member joined.
  final DateTime joinedAt;
  const HouseholdMemberRow(
      {required this.householdId,
      required this.householdName,
      required this.userId,
      required this.role,
      this.displayName,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['household_id'] = Variable<String>(householdId);
    map['household_name'] = Variable<String>(householdName);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  HouseholdMembersCompanion toCompanion(bool nullToAbsent) {
    return HouseholdMembersCompanion(
      householdId: Value(householdId),
      householdName: Value(householdName),
      userId: Value(userId),
      role: Value(role),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      joinedAt: Value(joinedAt),
    );
  }

  factory HouseholdMemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HouseholdMemberRow(
      householdId: serializer.fromJson<String>(json['householdId']),
      householdName: serializer.fromJson<String>(json['householdName']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'householdId': serializer.toJson<String>(householdId),
      'householdName': serializer.toJson<String>(householdName),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'displayName': serializer.toJson<String?>(displayName),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  HouseholdMemberRow copyWith(
          {String? householdId,
          String? householdName,
          String? userId,
          String? role,
          Value<String?> displayName = const Value.absent(),
          DateTime? joinedAt}) =>
      HouseholdMemberRow(
        householdId: householdId ?? this.householdId,
        householdName: householdName ?? this.householdName,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        displayName: displayName.present ? displayName.value : this.displayName,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  HouseholdMemberRow copyWithCompanion(HouseholdMembersCompanion data) {
    return HouseholdMemberRow(
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      householdName: data.householdName.present
          ? data.householdName.value
          : this.householdName,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HouseholdMemberRow(')
          ..write('householdId: $householdId, ')
          ..write('householdName: $householdName, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      householdId, householdName, userId, role, displayName, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HouseholdMemberRow &&
          other.householdId == this.householdId &&
          other.householdName == this.householdName &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.displayName == this.displayName &&
          other.joinedAt == this.joinedAt);
}

class HouseholdMembersCompanion extends UpdateCompanion<HouseholdMemberRow> {
  final Value<String> householdId;
  final Value<String> householdName;
  final Value<String> userId;
  final Value<String> role;
  final Value<String?> displayName;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const HouseholdMembersCompanion({
    this.householdId = const Value.absent(),
    this.householdName = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.displayName = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseholdMembersCompanion.insert({
    required String householdId,
    this.householdName = const Value.absent(),
    required String userId,
    this.role = const Value.absent(),
    this.displayName = const Value.absent(),
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  })  : householdId = Value(householdId),
        userId = Value(userId),
        joinedAt = Value(joinedAt);
  static Insertable<HouseholdMemberRow> custom({
    Expression<String>? householdId,
    Expression<String>? householdName,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? displayName,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (householdId != null) 'household_id': householdId,
      if (householdName != null) 'household_name': householdName,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (displayName != null) 'display_name': displayName,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseholdMembersCompanion copyWith(
      {Value<String>? householdId,
      Value<String>? householdName,
      Value<String>? userId,
      Value<String>? role,
      Value<String?>? displayName,
      Value<DateTime>? joinedAt,
      Value<int>? rowid}) {
    return HouseholdMembersCompanion(
      householdId: householdId ?? this.householdId,
      householdName: householdName ?? this.householdName,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (householdName.present) {
      map['household_name'] = Variable<String>(householdName.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseholdMembersCompanion(')
          ..write('householdId: $householdId, ')
          ..write('householdName: $householdName, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionMediasTable transactionMedias =
      $TransactionMediasTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $AIInferencesTable aIInferences = $AIInferencesTable(this);
  late final $ReceiptExtractionsTable receiptExtractions =
      $ReceiptExtractionsTable(this);
  late final $ReceiptLineItemsTable receiptLineItems =
      $ReceiptLineItemsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $HouseholdMembersTable householdMembers =
      $HouseholdMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        transactions,
        transactionMedias,
        budgets,
        aIInferences,
        receiptExtractions,
        receiptLineItems,
        chatMessages,
        syncOutbox,
        syncMetadata,
        recurringRules,
        householdMembers
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  Value<String?> parentId,
  required String name,
  required String icon,
  required int colorValue,
  Value<bool> isSystem,
  Value<int> sortOrder,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String?> parentId,
  Value<String> name,
  Value<String> icon,
  Value<int> colorValue,
  Value<bool> isSystem,
  Value<int> sortOrder,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            parentId: parentId,
            name: name,
            icon: icon,
            colorValue: colorValue,
            isSystem: isSystem,
            sortOrder: sortOrder,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> parentId = const Value.absent(),
            required String name,
            required String icon,
            required int colorValue,
            Value<bool> isSystem = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            parentId: parentId,
            name: name,
            icon: icon,
            colorValue: colorValue,
            isSystem: isSystem,
            sortOrder: sortOrder,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required TransactionType type,
  required double amount,
  Value<String> currency,
  required String categoryId,
  Value<String?> merchant,
  required DateTime occurredAt,
  Value<String?> note,
  Value<PaymentMethod?> paymentMethod,
  required TransactionSource source,
  required TransactionStatus status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isShared,
  Value<String?> householdId,
  Value<String?> createdByUserId,
  Value<String?> createdByName,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<TransactionType> type,
  Value<double> amount,
  Value<String> currency,
  Value<String> categoryId,
  Value<String?> merchant,
  Value<DateTime> occurredAt,
  Value<String?> note,
  Value<PaymentMethod?> paymentMethod,
  Value<TransactionSource> source,
  Value<TransactionStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isShared,
  Value<String?> householdId,
  Value<String?> createdByUserId,
  Value<String?> createdByName,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
      get paymentMethod => $composableBuilder(
          column: $table.paymentMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TransactionSource, TransactionSource, String>
      get source => $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TransactionStatus, TransactionStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByName => $composableBuilder(
      column: $table.createdByName, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByName => $composableBuilder(
      column: $table.createdByName,
      builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
          column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId, builder: (column) => column);

  GeneratedColumn<String> get createdByName => $composableBuilder(
      column: $table.createdByName, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionRow,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      TransactionRow,
      BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>
    ),
    TransactionRow,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> merchant = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
            Value<TransactionSource> source = const Value.absent(),
            Value<TransactionStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> householdId = const Value.absent(),
            Value<String?> createdByUserId = const Value.absent(),
            Value<String?> createdByName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            currency: currency,
            categoryId: categoryId,
            merchant: merchant,
            occurredAt: occurredAt,
            note: note,
            paymentMethod: paymentMethod,
            source: source,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            isShared: isShared,
            householdId: householdId,
            createdByUserId: createdByUserId,
            createdByName: createdByName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required TransactionType type,
            required double amount,
            Value<String> currency = const Value.absent(),
            required String categoryId,
            Value<String?> merchant = const Value.absent(),
            required DateTime occurredAt,
            Value<String?> note = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
            required TransactionSource source,
            required TransactionStatus status,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> householdId = const Value.absent(),
            Value<String?> createdByUserId = const Value.absent(),
            Value<String?> createdByName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            currency: currency,
            categoryId: categoryId,
            merchant: merchant,
            occurredAt: occurredAt,
            note: note,
            paymentMethod: paymentMethod,
            source: source,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            isShared: isShared,
            householdId: householdId,
            createdByUserId: createdByUserId,
            createdByName: createdByName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionRow,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      TransactionRow,
      BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>
    ),
    TransactionRow,
    PrefetchHooks Function()>;
typedef $$TransactionMediasTableCreateCompanionBuilder
    = TransactionMediasCompanion Function({
  required String id,
  required String transactionId,
  required MediaType type,
  Value<String?> originalPath,
  required String compressedPath,
  required String thumbnailPath,
  required String hash,
  Value<int?> width,
  Value<int?> height,
  Value<int?> fileSizeBytes,
  Value<DateTime?> capturedAt,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$TransactionMediasTableUpdateCompanionBuilder
    = TransactionMediasCompanion Function({
  Value<String> id,
  Value<String> transactionId,
  Value<MediaType> type,
  Value<String?> originalPath,
  Value<String> compressedPath,
  Value<String> thumbnailPath,
  Value<String> hash,
  Value<int?> width,
  Value<int?> height,
  Value<int?> fileSizeBytes,
  Value<DateTime?> capturedAt,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$TransactionMediasTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionMediasTable> {
  $$TransactionMediasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaType, MediaType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compressedPath => $composableBuilder(
      column: $table.compressedPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$TransactionMediasTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionMediasTable> {
  $$TransactionMediasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalPath => $composableBuilder(
      column: $table.originalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compressedPath => $composableBuilder(
      column: $table.compressedPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TransactionMediasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionMediasTable> {
  $$TransactionMediasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => column);

  GeneratedColumn<String> get compressedPath => $composableBuilder(
      column: $table.compressedPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$TransactionMediasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionMediasTable,
    TransactionMediaRow,
    $$TransactionMediasTableFilterComposer,
    $$TransactionMediasTableOrderingComposer,
    $$TransactionMediasTableAnnotationComposer,
    $$TransactionMediasTableCreateCompanionBuilder,
    $$TransactionMediasTableUpdateCompanionBuilder,
    (
      TransactionMediaRow,
      BaseReferences<_$AppDatabase, $TransactionMediasTable,
          TransactionMediaRow>
    ),
    TransactionMediaRow,
    PrefetchHooks Function()> {
  $$TransactionMediasTableTableManager(
      _$AppDatabase db, $TransactionMediasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionMediasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionMediasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionMediasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<MediaType> type = const Value.absent(),
            Value<String?> originalPath = const Value.absent(),
            Value<String> compressedPath = const Value.absent(),
            Value<String> thumbnailPath = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionMediasCompanion(
            id: id,
            transactionId: transactionId,
            type: type,
            originalPath: originalPath,
            compressedPath: compressedPath,
            thumbnailPath: thumbnailPath,
            hash: hash,
            width: width,
            height: height,
            fileSizeBytes: fileSizeBytes,
            capturedAt: capturedAt,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            required MediaType type,
            Value<String?> originalPath = const Value.absent(),
            required String compressedPath,
            required String thumbnailPath,
            required String hash,
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionMediasCompanion.insert(
            id: id,
            transactionId: transactionId,
            type: type,
            originalPath: originalPath,
            compressedPath: compressedPath,
            thumbnailPath: thumbnailPath,
            hash: hash,
            width: width,
            height: height,
            fileSizeBytes: fileSizeBytes,
            capturedAt: capturedAt,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionMediasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionMediasTable,
    TransactionMediaRow,
    $$TransactionMediasTableFilterComposer,
    $$TransactionMediasTableOrderingComposer,
    $$TransactionMediasTableAnnotationComposer,
    $$TransactionMediasTableCreateCompanionBuilder,
    $$TransactionMediasTableUpdateCompanionBuilder,
    (
      TransactionMediaRow,
      BaseReferences<_$AppDatabase, $TransactionMediasTable,
          TransactionMediaRow>
    ),
    TransactionMediaRow,
    PrefetchHooks Function()>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String categoryId,
  Value<String?> householdId,
  Value<String> period,
  required double amountLimit,
  Value<String> alertThresholds,
  Value<bool> alertSentAt80,
  Value<bool> alertSentAt100,
  Value<bool> alertSentAt120,
  required DateTime periodStart,
  required DateTime periodEnd,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String?> householdId,
  Value<String> period,
  Value<double> amountLimit,
  Value<String> alertThresholds,
  Value<bool> alertSentAt80,
  Value<bool> alertSentAt100,
  Value<bool> alertSentAt120,
  Value<DateTime> periodStart,
  Value<DateTime> periodEnd,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountLimit => $composableBuilder(
      column: $table.amountLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alertThresholds => $composableBuilder(
      column: $table.alertThresholds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get alertSentAt80 => $composableBuilder(
      column: $table.alertSentAt80, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get alertSentAt100 => $composableBuilder(
      column: $table.alertSentAt100,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get alertSentAt120 => $composableBuilder(
      column: $table.alertSentAt120,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountLimit => $composableBuilder(
      column: $table.amountLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alertThresholds => $composableBuilder(
      column: $table.alertThresholds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get alertSentAt80 => $composableBuilder(
      column: $table.alertSentAt80,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get alertSentAt100 => $composableBuilder(
      column: $table.alertSentAt100,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get alertSentAt120 => $composableBuilder(
      column: $table.alertSentAt120,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<double> get amountLimit => $composableBuilder(
      column: $table.amountLimit, builder: (column) => column);

  GeneratedColumn<String> get alertThresholds => $composableBuilder(
      column: $table.alertThresholds, builder: (column) => column);

  GeneratedColumn<bool> get alertSentAt80 => $composableBuilder(
      column: $table.alertSentAt80, builder: (column) => column);

  GeneratedColumn<bool> get alertSentAt100 => $composableBuilder(
      column: $table.alertSentAt100, builder: (column) => column);

  GeneratedColumn<bool> get alertSentAt120 => $composableBuilder(
      column: $table.alertSentAt120, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetRow,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
    BudgetRow,
    PrefetchHooks Function()> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> householdId = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<double> amountLimit = const Value.absent(),
            Value<String> alertThresholds = const Value.absent(),
            Value<bool> alertSentAt80 = const Value.absent(),
            Value<bool> alertSentAt100 = const Value.absent(),
            Value<bool> alertSentAt120 = const Value.absent(),
            Value<DateTime> periodStart = const Value.absent(),
            Value<DateTime> periodEnd = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryId: categoryId,
            householdId: householdId,
            period: period,
            amountLimit: amountLimit,
            alertThresholds: alertThresholds,
            alertSentAt80: alertSentAt80,
            alertSentAt100: alertSentAt100,
            alertSentAt120: alertSentAt120,
            periodStart: periodStart,
            periodEnd: periodEnd,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            Value<String?> householdId = const Value.absent(),
            Value<String> period = const Value.absent(),
            required double amountLimit,
            Value<String> alertThresholds = const Value.absent(),
            Value<bool> alertSentAt80 = const Value.absent(),
            Value<bool> alertSentAt100 = const Value.absent(),
            Value<bool> alertSentAt120 = const Value.absent(),
            required DateTime periodStart,
            required DateTime periodEnd,
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            householdId: householdId,
            period: period,
            amountLimit: amountLimit,
            alertThresholds: alertThresholds,
            alertSentAt80: alertSentAt80,
            alertSentAt100: alertSentAt100,
            alertSentAt120: alertSentAt120,
            periodStart: periodStart,
            periodEnd: periodEnd,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetRow,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
    BudgetRow,
    PrefetchHooks Function()>;
typedef $$AIInferencesTableCreateCompanionBuilder = AIInferencesCompanion
    Function({
  required String id,
  required String mediaId,
  required String modelVersion,
  Value<String> labelsJson,
  Value<String?> suggestedCategoryId,
  Value<double?> suggestedCategoryConfidence,
  Value<String> extractedAmountsJson,
  required double confidence,
  required int latencyMs,
  Value<String> source,
  Value<int> rowid,
});
typedef $$AIInferencesTableUpdateCompanionBuilder = AIInferencesCompanion
    Function({
  Value<String> id,
  Value<String> mediaId,
  Value<String> modelVersion,
  Value<String> labelsJson,
  Value<String?> suggestedCategoryId,
  Value<double?> suggestedCategoryConfidence,
  Value<String> extractedAmountsJson,
  Value<double> confidence,
  Value<int> latencyMs,
  Value<String> source,
  Value<int> rowid,
});

class $$AIInferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AIInferencesTable> {
  $$AIInferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labelsJson => $composableBuilder(
      column: $table.labelsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedCategoryId => $composableBuilder(
      column: $table.suggestedCategoryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get suggestedCategoryConfidence => $composableBuilder(
      column: $table.suggestedCategoryConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedAmountsJson => $composableBuilder(
      column: $table.extractedAmountsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get latencyMs => $composableBuilder(
      column: $table.latencyMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$AIInferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AIInferencesTable> {
  $$AIInferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelsJson => $composableBuilder(
      column: $table.labelsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedCategoryId => $composableBuilder(
      column: $table.suggestedCategoryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get suggestedCategoryConfidence => $composableBuilder(
      column: $table.suggestedCategoryConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedAmountsJson => $composableBuilder(
      column: $table.extractedAmountsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get latencyMs => $composableBuilder(
      column: $table.latencyMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$AIInferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIInferencesTable> {
  $$AIInferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  GeneratedColumn<String> get labelsJson => $composableBuilder(
      column: $table.labelsJson, builder: (column) => column);

  GeneratedColumn<String> get suggestedCategoryId => $composableBuilder(
      column: $table.suggestedCategoryId, builder: (column) => column);

  GeneratedColumn<double> get suggestedCategoryConfidence => $composableBuilder(
      column: $table.suggestedCategoryConfidence, builder: (column) => column);

  GeneratedColumn<String> get extractedAmountsJson => $composableBuilder(
      column: $table.extractedAmountsJson, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$AIInferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AIInferencesTable,
    AIInferenceRow,
    $$AIInferencesTableFilterComposer,
    $$AIInferencesTableOrderingComposer,
    $$AIInferencesTableAnnotationComposer,
    $$AIInferencesTableCreateCompanionBuilder,
    $$AIInferencesTableUpdateCompanionBuilder,
    (
      AIInferenceRow,
      BaseReferences<_$AppDatabase, $AIInferencesTable, AIInferenceRow>
    ),
    AIInferenceRow,
    PrefetchHooks Function()> {
  $$AIInferencesTableTableManager(_$AppDatabase db, $AIInferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIInferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIInferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AIInferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mediaId = const Value.absent(),
            Value<String> modelVersion = const Value.absent(),
            Value<String> labelsJson = const Value.absent(),
            Value<String?> suggestedCategoryId = const Value.absent(),
            Value<double?> suggestedCategoryConfidence = const Value.absent(),
            Value<String> extractedAmountsJson = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<int> latencyMs = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AIInferencesCompanion(
            id: id,
            mediaId: mediaId,
            modelVersion: modelVersion,
            labelsJson: labelsJson,
            suggestedCategoryId: suggestedCategoryId,
            suggestedCategoryConfidence: suggestedCategoryConfidence,
            extractedAmountsJson: extractedAmountsJson,
            confidence: confidence,
            latencyMs: latencyMs,
            source: source,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mediaId,
            required String modelVersion,
            Value<String> labelsJson = const Value.absent(),
            Value<String?> suggestedCategoryId = const Value.absent(),
            Value<double?> suggestedCategoryConfidence = const Value.absent(),
            Value<String> extractedAmountsJson = const Value.absent(),
            required double confidence,
            required int latencyMs,
            Value<String> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AIInferencesCompanion.insert(
            id: id,
            mediaId: mediaId,
            modelVersion: modelVersion,
            labelsJson: labelsJson,
            suggestedCategoryId: suggestedCategoryId,
            suggestedCategoryConfidence: suggestedCategoryConfidence,
            extractedAmountsJson: extractedAmountsJson,
            confidence: confidence,
            latencyMs: latencyMs,
            source: source,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AIInferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AIInferencesTable,
    AIInferenceRow,
    $$AIInferencesTableFilterComposer,
    $$AIInferencesTableOrderingComposer,
    $$AIInferencesTableAnnotationComposer,
    $$AIInferencesTableCreateCompanionBuilder,
    $$AIInferencesTableUpdateCompanionBuilder,
    (
      AIInferenceRow,
      BaseReferences<_$AppDatabase, $AIInferencesTable, AIInferenceRow>
    ),
    AIInferenceRow,
    PrefetchHooks Function()>;
typedef $$ReceiptExtractionsTableCreateCompanionBuilder
    = ReceiptExtractionsCompanion Function({
  required String transactionId,
  Value<String?> merchant,
  Value<double?> merchantConfidence,
  Value<bool> merchantUserEdited,
  Value<DateTime?> transactionDate,
  Value<double?> dateConfidence,
  Value<double?> total,
  Value<double?> totalConfidence,
  Value<double?> subtotal,
  Value<double?> tax,
  Value<PaymentMethod?> paymentMethod,
  required double overallConfidence,
  Value<String?> rawText,
  Value<bool> requiresReview,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ReceiptExtractionsTableUpdateCompanionBuilder
    = ReceiptExtractionsCompanion Function({
  Value<String> transactionId,
  Value<String?> merchant,
  Value<double?> merchantConfidence,
  Value<bool> merchantUserEdited,
  Value<DateTime?> transactionDate,
  Value<double?> dateConfidence,
  Value<double?> total,
  Value<double?> totalConfidence,
  Value<double?> subtotal,
  Value<double?> tax,
  Value<PaymentMethod?> paymentMethod,
  Value<double> overallConfidence,
  Value<String?> rawText,
  Value<bool> requiresReview,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ReceiptExtractionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptExtractionsTable> {
  $$ReceiptExtractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get merchantConfidence => $composableBuilder(
      column: $table.merchantConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get merchantUserEdited => $composableBuilder(
      column: $table.merchantUserEdited,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dateConfidence => $composableBuilder(
      column: $table.dateConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalConfidence => $composableBuilder(
      column: $table.totalConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tax => $composableBuilder(
      column: $table.tax, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
      get paymentMethod => $composableBuilder(
          column: $table.paymentMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get overallConfidence => $composableBuilder(
      column: $table.overallConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresReview => $composableBuilder(
      column: $table.requiresReview,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ReceiptExtractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptExtractionsTable> {
  $$ReceiptExtractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get merchantConfidence => $composableBuilder(
      column: $table.merchantConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get merchantUserEdited => $composableBuilder(
      column: $table.merchantUserEdited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dateConfidence => $composableBuilder(
      column: $table.dateConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalConfidence => $composableBuilder(
      column: $table.totalConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tax => $composableBuilder(
      column: $table.tax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get overallConfidence => $composableBuilder(
      column: $table.overallConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresReview => $composableBuilder(
      column: $table.requiresReview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ReceiptExtractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptExtractionsTable> {
  $$ReceiptExtractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<double> get merchantConfidence => $composableBuilder(
      column: $table.merchantConfidence, builder: (column) => column);

  GeneratedColumn<bool> get merchantUserEdited => $composableBuilder(
      column: $table.merchantUserEdited, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<double> get dateConfidence => $composableBuilder(
      column: $table.dateConfidence, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get totalConfidence => $composableBuilder(
      column: $table.totalConfidence, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
          column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<double> get overallConfidence => $composableBuilder(
      column: $table.overallConfidence, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<bool> get requiresReview => $composableBuilder(
      column: $table.requiresReview, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ReceiptExtractionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReceiptExtractionsTable,
    ReceiptExtractionRow,
    $$ReceiptExtractionsTableFilterComposer,
    $$ReceiptExtractionsTableOrderingComposer,
    $$ReceiptExtractionsTableAnnotationComposer,
    $$ReceiptExtractionsTableCreateCompanionBuilder,
    $$ReceiptExtractionsTableUpdateCompanionBuilder,
    (
      ReceiptExtractionRow,
      BaseReferences<_$AppDatabase, $ReceiptExtractionsTable,
          ReceiptExtractionRow>
    ),
    ReceiptExtractionRow,
    PrefetchHooks Function()> {
  $$ReceiptExtractionsTableTableManager(
      _$AppDatabase db, $ReceiptExtractionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptExtractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptExtractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptExtractionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> transactionId = const Value.absent(),
            Value<String?> merchant = const Value.absent(),
            Value<double?> merchantConfidence = const Value.absent(),
            Value<bool> merchantUserEdited = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<double?> dateConfidence = const Value.absent(),
            Value<double?> total = const Value.absent(),
            Value<double?> totalConfidence = const Value.absent(),
            Value<double?> subtotal = const Value.absent(),
            Value<double?> tax = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
            Value<double> overallConfidence = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<bool> requiresReview = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptExtractionsCompanion(
            transactionId: transactionId,
            merchant: merchant,
            merchantConfidence: merchantConfidence,
            merchantUserEdited: merchantUserEdited,
            transactionDate: transactionDate,
            dateConfidence: dateConfidence,
            total: total,
            totalConfidence: totalConfidence,
            subtotal: subtotal,
            tax: tax,
            paymentMethod: paymentMethod,
            overallConfidence: overallConfidence,
            rawText: rawText,
            requiresReview: requiresReview,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String transactionId,
            Value<String?> merchant = const Value.absent(),
            Value<double?> merchantConfidence = const Value.absent(),
            Value<bool> merchantUserEdited = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<double?> dateConfidence = const Value.absent(),
            Value<double?> total = const Value.absent(),
            Value<double?> totalConfidence = const Value.absent(),
            Value<double?> subtotal = const Value.absent(),
            Value<double?> tax = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
            required double overallConfidence,
            Value<String?> rawText = const Value.absent(),
            Value<bool> requiresReview = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptExtractionsCompanion.insert(
            transactionId: transactionId,
            merchant: merchant,
            merchantConfidence: merchantConfidence,
            merchantUserEdited: merchantUserEdited,
            transactionDate: transactionDate,
            dateConfidence: dateConfidence,
            total: total,
            totalConfidence: totalConfidence,
            subtotal: subtotal,
            tax: tax,
            paymentMethod: paymentMethod,
            overallConfidence: overallConfidence,
            rawText: rawText,
            requiresReview: requiresReview,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReceiptExtractionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReceiptExtractionsTable,
    ReceiptExtractionRow,
    $$ReceiptExtractionsTableFilterComposer,
    $$ReceiptExtractionsTableOrderingComposer,
    $$ReceiptExtractionsTableAnnotationComposer,
    $$ReceiptExtractionsTableCreateCompanionBuilder,
    $$ReceiptExtractionsTableUpdateCompanionBuilder,
    (
      ReceiptExtractionRow,
      BaseReferences<_$AppDatabase, $ReceiptExtractionsTable,
          ReceiptExtractionRow>
    ),
    ReceiptExtractionRow,
    PrefetchHooks Function()>;
typedef $$ReceiptLineItemsTableCreateCompanionBuilder
    = ReceiptLineItemsCompanion Function({
  required String id,
  required String transactionId,
  required String name,
  Value<double?> quantity,
  Value<double?> unitPrice,
  required double total,
  Value<String?> categorySuggestion,
  Value<double> confidence,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ReceiptLineItemsTableUpdateCompanionBuilder
    = ReceiptLineItemsCompanion Function({
  Value<String> id,
  Value<String> transactionId,
  Value<String> name,
  Value<double?> quantity,
  Value<double?> unitPrice,
  Value<double> total,
  Value<String?> categorySuggestion,
  Value<double> confidence,
  Value<int> revision,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ReceiptLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptLineItemsTable> {
  $$ReceiptLineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorySuggestion => $composableBuilder(
      column: $table.categorySuggestion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ReceiptLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptLineItemsTable> {
  $$ReceiptLineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorySuggestion => $composableBuilder(
      column: $table.categorySuggestion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ReceiptLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptLineItemsTable> {
  $$ReceiptLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get categorySuggestion => $composableBuilder(
      column: $table.categorySuggestion, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ReceiptLineItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReceiptLineItemsTable,
    ReceiptLineItemRow,
    $$ReceiptLineItemsTableFilterComposer,
    $$ReceiptLineItemsTableOrderingComposer,
    $$ReceiptLineItemsTableAnnotationComposer,
    $$ReceiptLineItemsTableCreateCompanionBuilder,
    $$ReceiptLineItemsTableUpdateCompanionBuilder,
    (
      ReceiptLineItemRow,
      BaseReferences<_$AppDatabase, $ReceiptLineItemsTable, ReceiptLineItemRow>
    ),
    ReceiptLineItemRow,
    PrefetchHooks Function()> {
  $$ReceiptLineItemsTableTableManager(
      _$AppDatabase db, $ReceiptLineItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptLineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptLineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double?> quantity = const Value.absent(),
            Value<double?> unitPrice = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String?> categorySuggestion = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptLineItemsCompanion(
            id: id,
            transactionId: transactionId,
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            categorySuggestion: categorySuggestion,
            confidence: confidence,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            required String name,
            Value<double?> quantity = const Value.absent(),
            Value<double?> unitPrice = const Value.absent(),
            required double total,
            Value<String?> categorySuggestion = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptLineItemsCompanion.insert(
            id: id,
            transactionId: transactionId,
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            categorySuggestion: categorySuggestion,
            confidence: confidence,
            revision: revision,
            deletedAt: deletedAt,
            syncState: syncState,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReceiptLineItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReceiptLineItemsTable,
    ReceiptLineItemRow,
    $$ReceiptLineItemsTableFilterComposer,
    $$ReceiptLineItemsTableOrderingComposer,
    $$ReceiptLineItemsTableAnnotationComposer,
    $$ReceiptLineItemsTableCreateCompanionBuilder,
    $$ReceiptLineItemsTableUpdateCompanionBuilder,
    (
      ReceiptLineItemRow,
      BaseReferences<_$AppDatabase, $ReceiptLineItemsTable, ReceiptLineItemRow>
    ),
    ReceiptLineItemRow,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  required String id,
  required String role,
  required String body,
  Value<String> blocksJson,
  Value<String> suggestionsJson,
  Value<bool> isLocal,
  Value<bool> isFeedback,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<String> id,
  Value<String> role,
  Value<String> body,
  Value<String> blocksJson,
  Value<String> suggestionsJson,
  Value<bool> isLocal,
  Value<bool> isFeedback,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocal => $composableBuilder(
      column: $table.isLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFeedback => $composableBuilder(
      column: $table.isFeedback, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocal => $composableBuilder(
      column: $table.isLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFeedback => $composableBuilder(
      column: $table.isFeedback, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => column);

  GeneratedColumn<String> get suggestionsJson => $composableBuilder(
      column: $table.suggestionsJson, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<bool> get isFeedback => $composableBuilder(
      column: $table.isFeedback, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRow,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>
    ),
    ChatMessageRow,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> blocksJson = const Value.absent(),
            Value<String> suggestionsJson = const Value.absent(),
            Value<bool> isLocal = const Value.absent(),
            Value<bool> isFeedback = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            role: role,
            body: body,
            blocksJson: blocksJson,
            suggestionsJson: suggestionsJson,
            isLocal: isLocal,
            isFeedback: isFeedback,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String role,
            required String body,
            Value<String> blocksJson = const Value.absent(),
            Value<String> suggestionsJson = const Value.absent(),
            Value<bool> isLocal = const Value.absent(),
            Value<bool> isFeedback = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            role: role,
            body: body,
            blocksJson: blocksJson,
            suggestionsJson: suggestionsJson,
            isLocal: isLocal,
            isFeedback: isFeedback,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRow,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>
    ),
    ChatMessageRow,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String> payloadJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxRow,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>
    ),
    SyncOutboxRow,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String operation,
            Value<String> payloadJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxRow,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>
    ),
    SyncOutboxRow,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableCreateCompanionBuilder = SyncMetadataCompanion
    Function({
  required String key,
  Value<String> value,
  Value<int> rowid,
});
typedef $$SyncMetadataTableUpdateCompanionBuilder = SyncMetadataCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
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

class $$SyncMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataRow,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataRow,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>
    ),
    SyncMetadataRow,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataRow,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataRow,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>
    ),
    SyncMetadataRow,
    PrefetchHooks Function()>;
typedef $$RecurringRulesTableCreateCompanionBuilder = RecurringRulesCompanion
    Function({
  required String id,
  required double amount,
  required TransactionType type,
  Value<String> currency,
  required String categoryId,
  Value<String?> merchant,
  Value<String?> note,
  required RecurringFrequency frequency,
  Value<int?> dayOfMonth,
  Value<int?> dayOfWeek,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required DateTime nextRunAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$RecurringRulesTableUpdateCompanionBuilder = RecurringRulesCompanion
    Function({
  Value<String> id,
  Value<double> amount,
  Value<TransactionType> type,
  Value<String> currency,
  Value<String> categoryId,
  Value<String?> merchant,
  Value<String?> note,
  Value<RecurringFrequency> frequency,
  Value<int?> dayOfMonth,
  Value<int?> dayOfWeek,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> nextRunAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurringFrequency, RecurringFrequency, String>
      get frequency => $composableBuilder(
          column: $table.frequency,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRunAt => $composableBuilder(
      column: $table.nextRunAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRunAt => $composableBuilder(
      column: $table.nextRunAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurringFrequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecurringRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringRulesTable,
    RecurringRuleRow,
    $$RecurringRulesTableFilterComposer,
    $$RecurringRulesTableOrderingComposer,
    $$RecurringRulesTableAnnotationComposer,
    $$RecurringRulesTableCreateCompanionBuilder,
    $$RecurringRulesTableUpdateCompanionBuilder,
    (
      RecurringRuleRow,
      BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRuleRow>
    ),
    RecurringRuleRow,
    PrefetchHooks Function()> {
  $$RecurringRulesTableTableManager(
      _$AppDatabase db, $RecurringRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> merchant = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<RecurringFrequency> frequency = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> dayOfWeek = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> nextRunAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringRulesCompanion(
            id: id,
            amount: amount,
            type: type,
            currency: currency,
            categoryId: categoryId,
            merchant: merchant,
            note: note,
            frequency: frequency,
            dayOfMonth: dayOfMonth,
            dayOfWeek: dayOfWeek,
            startDate: startDate,
            endDate: endDate,
            nextRunAt: nextRunAt,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required double amount,
            required TransactionType type,
            Value<String> currency = const Value.absent(),
            required String categoryId,
            Value<String?> merchant = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required RecurringFrequency frequency,
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> dayOfWeek = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required DateTime nextRunAt,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringRulesCompanion.insert(
            id: id,
            amount: amount,
            type: type,
            currency: currency,
            categoryId: categoryId,
            merchant: merchant,
            note: note,
            frequency: frequency,
            dayOfMonth: dayOfMonth,
            dayOfWeek: dayOfWeek,
            startDate: startDate,
            endDate: endDate,
            nextRunAt: nextRunAt,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecurringRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringRulesTable,
    RecurringRuleRow,
    $$RecurringRulesTableFilterComposer,
    $$RecurringRulesTableOrderingComposer,
    $$RecurringRulesTableAnnotationComposer,
    $$RecurringRulesTableCreateCompanionBuilder,
    $$RecurringRulesTableUpdateCompanionBuilder,
    (
      RecurringRuleRow,
      BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRuleRow>
    ),
    RecurringRuleRow,
    PrefetchHooks Function()>;
typedef $$HouseholdMembersTableCreateCompanionBuilder
    = HouseholdMembersCompanion Function({
  required String householdId,
  Value<String> householdName,
  required String userId,
  Value<String> role,
  Value<String?> displayName,
  required DateTime joinedAt,
  Value<int> rowid,
});
typedef $$HouseholdMembersTableUpdateCompanionBuilder
    = HouseholdMembersCompanion Function({
  Value<String> householdId,
  Value<String> householdName,
  Value<String> userId,
  Value<String> role,
  Value<String?> displayName,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

class $$HouseholdMembersTableFilterComposer
    extends Composer<_$AppDatabase, $HouseholdMembersTable> {
  $$HouseholdMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdName => $composableBuilder(
      column: $table.householdName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));
}

class $$HouseholdMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $HouseholdMembersTable> {
  $$HouseholdMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdName => $composableBuilder(
      column: $table.householdName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));
}

class $$HouseholdMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $HouseholdMembersTable> {
  $$HouseholdMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get householdName => $composableBuilder(
      column: $table.householdName, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$HouseholdMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HouseholdMembersTable,
    HouseholdMemberRow,
    $$HouseholdMembersTableFilterComposer,
    $$HouseholdMembersTableOrderingComposer,
    $$HouseholdMembersTableAnnotationComposer,
    $$HouseholdMembersTableCreateCompanionBuilder,
    $$HouseholdMembersTableUpdateCompanionBuilder,
    (
      HouseholdMemberRow,
      BaseReferences<_$AppDatabase, $HouseholdMembersTable, HouseholdMemberRow>
    ),
    HouseholdMemberRow,
    PrefetchHooks Function()> {
  $$HouseholdMembersTableTableManager(
      _$AppDatabase db, $HouseholdMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HouseholdMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HouseholdMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HouseholdMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> householdId = const Value.absent(),
            Value<String> householdName = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseholdMembersCompanion(
            householdId: householdId,
            householdName: householdName,
            userId: userId,
            role: role,
            displayName: displayName,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String householdId,
            Value<String> householdName = const Value.absent(),
            required String userId,
            Value<String> role = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            required DateTime joinedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseholdMembersCompanion.insert(
            householdId: householdId,
            householdName: householdName,
            userId: userId,
            role: role,
            displayName: displayName,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HouseholdMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HouseholdMembersTable,
    HouseholdMemberRow,
    $$HouseholdMembersTableFilterComposer,
    $$HouseholdMembersTableOrderingComposer,
    $$HouseholdMembersTableAnnotationComposer,
    $$HouseholdMembersTableCreateCompanionBuilder,
    $$HouseholdMembersTableUpdateCompanionBuilder,
    (
      HouseholdMemberRow,
      BaseReferences<_$AppDatabase, $HouseholdMembersTable, HouseholdMemberRow>
    ),
    HouseholdMemberRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionMediasTableTableManager get transactionMedias =>
      $$TransactionMediasTableTableManager(_db, _db.transactionMedias);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$AIInferencesTableTableManager get aIInferences =>
      $$AIInferencesTableTableManager(_db, _db.aIInferences);
  $$ReceiptExtractionsTableTableManager get receiptExtractions =>
      $$ReceiptExtractionsTableTableManager(_db, _db.receiptExtractions);
  $$ReceiptLineItemsTableTableManager get receiptLineItems =>
      $$ReceiptLineItemsTableTableManager(_db, _db.receiptLineItems);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$HouseholdMembersTableTableManager get householdMembers =>
      $$HouseholdMembersTableTableManager(_db, _db.householdMembers);
}
