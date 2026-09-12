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
  @override
  List<GeneratedColumn> get $columns =>
      [id, parentId, name, icon, colorValue, isSystem, sortOrder];
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
  const CategoryRow(
      {required this.id,
      this.parentId,
      required this.name,
      required this.icon,
      required this.colorValue,
      required this.isSystem,
      required this.sortOrder});
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
    };
  }

  CategoryRow copyWith(
          {String? id,
          Value<String?> parentId = const Value.absent(),
          String? name,
          String? icon,
          int? colorValue,
          bool? isSystem,
          int? sortOrder}) =>
      CategoryRow(
        id: id ?? this.id,
        parentId: parentId.present ? parentId.value : this.parentId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorValue: colorValue ?? this.colorValue,
        isSystem: isSystem ?? this.isSystem,
        sortOrder: sortOrder ?? this.sortOrder,
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
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, name, icon, colorValue, isSystem, sortOrder);
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
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> colorValue;
  final Value<bool> isSystem;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
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
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
        updatedAt
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
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
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
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
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
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
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
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  /// Unique identifier (ULID / UUID v7).
  final String id;

  /// Transaction type: 'expense' or 'income'.
  final String type;

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

  /// Payment method: 'cash', 'card', 'transfer', 'ewallet', 'other'.
  final String? paymentMethod;

  /// Source: 'product_snap', 'receipt_scan', 'manual', 'import'.
  final String source;

  /// Status: 'draft', 'confirmed', 'needs_review', 'failed'.
  final String status;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;
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
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
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
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
    );
  }

  factory TransactionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      note: serializer.fromJson<String?>(json['note']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<String>(categoryId),
      'merchant': serializer.toJson<String?>(merchant),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'note': serializer.toJson<String?>(note),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TransactionRow copyWith(
          {String? id,
          String? type,
          double? amount,
          String? currency,
          String? categoryId,
          Value<String?> merchant = const Value.absent(),
          DateTime? occurredAt,
          Value<String?> note = const Value.absent(),
          Value<String?> paymentMethod = const Value.absent(),
          String? source,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
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
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      updatedAt);
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
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> categoryId;
  final Value<String?> merchant;
  final Value<DateTime> occurredAt;
  final Value<String?> note;
  final Value<String?> paymentMethod;
  final Value<String> source;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
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
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    required double amount,
    this.currency = const Value.absent(),
    required String categoryId,
    this.merchant = const Value.absent(),
    required DateTime occurredAt,
    this.note = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    required String source,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<double>? amount,
      Value<String>? currency,
      Value<String>? categoryId,
      Value<String?>? merchant,
      Value<DateTime>? occurredAt,
      Value<String?>? note,
      Value<String?>? paymentMethod,
      Value<String>? source,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
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
      map['type'] = Variable<String>(type.value);
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
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
        capturedAt
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
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
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
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
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
    );
  }

  @override
  $TransactionMediasTable createAlias(String alias) {
    return $TransactionMediasTable(attachedDatabase, alias);
  }
}

class TransactionMediaRow extends DataClass
    implements Insertable<TransactionMediaRow> {
  /// Unique identifier.
  final String id;

  /// Foreign key to Transactions.id.
  final String transactionId;

  /// Media type: 'product', 'receipt', 'screenshot'.
  final String type;

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
      this.capturedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['type'] = Variable<String>(type);
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
    );
  }

  factory TransactionMediaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionMediaRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      type: serializer.fromJson<String>(json['type']),
      originalPath: serializer.fromJson<String?>(json['originalPath']),
      compressedPath: serializer.fromJson<String>(json['compressedPath']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
      hash: serializer.fromJson<String>(json['hash']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'type': serializer.toJson<String>(type),
      'originalPath': serializer.toJson<String?>(originalPath),
      'compressedPath': serializer.toJson<String>(compressedPath),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
      'hash': serializer.toJson<String>(hash),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
    };
  }

  TransactionMediaRow copyWith(
          {String? id,
          String? transactionId,
          String? type,
          Value<String?> originalPath = const Value.absent(),
          String? compressedPath,
          String? thumbnailPath,
          String? hash,
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          Value<int?> fileSizeBytes = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent()}) =>
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
          ..write('capturedAt: $capturedAt')
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
      capturedAt);
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
          other.capturedAt == this.capturedAt);
}

class TransactionMediasCompanion extends UpdateCompanion<TransactionMediaRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> type;
  final Value<String?> originalPath;
  final Value<String> compressedPath;
  final Value<String> thumbnailPath;
  final Value<String> hash;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> fileSizeBytes;
  final Value<DateTime?> capturedAt;
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
    this.rowid = const Value.absent(),
  });
  TransactionMediasCompanion.insert({
    required String id,
    required String transactionId,
    required String type,
    this.originalPath = const Value.absent(),
    required String compressedPath,
    required String thumbnailPath,
    required String hash,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.capturedAt = const Value.absent(),
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionMediasCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<String>? type,
      Value<String?>? originalPath,
      Value<String>? compressedPath,
      Value<String>? thumbnailPath,
      Value<String>? hash,
      Value<int?>? width,
      Value<int?>? height,
      Value<int?>? fileSizeBytes,
      Value<DateTime?>? capturedAt,
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
      map['type'] = Variable<String>(type.value);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        period,
        amountLimit,
        alertThresholds,
        alertSentAt80,
        alertSentAt100,
        periodStart,
        periodEnd
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
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end'])!,
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

  /// Start timestamp of current budget period.
  final DateTime periodStart;

  /// End timestamp of current budget period.
  final DateTime periodEnd;
  const BudgetRow(
      {required this.id,
      required this.categoryId,
      required this.period,
      required this.amountLimit,
      required this.alertThresholds,
      required this.alertSentAt80,
      required this.alertSentAt100,
      required this.periodStart,
      required this.periodEnd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['period'] = Variable<String>(period);
    map['amount_limit'] = Variable<double>(amountLimit);
    map['alert_thresholds'] = Variable<String>(alertThresholds);
    map['alert_sent_at80'] = Variable<bool>(alertSentAt80);
    map['alert_sent_at100'] = Variable<bool>(alertSentAt100);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      period: Value(period),
      amountLimit: Value(amountLimit),
      alertThresholds: Value(alertThresholds),
      alertSentAt80: Value(alertSentAt80),
      alertSentAt100: Value(alertSentAt100),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
    );
  }

  factory BudgetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      period: serializer.fromJson<String>(json['period']),
      amountLimit: serializer.fromJson<double>(json['amountLimit']),
      alertThresholds: serializer.fromJson<String>(json['alertThresholds']),
      alertSentAt80: serializer.fromJson<bool>(json['alertSentAt80']),
      alertSentAt100: serializer.fromJson<bool>(json['alertSentAt100']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'period': serializer.toJson<String>(period),
      'amountLimit': serializer.toJson<double>(amountLimit),
      'alertThresholds': serializer.toJson<String>(alertThresholds),
      'alertSentAt80': serializer.toJson<bool>(alertSentAt80),
      'alertSentAt100': serializer.toJson<bool>(alertSentAt100),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
    };
  }

  BudgetRow copyWith(
          {String? id,
          String? categoryId,
          String? period,
          double? amountLimit,
          String? alertThresholds,
          bool? alertSentAt80,
          bool? alertSentAt100,
          DateTime? periodStart,
          DateTime? periodEnd}) =>
      BudgetRow(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        period: period ?? this.period,
        amountLimit: amountLimit ?? this.amountLimit,
        alertThresholds: alertThresholds ?? this.alertThresholds,
        alertSentAt80: alertSentAt80 ?? this.alertSentAt80,
        alertSentAt100: alertSentAt100 ?? this.alertSentAt100,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
      );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
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
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('period: $period, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('alertThresholds: $alertThresholds, ')
          ..write('alertSentAt80: $alertSentAt80, ')
          ..write('alertSentAt100: $alertSentAt100, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, period, amountLimit,
      alertThresholds, alertSentAt80, alertSentAt100, periodStart, periodEnd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.period == this.period &&
          other.amountLimit == this.amountLimit &&
          other.alertThresholds == this.alertThresholds &&
          other.alertSentAt80 == this.alertSentAt80 &&
          other.alertSentAt100 == this.alertSentAt100 &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> period;
  final Value<double> amountLimit;
  final Value<String> alertThresholds;
  final Value<bool> alertSentAt80;
  final Value<bool> alertSentAt100;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.period = const Value.absent(),
    this.amountLimit = const Value.absent(),
    this.alertThresholds = const Value.absent(),
    this.alertSentAt80 = const Value.absent(),
    this.alertSentAt100 = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    this.period = const Value.absent(),
    required double amountLimit,
    this.alertThresholds = const Value.absent(),
    this.alertSentAt80 = const Value.absent(),
    this.alertSentAt100 = const Value.absent(),
    required DateTime periodStart,
    required DateTime periodEnd,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        amountLimit = Value(amountLimit),
        periodStart = Value(periodStart),
        periodEnd = Value(periodEnd);
  static Insertable<BudgetRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? period,
    Expression<double>? amountLimit,
    Expression<String>? alertThresholds,
    Expression<bool>? alertSentAt80,
    Expression<bool>? alertSentAt100,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (period != null) 'period': period,
      if (amountLimit != null) 'amount_limit': amountLimit,
      if (alertThresholds != null) 'alert_thresholds': alertThresholds,
      if (alertSentAt80 != null) 'alert_sent_at80': alertSentAt80,
      if (alertSentAt100 != null) 'alert_sent_at100': alertSentAt100,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String>? period,
      Value<double>? amountLimit,
      Value<String>? alertThresholds,
      Value<bool>? alertSentAt80,
      Value<bool>? alertSentAt100,
      Value<DateTime>? periodStart,
      Value<DateTime>? periodEnd,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      amountLimit: amountLimit ?? this.amountLimit,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      alertSentAt80: alertSentAt80 ?? this.alertSentAt80,
      alertSentAt100: alertSentAt100 ?? this.alertSentAt100,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
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
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
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
          ..write('period: $period, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('alertThresholds: $alertThresholds, ')
          ..write('alertSentAt80: $alertSentAt80, ')
          ..write('alertSentAt100: $alertSentAt100, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
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
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        requiresReview
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
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
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
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      overallConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}overall_confidence'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text']),
      requiresReview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}requires_review'])!,
    );
  }

  @override
  $ReceiptExtractionsTable createAlias(String alias) {
    return $ReceiptExtractionsTable(attachedDatabase, alias);
  }
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

  /// Detected payment method.
  final String? paymentMethod;

  /// Overall extraction confidence (0.0 to 1.0).
  final double overallConfidence;

  /// Full raw OCR text.
  final String? rawText;

  /// Whether the extraction was flagged for human review (confidence < 0.70).
  final bool requiresReview;
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
      required this.requiresReview});
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
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['overall_confidence'] = Variable<double>(overallConfidence);
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    map['requires_review'] = Variable<bool>(requiresReview);
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
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      overallConfidence: serializer.fromJson<double>(json['overallConfidence']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      requiresReview: serializer.fromJson<bool>(json['requiresReview']),
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
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'overallConfidence': serializer.toJson<double>(overallConfidence),
      'rawText': serializer.toJson<String?>(rawText),
      'requiresReview': serializer.toJson<bool>(requiresReview),
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
          Value<String?> paymentMethod = const Value.absent(),
          double? overallConfidence,
          Value<String?> rawText = const Value.absent(),
          bool? requiresReview}) =>
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
          ..write('requiresReview: $requiresReview')
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
      requiresReview);
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
          other.requiresReview == this.requiresReview);
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
  final Value<String?> paymentMethod;
  final Value<double> overallConfidence;
  final Value<String?> rawText;
  final Value<bool> requiresReview;
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
      Value<String?>? paymentMethod,
      Value<double>? overallConfidence,
      Value<String?>? rawText,
      Value<bool>? requiresReview,
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
      map['payment_method'] = Variable<String>(paymentMethod.value);
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
      defaultValue: const Constant(1.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        name,
        quantity,
        unitPrice,
        total,
        categorySuggestion,
        confidence
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
  const ReceiptLineItemRow(
      {required this.id,
      required this.transactionId,
      required this.name,
      this.quantity,
      this.unitPrice,
      required this.total,
      this.categorySuggestion,
      required this.confidence});
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
          double? confidence}) =>
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
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, name, quantity, unitPrice,
      total, categorySuggestion, confidence);
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
          other.confidence == this.confidence);
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
        receiptLineItems
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
  required String type,
  required double amount,
  Value<String> currency,
  required String categoryId,
  Value<String?> merchant,
  required DateTime occurredAt,
  Value<String?> note,
  Value<String?> paymentMethod,
  required String source,
  required String status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<double> amount,
  Value<String> currency,
  Value<String> categoryId,
  Value<String?> merchant,
  Value<DateTime> occurredAt,
  Value<String?> note,
  Value<String?> paymentMethod,
  Value<String> source,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
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

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
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

  GeneratedColumn<String> get type =>
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
            Value<String> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> merchant = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
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
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required double amount,
            Value<String> currency = const Value.absent(),
            required String categoryId,
            Value<String?> merchant = const Value.absent(),
            required DateTime occurredAt,
            Value<String?> note = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            required String source,
            required String status,
            required DateTime createdAt,
            required DateTime updatedAt,
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
  required String type,
  Value<String?> originalPath,
  required String compressedPath,
  required String thumbnailPath,
  required String hash,
  Value<int?> width,
  Value<int?> height,
  Value<int?> fileSizeBytes,
  Value<DateTime?> capturedAt,
  Value<int> rowid,
});
typedef $$TransactionMediasTableUpdateCompanionBuilder
    = TransactionMediasCompanion Function({
  Value<String> id,
  Value<String> transactionId,
  Value<String> type,
  Value<String?> originalPath,
  Value<String> compressedPath,
  Value<String> thumbnailPath,
  Value<String> hash,
  Value<int?> width,
  Value<int?> height,
  Value<int?> fileSizeBytes,
  Value<DateTime?> capturedAt,
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

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

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

  GeneratedColumn<String> get type =>
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
            Value<String> type = const Value.absent(),
            Value<String?> originalPath = const Value.absent(),
            Value<String> compressedPath = const Value.absent(),
            Value<String> thumbnailPath = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
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
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            required String type,
            Value<String?> originalPath = const Value.absent(),
            required String compressedPath,
            required String thumbnailPath,
            required String hash,
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
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
  Value<String> period,
  required double amountLimit,
  Value<String> alertThresholds,
  Value<bool> alertSentAt80,
  Value<bool> alertSentAt100,
  required DateTime periodStart,
  required DateTime periodEnd,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String> period,
  Value<double> amountLimit,
  Value<String> alertThresholds,
  Value<bool> alertSentAt80,
  Value<bool> alertSentAt100,
  Value<DateTime> periodStart,
  Value<DateTime> periodEnd,
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

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);
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
            Value<String> period = const Value.absent(),
            Value<double> amountLimit = const Value.absent(),
            Value<String> alertThresholds = const Value.absent(),
            Value<bool> alertSentAt80 = const Value.absent(),
            Value<bool> alertSentAt100 = const Value.absent(),
            Value<DateTime> periodStart = const Value.absent(),
            Value<DateTime> periodEnd = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryId: categoryId,
            period: period,
            amountLimit: amountLimit,
            alertThresholds: alertThresholds,
            alertSentAt80: alertSentAt80,
            alertSentAt100: alertSentAt100,
            periodStart: periodStart,
            periodEnd: periodEnd,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            Value<String> period = const Value.absent(),
            required double amountLimit,
            Value<String> alertThresholds = const Value.absent(),
            Value<bool> alertSentAt80 = const Value.absent(),
            Value<bool> alertSentAt100 = const Value.absent(),
            required DateTime periodStart,
            required DateTime periodEnd,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            period: period,
            amountLimit: amountLimit,
            alertThresholds: alertThresholds,
            alertSentAt80: alertSentAt80,
            alertSentAt100: alertSentAt100,
            periodStart: periodStart,
            periodEnd: periodEnd,
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
  Value<String?> paymentMethod,
  required double overallConfidence,
  Value<String?> rawText,
  Value<bool> requiresReview,
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
  Value<String?> paymentMethod,
  Value<double> overallConfidence,
  Value<String?> rawText,
  Value<bool> requiresReview,
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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get overallConfidence => $composableBuilder(
      column: $table.overallConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresReview => $composableBuilder(
      column: $table.requiresReview,
      builder: (column) => ColumnFilters(column));
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<double> get overallConfidence => $composableBuilder(
      column: $table.overallConfidence, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<bool> get requiresReview => $composableBuilder(
      column: $table.requiresReview, builder: (column) => column);
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
            Value<String?> paymentMethod = const Value.absent(),
            Value<double> overallConfidence = const Value.absent(),
            Value<String?> rawText = const Value.absent(),
            Value<bool> requiresReview = const Value.absent(),
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
            Value<String?> paymentMethod = const Value.absent(),
            required double overallConfidence,
            Value<String?> rawText = const Value.absent(),
            Value<bool> requiresReview = const Value.absent(),
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
}
