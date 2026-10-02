// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('g'),
  );
  static const VerificationMeta _blockMeta = const VerificationMeta('block');
  @override
  late final GeneratedColumn<String> block = GeneratedColumn<String>(
    'block',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('need'),
  );
  static const VerificationMeta _monthlyLimitMinorMeta = const VerificationMeta(
    'monthlyLimitMinor',
  );
  @override
  late final GeneratedColumn<int> monthlyLimitMinor = GeneratedColumn<int>(
    'monthly_limit_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    tone,
    block,
    monthlyLimitMinor,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('block')) {
      context.handle(
        _blockMeta,
        block.isAcceptableOrUnknown(data['block']!, _blockMeta),
      );
    }
    if (data.containsKey('monthly_limit_minor')) {
      context.handle(
        _monthlyLimitMinorMeta,
        monthlyLimitMinor.isAcceptableOrUnknown(
          data['monthly_limit_minor']!,
          _monthlyLimitMinorMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      block: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}block'],
      )!,
      monthlyLimitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_limit_minor'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String icon;

  /// Color suave del icono: b, o, g, r, p.
  final String tone;
  final String block;

  /// Límite mensual en unidades mínimas (null = sin límite).
  final int? monthlyLimitMinor;
  final int sortOrder;
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.tone,
    required this.block,
    this.monthlyLimitMinor,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['tone'] = Variable<String>(tone);
    map['block'] = Variable<String>(block);
    if (!nullToAbsent || monthlyLimitMinor != null) {
      map['monthly_limit_minor'] = Variable<int>(monthlyLimitMinor);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      tone: Value(tone),
      block: Value(block),
      monthlyLimitMinor: monthlyLimitMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyLimitMinor),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      tone: serializer.fromJson<String>(json['tone']),
      block: serializer.fromJson<String>(json['block']),
      monthlyLimitMinor: serializer.fromJson<int?>(json['monthlyLimitMinor']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'tone': serializer.toJson<String>(tone),
      'block': serializer.toJson<String>(block),
      'monthlyLimitMinor': serializer.toJson<int?>(monthlyLimitMinor),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? tone,
    String? block,
    Value<int?> monthlyLimitMinor = const Value.absent(),
    int? sortOrder,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    tone: tone ?? this.tone,
    block: block ?? this.block,
    monthlyLimitMinor: monthlyLimitMinor.present
        ? monthlyLimitMinor.value
        : this.monthlyLimitMinor,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      tone: data.tone.present ? data.tone.value : this.tone,
      block: data.block.present ? data.block.value : this.block,
      monthlyLimitMinor: data.monthlyLimitMinor.present
          ? data.monthlyLimitMinor.value
          : this.monthlyLimitMinor,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('block: $block, ')
          ..write('monthlyLimitMinor: $monthlyLimitMinor, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, tone, block, monthlyLimitMinor, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.tone == this.tone &&
          other.block == this.block &&
          other.monthlyLimitMinor == this.monthlyLimitMinor &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> tone;
  final Value<String> block;
  final Value<int?> monthlyLimitMinor;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.block = const Value.absent(),
    this.monthlyLimitMinor = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    this.tone = const Value.absent(),
    this.block = const Value.absent(),
    this.monthlyLimitMinor = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? tone,
    Expression<String>? block,
    Expression<int>? monthlyLimitMinor,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (tone != null) 'tone': tone,
      if (block != null) 'block': block,
      if (monthlyLimitMinor != null) 'monthly_limit_minor': monthlyLimitMinor,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? tone,
    Value<String>? block,
    Value<int?>? monthlyLimitMinor,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      block: block ?? this.block,
      monthlyLimitMinor: monthlyLimitMinor ?? this.monthlyLimitMinor,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (block.present) {
      map['block'] = Variable<String>(block.value);
    }
    if (monthlyLimitMinor.present) {
      map['monthly_limit_minor'] = Variable<int>(monthlyLimitMinor.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('block: $block, ')
          ..write('monthlyLimitMinor: $monthlyLimitMinor, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TxnsTable extends Txns with TableInfo<$TxnsTable, Txn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    kind,
    amountMinor,
    currency,
    categoryId,
    note,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'txns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Txn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
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
  Txn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Txn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TxnsTable createAlias(String alias) {
    return $TxnsTable(attachedDatabase, alias);
  }
}

class Txn extends DataClass implements Insertable<Txn> {
  final int id;
  final String kind;
  final int amountMinor;
  final String currency;
  final int? categoryId;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  const Txn({
    required this.id,
    required this.kind,
    required this.amountMinor,
    required this.currency,
    this.categoryId,
    required this.note,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['note'] = Variable<String>(note);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TxnsCompanion toCompanion(bool nullToAbsent) {
    return TxnsCompanion(
      id: Value(id),
      kind: Value(kind),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      note: Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory Txn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Txn(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<int?>(categoryId),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Txn copyWith({
    int? id,
    String? kind,
    int? amountMinor,
    String? currency,
    Value<int?> categoryId = const Value.absent(),
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) => Txn(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    note: note ?? this.note,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  Txn copyWithCompanion(TxnsCompanion data) {
    return Txn(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Txn(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    amountMinor,
    currency,
    categoryId,
    note,
    date,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Txn &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class TxnsCompanion extends UpdateCompanion<Txn> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int?> categoryId;
  final Value<String> note;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  const TxnsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TxnsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required int amountMinor,
    required String currency,
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime date,
    this.createdAt = const Value.absent(),
  }) : kind = Value(kind),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       date = Value(date);
  static Insertable<Txn> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TxnsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<int?>? categoryId,
    Value<String>? note,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
  }) {
    return TxnsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('g'),
  );
  static const VerificationMeta _targetMinorMeta = const VerificationMeta(
    'targetMinor',
  );
  @override
  late final GeneratedColumn<int> targetMinor = GeneratedColumn<int>(
    'target_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedMinorMeta = const VerificationMeta(
    'savedMinor',
  );
  @override
  late final GeneratedColumn<int> savedMinor = GeneratedColumn<int>(
    'saved_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    tone,
    targetMinor,
    savedMinor,
    currency,
    deadline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('target_minor')) {
      context.handle(
        _targetMinorMeta,
        targetMinor.isAcceptableOrUnknown(
          data['target_minor']!,
          _targetMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMinorMeta);
    }
    if (data.containsKey('saved_minor')) {
      context.handle(
        _savedMinorMeta,
        savedMinor.isAcceptableOrUnknown(data['saved_minor']!, _savedMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      targetMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minor'],
      )!,
      savedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String name;
  final String icon;
  final String tone;
  final int targetMinor;
  final int savedMinor;
  final String currency;
  final DateTime? deadline;
  const Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.tone,
    required this.targetMinor,
    required this.savedMinor,
    required this.currency,
    this.deadline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['tone'] = Variable<String>(tone);
    map['target_minor'] = Variable<int>(targetMinor);
    map['saved_minor'] = Variable<int>(savedMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      tone: Value(tone),
      targetMinor: Value(targetMinor),
      savedMinor: Value(savedMinor),
      currency: Value(currency),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      tone: serializer.fromJson<String>(json['tone']),
      targetMinor: serializer.fromJson<int>(json['targetMinor']),
      savedMinor: serializer.fromJson<int>(json['savedMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'tone': serializer.toJson<String>(tone),
      'targetMinor': serializer.toJson<int>(targetMinor),
      'savedMinor': serializer.toJson<int>(savedMinor),
      'currency': serializer.toJson<String>(currency),
      'deadline': serializer.toJson<DateTime?>(deadline),
    };
  }

  Goal copyWith({
    int? id,
    String? name,
    String? icon,
    String? tone,
    int? targetMinor,
    int? savedMinor,
    String? currency,
    Value<DateTime?> deadline = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    tone: tone ?? this.tone,
    targetMinor: targetMinor ?? this.targetMinor,
    savedMinor: savedMinor ?? this.savedMinor,
    currency: currency ?? this.currency,
    deadline: deadline.present ? deadline.value : this.deadline,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      tone: data.tone.present ? data.tone.value : this.tone,
      targetMinor: data.targetMinor.present
          ? data.targetMinor.value
          : this.targetMinor,
      savedMinor: data.savedMinor.present
          ? data.savedMinor.value
          : this.savedMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('savedMinor: $savedMinor, ')
          ..write('currency: $currency, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    tone,
    targetMinor,
    savedMinor,
    currency,
    deadline,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.tone == this.tone &&
          other.targetMinor == this.targetMinor &&
          other.savedMinor == this.savedMinor &&
          other.currency == this.currency &&
          other.deadline == this.deadline);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> tone;
  final Value<int> targetMinor;
  final Value<int> savedMinor;
  final Value<String> currency;
  final Value<DateTime?> deadline;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.targetMinor = const Value.absent(),
    this.savedMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.deadline = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    this.tone = const Value.absent(),
    required int targetMinor,
    this.savedMinor = const Value.absent(),
    required String currency,
    this.deadline = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon),
       targetMinor = Value(targetMinor),
       currency = Value(currency);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? tone,
    Expression<int>? targetMinor,
    Expression<int>? savedMinor,
    Expression<String>? currency,
    Expression<DateTime>? deadline,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (tone != null) 'tone': tone,
      if (targetMinor != null) 'target_minor': targetMinor,
      if (savedMinor != null) 'saved_minor': savedMinor,
      if (currency != null) 'currency': currency,
      if (deadline != null) 'deadline': deadline,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? tone,
    Value<int>? targetMinor,
    Value<int>? savedMinor,
    Value<String>? currency,
    Value<DateTime?>? deadline,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      targetMinor: targetMinor ?? this.targetMinor,
      savedMinor: savedMinor ?? this.savedMinor,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (targetMinor.present) {
      map['target_minor'] = Variable<int>(targetMinor.value);
    }
    if (savedMinor.present) {
      map['saved_minor'] = Variable<int>(savedMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('savedMinor: $savedMinor, ')
          ..write('currency: $currency, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }
}

class $DayChecksTable extends DayChecks
    with TableInfo<$DayChecksTable, DayCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DayCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCheck(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
    );
  }

  @override
  $DayChecksTable createAlias(String alias) {
    return $DayChecksTable(attachedDatabase, alias);
  }
}

class DayCheck extends DataClass implements Insertable<DayCheck> {
  final DateTime day;
  const DayCheck({required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    return map;
  }

  DayChecksCompanion toCompanion(bool nullToAbsent) {
    return DayChecksCompanion(day: Value(day));
  }

  factory DayCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCheck(day: serializer.fromJson<DateTime>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<DateTime>(day)};
  }

  DayCheck copyWith({DateTime? day}) => DayCheck(day: day ?? this.day);
  DayCheck copyWithCompanion(DayChecksCompanion data) {
    return DayCheck(day: data.day.present ? data.day.value : this.day);
  }

  @override
  String toString() {
    return (StringBuffer('DayCheck(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => day.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DayCheck && other.day == this.day);
}

class DayChecksCompanion extends UpdateCompanion<DayCheck> {
  final Value<DateTime> day;
  final Value<int> rowid;
  const DayChecksCompanion({
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayChecksCompanion.insert({
    required DateTime day,
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<DayCheck> custom({
    Expression<DateTime>? day,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayChecksCompanion copyWith({Value<DateTime>? day, Value<int>? rowid}) {
    return DayChecksCompanion(day: day ?? this.day, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayChecksCompanion(')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringsTable extends Recurrings
    with TableInfo<$RecurringsTable, Recurring> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastMonthMeta = const VerificationMeta(
    'lastMonth',
  );
  @override
  late final GeneratedColumn<String> lastMonth = GeneratedColumn<String>(
    'last_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amountMinor,
    currency,
    categoryId,
    dayOfMonth,
    active,
    lastMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recurring> instance, {
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('last_month')) {
      context.handle(
        _lastMonthMeta,
        lastMonth.isAcceptableOrUnknown(data['last_month']!, _lastMonthMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recurring map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recurring(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      lastMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_month'],
      )!,
    );
  }

  @override
  $RecurringsTable createAlias(String alias) {
    return $RecurringsTable(attachedDatabase, alias);
  }
}

class Recurring extends DataClass implements Insertable<Recurring> {
  final int id;
  final String name;
  final int amountMinor;
  final String currency;
  final int? categoryId;

  /// Día del mes en que se cobra (1-31; en meses cortos cae el último día).
  final int dayOfMonth;
  final bool active;

  /// Último mes generado, "2026-10". Evita duplicar el gasto.
  final String lastMonth;
  const Recurring({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.currency,
    this.categoryId,
    required this.dayOfMonth,
    required this.active,
    required this.lastMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['active'] = Variable<bool>(active);
    map['last_month'] = Variable<String>(lastMonth);
    return map;
  }

  RecurringsCompanion toCompanion(bool nullToAbsent) {
    return RecurringsCompanion(
      id: Value(id),
      name: Value(name),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      dayOfMonth: Value(dayOfMonth),
      active: Value(active),
      lastMonth: Value(lastMonth),
    );
  }

  factory Recurring.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recurring(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      active: serializer.fromJson<bool>(json['active']),
      lastMonth: serializer.fromJson<String>(json['lastMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<int?>(categoryId),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'active': serializer.toJson<bool>(active),
      'lastMonth': serializer.toJson<String>(lastMonth),
    };
  }

  Recurring copyWith({
    int? id,
    String? name,
    int? amountMinor,
    String? currency,
    Value<int?> categoryId = const Value.absent(),
    int? dayOfMonth,
    bool? active,
    String? lastMonth,
  }) => Recurring(
    id: id ?? this.id,
    name: name ?? this.name,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    active: active ?? this.active,
    lastMonth: lastMonth ?? this.lastMonth,
  );
  Recurring copyWithCompanion(RecurringsCompanion data) {
    return Recurring(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      active: data.active.present ? data.active.value : this.active,
      lastMonth: data.lastMonth.present ? data.lastMonth.value : this.lastMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recurring(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('active: $active, ')
          ..write('lastMonth: $lastMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amountMinor,
    currency,
    categoryId,
    dayOfMonth,
    active,
    lastMonth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recurring &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.dayOfMonth == this.dayOfMonth &&
          other.active == this.active &&
          other.lastMonth == this.lastMonth);
}

class RecurringsCompanion extends UpdateCompanion<Recurring> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int?> categoryId;
  final Value<int> dayOfMonth;
  final Value<bool> active;
  final Value<String> lastMonth;
  const RecurringsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.active = const Value.absent(),
    this.lastMonth = const Value.absent(),
  });
  RecurringsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int amountMinor,
    required String currency,
    this.categoryId = const Value.absent(),
    required int dayOfMonth,
    this.active = const Value.absent(),
    this.lastMonth = const Value.absent(),
  }) : name = Value(name),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       dayOfMonth = Value(dayOfMonth);
  static Insertable<Recurring> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? categoryId,
    Expression<int>? dayOfMonth,
    Expression<bool>? active,
    Expression<String>? lastMonth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (active != null) 'active': active,
      if (lastMonth != null) 'last_month': lastMonth,
    });
  }

  RecurringsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<int?>? categoryId,
    Value<int>? dayOfMonth,
    Value<bool>? active,
    Value<String>? lastMonth,
  }) {
    return RecurringsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      active: active ?? this.active,
      lastMonth: lastMonth ?? this.lastMonth,
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
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (lastMonth.present) {
      map['last_month'] = Variable<String>(lastMonth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('active: $active, ')
          ..write('lastMonth: $lastMonth')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualRatePctMeta = const VerificationMeta(
    'annualRatePct',
  );
  @override
  late final GeneratedColumn<double> annualRatePct = GeneratedColumn<double>(
    'annual_rate_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minPaymentMinorMeta = const VerificationMeta(
    'minPaymentMinor',
  );
  @override
  late final GeneratedColumn<int> minPaymentMinor = GeneratedColumn<int>(
    'min_payment_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    balanceMinor,
    currency,
    annualRatePct,
    minPaymentMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
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
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('annual_rate_pct')) {
      context.handle(
        _annualRatePctMeta,
        annualRatePct.isAcceptableOrUnknown(
          data['annual_rate_pct']!,
          _annualRatePctMeta,
        ),
      );
    }
    if (data.containsKey('min_payment_minor')) {
      context.handle(
        _minPaymentMinorMeta,
        minPaymentMinor.isAcceptableOrUnknown(
          data['min_payment_minor']!,
          _minPaymentMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minPaymentMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      annualRatePct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_rate_pct'],
      )!,
      minPaymentMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_payment_minor'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final String name;
  final int balanceMinor;
  final String currency;

  /// Tasa de interés anual en % (36 = 36 %).
  final double annualRatePct;
  final int minPaymentMinor;
  const Debt({
    required this.id,
    required this.name,
    required this.balanceMinor,
    required this.currency,
    required this.annualRatePct,
    required this.minPaymentMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['balance_minor'] = Variable<int>(balanceMinor);
    map['currency'] = Variable<String>(currency);
    map['annual_rate_pct'] = Variable<double>(annualRatePct);
    map['min_payment_minor'] = Variable<int>(minPaymentMinor);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      name: Value(name),
      balanceMinor: Value(balanceMinor),
      currency: Value(currency),
      annualRatePct: Value(annualRatePct),
      minPaymentMinor: Value(minPaymentMinor),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      balanceMinor: serializer.fromJson<int>(json['balanceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      annualRatePct: serializer.fromJson<double>(json['annualRatePct']),
      minPaymentMinor: serializer.fromJson<int>(json['minPaymentMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'balanceMinor': serializer.toJson<int>(balanceMinor),
      'currency': serializer.toJson<String>(currency),
      'annualRatePct': serializer.toJson<double>(annualRatePct),
      'minPaymentMinor': serializer.toJson<int>(minPaymentMinor),
    };
  }

  Debt copyWith({
    int? id,
    String? name,
    int? balanceMinor,
    String? currency,
    double? annualRatePct,
    int? minPaymentMinor,
  }) => Debt(
    id: id ?? this.id,
    name: name ?? this.name,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    currency: currency ?? this.currency,
    annualRatePct: annualRatePct ?? this.annualRatePct,
    minPaymentMinor: minPaymentMinor ?? this.minPaymentMinor,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      annualRatePct: data.annualRatePct.present
          ? data.annualRatePct.value
          : this.annualRatePct,
      minPaymentMinor: data.minPaymentMinor.present
          ? data.minPaymentMinor.value
          : this.minPaymentMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('currency: $currency, ')
          ..write('annualRatePct: $annualRatePct, ')
          ..write('minPaymentMinor: $minPaymentMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    balanceMinor,
    currency,
    annualRatePct,
    minPaymentMinor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.name == this.name &&
          other.balanceMinor == this.balanceMinor &&
          other.currency == this.currency &&
          other.annualRatePct == this.annualRatePct &&
          other.minPaymentMinor == this.minPaymentMinor);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> balanceMinor;
  final Value<String> currency;
  final Value<double> annualRatePct;
  final Value<int> minPaymentMinor;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.annualRatePct = const Value.absent(),
    this.minPaymentMinor = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int balanceMinor,
    required String currency,
    this.annualRatePct = const Value.absent(),
    required int minPaymentMinor,
  }) : name = Value(name),
       balanceMinor = Value(balanceMinor),
       currency = Value(currency),
       minPaymentMinor = Value(minPaymentMinor);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? balanceMinor,
    Expression<String>? currency,
    Expression<double>? annualRatePct,
    Expression<int>? minPaymentMinor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (currency != null) 'currency': currency,
      if (annualRatePct != null) 'annual_rate_pct': annualRatePct,
      if (minPaymentMinor != null) 'min_payment_minor': minPaymentMinor,
    });
  }

  DebtsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? balanceMinor,
    Value<String>? currency,
    Value<double>? annualRatePct,
    Value<int>? minPaymentMinor,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      currency: currency ?? this.currency,
      annualRatePct: annualRatePct ?? this.annualRatePct,
      minPaymentMinor: minPaymentMinor ?? this.minPaymentMinor,
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
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (annualRatePct.present) {
      map['annual_rate_pct'] = Variable<double>(annualRatePct.value);
    }
    if (minPaymentMinor.present) {
      map['min_payment_minor'] = Variable<int>(minPaymentMinor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('currency: $currency, ')
          ..write('annualRatePct: $annualRatePct, ')
          ..write('minPaymentMinor: $minPaymentMinor')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tag'),
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('o'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesPerDayMeta = const VerificationMeta(
    'timesPerDay',
  );
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
    'times_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(31),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdOnMeta = const VerificationMeta(
    'createdOn',
  );
  @override
  late final GeneratedColumn<DateTime> createdOn = GeneratedColumn<DateTime>(
    'created_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastGeneratedMeta = const VerificationMeta(
    'lastGenerated',
  );
  @override
  late final GeneratedColumn<String> lastGenerated = GeneratedColumn<String>(
    'last_generated',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    tone,
    categoryId,
    unitPriceMinor,
    currency,
    timesPerDay,
    weekdays,
    active,
    createdOn,
    lastGenerated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
        _timesPerDayMeta,
        timesPerDay.isAcceptableOrUnknown(
          data['times_per_day']!,
          _timesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_on')) {
      context.handle(
        _createdOnMeta,
        createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta),
      );
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('last_generated')) {
      context.handle(
        _lastGeneratedMeta,
        lastGenerated.isAcceptableOrUnknown(
          data['last_generated']!,
          _lastGeneratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      timesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_day'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_on'],
      )!,
      lastGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String icon;
  final String tone;
  final int? categoryId;

  /// Precio de UNA vez (un boleto, una merienda).
  final int unitPriceMinor;
  final String currency;
  final int timesPerDay;

  /// Días de la semana en bits: lun = 1 ... dom = 64 (ver HabitRule).
  final int weekdays;
  final bool active;
  final DateTime createdOn;

  /// Último día generado, "2026-10-12" (vacío = todavía ninguno).
  final String lastGenerated;
  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.tone,
    this.categoryId,
    required this.unitPriceMinor,
    required this.currency,
    required this.timesPerDay,
    required this.weekdays,
    required this.active,
    required this.createdOn,
    required this.lastGenerated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['tone'] = Variable<String>(tone);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['currency'] = Variable<String>(currency);
    map['times_per_day'] = Variable<int>(timesPerDay);
    map['weekdays'] = Variable<int>(weekdays);
    map['active'] = Variable<bool>(active);
    map['created_on'] = Variable<DateTime>(createdOn);
    map['last_generated'] = Variable<String>(lastGenerated);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      tone: Value(tone),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      unitPriceMinor: Value(unitPriceMinor),
      currency: Value(currency),
      timesPerDay: Value(timesPerDay),
      weekdays: Value(weekdays),
      active: Value(active),
      createdOn: Value(createdOn),
      lastGenerated: Value(lastGenerated),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      tone: serializer.fromJson<String>(json['tone']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      timesPerDay: serializer.fromJson<int>(json['timesPerDay']),
      weekdays: serializer.fromJson<int>(json['weekdays']),
      active: serializer.fromJson<bool>(json['active']),
      createdOn: serializer.fromJson<DateTime>(json['createdOn']),
      lastGenerated: serializer.fromJson<String>(json['lastGenerated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'tone': serializer.toJson<String>(tone),
      'categoryId': serializer.toJson<int?>(categoryId),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'currency': serializer.toJson<String>(currency),
      'timesPerDay': serializer.toJson<int>(timesPerDay),
      'weekdays': serializer.toJson<int>(weekdays),
      'active': serializer.toJson<bool>(active),
      'createdOn': serializer.toJson<DateTime>(createdOn),
      'lastGenerated': serializer.toJson<String>(lastGenerated),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? icon,
    String? tone,
    Value<int?> categoryId = const Value.absent(),
    int? unitPriceMinor,
    String? currency,
    int? timesPerDay,
    int? weekdays,
    bool? active,
    DateTime? createdOn,
    String? lastGenerated,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    tone: tone ?? this.tone,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    currency: currency ?? this.currency,
    timesPerDay: timesPerDay ?? this.timesPerDay,
    weekdays: weekdays ?? this.weekdays,
    active: active ?? this.active,
    createdOn: createdOn ?? this.createdOn,
    lastGenerated: lastGenerated ?? this.lastGenerated,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      tone: data.tone.present ? data.tone.value : this.tone,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      timesPerDay: data.timesPerDay.present
          ? data.timesPerDay.value
          : this.timesPerDay,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      active: data.active.present ? data.active.value : this.active,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      lastGenerated: data.lastGenerated.present
          ? data.lastGenerated.value
          : this.lastGenerated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('categoryId: $categoryId, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('currency: $currency, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('weekdays: $weekdays, ')
          ..write('active: $active, ')
          ..write('createdOn: $createdOn, ')
          ..write('lastGenerated: $lastGenerated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    tone,
    categoryId,
    unitPriceMinor,
    currency,
    timesPerDay,
    weekdays,
    active,
    createdOn,
    lastGenerated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.tone == this.tone &&
          other.categoryId == this.categoryId &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.currency == this.currency &&
          other.timesPerDay == this.timesPerDay &&
          other.weekdays == this.weekdays &&
          other.active == this.active &&
          other.createdOn == this.createdOn &&
          other.lastGenerated == this.lastGenerated);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> tone;
  final Value<int?> categoryId;
  final Value<int> unitPriceMinor;
  final Value<String> currency;
  final Value<int> timesPerDay;
  final Value<int> weekdays;
  final Value<bool> active;
  final Value<DateTime> createdOn;
  final Value<String> lastGenerated;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.active = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.lastGenerated = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int unitPriceMinor,
    required String currency,
    this.timesPerDay = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdOn,
    this.lastGenerated = const Value.absent(),
  }) : name = Value(name),
       unitPriceMinor = Value(unitPriceMinor),
       currency = Value(currency),
       createdOn = Value(createdOn);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? tone,
    Expression<int>? categoryId,
    Expression<int>? unitPriceMinor,
    Expression<String>? currency,
    Expression<int>? timesPerDay,
    Expression<int>? weekdays,
    Expression<bool>? active,
    Expression<DateTime>? createdOn,
    Expression<String>? lastGenerated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (tone != null) 'tone': tone,
      if (categoryId != null) 'category_id': categoryId,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (currency != null) 'currency': currency,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (weekdays != null) 'weekdays': weekdays,
      if (active != null) 'active': active,
      if (createdOn != null) 'created_on': createdOn,
      if (lastGenerated != null) 'last_generated': lastGenerated,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? tone,
    Value<int?>? categoryId,
    Value<int>? unitPriceMinor,
    Value<String>? currency,
    Value<int>? timesPerDay,
    Value<int>? weekdays,
    Value<bool>? active,
    Value<DateTime>? createdOn,
    Value<String>? lastGenerated,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      categoryId: categoryId ?? this.categoryId,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      currency: currency ?? this.currency,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      weekdays: weekdays ?? this.weekdays,
      active: active ?? this.active,
      createdOn: createdOn ?? this.createdOn,
      lastGenerated: lastGenerated ?? this.lastGenerated,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<DateTime>(createdOn.value);
    }
    if (lastGenerated.present) {
      map['last_generated'] = Variable<String>(lastGenerated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('categoryId: $categoryId, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('currency: $currency, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('weekdays: $weekdays, ')
          ..write('active: $active, ')
          ..write('createdOn: $createdOn, ')
          ..write('lastGenerated: $lastGenerated')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings with TableInfo<$HoldingsTable, Holding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coin'),
  );
  static const VerificationMeta _isLiabilityMeta = const VerificationMeta(
    'isLiability',
  );
  @override
  late final GeneratedColumn<bool> isLiability = GeneratedColumn<bool>(
    'is_liability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liability" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    isLiability,
    amountMinor,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Holding> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('is_liability')) {
      context.handle(
        _isLiabilityMeta,
        isLiability.isAcceptableOrUnknown(
          data['is_liability']!,
          _isLiabilityMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      isLiability: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liability'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }
}

class Holding extends DataClass implements Insertable<Holding> {
  final int id;
  final String name;
  final String icon;

  /// true = deuda (resta), false = activo (suma).
  final bool isLiability;
  final int amountMinor;
  final String currency;
  const Holding({
    required this.id,
    required this.name,
    required this.icon,
    required this.isLiability,
    required this.amountMinor,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['is_liability'] = Variable<bool>(isLiability);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      isLiability: Value(isLiability),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
    );
  }

  factory Holding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holding(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      isLiability: serializer.fromJson<bool>(json['isLiability']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'isLiability': serializer.toJson<bool>(isLiability),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  Holding copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isLiability,
    int? amountMinor,
    String? currency,
  }) => Holding(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    isLiability: isLiability ?? this.isLiability,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
  );
  Holding copyWithCompanion(HoldingsCompanion data) {
    return Holding(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      isLiability: data.isLiability.present
          ? data.isLiability.value
          : this.isLiability,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holding(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('isLiability: $isLiability, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, isLiability, amountMinor, currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holding &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.isLiability == this.isLiability &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency);
}

class HoldingsCompanion extends UpdateCompanion<Holding> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<bool> isLiability;
  final Value<int> amountMinor;
  final Value<String> currency;
  const HoldingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.isLiability = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
  });
  HoldingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.isLiability = const Value.absent(),
    required int amountMinor,
    required String currency,
  }) : name = Value(name),
       amountMinor = Value(amountMinor),
       currency = Value(currency);
  static Insertable<Holding> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<bool>? isLiability,
    Expression<int>? amountMinor,
    Expression<String>? currency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (isLiability != null) 'is_liability': isLiability,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
    });
  }

  HoldingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<bool>? isLiability,
    Value<int>? amountMinor,
    Value<String>? currency,
  }) {
    return HoldingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isLiability: isLiability ?? this.isLiability,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isLiability.present) {
      map['is_liability'] = Variable<bool>(isLiability.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('isLiability: $isLiability, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }
}

class $NetSnapshotsTable extends NetSnapshots
    with TableInfo<$NetSnapshotsTable, NetSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netMinorMeta = const VerificationMeta(
    'netMinor',
  );
  @override
  late final GeneratedColumn<int> netMinor = GeneratedColumn<int>(
    'net_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [month, netMinor, currency];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('net_minor')) {
      context.handle(
        _netMinorMeta,
        netMinor.isAcceptableOrUnknown(data['net_minor']!, _netMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_netMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {month};
  @override
  NetSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetSnapshot(
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      netMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $NetSnapshotsTable createAlias(String alias) {
    return $NetSnapshotsTable(attachedDatabase, alias);
  }
}

class NetSnapshot extends DataClass implements Insertable<NetSnapshot> {
  /// "2026-10".
  final String month;
  final int netMinor;
  final String currency;
  const NetSnapshot({
    required this.month,
    required this.netMinor,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month'] = Variable<String>(month);
    map['net_minor'] = Variable<int>(netMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  NetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return NetSnapshotsCompanion(
      month: Value(month),
      netMinor: Value(netMinor),
      currency: Value(currency),
    );
  }

  factory NetSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetSnapshot(
      month: serializer.fromJson<String>(json['month']),
      netMinor: serializer.fromJson<int>(json['netMinor']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'month': serializer.toJson<String>(month),
      'netMinor': serializer.toJson<int>(netMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  NetSnapshot copyWith({String? month, int? netMinor, String? currency}) =>
      NetSnapshot(
        month: month ?? this.month,
        netMinor: netMinor ?? this.netMinor,
        currency: currency ?? this.currency,
      );
  NetSnapshot copyWithCompanion(NetSnapshotsCompanion data) {
    return NetSnapshot(
      month: data.month.present ? data.month.value : this.month,
      netMinor: data.netMinor.present ? data.netMinor.value : this.netMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetSnapshot(')
          ..write('month: $month, ')
          ..write('netMinor: $netMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(month, netMinor, currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetSnapshot &&
          other.month == this.month &&
          other.netMinor == this.netMinor &&
          other.currency == this.currency);
}

class NetSnapshotsCompanion extends UpdateCompanion<NetSnapshot> {
  final Value<String> month;
  final Value<int> netMinor;
  final Value<String> currency;
  final Value<int> rowid;
  const NetSnapshotsCompanion({
    this.month = const Value.absent(),
    this.netMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetSnapshotsCompanion.insert({
    required String month,
    required int netMinor,
    required String currency,
    this.rowid = const Value.absent(),
  }) : month = Value(month),
       netMinor = Value(netMinor),
       currency = Value(currency);
  static Insertable<NetSnapshot> custom({
    Expression<String>? month,
    Expression<int>? netMinor,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (month != null) 'month': month,
      if (netMinor != null) 'net_minor': netMinor,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetSnapshotsCompanion copyWith({
    Value<String>? month,
    Value<int>? netMinor,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return NetSnapshotsCompanion(
      month: month ?? this.month,
      netMinor: netMinor ?? this.netMinor,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (netMinor.present) {
      map['net_minor'] = Variable<int>(netMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetSnapshotsCompanion(')
          ..write('month: $month, ')
          ..write('netMinor: $netMinor, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendsTable extends Friends with TableInfo<$FriendsTable, Friend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends';
  @override
  VerificationContext validateIntegrity(
    Insertable<Friend> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Friend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Friend(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $FriendsTable createAlias(String alias) {
    return $FriendsTable(attachedDatabase, alias);
  }
}

class Friend extends DataClass implements Insertable<Friend> {
  final int id;
  final String name;
  const Friend({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  FriendsCompanion toCompanion(bool nullToAbsent) {
    return FriendsCompanion(id: Value(id), name: Value(name));
  }

  factory Friend.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Friend(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Friend copyWith({int? id, String? name}) =>
      Friend(id: id ?? this.id, name: name ?? this.name);
  Friend copyWithCompanion(FriendsCompanion data) {
    return Friend(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Friend(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friend && other.id == this.id && other.name == this.name);
}

class FriendsCompanion extends UpdateCompanion<Friend> {
  final Value<int> id;
  final Value<String> name;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  FriendsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Friend> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  FriendsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return FriendsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ShareEntriesTable extends ShareEntries
    with TableInfo<$ShareEntriesTable, ShareEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShareEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<int> friendId = GeneratedColumn<int>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendId,
    amountMinor,
    currency,
    note,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'share_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShareEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShareEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShareEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}friend_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $ShareEntriesTable createAlias(String alias) {
    return $ShareEntriesTable(attachedDatabase, alias);
  }
}

class ShareEntry extends DataClass implements Insertable<ShareEntry> {
  final int id;
  final int friendId;
  final int amountMinor;
  final String currency;
  final String note;
  final DateTime date;
  const ShareEntry({
    required this.id,
    required this.friendId,
    required this.amountMinor,
    required this.currency,
    required this.note,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['friend_id'] = Variable<int>(friendId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['note'] = Variable<String>(note);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  ShareEntriesCompanion toCompanion(bool nullToAbsent) {
    return ShareEntriesCompanion(
      id: Value(id),
      friendId: Value(friendId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      note: Value(note),
      date: Value(date),
    );
  }

  factory ShareEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShareEntry(
      id: serializer.fromJson<int>(json['id']),
      friendId: serializer.fromJson<int>(json['friendId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'friendId': serializer.toJson<int>(friendId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  ShareEntry copyWith({
    int? id,
    int? friendId,
    int? amountMinor,
    String? currency,
    String? note,
    DateTime? date,
  }) => ShareEntry(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    note: note ?? this.note,
    date: date ?? this.date,
  );
  ShareEntry copyWithCompanion(ShareEntriesCompanion data) {
    return ShareEntry(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShareEntry(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, friendId, amountMinor, currency, note, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShareEntry &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.note == this.note &&
          other.date == this.date);
}

class ShareEntriesCompanion extends UpdateCompanion<ShareEntry> {
  final Value<int> id;
  final Value<int> friendId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> note;
  final Value<DateTime> date;
  const ShareEntriesCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
  });
  ShareEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int friendId,
    required int amountMinor,
    required String currency,
    this.note = const Value.absent(),
    required DateTime date,
  }) : friendId = Value(friendId),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       date = Value(date);
  static Insertable<ShareEntry> custom({
    Expression<int>? id,
    Expression<int>? friendId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? note,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
    });
  }

  ShareEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? friendId,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? note,
    Value<DateTime>? date,
  }) {
    return ShareEntriesCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<int>(friendId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShareEntriesCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TxnsTable txns = $TxnsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $DayChecksTable dayChecks = $DayChecksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $RecurringsTable recurrings = $RecurringsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HoldingsTable holdings = $HoldingsTable(this);
  late final $NetSnapshotsTable netSnapshots = $NetSnapshotsTable(this);
  late final $FriendsTable friends = $FriendsTable(this);
  late final $ShareEntriesTable shareEntries = $ShareEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    txns,
    goals,
    dayChecks,
    settings,
    recurrings,
    debts,
    habits,
    holdings,
    netSnapshots,
    friends,
    shareEntries,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String icon,
  Value<String> tone,
  Value<String> block,
  Value<int?> monthlyLimitMinor,
  Value<int> sortOrder,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> tone,
  Value<String> block,
  Value<int?> monthlyLimitMinor,
  Value<int> sortOrder,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TxnsTable, List<Txn>> _txnsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.txns,
    aliasName: 'categories__id__txns__category_id',
  );

  $$TxnsTableProcessedTableManager get txnsRefs {
    final manager = $$TxnsTableTableManager(
      $_db,
      $_db.txns,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_txnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringsTable, List<Recurring>>
  _recurringsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recurrings,
    aliasName: 'categories__id__recurrings__category_id',
  );

  $$RecurringsTableProcessedTableManager get recurringsRefs {
    final manager = $$RecurringsTableTableManager(
      $_db,
      $_db.recurrings,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitsTable, List<Habit>> _habitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.habits,
    aliasName: 'categories__id__habits__category_id',
  );

  $$HabitsTableProcessedTableManager get habitsRefs {
    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyLimitMinor => $composableBuilder(
    column: $table.monthlyLimitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> txnsRefs(
    Expression<bool> Function($$TxnsTableFilterComposer f) f,
  ) {
    final $$TxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableFilterComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringsRefs(
    Expression<bool> Function($$RecurringsTableFilterComposer f) f,
  ) {
    final $$RecurringsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurrings,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringsTableFilterComposer(
            $db: $db,
            $table: $db.recurrings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitsRefs(
    Expression<bool> Function($$HabitsTableFilterComposer f) f,
  ) {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get block => $composableBuilder(
    column: $table.block,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyLimitMinor => $composableBuilder(
    column: $table.monthlyLimitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<String> get block =>
      $composableBuilder(column: $table.block, builder: (column) => column);

  GeneratedColumn<int> get monthlyLimitMinor => $composableBuilder(
    column: $table.monthlyLimitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> txnsRefs<T extends Object>(
    Expression<T> Function($$TxnsTableAnnotationComposer a) f,
  ) {
    final $$TxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringsRefs<T extends Object>(
    Expression<T> Function($$RecurringsTableAnnotationComposer a) f,
  ) {
    final $$RecurringsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurrings,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringsTableAnnotationComposer(
            $db: $db,
            $table: $db.recurrings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitsRefs<T extends Object>(
    Expression<T> Function($$HabitsTableAnnotationComposer a) f,
  ) {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool txnsRefs,
            bool recurringsRefs,
            bool habitsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<String> block = const Value.absent(),
                Value<int?> monthlyLimitMinor = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                block: block,
                monthlyLimitMinor: monthlyLimitMinor,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                Value<String> tone = const Value.absent(),
                Value<String> block = const Value.absent(),
                Value<int?> monthlyLimitMinor = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                block: block,
                monthlyLimitMinor: monthlyLimitMinor,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({txnsRefs = false, recurringsRefs = false, habitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (txnsRefs) db.txns,
                    if (recurringsRefs) db.recurrings,
                    if (habitsRefs) db.habits,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (txnsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Txn
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._txnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).txnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Recurring
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Habit
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._habitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).habitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool txnsRefs,
        bool recurringsRefs,
        bool habitsRefs,
      })
    >;
typedef $$TxnsTableCreateCompanionBuilder = TxnsCompanion Function({
  Value<int> id,
  required String kind,
  required int amountMinor,
  required String currency,
  Value<int?> categoryId,
  Value<String> note,
  required DateTime date,
  Value<DateTime> createdAt,
});
typedef $$TxnsTableUpdateCompanionBuilder = TxnsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<int> amountMinor,
  Value<String> currency,
  Value<int?> categoryId,
  Value<String> note,
  Value<DateTime> date,
  Value<DateTime> createdAt,
});

final class $$TxnsTableReferences
    extends BaseReferences<_$AppDatabase, $TxnsTable, Txn> {
  $$TxnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('txns__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TxnsTableFilterComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableOrderingComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TxnsTable,
          Txn,
          $$TxnsTableFilterComposer,
          $$TxnsTableOrderingComposer,
          $$TxnsTableAnnotationComposer,
          $$TxnsTableCreateCompanionBuilder,
          $$TxnsTableUpdateCompanionBuilder,
          (Txn, $$TxnsTableReferences),
          Txn,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TxnsTableTableManager(_$AppDatabase db, $TxnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TxnsCompanion(
                id: id,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                categoryId: categoryId,
                note: note,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required int amountMinor,
                required String currency,
                Value<int?> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
              }) => TxnsCompanion.insert(
                id: id,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                categoryId: categoryId,
                note: note,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TxnsTable, Txn>(table),
                  $$TxnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$TxnsTableReferences._categoryIdTable(
                          db,
                        ),
                        referencedColumn: $$TxnsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TxnsTable,
      Txn,
      $$TxnsTableFilterComposer,
      $$TxnsTableOrderingComposer,
      $$TxnsTableAnnotationComposer,
      $$TxnsTableCreateCompanionBuilder,
      $$TxnsTableUpdateCompanionBuilder,
      (Txn, $$TxnsTableReferences),
      Txn,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required String name,
  required String icon,
  Value<String> tone,
  required int targetMinor,
  Value<int> savedMinor,
  required String currency,
  Value<DateTime?> deadline,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> tone,
  Value<int> targetMinor,
  Value<int> savedMinor,
  Value<String> currency,
  Value<DateTime?> deadline,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedMinor => $composableBuilder(
    column: $table.savedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<int> targetMinor = const Value.absent(),
                Value<int> savedMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                targetMinor: targetMinor,
                savedMinor: savedMinor,
                currency: currency,
                deadline: deadline,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                Value<String> tone = const Value.absent(),
                required int targetMinor,
                Value<int> savedMinor = const Value.absent(),
                required String currency,
                Value<DateTime?> deadline = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                targetMinor: targetMinor,
                savedMinor: savedMinor,
                currency: currency,
                deadline: deadline,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, Goal>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, Goal>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$DayChecksTableCreateCompanionBuilder = DayChecksCompanion Function({
  required DateTime day,
  Value<int> rowid,
});
typedef $$DayChecksTableUpdateCompanionBuilder = DayChecksCompanion Function({
  Value<DateTime> day,
  Value<int> rowid,
});

class $$DayChecksTableFilterComposer
    extends Composer<_$AppDatabase, $DayChecksTable> {
  $$DayChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DayChecksTable> {
  $$DayChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayChecksTable> {
  $$DayChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$DayChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayChecksTable,
          DayCheck,
          $$DayChecksTableFilterComposer,
          $$DayChecksTableOrderingComposer,
          $$DayChecksTableAnnotationComposer,
          $$DayChecksTableCreateCompanionBuilder,
          $$DayChecksTableUpdateCompanionBuilder,
          (DayCheck, BaseReferences<_$AppDatabase, $DayChecksTable, DayCheck>),
          DayCheck,
          PrefetchHooks Function()
        > {
  $$DayChecksTableTableManager(_$AppDatabase db, $DayChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> day = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => DayChecksCompanion(day: day, rowid: rowid),
          createCompanionCallback: ({
            required DateTime day,
            Value<int> rowid = const Value.absent(),
          }) => DayChecksCompanion.insert(day: day, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayChecksTable, DayCheck>(table),
                  BaseReferences<_$AppDatabase, $DayChecksTable, DayCheck>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayChecksTable,
      DayCheck,
      $$DayChecksTableFilterComposer,
      $$DayChecksTableOrderingComposer,
      $$DayChecksTableAnnotationComposer,
      $$DayChecksTableCreateCompanionBuilder,
      $$DayChecksTableUpdateCompanionBuilder,
      (DayCheck, BaseReferences<_$AppDatabase, $DayChecksTable, DayCheck>),
      DayCheck,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$RecurringsTableCreateCompanionBuilder = RecurringsCompanion Function({
  Value<int> id,
  required String name,
  required int amountMinor,
  required String currency,
  Value<int?> categoryId,
  required int dayOfMonth,
  Value<bool> active,
  Value<String> lastMonth,
});
typedef $$RecurringsTableUpdateCompanionBuilder = RecurringsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> amountMinor,
  Value<String> currency,
  Value<int?> categoryId,
  Value<int> dayOfMonth,
  Value<bool> active,
  Value<String> lastMonth,
});

final class $$RecurringsTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringsTable, Recurring> {
  $$RecurringsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('recurrings__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMonth => $composableBuilder(
    column: $table.lastMonth,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMonth => $composableBuilder(
    column: $table.lastMonth,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableAnnotationComposer({
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

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get lastMonth =>
      $composableBuilder(column: $table.lastMonth, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringsTable,
          Recurring,
          $$RecurringsTableFilterComposer,
          $$RecurringsTableOrderingComposer,
          $$RecurringsTableAnnotationComposer,
          $$RecurringsTableCreateCompanionBuilder,
          $$RecurringsTableUpdateCompanionBuilder,
          (Recurring, $$RecurringsTableReferences),
          Recurring,
          PrefetchHooks Function({bool categoryId})
        > {
  $$RecurringsTableTableManager(_$AppDatabase db, $RecurringsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> lastMonth = const Value.absent(),
              }) => RecurringsCompanion(
                id: id,
                name: name,
                amountMinor: amountMinor,
                currency: currency,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                active: active,
                lastMonth: lastMonth,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int amountMinor,
                required String currency,
                Value<int?> categoryId = const Value.absent(),
                required int dayOfMonth,
                Value<bool> active = const Value.absent(),
                Value<String> lastMonth = const Value.absent(),
              }) => RecurringsCompanion.insert(
                id: id,
                name: name,
                amountMinor: amountMinor,
                currency: currency,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                active: active,
                lastMonth: lastMonth,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringsTable, Recurring>(table),
                  $$RecurringsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$RecurringsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$RecurringsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RecurringsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringsTable,
      Recurring,
      $$RecurringsTableFilterComposer,
      $$RecurringsTableOrderingComposer,
      $$RecurringsTableAnnotationComposer,
      $$RecurringsTableCreateCompanionBuilder,
      $$RecurringsTableUpdateCompanionBuilder,
      (Recurring, $$RecurringsTableReferences),
      Recurring,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$DebtsTableCreateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  required String name,
  required int balanceMinor,
  required String currency,
  Value<double> annualRatePct,
  required int minPaymentMinor,
});
typedef $$DebtsTableUpdateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> balanceMinor,
  Value<String> currency,
  Value<double> annualRatePct,
  Value<int> minPaymentMinor,
});

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
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

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualRatePct => $composableBuilder(
    column: $table.annualRatePct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPaymentMinor => $composableBuilder(
    column: $table.minPaymentMinor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
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

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualRatePct => $composableBuilder(
    column: $table.annualRatePct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPaymentMinor => $composableBuilder(
    column: $table.minPaymentMinor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
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

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get annualRatePct => $composableBuilder(
    column: $table.annualRatePct,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPaymentMinor => $composableBuilder(
    column: $table.minPaymentMinor,
    builder: (column) => column,
  );
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> annualRatePct = const Value.absent(),
                Value<int> minPaymentMinor = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                name: name,
                balanceMinor: balanceMinor,
                currency: currency,
                annualRatePct: annualRatePct,
                minPaymentMinor: minPaymentMinor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int balanceMinor,
                required String currency,
                Value<double> annualRatePct = const Value.absent(),
                required int minPaymentMinor,
              }) => DebtsCompanion.insert(
                id: id,
                name: name,
                balanceMinor: balanceMinor,
                currency: currency,
                annualRatePct: annualRatePct,
                minPaymentMinor: minPaymentMinor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebtsTable, Debt>(table),
                  BaseReferences<_$AppDatabase, $DebtsTable, Debt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> icon,
  Value<String> tone,
  Value<int?> categoryId,
  required int unitPriceMinor,
  required String currency,
  Value<int> timesPerDay,
  Value<int> weekdays,
  Value<bool> active,
  required DateTime createdOn,
  Value<String> lastGenerated,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> tone,
  Value<int?> categoryId,
  Value<int> unitPriceMinor,
  Value<String> currency,
  Value<int> timesPerDay,
  Value<int> weekdays,
  Value<bool> active,
  Value<DateTime> createdOn,
  Value<String> lastGenerated,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('habits__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<String> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool categoryId})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> timesPerDay = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdOn = const Value.absent(),
                Value<String> lastGenerated = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                categoryId: categoryId,
                unitPriceMinor: unitPriceMinor,
                currency: currency,
                timesPerDay: timesPerDay,
                weekdays: weekdays,
                active: active,
                createdOn: createdOn,
                lastGenerated: lastGenerated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                required int unitPriceMinor,
                required String currency,
                Value<int> timesPerDay = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdOn,
                Value<String> lastGenerated = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                categoryId: categoryId,
                unitPriceMinor: unitPriceMinor,
                currency: currency,
                timesPerDay: timesPerDay,
                weekdays: weekdays,
                active: active,
                createdOn: createdOn,
                lastGenerated: lastGenerated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$HabitsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$HabitsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
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

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$HoldingsTableCreateCompanionBuilder = HoldingsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> icon,
  Value<bool> isLiability,
  required int amountMinor,
  required String currency,
});
typedef $$HoldingsTableUpdateCompanionBuilder = HoldingsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<bool> isLiability,
  Value<int> amountMinor,
  Value<String> currency,
});

class $$HoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiability => $composableBuilder(
    column: $table.isLiability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer({
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiability => $composableBuilder(
    column: $table.isLiability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isLiability => $composableBuilder(
    column: $table.isLiability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$HoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTable,
          Holding,
          $$HoldingsTableFilterComposer,
          $$HoldingsTableOrderingComposer,
          $$HoldingsTableAnnotationComposer,
          $$HoldingsTableCreateCompanionBuilder,
          $$HoldingsTableUpdateCompanionBuilder,
          (Holding, BaseReferences<_$AppDatabase, $HoldingsTable, Holding>),
          Holding,
          PrefetchHooks Function()
        > {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> isLiability = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
              }) => HoldingsCompanion(
                id: id,
                name: name,
                icon: icon,
                isLiability: isLiability,
                amountMinor: amountMinor,
                currency: currency,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<bool> isLiability = const Value.absent(),
                required int amountMinor,
                required String currency,
              }) => HoldingsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                isLiability: isLiability,
                amountMinor: amountMinor,
                currency: currency,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HoldingsTable, Holding>(table),
                  BaseReferences<_$AppDatabase, $HoldingsTable, Holding>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTable,
      Holding,
      $$HoldingsTableFilterComposer,
      $$HoldingsTableOrderingComposer,
      $$HoldingsTableAnnotationComposer,
      $$HoldingsTableCreateCompanionBuilder,
      $$HoldingsTableUpdateCompanionBuilder,
      (Holding, BaseReferences<_$AppDatabase, $HoldingsTable, Holding>),
      Holding,
      PrefetchHooks Function()
    >;
typedef $$NetSnapshotsTableCreateCompanionBuilder =
    NetSnapshotsCompanion Function({
      required String month,
      required int netMinor,
      required String currency,
      Value<int> rowid,
    });
typedef $$NetSnapshotsTableUpdateCompanionBuilder =
    NetSnapshotsCompanion Function({
      Value<String> month,
      Value<int> netMinor,
      Value<String> currency,
      Value<int> rowid,
    });

class $$NetSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $NetSnapshotsTable> {
  $$NetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netMinor => $composableBuilder(
    column: $table.netMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetSnapshotsTable> {
  $$NetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netMinor => $composableBuilder(
    column: $table.netMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetSnapshotsTable> {
  $$NetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get netMinor =>
      $composableBuilder(column: $table.netMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$NetSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetSnapshotsTable,
          NetSnapshot,
          $$NetSnapshotsTableFilterComposer,
          $$NetSnapshotsTableOrderingComposer,
          $$NetSnapshotsTableAnnotationComposer,
          $$NetSnapshotsTableCreateCompanionBuilder,
          $$NetSnapshotsTableUpdateCompanionBuilder,
          (
            NetSnapshot,
            BaseReferences<_$AppDatabase, $NetSnapshotsTable, NetSnapshot>,
          ),
          NetSnapshot,
          PrefetchHooks Function()
        > {
  $$NetSnapshotsTableTableManager(_$AppDatabase db, $NetSnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> month = const Value.absent(),
                Value<int> netMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetSnapshotsCompanion(
                month: month,
                netMinor: netMinor,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String month,
                required int netMinor,
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => NetSnapshotsCompanion.insert(
                month: month,
                netMinor: netMinor,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NetSnapshotsTable, NetSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NetSnapshotsTable,
                    NetSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetSnapshotsTable,
      NetSnapshot,
      $$NetSnapshotsTableFilterComposer,
      $$NetSnapshotsTableOrderingComposer,
      $$NetSnapshotsTableAnnotationComposer,
      $$NetSnapshotsTableCreateCompanionBuilder,
      $$NetSnapshotsTableUpdateCompanionBuilder,
      (
        NetSnapshot,
        BaseReferences<_$AppDatabase, $NetSnapshotsTable, NetSnapshot>,
      ),
      NetSnapshot,
      PrefetchHooks Function()
    >;
typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$FriendsTableUpdateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$FriendsTableReferences
    extends BaseReferences<_$AppDatabase, $FriendsTable, Friend> {
  $$FriendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShareEntriesTable, List<ShareEntry>>
  _shareEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shareEntries,
    aliasName: 'friends__id__share_entries__friend_id',
  );

  $$ShareEntriesTableProcessedTableManager get shareEntriesRefs {
    final manager = $$ShareEntriesTableTableManager(
      $_db,
      $_db.shareEntries,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shareEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FriendsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableFilterComposer({
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

  Expression<bool> shareEntriesRefs(
    Expression<bool> Function($$ShareEntriesTableFilterComposer f) f,
  ) {
    final $$ShareEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareEntries,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareEntriesTableFilterComposer(
            $db: $db,
            $table: $db.shareEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableOrderingComposer({
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
}

class $$FriendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableAnnotationComposer({
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

  Expression<T> shareEntriesRefs<T extends Object>(
    Expression<T> Function($$ShareEntriesTableAnnotationComposer a) f,
  ) {
    final $$ShareEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareEntries,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FriendsTable,
          Friend,
          $$FriendsTableFilterComposer,
          $$FriendsTableOrderingComposer,
          $$FriendsTableAnnotationComposer,
          $$FriendsTableCreateCompanionBuilder,
          $$FriendsTableUpdateCompanionBuilder,
          (Friend, $$FriendsTableReferences),
          Friend,
          PrefetchHooks Function({bool shareEntriesRefs})
        > {
  $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => FriendsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => FriendsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FriendsTable, Friend>(table),
                  $$FriendsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shareEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shareEntriesRefs) db.shareEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shareEntriesRefs)
                    await $_getPrefetchedData<
                      Friend,
                      $FriendsTable,
                      ShareEntry
                    >(
                      currentTable: table,
                      referencedTable: $$FriendsTableReferences
                          ._shareEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$FriendsTableReferences(
                        db,
                        table,
                        p0,
                      ).shareEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.friendId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FriendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FriendsTable,
      Friend,
      $$FriendsTableFilterComposer,
      $$FriendsTableOrderingComposer,
      $$FriendsTableAnnotationComposer,
      $$FriendsTableCreateCompanionBuilder,
      $$FriendsTableUpdateCompanionBuilder,
      (Friend, $$FriendsTableReferences),
      Friend,
      PrefetchHooks Function({bool shareEntriesRefs})
    >;
typedef $$ShareEntriesTableCreateCompanionBuilder =
    ShareEntriesCompanion Function({
      Value<int> id,
      required int friendId,
      required int amountMinor,
      required String currency,
      Value<String> note,
      required DateTime date,
    });
typedef $$ShareEntriesTableUpdateCompanionBuilder =
    ShareEntriesCompanion Function({
      Value<int> id,
      Value<int> friendId,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> note,
      Value<DateTime> date,
    });

final class $$ShareEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ShareEntriesTable, ShareEntry> {
  $$ShareEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('share_entries__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<int>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShareEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ShareEntriesTable> {
  $$ShareEntriesTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShareEntriesTable> {
  $$ShareEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShareEntriesTable> {
  $$ShareEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShareEntriesTable,
          ShareEntry,
          $$ShareEntriesTableFilterComposer,
          $$ShareEntriesTableOrderingComposer,
          $$ShareEntriesTableAnnotationComposer,
          $$ShareEntriesTableCreateCompanionBuilder,
          $$ShareEntriesTableUpdateCompanionBuilder,
          (ShareEntry, $$ShareEntriesTableReferences),
          ShareEntry,
          PrefetchHooks Function({bool friendId})
        > {
  $$ShareEntriesTableTableManager(_$AppDatabase db, $ShareEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShareEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShareEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShareEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> friendId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => ShareEntriesCompanion(
                id: id,
                friendId: friendId,
                amountMinor: amountMinor,
                currency: currency,
                note: note,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int friendId,
                required int amountMinor,
                required String currency,
                Value<String> note = const Value.absent(),
                required DateTime date,
              }) => ShareEntriesCompanion.insert(
                id: id,
                friendId: friendId,
                amountMinor: amountMinor,
                currency: currency,
                note: note,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShareEntriesTable, ShareEntry>(table),
                  $$ShareEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false}) {
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
                    if (friendId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.friendId,
                        referencedTable: $$ShareEntriesTableReferences
                            ._friendIdTable(db),
                        referencedColumn: $$ShareEntriesTableReferences
                            ._friendIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ShareEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShareEntriesTable,
      ShareEntry,
      $$ShareEntriesTableFilterComposer,
      $$ShareEntriesTableOrderingComposer,
      $$ShareEntriesTableAnnotationComposer,
      $$ShareEntriesTableCreateCompanionBuilder,
      $$ShareEntriesTableUpdateCompanionBuilder,
      (ShareEntry, $$ShareEntriesTableReferences),
      ShareEntry,
      PrefetchHooks Function({bool friendId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TxnsTableTableManager get txns => $$TxnsTableTableManager(_db, _db.txns);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$DayChecksTableTableManager get dayChecks =>
      $$DayChecksTableTableManager(_db, _db.dayChecks);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$RecurringsTableTableManager get recurrings =>
      $$RecurringsTableTableManager(_db, _db.recurrings);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
  $$NetSnapshotsTableTableManager get netSnapshots =>
      $$NetSnapshotsTableTableManager(_db, _db.netSnapshots);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
  $$ShareEntriesTableTableManager get shareEntries =>
      $$ShareEntriesTableTableManager(_db, _db.shareEntries);
}
