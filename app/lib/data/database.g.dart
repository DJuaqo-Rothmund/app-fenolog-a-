// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CropsTable extends Crops with TableInfo<$CropsTable, Crop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _shortCodeMeta = const VerificationMeta(
    'shortCode',
  );
  @override
  late final GeneratedColumn<String> shortCode = GeneratedColumn<String>(
    'short_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seasonStartMonthMeta = const VerificationMeta(
    'seasonStartMonth',
  );
  @override
  late final GeneratedColumn<int> seasonStartMonth = GeneratedColumn<int>(
    'season_start_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonStartDayMeta = const VerificationMeta(
    'seasonStartDay',
  );
  @override
  late final GeneratedColumn<int> seasonStartDay = GeneratedColumn<int>(
    'season_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    code,
    shortCode,
    name,
    scientificName,
    seasonStartMonth,
    seasonStartDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Crop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('short_code')) {
      context.handle(
        _shortCodeMeta,
        shortCode.isAcceptableOrUnknown(data['short_code']!, _shortCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_shortCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    }
    if (data.containsKey('season_start_month')) {
      context.handle(
        _seasonStartMonthMeta,
        seasonStartMonth.isAcceptableOrUnknown(
          data['season_start_month']!,
          _seasonStartMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonStartMonthMeta);
    }
    if (data.containsKey('season_start_day')) {
      context.handle(
        _seasonStartDayMeta,
        seasonStartDay.isAcceptableOrUnknown(
          data['season_start_day']!,
          _seasonStartDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonStartDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Crop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Crop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      shortCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      seasonStartMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_start_month'],
      )!,
      seasonStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_start_day'],
      )!,
    );
  }

  @override
  $CropsTable createAlias(String alias) {
    return $CropsTable(attachedDatabase, alias);
  }
}

class Crop extends DataClass implements Insertable<Crop> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String code;
  final String shortCode;
  final String name;
  final String scientificName;
  final int seasonStartMonth;
  final int seasonStartDay;
  const Crop({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.code,
    required this.shortCode,
    required this.name,
    required this.scientificName,
    required this.seasonStartMonth,
    required this.seasonStartDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['code'] = Variable<String>(code);
    map['short_code'] = Variable<String>(shortCode);
    map['name'] = Variable<String>(name);
    map['scientific_name'] = Variable<String>(scientificName);
    map['season_start_month'] = Variable<int>(seasonStartMonth);
    map['season_start_day'] = Variable<int>(seasonStartDay);
    return map;
  }

  CropsCompanion toCompanion(bool nullToAbsent) {
    return CropsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      code: Value(code),
      shortCode: Value(shortCode),
      name: Value(name),
      scientificName: Value(scientificName),
      seasonStartMonth: Value(seasonStartMonth),
      seasonStartDay: Value(seasonStartDay),
    );
  }

  factory Crop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Crop(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      code: serializer.fromJson<String>(json['code']),
      shortCode: serializer.fromJson<String>(json['shortCode']),
      name: serializer.fromJson<String>(json['name']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      seasonStartMonth: serializer.fromJson<int>(json['seasonStartMonth']),
      seasonStartDay: serializer.fromJson<int>(json['seasonStartDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'code': serializer.toJson<String>(code),
      'shortCode': serializer.toJson<String>(shortCode),
      'name': serializer.toJson<String>(name),
      'scientificName': serializer.toJson<String>(scientificName),
      'seasonStartMonth': serializer.toJson<int>(seasonStartMonth),
      'seasonStartDay': serializer.toJson<int>(seasonStartDay),
    };
  }

  Crop copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? code,
    String? shortCode,
    String? name,
    String? scientificName,
    int? seasonStartMonth,
    int? seasonStartDay,
  }) => Crop(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    code: code ?? this.code,
    shortCode: shortCode ?? this.shortCode,
    name: name ?? this.name,
    scientificName: scientificName ?? this.scientificName,
    seasonStartMonth: seasonStartMonth ?? this.seasonStartMonth,
    seasonStartDay: seasonStartDay ?? this.seasonStartDay,
  );
  Crop copyWithCompanion(CropsCompanion data) {
    return Crop(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      code: data.code.present ? data.code.value : this.code,
      shortCode: data.shortCode.present ? data.shortCode.value : this.shortCode,
      name: data.name.present ? data.name.value : this.name,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      seasonStartMonth: data.seasonStartMonth.present
          ? data.seasonStartMonth.value
          : this.seasonStartMonth,
      seasonStartDay: data.seasonStartDay.present
          ? data.seasonStartDay.value
          : this.seasonStartDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Crop(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('shortCode: $shortCode, ')
          ..write('name: $name, ')
          ..write('scientificName: $scientificName, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonStartDay: $seasonStartDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    code,
    shortCode,
    name,
    scientificName,
    seasonStartMonth,
    seasonStartDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crop &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.code == this.code &&
          other.shortCode == this.shortCode &&
          other.name == this.name &&
          other.scientificName == this.scientificName &&
          other.seasonStartMonth == this.seasonStartMonth &&
          other.seasonStartDay == this.seasonStartDay);
}

class CropsCompanion extends UpdateCompanion<Crop> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> code;
  final Value<String> shortCode;
  final Value<String> name;
  final Value<String> scientificName;
  final Value<int> seasonStartMonth;
  final Value<int> seasonStartDay;
  final Value<int> rowid;
  const CropsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.code = const Value.absent(),
    this.shortCode = const Value.absent(),
    this.name = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.seasonStartMonth = const Value.absent(),
    this.seasonStartDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String code,
    required String shortCode,
    required String name,
    this.scientificName = const Value.absent(),
    required int seasonStartMonth,
    required int seasonStartDay,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       shortCode = Value(shortCode),
       name = Value(name),
       seasonStartMonth = Value(seasonStartMonth),
       seasonStartDay = Value(seasonStartDay);
  static Insertable<Crop> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? code,
    Expression<String>? shortCode,
    Expression<String>? name,
    Expression<String>? scientificName,
    Expression<int>? seasonStartMonth,
    Expression<int>? seasonStartDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (code != null) 'code': code,
      if (shortCode != null) 'short_code': shortCode,
      if (name != null) 'name': name,
      if (scientificName != null) 'scientific_name': scientificName,
      if (seasonStartMonth != null) 'season_start_month': seasonStartMonth,
      if (seasonStartDay != null) 'season_start_day': seasonStartDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? code,
    Value<String>? shortCode,
    Value<String>? name,
    Value<String>? scientificName,
    Value<int>? seasonStartMonth,
    Value<int>? seasonStartDay,
    Value<int>? rowid,
  }) {
    return CropsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      code: code ?? this.code,
      shortCode: shortCode ?? this.shortCode,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      seasonStartMonth: seasonStartMonth ?? this.seasonStartMonth,
      seasonStartDay: seasonStartDay ?? this.seasonStartDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (shortCode.present) {
      map['short_code'] = Variable<String>(shortCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (seasonStartMonth.present) {
      map['season_start_month'] = Variable<int>(seasonStartMonth.value);
    }
    if (seasonStartDay.present) {
      map['season_start_day'] = Variable<int>(seasonStartDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('shortCode: $shortCode, ')
          ..write('name: $name, ')
          ..write('scientificName: $scientificName, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonStartDay: $seasonStartDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhenoScalesTable extends PhenoScales
    with TableInfo<$PhenoScalesTable, PhenoScale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhenoScalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crops (id)',
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    name,
    version,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pheno_scales';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhenoScale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhenoScale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhenoScale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $PhenoScalesTable createAlias(String alias) {
    return $PhenoScalesTable(attachedDatabase, alias);
  }
}

class PhenoScale extends DataClass implements Insertable<PhenoScale> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String cropId;
  final String name;
  final int version;
  final bool isDefault;
  const PhenoScale({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cropId,
    required this.name,
    required this.version,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['crop_id'] = Variable<String>(cropId);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  PhenoScalesCompanion toCompanion(bool nullToAbsent) {
    return PhenoScalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cropId: Value(cropId),
      name: Value(name),
      version: Value(version),
      isDefault: Value(isDefault),
    );
  }

  factory PhenoScale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhenoScale(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      cropId: serializer.fromJson<String>(json['cropId']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'cropId': serializer.toJson<String>(cropId),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  PhenoScale copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? cropId,
    String? name,
    int? version,
    bool? isDefault,
  }) => PhenoScale(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cropId: cropId ?? this.cropId,
    name: name ?? this.name,
    version: version ?? this.version,
    isDefault: isDefault ?? this.isDefault,
  );
  PhenoScale copyWithCompanion(PhenoScalesCompanion data) {
    return PhenoScale(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhenoScale(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    name,
    version,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhenoScale &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cropId == this.cropId &&
          other.name == this.name &&
          other.version == this.version &&
          other.isDefault == this.isDefault);
}

class PhenoScalesCompanion extends UpdateCompanion<PhenoScale> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> cropId;
  final Value<String> name;
  final Value<int> version;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const PhenoScalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cropId = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhenoScalesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String cropId,
    required String name,
    required int version,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cropId = Value(cropId),
       name = Value(name),
       version = Value(version);
  static Insertable<PhenoScale> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? cropId,
    Expression<String>? name,
    Expression<int>? version,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cropId != null) 'crop_id': cropId,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhenoScalesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? cropId,
    Value<String>? name,
    Value<int>? version,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return PhenoScalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      version: version ?? this.version,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhenoScalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhenoMacrosTable extends PhenoMacros
    with TableInfo<$PhenoMacrosTable, PhenoMacro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhenoMacrosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scaleIdMeta = const VerificationMeta(
    'scaleId',
  );
  @override
  late final GeneratedColumn<String> scaleId = GeneratedColumn<String>(
    'scale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pheno_scales (id)',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    scaleId,
    code,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pheno_macros';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhenoMacro> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('scale_id')) {
      context.handle(
        _scaleIdMeta,
        scaleId.isAcceptableOrUnknown(data['scale_id']!, _scaleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scaleIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhenoMacro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhenoMacro(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      scaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scale_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PhenoMacrosTable createAlias(String alias) {
    return $PhenoMacrosTable(attachedDatabase, alias);
  }
}

class PhenoMacro extends DataClass implements Insertable<PhenoMacro> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String scaleId;
  final String code;
  final String name;
  final int sortOrder;
  const PhenoMacro({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.scaleId,
    required this.code,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['scale_id'] = Variable<String>(scaleId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PhenoMacrosCompanion toCompanion(bool nullToAbsent) {
    return PhenoMacrosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      scaleId: Value(scaleId),
      code: Value(code),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory PhenoMacro.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhenoMacro(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      scaleId: serializer.fromJson<String>(json['scaleId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'scaleId': serializer.toJson<String>(scaleId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PhenoMacro copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? scaleId,
    String? code,
    String? name,
    int? sortOrder,
  }) => PhenoMacro(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    scaleId: scaleId ?? this.scaleId,
    code: code ?? this.code,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PhenoMacro copyWithCompanion(PhenoMacrosCompanion data) {
    return PhenoMacro(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      scaleId: data.scaleId.present ? data.scaleId.value : this.scaleId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhenoMacro(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scaleId: $scaleId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    scaleId,
    code,
    name,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhenoMacro &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.scaleId == this.scaleId &&
          other.code == this.code &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class PhenoMacrosCompanion extends UpdateCompanion<PhenoMacro> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> scaleId;
  final Value<String> code;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PhenoMacrosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.scaleId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhenoMacrosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String scaleId,
    required String code,
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : scaleId = Value(scaleId),
       code = Value(code),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<PhenoMacro> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? scaleId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (scaleId != null) 'scale_id': scaleId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhenoMacrosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? scaleId,
    Value<String>? code,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PhenoMacrosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      scaleId: scaleId ?? this.scaleId,
      code: code ?? this.code,
      name: name ?? this.name,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (scaleId.present) {
      map['scale_id'] = Variable<String>(scaleId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('PhenoMacrosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scaleId: $scaleId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhenoStagesTable extends PhenoStages
    with TableInfo<$PhenoStagesTable, PhenoStage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhenoStagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scaleIdMeta = const VerificationMeta(
    'scaleId',
  );
  @override
  late final GeneratedColumn<String> scaleId = GeneratedColumn<String>(
    'scale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pheno_scales (id)',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _macroCodeMeta = const VerificationMeta(
    'macroCode',
  );
  @override
  late final GeneratedColumn<String> macroCode = GeneratedColumn<String>(
    'macro_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    scaleId,
    code,
    macroCode,
    sortOrder,
    name,
    description,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pheno_stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhenoStage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('scale_id')) {
      context.handle(
        _scaleIdMeta,
        scaleId.isAcceptableOrUnknown(data['scale_id']!, _scaleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scaleIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('macro_code')) {
      context.handle(
        _macroCodeMeta,
        macroCode.isAcceptableOrUnknown(data['macro_code']!, _macroCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_macroCodeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhenoStage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhenoStage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      scaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scale_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      macroCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}macro_code'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $PhenoStagesTable createAlias(String alias) {
    return $PhenoStagesTable(attachedDatabase, alias);
  }
}

class PhenoStage extends DataClass implements Insertable<PhenoStage> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String scaleId;
  final String code;
  final String macroCode;
  final int sortOrder;
  final String name;
  final String description;
  final int color;
  const PhenoStage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.scaleId,
    required this.code,
    required this.macroCode,
    required this.sortOrder,
    required this.name,
    required this.description,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['scale_id'] = Variable<String>(scaleId);
    map['code'] = Variable<String>(code);
    map['macro_code'] = Variable<String>(macroCode);
    map['sort_order'] = Variable<int>(sortOrder);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['color'] = Variable<int>(color);
    return map;
  }

  PhenoStagesCompanion toCompanion(bool nullToAbsent) {
    return PhenoStagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      scaleId: Value(scaleId),
      code: Value(code),
      macroCode: Value(macroCode),
      sortOrder: Value(sortOrder),
      name: Value(name),
      description: Value(description),
      color: Value(color),
    );
  }

  factory PhenoStage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhenoStage(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      scaleId: serializer.fromJson<String>(json['scaleId']),
      code: serializer.fromJson<String>(json['code']),
      macroCode: serializer.fromJson<String>(json['macroCode']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'scaleId': serializer.toJson<String>(scaleId),
      'code': serializer.toJson<String>(code),
      'macroCode': serializer.toJson<String>(macroCode),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'color': serializer.toJson<int>(color),
    };
  }

  PhenoStage copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? scaleId,
    String? code,
    String? macroCode,
    int? sortOrder,
    String? name,
    String? description,
    int? color,
  }) => PhenoStage(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    scaleId: scaleId ?? this.scaleId,
    code: code ?? this.code,
    macroCode: macroCode ?? this.macroCode,
    sortOrder: sortOrder ?? this.sortOrder,
    name: name ?? this.name,
    description: description ?? this.description,
    color: color ?? this.color,
  );
  PhenoStage copyWithCompanion(PhenoStagesCompanion data) {
    return PhenoStage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      scaleId: data.scaleId.present ? data.scaleId.value : this.scaleId,
      code: data.code.present ? data.code.value : this.code,
      macroCode: data.macroCode.present ? data.macroCode.value : this.macroCode,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhenoStage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scaleId: $scaleId, ')
          ..write('code: $code, ')
          ..write('macroCode: $macroCode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    scaleId,
    code,
    macroCode,
    sortOrder,
    name,
    description,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhenoStage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.scaleId == this.scaleId &&
          other.code == this.code &&
          other.macroCode == this.macroCode &&
          other.sortOrder == this.sortOrder &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color);
}

class PhenoStagesCompanion extends UpdateCompanion<PhenoStage> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> scaleId;
  final Value<String> code;
  final Value<String> macroCode;
  final Value<int> sortOrder;
  final Value<String> name;
  final Value<String> description;
  final Value<int> color;
  final Value<int> rowid;
  const PhenoStagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.scaleId = const Value.absent(),
    this.code = const Value.absent(),
    this.macroCode = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhenoStagesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String scaleId,
    required String code,
    required String macroCode,
    required int sortOrder,
    required String name,
    this.description = const Value.absent(),
    required int color,
    this.rowid = const Value.absent(),
  }) : scaleId = Value(scaleId),
       code = Value(code),
       macroCode = Value(macroCode),
       sortOrder = Value(sortOrder),
       name = Value(name),
       color = Value(color);
  static Insertable<PhenoStage> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? scaleId,
    Expression<String>? code,
    Expression<String>? macroCode,
    Expression<int>? sortOrder,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (scaleId != null) 'scale_id': scaleId,
      if (code != null) 'code': code,
      if (macroCode != null) 'macro_code': macroCode,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhenoStagesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? scaleId,
    Value<String>? code,
    Value<String>? macroCode,
    Value<int>? sortOrder,
    Value<String>? name,
    Value<String>? description,
    Value<int>? color,
    Value<int>? rowid,
  }) {
    return PhenoStagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      scaleId: scaleId ?? this.scaleId,
      code: code ?? this.code,
      macroCode: macroCode ?? this.macroCode,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (scaleId.present) {
      map['scale_id'] = Variable<String>(scaleId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (macroCode.present) {
      map['macro_code'] = Variable<String>(macroCode.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhenoStagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scaleId: $scaleId, ')
          ..write('code: $code, ')
          ..write('macroCode: $macroCode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VarietiesTable extends Varieties
    with TableInfo<$VarietiesTable, Variety> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VarietiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crops (id)',
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    name,
    code,
    notes,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'varieties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Variety> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Variety map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Variety(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $VarietiesTable createAlias(String alias) {
    return $VarietiesTable(attachedDatabase, alias);
  }
}

class Variety extends DataClass implements Insertable<Variety> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String cropId;
  final String name;
  final String code;
  final String notes;
  final bool archived;
  const Variety({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cropId,
    required this.name,
    required this.code,
    required this.notes,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['crop_id'] = Variable<String>(cropId);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['notes'] = Variable<String>(notes);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  VarietiesCompanion toCompanion(bool nullToAbsent) {
    return VarietiesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cropId: Value(cropId),
      name: Value(name),
      code: Value(code),
      notes: Value(notes),
      archived: Value(archived),
    );
  }

  factory Variety.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Variety(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      cropId: serializer.fromJson<String>(json['cropId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      notes: serializer.fromJson<String>(json['notes']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'cropId': serializer.toJson<String>(cropId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'notes': serializer.toJson<String>(notes),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Variety copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? cropId,
    String? name,
    String? code,
    String? notes,
    bool? archived,
  }) => Variety(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cropId: cropId ?? this.cropId,
    name: name ?? this.name,
    code: code ?? this.code,
    notes: notes ?? this.notes,
    archived: archived ?? this.archived,
  );
  Variety copyWithCompanion(VarietiesCompanion data) {
    return Variety(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      notes: data.notes.present ? data.notes.value : this.notes,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Variety(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('notes: $notes, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    name,
    code,
    notes,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Variety &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cropId == this.cropId &&
          other.name == this.name &&
          other.code == this.code &&
          other.notes == this.notes &&
          other.archived == this.archived);
}

class VarietiesCompanion extends UpdateCompanion<Variety> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> cropId;
  final Value<String> name;
  final Value<String> code;
  final Value<String> notes;
  final Value<bool> archived;
  final Value<int> rowid;
  const VarietiesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cropId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.notes = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VarietiesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String cropId,
    required String name,
    this.code = const Value.absent(),
    this.notes = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cropId = Value(cropId),
       name = Value(name);
  static Insertable<Variety> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? cropId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? notes,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cropId != null) 'crop_id': cropId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (notes != null) 'notes': notes,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VarietiesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? cropId,
    Value<String>? name,
    Value<String>? code,
    Value<String>? notes,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return VarietiesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      code: code ?? this.code,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VarietiesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('notes: $notes, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crops (id)',
    ),
  );
  static const VerificationMeta _scaleIdMeta = const VerificationMeta(
    'scaleId',
  );
  @override
  late final GeneratedColumn<String> scaleId = GeneratedColumn<String>(
    'scale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pheno_scales (id)',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    scaleId,
    kind,
    name,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('scale_id')) {
      context.handle(
        _scaleIdMeta,
        scaleId.isAcceptableOrUnknown(data['scale_id']!, _scaleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scaleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      scaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scale_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String cropId;
  final String scaleId;

  /// Nombre de [ProjectKind].
  final String kind;
  final String name;
  final bool archived;
  const Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cropId,
    required this.scaleId,
    required this.kind,
    required this.name,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['crop_id'] = Variable<String>(cropId);
    map['scale_id'] = Variable<String>(scaleId);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cropId: Value(cropId),
      scaleId: Value(scaleId),
      kind: Value(kind),
      name: Value(name),
      archived: Value(archived),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      cropId: serializer.fromJson<String>(json['cropId']),
      scaleId: serializer.fromJson<String>(json['scaleId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'cropId': serializer.toJson<String>(cropId),
      'scaleId': serializer.toJson<String>(scaleId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Project copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? cropId,
    String? scaleId,
    String? kind,
    String? name,
    bool? archived,
  }) => Project(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cropId: cropId ?? this.cropId,
    scaleId: scaleId ?? this.scaleId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    archived: archived ?? this.archived,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      scaleId: data.scaleId.present ? data.scaleId.value : this.scaleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('scaleId: $scaleId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    cropId,
    scaleId,
    kind,
    name,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cropId == this.cropId &&
          other.scaleId == this.scaleId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.archived == this.archived);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> cropId;
  final Value<String> scaleId;
  final Value<String> kind;
  final Value<String> name;
  final Value<bool> archived;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cropId = const Value.absent(),
    this.scaleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String cropId,
    required String scaleId,
    required String kind,
    required String name,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cropId = Value(cropId),
       scaleId = Value(scaleId),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? cropId,
    Expression<String>? scaleId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cropId != null) 'crop_id': cropId,
      if (scaleId != null) 'scale_id': scaleId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? cropId,
    Value<String>? scaleId,
    Value<String>? kind,
    Value<String>? name,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cropId: cropId ?? this.cropId,
      scaleId: scaleId ?? this.scaleId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (scaleId.present) {
      map['scale_id'] = Variable<String>(scaleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cropId: $cropId, ')
          ..write('scaleId: $scaleId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeasonsTable extends Seasons with TableInfo<$SeasonsTable, Season> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
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
  static const VerificationMeta _week1StartMeta = const VerificationMeta(
    'week1Start',
  );
  @override
  late final GeneratedColumn<DateTime> week1Start = GeneratedColumn<DateTime>(
    'week1_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    name,
    week1Start,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Season> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('week1_start')) {
      context.handle(
        _week1StartMeta,
        week1Start.isAcceptableOrUnknown(data['week1_start']!, _week1StartMeta),
      );
    } else if (isInserting) {
      context.missing(_week1StartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Season map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Season(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      week1Start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week1_start'],
      )!,
    );
  }

  @override
  $SeasonsTable createAlias(String alias) {
    return $SeasonsTable(attachedDatabase, alias);
  }
}

class Season extends DataClass implements Insertable<Season> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String projectId;
  final String name;
  final DateTime week1Start;
  const Season({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.projectId,
    required this.name,
    required this.week1Start,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['week1_start'] = Variable<DateTime>(week1Start);
    return map;
  }

  SeasonsCompanion toCompanion(bool nullToAbsent) {
    return SeasonsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      projectId: Value(projectId),
      name: Value(name),
      week1Start: Value(week1Start),
    );
  }

  factory Season.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Season(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      week1Start: serializer.fromJson<DateTime>(json['week1Start']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'week1Start': serializer.toJson<DateTime>(week1Start),
    };
  }

  Season copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? projectId,
    String? name,
    DateTime? week1Start,
  }) => Season(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    week1Start: week1Start ?? this.week1Start,
  );
  Season copyWithCompanion(SeasonsCompanion data) {
    return Season(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      week1Start: data.week1Start.present
          ? data.week1Start.value
          : this.week1Start,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Season(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('week1Start: $week1Start')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    name,
    week1Start,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Season &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.week1Start == this.week1Start);
}

class SeasonsCompanion extends UpdateCompanion<Season> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> projectId;
  final Value<String> name;
  final Value<DateTime> week1Start;
  final Value<int> rowid;
  const SeasonsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.week1Start = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeasonsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String projectId,
    required String name,
    required DateTime week1Start,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name),
       week1Start = Value(week1Start);
  static Insertable<Season> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<DateTime>? week1Start,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (week1Start != null) 'week1_start': week1Start,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeasonsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? projectId,
    Value<String>? name,
    Value<DateTime>? week1Start,
    Value<int>? rowid,
  }) {
    return SeasonsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      week1Start: week1Start ?? this.week1Start,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (week1Start.present) {
      map['week1_start'] = Variable<DateTime>(week1Start.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeasonsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('week1Start: $week1Start, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _varietyIdMeta = const VerificationMeta(
    'varietyId',
  );
  @override
  late final GeneratedColumn<String> varietyId = GeneratedColumn<String>(
    'variety_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES varieties (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatmentMeta = const VerificationMeta(
    'treatment',
  );
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
    'treatment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replicateMeta = const VerificationMeta(
    'replicate',
  );
  @override
  late final GeneratedColumn<int> replicate = GeneratedColumn<int>(
    'replicate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _irrigationGroupMeta = const VerificationMeta(
    'irrigationGroup',
  );
  @override
  late final GeneratedColumn<String> irrigationGroup = GeneratedColumn<String>(
    'irrigation_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    varietyId,
    label,
    treatment,
    replicate,
    irrigationGroup,
    sector,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('variety_id')) {
      context.handle(
        _varietyIdMeta,
        varietyId.isAcceptableOrUnknown(data['variety_id']!, _varietyIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('treatment')) {
      context.handle(
        _treatmentMeta,
        treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta),
      );
    }
    if (data.containsKey('replicate')) {
      context.handle(
        _replicateMeta,
        replicate.isAcceptableOrUnknown(data['replicate']!, _replicateMeta),
      );
    }
    if (data.containsKey('irrigation_group')) {
      context.handle(
        _irrigationGroupMeta,
        irrigationGroup.isAcceptableOrUnknown(
          data['irrigation_group']!,
          _irrigationGroupMeta,
        ),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
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
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      varietyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variety_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      treatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment'],
      ),
      replicate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replicate'],
      ),
      irrigationGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}irrigation_group'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String projectId;
  final String? varietyId;
  final String label;
  final String? treatment;
  final int? replicate;
  final String? irrigationGroup;
  final String? sector;
  final int sortOrder;
  const Unit({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.projectId,
    this.varietyId,
    required this.label,
    this.treatment,
    this.replicate,
    this.irrigationGroup,
    this.sector,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || varietyId != null) {
      map['variety_id'] = Variable<String>(varietyId);
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    if (!nullToAbsent || replicate != null) {
      map['replicate'] = Variable<int>(replicate);
    }
    if (!nullToAbsent || irrigationGroup != null) {
      map['irrigation_group'] = Variable<String>(irrigationGroup);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      projectId: Value(projectId),
      varietyId: varietyId == null && nullToAbsent
          ? const Value.absent()
          : Value(varietyId),
      label: Value(label),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      replicate: replicate == null && nullToAbsent
          ? const Value.absent()
          : Value(replicate),
      irrigationGroup: irrigationGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(irrigationGroup),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
      sortOrder: Value(sortOrder),
    );
  }

  factory Unit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      projectId: serializer.fromJson<String>(json['projectId']),
      varietyId: serializer.fromJson<String?>(json['varietyId']),
      label: serializer.fromJson<String>(json['label']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      replicate: serializer.fromJson<int?>(json['replicate']),
      irrigationGroup: serializer.fromJson<String?>(json['irrigationGroup']),
      sector: serializer.fromJson<String?>(json['sector']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'projectId': serializer.toJson<String>(projectId),
      'varietyId': serializer.toJson<String?>(varietyId),
      'label': serializer.toJson<String>(label),
      'treatment': serializer.toJson<String?>(treatment),
      'replicate': serializer.toJson<int?>(replicate),
      'irrigationGroup': serializer.toJson<String?>(irrigationGroup),
      'sector': serializer.toJson<String?>(sector),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Unit copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? projectId,
    Value<String?> varietyId = const Value.absent(),
    String? label,
    Value<String?> treatment = const Value.absent(),
    Value<int?> replicate = const Value.absent(),
    Value<String?> irrigationGroup = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    int? sortOrder,
  }) => Unit(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    projectId: projectId ?? this.projectId,
    varietyId: varietyId.present ? varietyId.value : this.varietyId,
    label: label ?? this.label,
    treatment: treatment.present ? treatment.value : this.treatment,
    replicate: replicate.present ? replicate.value : this.replicate,
    irrigationGroup: irrigationGroup.present
        ? irrigationGroup.value
        : this.irrigationGroup,
    sector: sector.present ? sector.value : this.sector,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      varietyId: data.varietyId.present ? data.varietyId.value : this.varietyId,
      label: data.label.present ? data.label.value : this.label,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      replicate: data.replicate.present ? data.replicate.value : this.replicate,
      irrigationGroup: data.irrigationGroup.present
          ? data.irrigationGroup.value
          : this.irrigationGroup,
      sector: data.sector.present ? data.sector.value : this.sector,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('varietyId: $varietyId, ')
          ..write('label: $label, ')
          ..write('treatment: $treatment, ')
          ..write('replicate: $replicate, ')
          ..write('irrigationGroup: $irrigationGroup, ')
          ..write('sector: $sector, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    varietyId,
    label,
    treatment,
    replicate,
    irrigationGroup,
    sector,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.projectId == this.projectId &&
          other.varietyId == this.varietyId &&
          other.label == this.label &&
          other.treatment == this.treatment &&
          other.replicate == this.replicate &&
          other.irrigationGroup == this.irrigationGroup &&
          other.sector == this.sector &&
          other.sortOrder == this.sortOrder);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> projectId;
  final Value<String?> varietyId;
  final Value<String> label;
  final Value<String?> treatment;
  final Value<int?> replicate;
  final Value<String?> irrigationGroup;
  final Value<String?> sector;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.varietyId = const Value.absent(),
    this.label = const Value.absent(),
    this.treatment = const Value.absent(),
    this.replicate = const Value.absent(),
    this.irrigationGroup = const Value.absent(),
    this.sector = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String projectId,
    this.varietyId = const Value.absent(),
    required String label,
    this.treatment = const Value.absent(),
    this.replicate = const Value.absent(),
    this.irrigationGroup = const Value.absent(),
    this.sector = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       label = Value(label);
  static Insertable<Unit> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? projectId,
    Expression<String>? varietyId,
    Expression<String>? label,
    Expression<String>? treatment,
    Expression<int>? replicate,
    Expression<String>? irrigationGroup,
    Expression<String>? sector,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (projectId != null) 'project_id': projectId,
      if (varietyId != null) 'variety_id': varietyId,
      if (label != null) 'label': label,
      if (treatment != null) 'treatment': treatment,
      if (replicate != null) 'replicate': replicate,
      if (irrigationGroup != null) 'irrigation_group': irrigationGroup,
      if (sector != null) 'sector': sector,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? projectId,
    Value<String?>? varietyId,
    Value<String>? label,
    Value<String?>? treatment,
    Value<int?>? replicate,
    Value<String?>? irrigationGroup,
    Value<String?>? sector,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return UnitsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      projectId: projectId ?? this.projectId,
      varietyId: varietyId ?? this.varietyId,
      label: label ?? this.label,
      treatment: treatment ?? this.treatment,
      replicate: replicate ?? this.replicate,
      irrigationGroup: irrigationGroup ?? this.irrigationGroup,
      sector: sector ?? this.sector,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (varietyId.present) {
      map['variety_id'] = Variable<String>(varietyId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (replicate.present) {
      map['replicate'] = Variable<int>(replicate.value);
    }
    if (irrigationGroup.present) {
      map['irrigation_group'] = Variable<String>(irrigationGroup.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
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
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('varietyId: $varietyId, ')
          ..write('label: $label, ')
          ..write('treatment: $treatment, ')
          ..write('replicate: $replicate, ')
          ..write('irrigationGroup: $irrigationGroup, ')
          ..write('sector: $sector, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekStatusesTable extends WeekStatuses
    with TableInfo<$WeekStatusesTable, WeekStatus> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES seasons (id)',
    ),
  );
  static const VerificationMeta _weekNumberMeta = const VerificationMeta(
    'weekNumber',
  );
  @override
  late final GeneratedColumn<int> weekNumber = GeneratedColumn<int>(
    'week_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notSampledMeta = const VerificationMeta(
    'notSampled',
  );
  @override
  late final GeneratedColumn<bool> notSampled = GeneratedColumn<bool>(
    'not_sampled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("not_sampled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    seasonId,
    weekNumber,
    notSampled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekStatus> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonIdMeta);
    }
    if (data.containsKey('week_number')) {
      context.handle(
        _weekNumberMeta,
        weekNumber.isAcceptableOrUnknown(data['week_number']!, _weekNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_weekNumberMeta);
    }
    if (data.containsKey('not_sampled')) {
      context.handle(
        _notSampledMeta,
        notSampled.isAcceptableOrUnknown(data['not_sampled']!, _notSampledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {seasonId, weekNumber},
  ];
  @override
  WeekStatus map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekStatus(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      )!,
      weekNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_number'],
      )!,
      notSampled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}not_sampled'],
      )!,
    );
  }

  @override
  $WeekStatusesTable createAlias(String alias) {
    return $WeekStatusesTable(attachedDatabase, alias);
  }
}

class WeekStatus extends DataClass implements Insertable<WeekStatus> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String seasonId;
  final int weekNumber;
  final bool notSampled;
  const WeekStatus({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.seasonId,
    required this.weekNumber,
    required this.notSampled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['season_id'] = Variable<String>(seasonId);
    map['week_number'] = Variable<int>(weekNumber);
    map['not_sampled'] = Variable<bool>(notSampled);
    return map;
  }

  WeekStatusesCompanion toCompanion(bool nullToAbsent) {
    return WeekStatusesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      seasonId: Value(seasonId),
      weekNumber: Value(weekNumber),
      notSampled: Value(notSampled),
    );
  }

  factory WeekStatus.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekStatus(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      seasonId: serializer.fromJson<String>(json['seasonId']),
      weekNumber: serializer.fromJson<int>(json['weekNumber']),
      notSampled: serializer.fromJson<bool>(json['notSampled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'seasonId': serializer.toJson<String>(seasonId),
      'weekNumber': serializer.toJson<int>(weekNumber),
      'notSampled': serializer.toJson<bool>(notSampled),
    };
  }

  WeekStatus copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? seasonId,
    int? weekNumber,
    bool? notSampled,
  }) => WeekStatus(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    seasonId: seasonId ?? this.seasonId,
    weekNumber: weekNumber ?? this.weekNumber,
    notSampled: notSampled ?? this.notSampled,
  );
  WeekStatus copyWithCompanion(WeekStatusesCompanion data) {
    return WeekStatus(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      weekNumber: data.weekNumber.present
          ? data.weekNumber.value
          : this.weekNumber,
      notSampled: data.notSampled.present
          ? data.notSampled.value
          : this.notSampled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekStatus(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seasonId: $seasonId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('notSampled: $notSampled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    seasonId,
    weekNumber,
    notSampled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekStatus &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.seasonId == this.seasonId &&
          other.weekNumber == this.weekNumber &&
          other.notSampled == this.notSampled);
}

class WeekStatusesCompanion extends UpdateCompanion<WeekStatus> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> seasonId;
  final Value<int> weekNumber;
  final Value<bool> notSampled;
  final Value<int> rowid;
  const WeekStatusesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.weekNumber = const Value.absent(),
    this.notSampled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekStatusesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String seasonId,
    required int weekNumber,
    this.notSampled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : seasonId = Value(seasonId),
       weekNumber = Value(weekNumber);
  static Insertable<WeekStatus> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? seasonId,
    Expression<int>? weekNumber,
    Expression<bool>? notSampled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (seasonId != null) 'season_id': seasonId,
      if (weekNumber != null) 'week_number': weekNumber,
      if (notSampled != null) 'not_sampled': notSampled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekStatusesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? seasonId,
    Value<int>? weekNumber,
    Value<bool>? notSampled,
    Value<int>? rowid,
  }) {
    return WeekStatusesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      seasonId: seasonId ?? this.seasonId,
      weekNumber: weekNumber ?? this.weekNumber,
      notSampled: notSampled ?? this.notSampled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (weekNumber.present) {
      map['week_number'] = Variable<int>(weekNumber.value);
    }
    if (notSampled.present) {
      map['not_sampled'] = Variable<bool>(notSampled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekStatusesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seasonId: $seasonId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('notSampled: $notSampled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES seasons (id)',
    ),
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (id)',
    ),
  );
  static const VerificationMeta _weekNumberMeta = const VerificationMeta(
    'weekNumber',
  );
  @override
  late final GeneratedColumn<int> weekNumber = GeneratedColumn<int>(
    'week_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pheno_stages (id)',
    ),
  );
  static const VerificationMeta _stageSourceMeta = const VerificationMeta(
    'stageSource',
  );
  @override
  late final GeneratedColumn<String> stageSource = GeneratedColumn<String>(
    'stage_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    seasonId,
    unitId,
    weekNumber,
    stageId,
    stageSource,
    notes,
    lat,
    lon,
    accuracyM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('week_number')) {
      context.handle(
        _weekNumberMeta,
        weekNumber.isAcceptableOrUnknown(data['week_number']!, _weekNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_weekNumberMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    }
    if (data.containsKey('stage_source')) {
      context.handle(
        _stageSourceMeta,
        stageSource.isAcceptableOrUnknown(
          data['stage_source']!,
          _stageSourceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {seasonId, unitId, weekNumber},
  ];
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      weekNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_number'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      ),
      stageSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_source'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String seasonId;
  final String unitId;
  final int weekNumber;
  final String? stageId;

  /// `manual` por ahora; más adelante `ai_accepted` / `ai_corrected`.
  final String stageSource;
  final String notes;
  final double? lat;
  final double? lon;
  final double? accuracyM;
  const Observation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.seasonId,
    required this.unitId,
    required this.weekNumber,
    this.stageId,
    required this.stageSource,
    required this.notes,
    this.lat,
    this.lon,
    this.accuracyM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['season_id'] = Variable<String>(seasonId);
    map['unit_id'] = Variable<String>(unitId);
    map['week_number'] = Variable<int>(weekNumber);
    if (!nullToAbsent || stageId != null) {
      map['stage_id'] = Variable<String>(stageId);
    }
    map['stage_source'] = Variable<String>(stageSource);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      seasonId: Value(seasonId),
      unitId: Value(unitId),
      weekNumber: Value(weekNumber),
      stageId: stageId == null && nullToAbsent
          ? const Value.absent()
          : Value(stageId),
      stageSource: Value(stageSource),
      notes: Value(notes),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      seasonId: serializer.fromJson<String>(json['seasonId']),
      unitId: serializer.fromJson<String>(json['unitId']),
      weekNumber: serializer.fromJson<int>(json['weekNumber']),
      stageId: serializer.fromJson<String?>(json['stageId']),
      stageSource: serializer.fromJson<String>(json['stageSource']),
      notes: serializer.fromJson<String>(json['notes']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'seasonId': serializer.toJson<String>(seasonId),
      'unitId': serializer.toJson<String>(unitId),
      'weekNumber': serializer.toJson<int>(weekNumber),
      'stageId': serializer.toJson<String?>(stageId),
      'stageSource': serializer.toJson<String>(stageSource),
      'notes': serializer.toJson<String>(notes),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'accuracyM': serializer.toJson<double?>(accuracyM),
    };
  }

  Observation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? seasonId,
    String? unitId,
    int? weekNumber,
    Value<String?> stageId = const Value.absent(),
    String? stageSource,
    String? notes,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
  }) => Observation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    seasonId: seasonId ?? this.seasonId,
    unitId: unitId ?? this.unitId,
    weekNumber: weekNumber ?? this.weekNumber,
    stageId: stageId.present ? stageId.value : this.stageId,
    stageSource: stageSource ?? this.stageSource,
    notes: notes ?? this.notes,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      weekNumber: data.weekNumber.present
          ? data.weekNumber.value
          : this.weekNumber,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      stageSource: data.stageSource.present
          ? data.stageSource.value
          : this.stageSource,
      notes: data.notes.present ? data.notes.value : this.notes,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seasonId: $seasonId, ')
          ..write('unitId: $unitId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('stageId: $stageId, ')
          ..write('stageSource: $stageSource, ')
          ..write('notes: $notes, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('accuracyM: $accuracyM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    seasonId,
    unitId,
    weekNumber,
    stageId,
    stageSource,
    notes,
    lat,
    lon,
    accuracyM,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.seasonId == this.seasonId &&
          other.unitId == this.unitId &&
          other.weekNumber == this.weekNumber &&
          other.stageId == this.stageId &&
          other.stageSource == this.stageSource &&
          other.notes == this.notes &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.accuracyM == this.accuracyM);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> seasonId;
  final Value<String> unitId;
  final Value<int> weekNumber;
  final Value<String?> stageId;
  final Value<String> stageSource;
  final Value<String> notes;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<double?> accuracyM;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.weekNumber = const Value.absent(),
    this.stageId = const Value.absent(),
    this.stageSource = const Value.absent(),
    this.notes = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String seasonId,
    required String unitId,
    required int weekNumber,
    this.stageId = const Value.absent(),
    this.stageSource = const Value.absent(),
    this.notes = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : seasonId = Value(seasonId),
       unitId = Value(unitId),
       weekNumber = Value(weekNumber);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? seasonId,
    Expression<String>? unitId,
    Expression<int>? weekNumber,
    Expression<String>? stageId,
    Expression<String>? stageSource,
    Expression<String>? notes,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? accuracyM,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (seasonId != null) 'season_id': seasonId,
      if (unitId != null) 'unit_id': unitId,
      if (weekNumber != null) 'week_number': weekNumber,
      if (stageId != null) 'stage_id': stageId,
      if (stageSource != null) 'stage_source': stageSource,
      if (notes != null) 'notes': notes,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? seasonId,
    Value<String>? unitId,
    Value<int>? weekNumber,
    Value<String?>? stageId,
    Value<String>? stageSource,
    Value<String>? notes,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<double?>? accuracyM,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      seasonId: seasonId ?? this.seasonId,
      unitId: unitId ?? this.unitId,
      weekNumber: weekNumber ?? this.weekNumber,
      stageId: stageId ?? this.stageId,
      stageSource: stageSource ?? this.stageSource,
      notes: notes ?? this.notes,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      accuracyM: accuracyM ?? this.accuracyM,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (weekNumber.present) {
      map['week_number'] = Variable<int>(weekNumber.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (stageSource.present) {
      map['stage_source'] = Variable<String>(stageSource.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seasonId: $seasonId, ')
          ..write('unitId: $unitId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('stageId: $stageId, ')
          ..write('stageSource: $stageSource, ')
          ..write('notes: $notes, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observations (id)',
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
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadStatusMeta = const VerificationMeta(
    'uploadStatus',
  );
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    observationId,
    kind,
    seq,
    fileName,
    localPath,
    takenAt,
    uploadStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('upload_status')) {
      context.handle(
        _uploadStatusMeta,
        uploadStatus.isAcceptableOrUnknown(
          data['upload_status']!,
          _uploadStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      uploadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_status'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String observationId;

  /// Nombre de [PhotoKind].
  final String kind;
  final int seq;
  final String fileName;
  final String localPath;
  final DateTime takenAt;

  /// `pending` hasta que exista la nube (etapa 4).
  final String uploadStatus;
  const Photo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.observationId,
    required this.kind,
    required this.seq,
    required this.fileName,
    required this.localPath,
    required this.takenAt,
    required this.uploadStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['observation_id'] = Variable<String>(observationId);
    map['kind'] = Variable<String>(kind);
    map['seq'] = Variable<int>(seq);
    map['file_name'] = Variable<String>(fileName);
    map['local_path'] = Variable<String>(localPath);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['upload_status'] = Variable<String>(uploadStatus);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      observationId: Value(observationId),
      kind: Value(kind),
      seq: Value(seq),
      fileName: Value(fileName),
      localPath: Value(localPath),
      takenAt: Value(takenAt),
      uploadStatus: Value(uploadStatus),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      observationId: serializer.fromJson<String>(json['observationId']),
      kind: serializer.fromJson<String>(json['kind']),
      seq: serializer.fromJson<int>(json['seq']),
      fileName: serializer.fromJson<String>(json['fileName']),
      localPath: serializer.fromJson<String>(json['localPath']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'observationId': serializer.toJson<String>(observationId),
      'kind': serializer.toJson<String>(kind),
      'seq': serializer.toJson<int>(seq),
      'fileName': serializer.toJson<String>(fileName),
      'localPath': serializer.toJson<String>(localPath),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
    };
  }

  Photo copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? observationId,
    String? kind,
    int? seq,
    String? fileName,
    String? localPath,
    DateTime? takenAt,
    String? uploadStatus,
  }) => Photo(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    observationId: observationId ?? this.observationId,
    kind: kind ?? this.kind,
    seq: seq ?? this.seq,
    fileName: fileName ?? this.fileName,
    localPath: localPath ?? this.localPath,
    takenAt: takenAt ?? this.takenAt,
    uploadStatus: uploadStatus ?? this.uploadStatus,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      kind: data.kind.present ? data.kind.value : this.kind,
      seq: data.seq.present ? data.seq.value : this.seq,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('observationId: $observationId, ')
          ..write('kind: $kind, ')
          ..write('seq: $seq, ')
          ..write('fileName: $fileName, ')
          ..write('localPath: $localPath, ')
          ..write('takenAt: $takenAt, ')
          ..write('uploadStatus: $uploadStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    observationId,
    kind,
    seq,
    fileName,
    localPath,
    takenAt,
    uploadStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.observationId == this.observationId &&
          other.kind == this.kind &&
          other.seq == this.seq &&
          other.fileName == this.fileName &&
          other.localPath == this.localPath &&
          other.takenAt == this.takenAt &&
          other.uploadStatus == this.uploadStatus);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> observationId;
  final Value<String> kind;
  final Value<int> seq;
  final Value<String> fileName;
  final Value<String> localPath;
  final Value<DateTime> takenAt;
  final Value<String> uploadStatus;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.observationId = const Value.absent(),
    this.kind = const Value.absent(),
    this.seq = const Value.absent(),
    this.fileName = const Value.absent(),
    this.localPath = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String observationId,
    required String kind,
    required int seq,
    required String fileName,
    required String localPath,
    required DateTime takenAt,
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : observationId = Value(observationId),
       kind = Value(kind),
       seq = Value(seq),
       fileName = Value(fileName),
       localPath = Value(localPath),
       takenAt = Value(takenAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? observationId,
    Expression<String>? kind,
    Expression<int>? seq,
    Expression<String>? fileName,
    Expression<String>? localPath,
    Expression<DateTime>? takenAt,
    Expression<String>? uploadStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (observationId != null) 'observation_id': observationId,
      if (kind != null) 'kind': kind,
      if (seq != null) 'seq': seq,
      if (fileName != null) 'file_name': fileName,
      if (localPath != null) 'local_path': localPath,
      if (takenAt != null) 'taken_at': takenAt,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? observationId,
    Value<String>? kind,
    Value<int>? seq,
    Value<String>? fileName,
    Value<String>? localPath,
    Value<DateTime>? takenAt,
    Value<String>? uploadStatus,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      observationId: observationId ?? this.observationId,
      kind: kind ?? this.kind,
      seq: seq ?? this.seq,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      takenAt: takenAt ?? this.takenAt,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('observationId: $observationId, ')
          ..write('kind: $kind, ')
          ..write('seq: $seq, ')
          ..write('fileName: $fileName, ')
          ..write('localPath: $localPath, ')
          ..write('takenAt: $takenAt, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementDefsTable extends MeasurementDefs
    with TableInfo<$MeasurementDefsTable, MeasurementDef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementDefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _choicesMeta = const VerificationMeta(
    'choices',
  );
  @override
  late final GeneratedColumn<String> choices = GeneratedColumn<String>(
    'choices',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    name,
    kind,
    scope,
    unit,
    minValue,
    maxValue,
    choices,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_defs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementDef> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    }
    if (data.containsKey('choices')) {
      context.handle(
        _choicesMeta,
        choices.isAcceptableOrUnknown(data['choices']!, _choicesMeta),
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
  MeasurementDef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementDef(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      ),
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      ),
      choices: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choices'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MeasurementDefsTable createAlias(String alias) {
    return $MeasurementDefsTable(attachedDatabase, alias);
  }
}

class MeasurementDef extends DataClass implements Insertable<MeasurementDef> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String projectId;
  final String name;

  /// Nombre de [MeasurementKind].
  final String kind;

  /// Nombre de [MeasurementScope].
  final String scope;
  final String unit;
  final double? minValue;
  final double? maxValue;

  /// Opciones separadas por salto de línea (solo para `choice`).
  final String choices;
  final int sortOrder;
  const MeasurementDef({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.projectId,
    required this.name,
    required this.kind,
    required this.scope,
    required this.unit,
    this.minValue,
    this.maxValue,
    required this.choices,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['scope'] = Variable<String>(scope);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<double>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<double>(maxValue);
    }
    map['choices'] = Variable<String>(choices);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MeasurementDefsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementDefsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      projectId: Value(projectId),
      name: Value(name),
      kind: Value(kind),
      scope: Value(scope),
      unit: Value(unit),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      choices: Value(choices),
      sortOrder: Value(sortOrder),
    );
  }

  factory MeasurementDef.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementDef(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      scope: serializer.fromJson<String>(json['scope']),
      unit: serializer.fromJson<String>(json['unit']),
      minValue: serializer.fromJson<double?>(json['minValue']),
      maxValue: serializer.fromJson<double?>(json['maxValue']),
      choices: serializer.fromJson<String>(json['choices']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'scope': serializer.toJson<String>(scope),
      'unit': serializer.toJson<String>(unit),
      'minValue': serializer.toJson<double?>(minValue),
      'maxValue': serializer.toJson<double?>(maxValue),
      'choices': serializer.toJson<String>(choices),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MeasurementDef copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? projectId,
    String? name,
    String? kind,
    String? scope,
    String? unit,
    Value<double?> minValue = const Value.absent(),
    Value<double?> maxValue = const Value.absent(),
    String? choices,
    int? sortOrder,
  }) => MeasurementDef(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    scope: scope ?? this.scope,
    unit: unit ?? this.unit,
    minValue: minValue.present ? minValue.value : this.minValue,
    maxValue: maxValue.present ? maxValue.value : this.maxValue,
    choices: choices ?? this.choices,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MeasurementDef copyWithCompanion(MeasurementDefsCompanion data) {
    return MeasurementDef(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      scope: data.scope.present ? data.scope.value : this.scope,
      unit: data.unit.present ? data.unit.value : this.unit,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      choices: data.choices.present ? data.choices.value : this.choices,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementDef(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('scope: $scope, ')
          ..write('unit: $unit, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('choices: $choices, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
    name,
    kind,
    scope,
    unit,
    minValue,
    maxValue,
    choices,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementDef &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.scope == this.scope &&
          other.unit == this.unit &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.choices == this.choices &&
          other.sortOrder == this.sortOrder);
}

class MeasurementDefsCompanion extends UpdateCompanion<MeasurementDef> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> projectId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> scope;
  final Value<String> unit;
  final Value<double?> minValue;
  final Value<double?> maxValue;
  final Value<String> choices;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MeasurementDefsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.scope = const Value.absent(),
    this.unit = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.choices = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementDefsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String projectId,
    required String name,
    required String kind,
    required String scope,
    this.unit = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.choices = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name),
       kind = Value(kind),
       scope = Value(scope);
  static Insertable<MeasurementDef> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? scope,
    Expression<String>? unit,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<String>? choices,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (scope != null) 'scope': scope,
      if (unit != null) 'unit': unit,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (choices != null) 'choices': choices,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementDefsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? projectId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? scope,
    Value<String>? unit,
    Value<double?>? minValue,
    Value<double?>? maxValue,
    Value<String>? choices,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MeasurementDefsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      scope: scope ?? this.scope,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      choices: choices ?? this.choices,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (choices.present) {
      map['choices'] = Variable<String>(choices.value);
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
    return (StringBuffer('MeasurementDefsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('scope: $scope, ')
          ..write('unit: $unit, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('choices: $choices, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementValuesTable extends MeasurementValues
    with TableInfo<$MeasurementValuesTable, MeasurementValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    clientDefault: DateTime.now,
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
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defIdMeta = const VerificationMeta('defId');
  @override
  late final GeneratedColumn<String> defId = GeneratedColumn<String>(
    'def_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_defs (id)',
    ),
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observations (id)',
    ),
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES seasons (id)',
    ),
  );
  static const VerificationMeta _varietyIdMeta = const VerificationMeta(
    'varietyId',
  );
  @override
  late final GeneratedColumn<String> varietyId = GeneratedColumn<String>(
    'variety_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES varieties (id)',
    ),
  );
  static const VerificationMeta _valueNumMeta = const VerificationMeta(
    'valueNum',
  );
  @override
  late final GeneratedColumn<double> valueNum = GeneratedColumn<double>(
    'value_num',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    defId,
    observationId,
    seasonId,
    varietyId,
    valueNum,
    valueText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('def_id')) {
      context.handle(
        _defIdMeta,
        defId.isAcceptableOrUnknown(data['def_id']!, _defIdMeta),
      );
    } else if (isInserting) {
      context.missing(_defIdMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    }
    if (data.containsKey('variety_id')) {
      context.handle(
        _varietyIdMeta,
        varietyId.isAcceptableOrUnknown(data['variety_id']!, _varietyIdMeta),
      );
    }
    if (data.containsKey('value_num')) {
      context.handle(
        _valueNumMeta,
        valueNum.isAcceptableOrUnknown(data['value_num']!, _valueNumMeta),
      );
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      defId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}def_id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      ),
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      ),
      varietyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variety_id'],
      ),
      valueNum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_num'],
      ),
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
    );
  }

  @override
  $MeasurementValuesTable createAlias(String alias) {
    return $MeasurementValuesTable(attachedDatabase, alias);
  }
}

class MeasurementValue extends DataClass
    implements Insertable<MeasurementValue> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String defId;
  final String? observationId;
  final String? seasonId;
  final String? varietyId;
  final double? valueNum;
  final String? valueText;
  const MeasurementValue({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.defId,
    this.observationId,
    this.seasonId,
    this.varietyId,
    this.valueNum,
    this.valueText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['def_id'] = Variable<String>(defId);
    if (!nullToAbsent || observationId != null) {
      map['observation_id'] = Variable<String>(observationId);
    }
    if (!nullToAbsent || seasonId != null) {
      map['season_id'] = Variable<String>(seasonId);
    }
    if (!nullToAbsent || varietyId != null) {
      map['variety_id'] = Variable<String>(varietyId);
    }
    if (!nullToAbsent || valueNum != null) {
      map['value_num'] = Variable<double>(valueNum);
    }
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    return map;
  }

  MeasurementValuesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementValuesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      defId: Value(defId),
      observationId: observationId == null && nullToAbsent
          ? const Value.absent()
          : Value(observationId),
      seasonId: seasonId == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonId),
      varietyId: varietyId == null && nullToAbsent
          ? const Value.absent()
          : Value(varietyId),
      valueNum: valueNum == null && nullToAbsent
          ? const Value.absent()
          : Value(valueNum),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
    );
  }

  factory MeasurementValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementValue(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      defId: serializer.fromJson<String>(json['defId']),
      observationId: serializer.fromJson<String?>(json['observationId']),
      seasonId: serializer.fromJson<String?>(json['seasonId']),
      varietyId: serializer.fromJson<String?>(json['varietyId']),
      valueNum: serializer.fromJson<double?>(json['valueNum']),
      valueText: serializer.fromJson<String?>(json['valueText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'defId': serializer.toJson<String>(defId),
      'observationId': serializer.toJson<String?>(observationId),
      'seasonId': serializer.toJson<String?>(seasonId),
      'varietyId': serializer.toJson<String?>(varietyId),
      'valueNum': serializer.toJson<double?>(valueNum),
      'valueText': serializer.toJson<String?>(valueText),
    };
  }

  MeasurementValue copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? defId,
    Value<String?> observationId = const Value.absent(),
    Value<String?> seasonId = const Value.absent(),
    Value<String?> varietyId = const Value.absent(),
    Value<double?> valueNum = const Value.absent(),
    Value<String?> valueText = const Value.absent(),
  }) => MeasurementValue(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    defId: defId ?? this.defId,
    observationId: observationId.present
        ? observationId.value
        : this.observationId,
    seasonId: seasonId.present ? seasonId.value : this.seasonId,
    varietyId: varietyId.present ? varietyId.value : this.varietyId,
    valueNum: valueNum.present ? valueNum.value : this.valueNum,
    valueText: valueText.present ? valueText.value : this.valueText,
  );
  MeasurementValue copyWithCompanion(MeasurementValuesCompanion data) {
    return MeasurementValue(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      defId: data.defId.present ? data.defId.value : this.defId,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      varietyId: data.varietyId.present ? data.varietyId.value : this.varietyId,
      valueNum: data.valueNum.present ? data.valueNum.value : this.valueNum,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementValue(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('defId: $defId, ')
          ..write('observationId: $observationId, ')
          ..write('seasonId: $seasonId, ')
          ..write('varietyId: $varietyId, ')
          ..write('valueNum: $valueNum, ')
          ..write('valueText: $valueText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    defId,
    observationId,
    seasonId,
    varietyId,
    valueNum,
    valueText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementValue &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.defId == this.defId &&
          other.observationId == this.observationId &&
          other.seasonId == this.seasonId &&
          other.varietyId == this.varietyId &&
          other.valueNum == this.valueNum &&
          other.valueText == this.valueText);
}

class MeasurementValuesCompanion extends UpdateCompanion<MeasurementValue> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> defId;
  final Value<String?> observationId;
  final Value<String?> seasonId;
  final Value<String?> varietyId;
  final Value<double?> valueNum;
  final Value<String?> valueText;
  final Value<int> rowid;
  const MeasurementValuesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.defId = const Value.absent(),
    this.observationId = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.varietyId = const Value.absent(),
    this.valueNum = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementValuesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String defId,
    this.observationId = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.varietyId = const Value.absent(),
    this.valueNum = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : defId = Value(defId);
  static Insertable<MeasurementValue> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? defId,
    Expression<String>? observationId,
    Expression<String>? seasonId,
    Expression<String>? varietyId,
    Expression<double>? valueNum,
    Expression<String>? valueText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (defId != null) 'def_id': defId,
      if (observationId != null) 'observation_id': observationId,
      if (seasonId != null) 'season_id': seasonId,
      if (varietyId != null) 'variety_id': varietyId,
      if (valueNum != null) 'value_num': valueNum,
      if (valueText != null) 'value_text': valueText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementValuesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? defId,
    Value<String?>? observationId,
    Value<String?>? seasonId,
    Value<String?>? varietyId,
    Value<double?>? valueNum,
    Value<String?>? valueText,
    Value<int>? rowid,
  }) {
    return MeasurementValuesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      defId: defId ?? this.defId,
      observationId: observationId ?? this.observationId,
      seasonId: seasonId ?? this.seasonId,
      varietyId: varietyId ?? this.varietyId,
      valueNum: valueNum ?? this.valueNum,
      valueText: valueText ?? this.valueText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (defId.present) {
      map['def_id'] = Variable<String>(defId.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (varietyId.present) {
      map['variety_id'] = Variable<String>(varietyId.value);
    }
    if (valueNum.present) {
      map['value_num'] = Variable<double>(valueNum.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementValuesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('defId: $defId, ')
          ..write('observationId: $observationId, ')
          ..write('seasonId: $seasonId, ')
          ..write('varietyId: $varietyId, ')
          ..write('valueNum: $valueNum, ')
          ..write('valueText: $valueText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tblMeta = const VerificationMeta('tbl');
  @override
  late final GeneratedColumn<String> tbl = GeneratedColumn<String>(
    'tbl',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, tbl, rowId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('tbl')) {
      context.handle(
        _tblMeta,
        tbl.isAcceptableOrUnknown(data['tbl']!, _tblMeta),
      );
    } else if (isInserting) {
      context.missing(_tblMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      tbl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tbl'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int seq;
  final String tbl;
  final String rowId;
  const OutboxEntry({
    required this.seq,
    required this.tbl,
    required this.rowId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['tbl'] = Variable<String>(tbl);
    map['row_id'] = Variable<String>(rowId);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      seq: Value(seq),
      tbl: Value(tbl),
      rowId: Value(rowId),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      seq: serializer.fromJson<int>(json['seq']),
      tbl: serializer.fromJson<String>(json['tbl']),
      rowId: serializer.fromJson<String>(json['rowId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'tbl': serializer.toJson<String>(tbl),
      'rowId': serializer.toJson<String>(rowId),
    };
  }

  OutboxEntry copyWith({int? seq, String? tbl, String? rowId}) => OutboxEntry(
    seq: seq ?? this.seq,
    tbl: tbl ?? this.tbl,
    rowId: rowId ?? this.rowId,
  );
  OutboxEntry copyWithCompanion(SyncOutboxCompanion data) {
    return OutboxEntry(
      seq: data.seq.present ? data.seq.value : this.seq,
      tbl: data.tbl.present ? data.tbl.value : this.tbl,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('seq: $seq, ')
          ..write('tbl: $tbl, ')
          ..write('rowId: $rowId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, tbl, rowId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.seq == this.seq &&
          other.tbl == this.tbl &&
          other.rowId == this.rowId);
}

class SyncOutboxCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> seq;
  final Value<String> tbl;
  final Value<String> rowId;
  const SyncOutboxCompanion({
    this.seq = const Value.absent(),
    this.tbl = const Value.absent(),
    this.rowId = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String tbl,
    required String rowId,
  }) : tbl = Value(tbl),
       rowId = Value(rowId);
  static Insertable<OutboxEntry> custom({
    Expression<int>? seq,
    Expression<String>? tbl,
    Expression<String>? rowId,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (tbl != null) 'tbl': tbl,
      if (rowId != null) 'row_id': rowId,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? tbl,
    Value<String>? rowId,
  }) {
    return SyncOutboxCompanion(
      seq: seq ?? this.seq,
      tbl: tbl ?? this.tbl,
      rowId: rowId ?? this.rowId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (tbl.present) {
      map['tbl'] = Variable<String>(tbl.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('tbl: $tbl, ')
          ..write('rowId: $rowId')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaEntry> instance, {
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
  SyncMetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaEntry(
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
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaEntry extends DataClass implements Insertable<SyncMetaEntry> {
  final String key;
  final String value;
  const SyncMetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaEntry(
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

  SyncMetaEntry copyWith({String? key, String? value}) =>
      SyncMetaEntry(key: key ?? this.key, value: value ?? this.value);
  SyncMetaEntry copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaEntry(')
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
      (other is SyncMetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaEntry> custom({
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

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
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
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CropsTable crops = $CropsTable(this);
  late final $PhenoScalesTable phenoScales = $PhenoScalesTable(this);
  late final $PhenoMacrosTable phenoMacros = $PhenoMacrosTable(this);
  late final $PhenoStagesTable phenoStages = $PhenoStagesTable(this);
  late final $VarietiesTable varieties = $VarietiesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $SeasonsTable seasons = $SeasonsTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $WeekStatusesTable weekStatuses = $WeekStatusesTable(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $MeasurementDefsTable measurementDefs = $MeasurementDefsTable(
    this,
  );
  late final $MeasurementValuesTable measurementValues =
      $MeasurementValuesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    crops,
    phenoScales,
    phenoMacros,
    phenoStages,
    varieties,
    projects,
    seasons,
    units,
    weekStatuses,
    observations,
    photos,
    measurementDefs,
    measurementValues,
    syncOutbox,
    syncMeta,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CropsTableCreateCompanionBuilder = CropsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String code,
  required String shortCode,
  required String name,
  Value<String> scientificName,
  required int seasonStartMonth,
  required int seasonStartDay,
  Value<int> rowid,
});
typedef $$CropsTableUpdateCompanionBuilder = CropsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> code,
  Value<String> shortCode,
  Value<String> name,
  Value<String> scientificName,
  Value<int> seasonStartMonth,
  Value<int> seasonStartDay,
  Value<int> rowid,
});

final class $$CropsTableReferences
    extends BaseReferences<_$AppDatabase, $CropsTable, Crop> {
  $$CropsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PhenoScalesTable, List<PhenoScale>>
  _phenoScalesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.phenoScales,
    aliasName: 'crops__id__pheno_scales__crop_id',
  );

  $$PhenoScalesTableProcessedTableManager get phenoScalesRefs {
    final manager = $$PhenoScalesTableTableManager(
      $_db,
      $_db.phenoScales,
    ).filter((f) => f.cropId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_phenoScalesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VarietiesTable, List<Variety>>
  _varietiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.varieties,
    aliasName: 'crops__id__varieties__crop_id',
  );

  $$VarietiesTableProcessedTableManager get varietiesRefs {
    final manager = $$VarietiesTableTableManager(
      $_db,
      $_db.varieties,
    ).filter((f) => f.cropId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_varietiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'crops__id__projects__crop_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.cropId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CropsTableFilterComposer extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortCode => $composableBuilder(
    column: $table.shortCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartDay => $composableBuilder(
    column: $table.seasonStartDay,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> phenoScalesRefs(
    Expression<bool> Function($$PhenoScalesTableFilterComposer f) f,
  ) {
    final $$PhenoScalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableFilterComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> varietiesRefs(
    Expression<bool> Function($$VarietiesTableFilterComposer f) f,
  ) {
    final $$VarietiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableFilterComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CropsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortCode => $composableBuilder(
    column: $table.shortCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartDay => $composableBuilder(
    column: $table.seasonStartDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get shortCode =>
      $composableBuilder(column: $table.shortCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasonStartDay => $composableBuilder(
    column: $table.seasonStartDay,
    builder: (column) => column,
  );

  Expression<T> phenoScalesRefs<T extends Object>(
    Expression<T> Function($$PhenoScalesTableAnnotationComposer a) f,
  ) {
    final $$PhenoScalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> varietiesRefs<T extends Object>(
    Expression<T> Function($$VarietiesTableAnnotationComposer a) f,
  ) {
    final $$VarietiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableAnnotationComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.cropId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CropsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropsTable,
          Crop,
          $$CropsTableFilterComposer,
          $$CropsTableOrderingComposer,
          $$CropsTableAnnotationComposer,
          $$CropsTableCreateCompanionBuilder,
          $$CropsTableUpdateCompanionBuilder,
          (Crop, $$CropsTableReferences),
          Crop,
          PrefetchHooks Function({
            bool phenoScalesRefs,
            bool varietiesRefs,
            bool projectsRefs,
          })
        > {
  $$CropsTableTableManager(_$AppDatabase db, $CropsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> shortCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<int> seasonStartMonth = const Value.absent(),
                Value<int> seasonStartDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                code: code,
                shortCode: shortCode,
                name: name,
                scientificName: scientificName,
                seasonStartMonth: seasonStartMonth,
                seasonStartDay: seasonStartDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String code,
                required String shortCode,
                required String name,
                Value<String> scientificName = const Value.absent(),
                required int seasonStartMonth,
                required int seasonStartDay,
                Value<int> rowid = const Value.absent(),
              }) => CropsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                code: code,
                shortCode: shortCode,
                name: name,
                scientificName: scientificName,
                seasonStartMonth: seasonStartMonth,
                seasonStartDay: seasonStartDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CropsTable, Crop>(table),
                  $$CropsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                phenoScalesRefs = false,
                varietiesRefs = false,
                projectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (phenoScalesRefs) db.phenoScales,
                    if (varietiesRefs) db.varieties,
                    if (projectsRefs) db.projects,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (phenoScalesRefs)
                        await $_getPrefetchedDataByColumns<
                          Crop,
                          $CropsTable,
                          PhenoScale,
                          $PhenoScalesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CropsTableReferences
                              ._phenoScalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CropsTableReferences(
                                db,
                                table,
                                p0,
                              ).phenoScalesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'crop_id',
                          typedResults: items,
                        ),
                      if (varietiesRefs)
                        await $_getPrefetchedDataByColumns<
                          Crop,
                          $CropsTable,
                          Variety,
                          $VarietiesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CropsTableReferences
                              ._varietiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CropsTableReferences(
                                db,
                                table,
                                p0,
                              ).varietiesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'crop_id',
                          typedResults: items,
                        ),
                      if (projectsRefs)
                        await $_getPrefetchedDataByColumns<
                          Crop,
                          $CropsTable,
                          Project,
                          $ProjectsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CropsTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CropsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'crop_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CropsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropsTable,
      Crop,
      $$CropsTableFilterComposer,
      $$CropsTableOrderingComposer,
      $$CropsTableAnnotationComposer,
      $$CropsTableCreateCompanionBuilder,
      $$CropsTableUpdateCompanionBuilder,
      (Crop, $$CropsTableReferences),
      Crop,
      PrefetchHooks Function({
        bool phenoScalesRefs,
        bool varietiesRefs,
        bool projectsRefs,
      })
    >;
typedef $$PhenoScalesTableCreateCompanionBuilder =
    PhenoScalesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String cropId,
      required String name,
      required int version,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$PhenoScalesTableUpdateCompanionBuilder =
    PhenoScalesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> cropId,
      Value<String> name,
      Value<int> version,
      Value<bool> isDefault,
      Value<int> rowid,
    });

final class $$PhenoScalesTableReferences
    extends BaseReferences<_$AppDatabase, $PhenoScalesTable, PhenoScale> {
  $$PhenoScalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CropsTable _cropIdTable(_$AppDatabase db) =>
      db.crops.createAlias('pheno_scales__crop_id__crops__id');

  $$CropsTableProcessedTableManager get cropId {
    final $_column = $_itemColumn<String>('crop_id')!;

    final manager = $$CropsTableTableManager(
      $_db,
      $_db.crops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PhenoMacrosTable, List<PhenoMacro>>
  _phenoMacrosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.phenoMacros,
    aliasName: 'pheno_scales__id__pheno_macros__scale_id',
  );

  $$PhenoMacrosTableProcessedTableManager get phenoMacrosRefs {
    final manager = $$PhenoMacrosTableTableManager(
      $_db,
      $_db.phenoMacros,
    ).filter((f) => f.scaleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_phenoMacrosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhenoStagesTable, List<PhenoStage>>
  _phenoStagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.phenoStages,
    aliasName: 'pheno_scales__id__pheno_stages__scale_id',
  );

  $$PhenoStagesTableProcessedTableManager get phenoStagesRefs {
    final manager = $$PhenoStagesTableTableManager(
      $_db,
      $_db.phenoStages,
    ).filter((f) => f.scaleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_phenoStagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'pheno_scales__id__projects__scale_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.scaleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhenoScalesTableFilterComposer
    extends Composer<_$AppDatabase, $PhenoScalesTable> {
  $$PhenoScalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  $$CropsTableFilterComposer get cropId {
    final $$CropsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableFilterComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> phenoMacrosRefs(
    Expression<bool> Function($$PhenoMacrosTableFilterComposer f) f,
  ) {
    final $$PhenoMacrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoMacros,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoMacrosTableFilterComposer(
            $db: $db,
            $table: $db.phenoMacros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> phenoStagesRefs(
    Expression<bool> Function($$PhenoStagesTableFilterComposer f) f,
  ) {
    final $$PhenoStagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoStages,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoStagesTableFilterComposer(
            $db: $db,
            $table: $db.phenoStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhenoScalesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhenoScalesTable> {
  $$PhenoScalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  $$CropsTableOrderingComposer get cropId {
    final $$CropsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableOrderingComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhenoScalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhenoScalesTable> {
  $$PhenoScalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  $$CropsTableAnnotationComposer get cropId {
    final $$CropsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableAnnotationComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> phenoMacrosRefs<T extends Object>(
    Expression<T> Function($$PhenoMacrosTableAnnotationComposer a) f,
  ) {
    final $$PhenoMacrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoMacros,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoMacrosTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoMacros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> phenoStagesRefs<T extends Object>(
    Expression<T> Function($$PhenoStagesTableAnnotationComposer a) f,
  ) {
    final $$PhenoStagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phenoStages,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoStagesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.scaleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhenoScalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhenoScalesTable,
          PhenoScale,
          $$PhenoScalesTableFilterComposer,
          $$PhenoScalesTableOrderingComposer,
          $$PhenoScalesTableAnnotationComposer,
          $$PhenoScalesTableCreateCompanionBuilder,
          $$PhenoScalesTableUpdateCompanionBuilder,
          (PhenoScale, $$PhenoScalesTableReferences),
          PhenoScale,
          PrefetchHooks Function({
            bool cropId,
            bool phenoMacrosRefs,
            bool phenoStagesRefs,
            bool projectsRefs,
          })
        > {
  $$PhenoScalesTableTableManager(_$AppDatabase db, $PhenoScalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhenoScalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhenoScalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhenoScalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhenoScalesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                name: name,
                version: version,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String cropId,
                required String name,
                required int version,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhenoScalesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                name: name,
                version: version,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhenoScalesTable, PhenoScale>(table),
                  $$PhenoScalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cropId = false,
                phenoMacrosRefs = false,
                phenoStagesRefs = false,
                projectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (phenoMacrosRefs) db.phenoMacros,
                    if (phenoStagesRefs) db.phenoStages,
                    if (projectsRefs) db.projects,
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
                        if (cropId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cropId,
                            referencedTable: $$PhenoScalesTableReferences
                                ._cropIdTable(db),
                            referencedColumn: $$PhenoScalesTableReferences
                                ._cropIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (phenoMacrosRefs)
                        await $_getPrefetchedDataByColumns<
                          PhenoScale,
                          $PhenoScalesTable,
                          PhenoMacro,
                          $PhenoMacrosTable
                        >(
                          currentTable: table,
                          referencedTable: $$PhenoScalesTableReferences
                              ._phenoMacrosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PhenoScalesTableReferences(
                                db,
                                table,
                                p0,
                              ).phenoMacrosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scale_id',
                          typedResults: items,
                        ),
                      if (phenoStagesRefs)
                        await $_getPrefetchedDataByColumns<
                          PhenoScale,
                          $PhenoScalesTable,
                          PhenoStage,
                          $PhenoStagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PhenoScalesTableReferences
                              ._phenoStagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PhenoScalesTableReferences(
                                db,
                                table,
                                p0,
                              ).phenoStagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scale_id',
                          typedResults: items,
                        ),
                      if (projectsRefs)
                        await $_getPrefetchedDataByColumns<
                          PhenoScale,
                          $PhenoScalesTable,
                          Project,
                          $ProjectsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PhenoScalesTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PhenoScalesTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scale_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PhenoScalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhenoScalesTable,
      PhenoScale,
      $$PhenoScalesTableFilterComposer,
      $$PhenoScalesTableOrderingComposer,
      $$PhenoScalesTableAnnotationComposer,
      $$PhenoScalesTableCreateCompanionBuilder,
      $$PhenoScalesTableUpdateCompanionBuilder,
      (PhenoScale, $$PhenoScalesTableReferences),
      PhenoScale,
      PrefetchHooks Function({
        bool cropId,
        bool phenoMacrosRefs,
        bool phenoStagesRefs,
        bool projectsRefs,
      })
    >;
typedef $$PhenoMacrosTableCreateCompanionBuilder =
    PhenoMacrosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String scaleId,
      required String code,
      required String name,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$PhenoMacrosTableUpdateCompanionBuilder =
    PhenoMacrosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> scaleId,
      Value<String> code,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PhenoMacrosTableReferences
    extends BaseReferences<_$AppDatabase, $PhenoMacrosTable, PhenoMacro> {
  $$PhenoMacrosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PhenoScalesTable _scaleIdTable(_$AppDatabase db) =>
      db.phenoScales.createAlias('pheno_macros__scale_id__pheno_scales__id');

  $$PhenoScalesTableProcessedTableManager get scaleId {
    final $_column = $_itemColumn<String>('scale_id')!;

    final manager = $$PhenoScalesTableTableManager(
      $_db,
      $_db.phenoScales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scaleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhenoMacrosTableFilterComposer
    extends Composer<_$AppDatabase, $PhenoMacrosTable> {
  $$PhenoMacrosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PhenoScalesTableFilterComposer get scaleId {
    final $$PhenoScalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableFilterComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhenoMacrosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhenoMacrosTable> {
  $$PhenoMacrosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PhenoScalesTableOrderingComposer get scaleId {
    final $$PhenoScalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableOrderingComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhenoMacrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhenoMacrosTable> {
  $$PhenoMacrosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PhenoScalesTableAnnotationComposer get scaleId {
    final $$PhenoScalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhenoMacrosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhenoMacrosTable,
          PhenoMacro,
          $$PhenoMacrosTableFilterComposer,
          $$PhenoMacrosTableOrderingComposer,
          $$PhenoMacrosTableAnnotationComposer,
          $$PhenoMacrosTableCreateCompanionBuilder,
          $$PhenoMacrosTableUpdateCompanionBuilder,
          (PhenoMacro, $$PhenoMacrosTableReferences),
          PhenoMacro,
          PrefetchHooks Function({bool scaleId})
        > {
  $$PhenoMacrosTableTableManager(_$AppDatabase db, $PhenoMacrosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhenoMacrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhenoMacrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhenoMacrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> scaleId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhenoMacrosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scaleId: scaleId,
                code: code,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String scaleId,
                required String code,
                required String name,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => PhenoMacrosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scaleId: scaleId,
                code: code,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhenoMacrosTable, PhenoMacro>(table),
                  $$PhenoMacrosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scaleId = false}) {
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
                    if (scaleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.scaleId,
                        referencedTable: $$PhenoMacrosTableReferences
                            ._scaleIdTable(db),
                        referencedColumn: $$PhenoMacrosTableReferences
                            ._scaleIdTable(db)
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

typedef $$PhenoMacrosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhenoMacrosTable,
      PhenoMacro,
      $$PhenoMacrosTableFilterComposer,
      $$PhenoMacrosTableOrderingComposer,
      $$PhenoMacrosTableAnnotationComposer,
      $$PhenoMacrosTableCreateCompanionBuilder,
      $$PhenoMacrosTableUpdateCompanionBuilder,
      (PhenoMacro, $$PhenoMacrosTableReferences),
      PhenoMacro,
      PrefetchHooks Function({bool scaleId})
    >;
typedef $$PhenoStagesTableCreateCompanionBuilder =
    PhenoStagesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String scaleId,
      required String code,
      required String macroCode,
      required int sortOrder,
      required String name,
      Value<String> description,
      required int color,
      Value<int> rowid,
    });
typedef $$PhenoStagesTableUpdateCompanionBuilder =
    PhenoStagesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> scaleId,
      Value<String> code,
      Value<String> macroCode,
      Value<int> sortOrder,
      Value<String> name,
      Value<String> description,
      Value<int> color,
      Value<int> rowid,
    });

final class $$PhenoStagesTableReferences
    extends BaseReferences<_$AppDatabase, $PhenoStagesTable, PhenoStage> {
  $$PhenoStagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PhenoScalesTable _scaleIdTable(_$AppDatabase db) =>
      db.phenoScales.createAlias('pheno_stages__scale_id__pheno_scales__id');

  $$PhenoScalesTableProcessedTableManager get scaleId {
    final $_column = $_itemColumn<String>('scale_id')!;

    final manager = $$PhenoScalesTableTableManager(
      $_db,
      $_db.phenoScales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scaleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'pheno_stages__id__observations__stage_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.stageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhenoStagesTableFilterComposer
    extends Composer<_$AppDatabase, $PhenoStagesTable> {
  $$PhenoStagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macroCode => $composableBuilder(
    column: $table.macroCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$PhenoScalesTableFilterComposer get scaleId {
    final $$PhenoScalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableFilterComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhenoStagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhenoStagesTable> {
  $$PhenoStagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macroCode => $composableBuilder(
    column: $table.macroCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$PhenoScalesTableOrderingComposer get scaleId {
    final $$PhenoScalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableOrderingComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhenoStagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhenoStagesTable> {
  $$PhenoStagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get macroCode =>
      $composableBuilder(column: $table.macroCode, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$PhenoScalesTableAnnotationComposer get scaleId {
    final $$PhenoScalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhenoStagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhenoStagesTable,
          PhenoStage,
          $$PhenoStagesTableFilterComposer,
          $$PhenoStagesTableOrderingComposer,
          $$PhenoStagesTableAnnotationComposer,
          $$PhenoStagesTableCreateCompanionBuilder,
          $$PhenoStagesTableUpdateCompanionBuilder,
          (PhenoStage, $$PhenoStagesTableReferences),
          PhenoStage,
          PrefetchHooks Function({bool scaleId, bool observationsRefs})
        > {
  $$PhenoStagesTableTableManager(_$AppDatabase db, $PhenoStagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhenoStagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhenoStagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhenoStagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> scaleId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> macroCode = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhenoStagesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scaleId: scaleId,
                code: code,
                macroCode: macroCode,
                sortOrder: sortOrder,
                name: name,
                description: description,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String scaleId,
                required String code,
                required String macroCode,
                required int sortOrder,
                required String name,
                Value<String> description = const Value.absent(),
                required int color,
                Value<int> rowid = const Value.absent(),
              }) => PhenoStagesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scaleId: scaleId,
                code: code,
                macroCode: macroCode,
                sortOrder: sortOrder,
                name: name,
                description: description,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhenoStagesTable, PhenoStage>(table),
                  $$PhenoStagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scaleId = false, observationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (observationsRefs) db.observations],
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
                    if (scaleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.scaleId,
                        referencedTable: $$PhenoStagesTableReferences
                            ._scaleIdTable(db),
                        referencedColumn: $$PhenoStagesTableReferences
                            ._scaleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (observationsRefs)
                    await $_getPrefetchedDataByColumns<
                      PhenoStage,
                      $PhenoStagesTable,
                      Observation,
                      $ObservationsTable
                    >(
                      currentTable: table,
                      referencedTable: $$PhenoStagesTableReferences
                          ._observationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PhenoStagesTableReferences(
                            db,
                            table,
                            p0,
                          ).observationsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'stage_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhenoStagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhenoStagesTable,
      PhenoStage,
      $$PhenoStagesTableFilterComposer,
      $$PhenoStagesTableOrderingComposer,
      $$PhenoStagesTableAnnotationComposer,
      $$PhenoStagesTableCreateCompanionBuilder,
      $$PhenoStagesTableUpdateCompanionBuilder,
      (PhenoStage, $$PhenoStagesTableReferences),
      PhenoStage,
      PrefetchHooks Function({bool scaleId, bool observationsRefs})
    >;
typedef $$VarietiesTableCreateCompanionBuilder = VarietiesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String cropId,
  required String name,
  Value<String> code,
  Value<String> notes,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$VarietiesTableUpdateCompanionBuilder = VarietiesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> cropId,
  Value<String> name,
  Value<String> code,
  Value<String> notes,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$VarietiesTableReferences
    extends BaseReferences<_$AppDatabase, $VarietiesTable, Variety> {
  $$VarietiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CropsTable _cropIdTable(_$AppDatabase db) =>
      db.crops.createAlias('varieties__crop_id__crops__id');

  $$CropsTableProcessedTableManager get cropId {
    final $_column = $_itemColumn<String>('crop_id')!;

    final manager = $$CropsTableTableManager(
      $_db,
      $_db.crops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.units,
    aliasName: 'varieties__id__units__variety_id',
  );

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.varietyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementValuesTable, List<MeasurementValue>>
  _measurementValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementValues,
        aliasName: 'varieties__id__measurement_values__variety_id',
      );

  $$MeasurementValuesTableProcessedTableManager get measurementValuesRefs {
    final manager = $$MeasurementValuesTableTableManager(
      $_db,
      $_db.measurementValues,
    ).filter((f) => f.varietyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VarietiesTableFilterComposer
    extends Composer<_$AppDatabase, $VarietiesTable> {
  $$VarietiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  $$CropsTableFilterComposer get cropId {
    final $$CropsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableFilterComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> unitsRefs(
    Expression<bool> Function($$UnitsTableFilterComposer f) f,
  ) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.varietyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementValuesRefs(
    Expression<bool> Function($$MeasurementValuesTableFilterComposer f) f,
  ) {
    final $$MeasurementValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementValues,
      getReferencedColumn: (t) => t.varietyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementValuesTableFilterComposer(
            $db: $db,
            $table: $db.measurementValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VarietiesTableOrderingComposer
    extends Composer<_$AppDatabase, $VarietiesTable> {
  $$VarietiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  $$CropsTableOrderingComposer get cropId {
    final $$CropsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableOrderingComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VarietiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VarietiesTable> {
  $$VarietiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  $$CropsTableAnnotationComposer get cropId {
    final $$CropsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableAnnotationComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> unitsRefs<T extends Object>(
    Expression<T> Function($$UnitsTableAnnotationComposer a) f,
  ) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.varietyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementValuesRefs<T extends Object>(
    Expression<T> Function($$MeasurementValuesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementValues,
          getReferencedColumn: (t) => t.varietyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VarietiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VarietiesTable,
          Variety,
          $$VarietiesTableFilterComposer,
          $$VarietiesTableOrderingComposer,
          $$VarietiesTableAnnotationComposer,
          $$VarietiesTableCreateCompanionBuilder,
          $$VarietiesTableUpdateCompanionBuilder,
          (Variety, $$VarietiesTableReferences),
          Variety,
          PrefetchHooks Function({
            bool cropId,
            bool unitsRefs,
            bool measurementValuesRefs,
          })
        > {
  $$VarietiesTableTableManager(_$AppDatabase db, $VarietiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VarietiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VarietiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VarietiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VarietiesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                name: name,
                code: code,
                notes: notes,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String cropId,
                required String name,
                Value<String> code = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VarietiesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                name: name,
                code: code,
                notes: notes,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VarietiesTable, Variety>(table),
                  $$VarietiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cropId = false,
                unitsRefs = false,
                measurementValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (unitsRefs) db.units,
                    if (measurementValuesRefs) db.measurementValues,
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
                        if (cropId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cropId,
                            referencedTable: $$VarietiesTableReferences
                                ._cropIdTable(db),
                            referencedColumn: $$VarietiesTableReferences
                                ._cropIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (unitsRefs)
                        await $_getPrefetchedDataByColumns<
                          Variety,
                          $VarietiesTable,
                          Unit,
                          $UnitsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VarietiesTableReferences
                              ._unitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VarietiesTableReferences(
                                db,
                                table,
                                p0,
                              ).unitsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'variety_id',
                          typedResults: items,
                        ),
                      if (measurementValuesRefs)
                        await $_getPrefetchedDataByColumns<
                          Variety,
                          $VarietiesTable,
                          MeasurementValue,
                          $MeasurementValuesTable
                        >(
                          currentTable: table,
                          referencedTable: $$VarietiesTableReferences
                              ._measurementValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VarietiesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementValuesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'variety_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VarietiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VarietiesTable,
      Variety,
      $$VarietiesTableFilterComposer,
      $$VarietiesTableOrderingComposer,
      $$VarietiesTableAnnotationComposer,
      $$VarietiesTableCreateCompanionBuilder,
      $$VarietiesTableUpdateCompanionBuilder,
      (Variety, $$VarietiesTableReferences),
      Variety,
      PrefetchHooks Function({
        bool cropId,
        bool unitsRefs,
        bool measurementValuesRefs,
      })
    >;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String cropId,
  required String scaleId,
  required String kind,
  required String name,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> cropId,
  Value<String> scaleId,
  Value<String> kind,
  Value<String> name,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CropsTable _cropIdTable(_$AppDatabase db) =>
      db.crops.createAlias('projects__crop_id__crops__id');

  $$CropsTableProcessedTableManager get cropId {
    final $_column = $_itemColumn<String>('crop_id')!;

    final manager = $$CropsTableTableManager(
      $_db,
      $_db.crops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhenoScalesTable _scaleIdTable(_$AppDatabase db) =>
      db.phenoScales.createAlias('projects__scale_id__pheno_scales__id');

  $$PhenoScalesTableProcessedTableManager get scaleId {
    final $_column = $_itemColumn<String>('scale_id')!;

    final manager = $$PhenoScalesTableTableManager(
      $_db,
      $_db.phenoScales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scaleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SeasonsTable, List<Season>> _seasonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.seasons,
    aliasName: 'projects__id__seasons__project_id',
  );

  $$SeasonsTableProcessedTableManager get seasonsRefs {
    final manager = $$SeasonsTableTableManager(
      $_db,
      $_db.seasons,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seasonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.units,
    aliasName: 'projects__id__units__project_id',
  );

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementDefsTable, List<MeasurementDef>>
  _measurementDefsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.measurementDefs,
    aliasName: 'projects__id__measurement_defs__project_id',
  );

  $$MeasurementDefsTableProcessedTableManager get measurementDefsRefs {
    final manager = $$MeasurementDefsTableTableManager(
      $_db,
      $_db.measurementDefs,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementDefsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  $$CropsTableFilterComposer get cropId {
    final $$CropsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableFilterComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoScalesTableFilterComposer get scaleId {
    final $$PhenoScalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableFilterComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> seasonsRefs(
    Expression<bool> Function($$SeasonsTableFilterComposer f) f,
  ) {
    final $$SeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableFilterComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unitsRefs(
    Expression<bool> Function($$UnitsTableFilterComposer f) f,
  ) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementDefsRefs(
    Expression<bool> Function($$MeasurementDefsTableFilterComposer f) f,
  ) {
    final $$MeasurementDefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementDefs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementDefsTableFilterComposer(
            $db: $db,
            $table: $db.measurementDefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  $$CropsTableOrderingComposer get cropId {
    final $$CropsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableOrderingComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoScalesTableOrderingComposer get scaleId {
    final $$PhenoScalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableOrderingComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  $$CropsTableAnnotationComposer get cropId {
    final $$CropsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cropId,
      referencedTable: $db.crops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropsTableAnnotationComposer(
            $db: $db,
            $table: $db.crops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoScalesTableAnnotationComposer get scaleId {
    final $$PhenoScalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scaleId,
      referencedTable: $db.phenoScales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoScalesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> seasonsRefs<T extends Object>(
    Expression<T> Function($$SeasonsTableAnnotationComposer a) f,
  ) {
    final $$SeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> unitsRefs<T extends Object>(
    Expression<T> Function($$UnitsTableAnnotationComposer a) f,
  ) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementDefsRefs<T extends Object>(
    Expression<T> Function($$MeasurementDefsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementDefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementDefs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementDefsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementDefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool cropId,
            bool scaleId,
            bool seasonsRefs,
            bool unitsRefs,
            bool measurementDefsRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<String> scaleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                scaleId: scaleId,
                kind: kind,
                name: name,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String cropId,
                required String scaleId,
                required String kind,
                required String name,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cropId: cropId,
                scaleId: scaleId,
                kind: kind,
                name: name,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cropId = false,
                scaleId = false,
                seasonsRefs = false,
                unitsRefs = false,
                measurementDefsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (seasonsRefs) db.seasons,
                    if (unitsRefs) db.units,
                    if (measurementDefsRefs) db.measurementDefs,
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
                        if (cropId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cropId,
                            referencedTable: $$ProjectsTableReferences
                                ._cropIdTable(db),
                            referencedColumn: $$ProjectsTableReferences
                                ._cropIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (scaleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scaleId,
                            referencedTable: $$ProjectsTableReferences
                                ._scaleIdTable(db),
                            referencedColumn: $$ProjectsTableReferences
                                ._scaleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (seasonsRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          Season,
                          $SeasonsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._seasonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).seasonsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                      if (unitsRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          Unit,
                          $UnitsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._unitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).unitsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                      if (measurementDefsRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          MeasurementDef,
                          $MeasurementDefsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._measurementDefsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementDefsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool cropId,
        bool scaleId,
        bool seasonsRefs,
        bool unitsRefs,
        bool measurementDefsRefs,
      })
    >;
typedef $$SeasonsTableCreateCompanionBuilder = SeasonsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String projectId,
  required String name,
  required DateTime week1Start,
  Value<int> rowid,
});
typedef $$SeasonsTableUpdateCompanionBuilder = SeasonsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> projectId,
  Value<String> name,
  Value<DateTime> week1Start,
  Value<int> rowid,
});

final class $$SeasonsTableReferences
    extends BaseReferences<_$AppDatabase, $SeasonsTable, Season> {
  $$SeasonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('seasons__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WeekStatusesTable, List<WeekStatus>>
  _weekStatusesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weekStatuses,
    aliasName: 'seasons__id__week_statuses__season_id',
  );

  $$WeekStatusesTableProcessedTableManager get weekStatusesRefs {
    final manager = $$WeekStatusesTableTableManager(
      $_db,
      $_db.weekStatuses,
    ).filter((f) => f.seasonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_weekStatusesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'seasons__id__observations__season_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.seasonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementValuesTable, List<MeasurementValue>>
  _measurementValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementValues,
        aliasName: 'seasons__id__measurement_values__season_id',
      );

  $$MeasurementValuesTableProcessedTableManager get measurementValuesRefs {
    final manager = $$MeasurementValuesTableTableManager(
      $_db,
      $_db.measurementValues,
    ).filter((f) => f.seasonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeasonsTableFilterComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get week1Start => $composableBuilder(
    column: $table.week1Start,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> weekStatusesRefs(
    Expression<bool> Function($$WeekStatusesTableFilterComposer f) f,
  ) {
    final $$WeekStatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weekStatuses,
      getReferencedColumn: (t) => t.seasonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeekStatusesTableFilterComposer(
            $db: $db,
            $table: $db.weekStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.seasonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementValuesRefs(
    Expression<bool> Function($$MeasurementValuesTableFilterComposer f) f,
  ) {
    final $$MeasurementValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementValues,
      getReferencedColumn: (t) => t.seasonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementValuesTableFilterComposer(
            $db: $db,
            $table: $db.measurementValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeasonsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get week1Start => $composableBuilder(
    column: $table.week1Start,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeasonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get week1Start => $composableBuilder(
    column: $table.week1Start,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> weekStatusesRefs<T extends Object>(
    Expression<T> Function($$WeekStatusesTableAnnotationComposer a) f,
  ) {
    final $$WeekStatusesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weekStatuses,
      getReferencedColumn: (t) => t.seasonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeekStatusesTableAnnotationComposer(
            $db: $db,
            $table: $db.weekStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.seasonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementValuesRefs<T extends Object>(
    Expression<T> Function($$MeasurementValuesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementValues,
          getReferencedColumn: (t) => t.seasonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SeasonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeasonsTable,
          Season,
          $$SeasonsTableFilterComposer,
          $$SeasonsTableOrderingComposer,
          $$SeasonsTableAnnotationComposer,
          $$SeasonsTableCreateCompanionBuilder,
          $$SeasonsTableUpdateCompanionBuilder,
          (Season, $$SeasonsTableReferences),
          Season,
          PrefetchHooks Function({
            bool projectId,
            bool weekStatusesRefs,
            bool observationsRefs,
            bool measurementValuesRefs,
          })
        > {
  $$SeasonsTableTableManager(_$AppDatabase db, $SeasonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> week1Start = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeasonsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                name: name,
                week1Start: week1Start,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String projectId,
                required String name,
                required DateTime week1Start,
                Value<int> rowid = const Value.absent(),
              }) => SeasonsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                name: name,
                week1Start: week1Start,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeasonsTable, Season>(table),
                  $$SeasonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                weekStatusesRefs = false,
                observationsRefs = false,
                measurementValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (weekStatusesRefs) db.weekStatuses,
                    if (observationsRefs) db.observations,
                    if (measurementValuesRefs) db.measurementValues,
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
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$SeasonsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$SeasonsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (weekStatusesRefs)
                        await $_getPrefetchedDataByColumns<
                          Season,
                          $SeasonsTable,
                          WeekStatus,
                          $WeekStatusesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SeasonsTableReferences
                              ._weekStatusesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SeasonsTableReferences(
                                db,
                                table,
                                p0,
                              ).weekStatusesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'season_id',
                          typedResults: items,
                        ),
                      if (observationsRefs)
                        await $_getPrefetchedDataByColumns<
                          Season,
                          $SeasonsTable,
                          Observation,
                          $ObservationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SeasonsTableReferences
                              ._observationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SeasonsTableReferences(
                                db,
                                table,
                                p0,
                              ).observationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'season_id',
                          typedResults: items,
                        ),
                      if (measurementValuesRefs)
                        await $_getPrefetchedDataByColumns<
                          Season,
                          $SeasonsTable,
                          MeasurementValue,
                          $MeasurementValuesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SeasonsTableReferences
                              ._measurementValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SeasonsTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementValuesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'season_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeasonsTable,
      Season,
      $$SeasonsTableFilterComposer,
      $$SeasonsTableOrderingComposer,
      $$SeasonsTableAnnotationComposer,
      $$SeasonsTableCreateCompanionBuilder,
      $$SeasonsTableUpdateCompanionBuilder,
      (Season, $$SeasonsTableReferences),
      Season,
      PrefetchHooks Function({
        bool projectId,
        bool weekStatusesRefs,
        bool observationsRefs,
        bool measurementValuesRefs,
      })
    >;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String projectId,
  Value<String?> varietyId,
  required String label,
  Value<String?> treatment,
  Value<int?> replicate,
  Value<String?> irrigationGroup,
  Value<String?> sector,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> projectId,
  Value<String?> varietyId,
  Value<String> label,
  Value<String?> treatment,
  Value<int?> replicate,
  Value<String?> irrigationGroup,
  Value<String?> sector,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('units__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VarietiesTable _varietyIdTable(_$AppDatabase db) =>
      db.varieties.createAlias('units__variety_id__varieties__id');

  $$VarietiesTableProcessedTableManager? get varietyId {
    final $_column = $_itemColumn<String>('variety_id');
    if ($_column == null) return null;
    final manager = $$VarietiesTableTableManager(
      $_db,
      $_db.varieties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_varietyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'units__id__observations__unit_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.unitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replicate => $composableBuilder(
    column: $table.replicate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get irrigationGroup => $composableBuilder(
    column: $table.irrigationGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableFilterComposer get varietyId {
    final $$VarietiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableFilterComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replicate => $composableBuilder(
    column: $table.replicate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get irrigationGroup => $composableBuilder(
    column: $table.irrigationGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableOrderingComposer get varietyId {
    final $$VarietiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableOrderingComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<int> get replicate =>
      $composableBuilder(column: $table.replicate, builder: (column) => column);

  GeneratedColumn<String> get irrigationGroup => $composableBuilder(
    column: $table.irrigationGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableAnnotationComposer get varietyId {
    final $$VarietiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableAnnotationComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsTable,
          Unit,
          $$UnitsTableFilterComposer,
          $$UnitsTableOrderingComposer,
          $$UnitsTableAnnotationComposer,
          $$UnitsTableCreateCompanionBuilder,
          $$UnitsTableUpdateCompanionBuilder,
          (Unit, $$UnitsTableReferences),
          Unit,
          PrefetchHooks Function({
            bool projectId,
            bool varietyId,
            bool observationsRefs,
          })
        > {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> varietyId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> treatment = const Value.absent(),
                Value<int?> replicate = const Value.absent(),
                Value<String?> irrigationGroup = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                varietyId: varietyId,
                label: label,
                treatment: treatment,
                replicate: replicate,
                irrigationGroup: irrigationGroup,
                sector: sector,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String projectId,
                Value<String?> varietyId = const Value.absent(),
                required String label,
                Value<String?> treatment = const Value.absent(),
                Value<int?> replicate = const Value.absent(),
                Value<String?> irrigationGroup = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                varietyId: varietyId,
                label: label,
                treatment: treatment,
                replicate: replicate,
                irrigationGroup: irrigationGroup,
                sector: sector,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnitsTable, Unit>(table),
                  $$UnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                varietyId = false,
                observationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (observationsRefs) db.observations,
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
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$UnitsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$UnitsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (varietyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.varietyId,
                            referencedTable: $$UnitsTableReferences
                                ._varietyIdTable(db),
                            referencedColumn: $$UnitsTableReferences
                                ._varietyIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (observationsRefs)
                        await $_getPrefetchedDataByColumns<
                          Unit,
                          $UnitsTable,
                          Observation,
                          $ObservationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$UnitsTableReferences
                              ._observationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).observationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'unit_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsTable,
      Unit,
      $$UnitsTableFilterComposer,
      $$UnitsTableOrderingComposer,
      $$UnitsTableAnnotationComposer,
      $$UnitsTableCreateCompanionBuilder,
      $$UnitsTableUpdateCompanionBuilder,
      (Unit, $$UnitsTableReferences),
      Unit,
      PrefetchHooks Function({
        bool projectId,
        bool varietyId,
        bool observationsRefs,
      })
    >;
typedef $$WeekStatusesTableCreateCompanionBuilder =
    WeekStatusesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String seasonId,
      required int weekNumber,
      Value<bool> notSampled,
      Value<int> rowid,
    });
typedef $$WeekStatusesTableUpdateCompanionBuilder =
    WeekStatusesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> seasonId,
      Value<int> weekNumber,
      Value<bool> notSampled,
      Value<int> rowid,
    });

final class $$WeekStatusesTableReferences
    extends BaseReferences<_$AppDatabase, $WeekStatusesTable, WeekStatus> {
  $$WeekStatusesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeasonsTable _seasonIdTable(_$AppDatabase db) =>
      db.seasons.createAlias('week_statuses__season_id__seasons__id');

  $$SeasonsTableProcessedTableManager get seasonId {
    final $_column = $_itemColumn<String>('season_id')!;

    final manager = $$SeasonsTableTableManager(
      $_db,
      $_db.seasons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seasonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeekStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $WeekStatusesTable> {
  $$WeekStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notSampled => $composableBuilder(
    column: $table.notSampled,
    builder: (column) => ColumnFilters(column),
  );

  $$SeasonsTableFilterComposer get seasonId {
    final $$SeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableFilterComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekStatusesTable> {
  $$WeekStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notSampled => $composableBuilder(
    column: $table.notSampled,
    builder: (column) => ColumnOrderings(column),
  );

  $$SeasonsTableOrderingComposer get seasonId {
    final $$SeasonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableOrderingComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekStatusesTable> {
  $$WeekStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notSampled => $composableBuilder(
    column: $table.notSampled,
    builder: (column) => column,
  );

  $$SeasonsTableAnnotationComposer get seasonId {
    final $$SeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeekStatusesTable,
          WeekStatus,
          $$WeekStatusesTableFilterComposer,
          $$WeekStatusesTableOrderingComposer,
          $$WeekStatusesTableAnnotationComposer,
          $$WeekStatusesTableCreateCompanionBuilder,
          $$WeekStatusesTableUpdateCompanionBuilder,
          (WeekStatus, $$WeekStatusesTableReferences),
          WeekStatus,
          PrefetchHooks Function({bool seasonId})
        > {
  $$WeekStatusesTableTableManager(_$AppDatabase db, $WeekStatusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekStatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> seasonId = const Value.absent(),
                Value<int> weekNumber = const Value.absent(),
                Value<bool> notSampled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekStatusesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seasonId: seasonId,
                weekNumber: weekNumber,
                notSampled: notSampled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String seasonId,
                required int weekNumber,
                Value<bool> notSampled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekStatusesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seasonId: seasonId,
                weekNumber: weekNumber,
                notSampled: notSampled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeekStatusesTable, WeekStatus>(table),
                  $$WeekStatusesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seasonId = false}) {
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
                    if (seasonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seasonId,
                        referencedTable: $$WeekStatusesTableReferences
                            ._seasonIdTable(db),
                        referencedColumn: $$WeekStatusesTableReferences
                            ._seasonIdTable(db)
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

typedef $$WeekStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeekStatusesTable,
      WeekStatus,
      $$WeekStatusesTableFilterComposer,
      $$WeekStatusesTableOrderingComposer,
      $$WeekStatusesTableAnnotationComposer,
      $$WeekStatusesTableCreateCompanionBuilder,
      $$WeekStatusesTableUpdateCompanionBuilder,
      (WeekStatus, $$WeekStatusesTableReferences),
      WeekStatus,
      PrefetchHooks Function({bool seasonId})
    >;
typedef $$ObservationsTableCreateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String seasonId,
      required String unitId,
      required int weekNumber,
      Value<String?> stageId,
      Value<String> stageSource,
      Value<String> notes,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> accuracyM,
      Value<int> rowid,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> seasonId,
      Value<String> unitId,
      Value<int> weekNumber,
      Value<String?> stageId,
      Value<String> stageSource,
      Value<String> notes,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> accuracyM,
      Value<int> rowid,
    });

final class $$ObservationsTableReferences
    extends BaseReferences<_$AppDatabase, $ObservationsTable, Observation> {
  $$ObservationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeasonsTable _seasonIdTable(_$AppDatabase db) =>
      db.seasons.createAlias('observations__season_id__seasons__id');

  $$SeasonsTableProcessedTableManager get seasonId {
    final $_column = $_itemColumn<String>('season_id')!;

    final manager = $$SeasonsTableTableManager(
      $_db,
      $_db.seasons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seasonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitsTable _unitIdTable(_$AppDatabase db) =>
      db.units.createAlias('observations__unit_id__units__id');

  $$UnitsTableProcessedTableManager get unitId {
    final $_column = $_itemColumn<String>('unit_id')!;

    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhenoStagesTable _stageIdTable(_$AppDatabase db) =>
      db.phenoStages.createAlias('observations__stage_id__pheno_stages__id');

  $$PhenoStagesTableProcessedTableManager? get stageId {
    final $_column = $_itemColumn<String>('stage_id');
    if ($_column == null) return null;
    final manager = $$PhenoStagesTableTableManager(
      $_db,
      $_db.phenoStages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'observations__id__photos__observation_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementValuesTable, List<MeasurementValue>>
  _measurementValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementValues,
        aliasName: 'observations__id__measurement_values__observation_id',
      );

  $$MeasurementValuesTableProcessedTableManager get measurementValuesRefs {
    final manager = $$MeasurementValuesTableTableManager(
      $_db,
      $_db.measurementValues,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageSource => $composableBuilder(
    column: $table.stageSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  $$SeasonsTableFilterComposer get seasonId {
    final $$SeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableFilterComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoStagesTableFilterComposer get stageId {
    final $$PhenoStagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.phenoStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoStagesTableFilterComposer(
            $db: $db,
            $table: $db.phenoStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementValuesRefs(
    Expression<bool> Function($$MeasurementValuesTableFilterComposer f) f,
  ) {
    final $$MeasurementValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementValues,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementValuesTableFilterComposer(
            $db: $db,
            $table: $db.measurementValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageSource => $composableBuilder(
    column: $table.stageSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  $$SeasonsTableOrderingComposer get seasonId {
    final $$SeasonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableOrderingComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoStagesTableOrderingComposer get stageId {
    final $$PhenoStagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.phenoStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoStagesTableOrderingComposer(
            $db: $db,
            $table: $db.phenoStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stageSource => $composableBuilder(
    column: $table.stageSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  $$SeasonsTableAnnotationComposer get seasonId {
    final $$SeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhenoStagesTableAnnotationComposer get stageId {
    final $$PhenoStagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.phenoStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhenoStagesTableAnnotationComposer(
            $db: $db,
            $table: $db.phenoStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementValuesRefs<T extends Object>(
    Expression<T> Function($$MeasurementValuesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementValues,
          getReferencedColumn: (t) => t.observationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservationsTable,
          Observation,
          $$ObservationsTableFilterComposer,
          $$ObservationsTableOrderingComposer,
          $$ObservationsTableAnnotationComposer,
          $$ObservationsTableCreateCompanionBuilder,
          $$ObservationsTableUpdateCompanionBuilder,
          (Observation, $$ObservationsTableReferences),
          Observation,
          PrefetchHooks Function({
            bool seasonId,
            bool unitId,
            bool stageId,
            bool photosRefs,
            bool measurementValuesRefs,
          })
        > {
  $$ObservationsTableTableManager(_$AppDatabase db, $ObservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> seasonId = const Value.absent(),
                Value<String> unitId = const Value.absent(),
                Value<int> weekNumber = const Value.absent(),
                Value<String?> stageId = const Value.absent(),
                Value<String> stageSource = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seasonId: seasonId,
                unitId: unitId,
                weekNumber: weekNumber,
                stageId: stageId,
                stageSource: stageSource,
                notes: notes,
                lat: lat,
                lon: lon,
                accuracyM: accuracyM,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String seasonId,
                required String unitId,
                required int weekNumber,
                Value<String?> stageId = const Value.absent(),
                Value<String> stageSource = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seasonId: seasonId,
                unitId: unitId,
                weekNumber: weekNumber,
                stageId: stageId,
                stageSource: stageSource,
                notes: notes,
                lat: lat,
                lon: lon,
                accuracyM: accuracyM,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObservationsTable, Observation>(table),
                  $$ObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                seasonId = false,
                unitId = false,
                stageId = false,
                photosRefs = false,
                measurementValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (photosRefs) db.photos,
                    if (measurementValuesRefs) db.measurementValues,
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
                        if (seasonId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seasonId,
                            referencedTable: $$ObservationsTableReferences
                                ._seasonIdTable(db),
                            referencedColumn: $$ObservationsTableReferences
                                ._seasonIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (unitId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.unitId,
                            referencedTable: $$ObservationsTableReferences
                                ._unitIdTable(db),
                            referencedColumn: $$ObservationsTableReferences
                                ._unitIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (stageId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stageId,
                            referencedTable: $$ObservationsTableReferences
                                ._stageIdTable(db),
                            referencedColumn: $$ObservationsTableReferences
                                ._stageIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (photosRefs)
                        await $_getPrefetchedDataByColumns<
                          Observation,
                          $ObservationsTable,
                          Photo,
                          $PhotosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ObservationsTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'observation_id',
                          typedResults: items,
                        ),
                      if (measurementValuesRefs)
                        await $_getPrefetchedDataByColumns<
                          Observation,
                          $ObservationsTable,
                          MeasurementValue,
                          $MeasurementValuesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ObservationsTableReferences
                              ._measurementValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementValuesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'observation_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservationsTable,
      Observation,
      $$ObservationsTableFilterComposer,
      $$ObservationsTableOrderingComposer,
      $$ObservationsTableAnnotationComposer,
      $$ObservationsTableCreateCompanionBuilder,
      $$ObservationsTableUpdateCompanionBuilder,
      (Observation, $$ObservationsTableReferences),
      Observation,
      PrefetchHooks Function({
        bool seasonId,
        bool unitId,
        bool stageId,
        bool photosRefs,
        bool measurementValuesRefs,
      })
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String observationId,
  required String kind,
  required int seq,
  required String fileName,
  required String localPath,
  required DateTime takenAt,
  Value<String> uploadStatus,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> observationId,
  Value<String> kind,
  Value<int> seq,
  Value<String> fileName,
  Value<String> localPath,
  Value<DateTime> takenAt,
  Value<String> uploadStatus,
  Value<int> rowid,
});

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.observations.createAlias('photos__observation_id__observations__id');

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => column,
  );

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, $$PhotosTableReferences),
          Photo,
          PrefetchHooks Function({bool observationId})
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                observationId: observationId,
                kind: kind,
                seq: seq,
                fileName: fileName,
                localPath: localPath,
                takenAt: takenAt,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String observationId,
                required String kind,
                required int seq,
                required String fileName,
                required String localPath,
                required DateTime takenAt,
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                observationId: observationId,
                kind: kind,
                seq: seq,
                fileName: fileName,
                localPath: localPath,
                takenAt: takenAt,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, Photo>(table),
                  $$PhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({observationId = false}) {
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
                    if (observationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.observationId,
                        referencedTable: $$PhotosTableReferences
                            ._observationIdTable(db),
                        referencedColumn: $$PhotosTableReferences
                            ._observationIdTable(db)
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

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, $$PhotosTableReferences),
      Photo,
      PrefetchHooks Function({bool observationId})
    >;
typedef $$MeasurementDefsTableCreateCompanionBuilder =
    MeasurementDefsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String projectId,
      required String name,
      required String kind,
      required String scope,
      Value<String> unit,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<String> choices,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$MeasurementDefsTableUpdateCompanionBuilder =
    MeasurementDefsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> projectId,
      Value<String> name,
      Value<String> kind,
      Value<String> scope,
      Value<String> unit,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<String> choices,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MeasurementDefsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementDefsTable, MeasurementDef> {
  $$MeasurementDefsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('measurement_defs__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MeasurementValuesTable, List<MeasurementValue>>
  _measurementValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementValues,
        aliasName: 'measurement_defs__id__measurement_values__def_id',
      );

  $$MeasurementValuesTableProcessedTableManager get measurementValuesRefs {
    final manager = $$MeasurementValuesTableTableManager(
      $_db,
      $_db.measurementValues,
    ).filter((f) => f.defId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementDefsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementDefsTable> {
  $$MeasurementDefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choices => $composableBuilder(
    column: $table.choices,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> measurementValuesRefs(
    Expression<bool> Function($$MeasurementValuesTableFilterComposer f) f,
  ) {
    final $$MeasurementValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementValues,
      getReferencedColumn: (t) => t.defId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementValuesTableFilterComposer(
            $db: $db,
            $table: $db.measurementValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementDefsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementDefsTable> {
  $$MeasurementDefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choices => $composableBuilder(
    column: $table.choices,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementDefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementDefsTable> {
  $$MeasurementDefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<String> get choices =>
      $composableBuilder(column: $table.choices, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> measurementValuesRefs<T extends Object>(
    Expression<T> Function($$MeasurementValuesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementValues,
          getReferencedColumn: (t) => t.defId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementDefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementDefsTable,
          MeasurementDef,
          $$MeasurementDefsTableFilterComposer,
          $$MeasurementDefsTableOrderingComposer,
          $$MeasurementDefsTableAnnotationComposer,
          $$MeasurementDefsTableCreateCompanionBuilder,
          $$MeasurementDefsTableUpdateCompanionBuilder,
          (MeasurementDef, $$MeasurementDefsTableReferences),
          MeasurementDef,
          PrefetchHooks Function({bool projectId, bool measurementValuesRefs})
        > {
  $$MeasurementDefsTableTableManager(
    _$AppDatabase db,
    $MeasurementDefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementDefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementDefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementDefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<String> choices = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementDefsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                name: name,
                kind: kind,
                scope: scope,
                unit: unit,
                minValue: minValue,
                maxValue: maxValue,
                choices: choices,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String projectId,
                required String name,
                required String kind,
                required String scope,
                Value<String> unit = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<String> choices = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementDefsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                name: name,
                kind: kind,
                scope: scope,
                unit: unit,
                minValue: minValue,
                maxValue: maxValue,
                choices: choices,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementDefsTable, MeasurementDef>(table),
                  $$MeasurementDefsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, measurementValuesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (measurementValuesRefs) db.measurementValues,
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
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$MeasurementDefsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$MeasurementDefsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (measurementValuesRefs)
                        await $_getPrefetchedDataByColumns<
                          MeasurementDef,
                          $MeasurementDefsTable,
                          MeasurementValue,
                          $MeasurementValuesTable
                        >(
                          currentTable: table,
                          referencedTable: $$MeasurementDefsTableReferences
                              ._measurementValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MeasurementDefsTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementValuesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'def_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MeasurementDefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementDefsTable,
      MeasurementDef,
      $$MeasurementDefsTableFilterComposer,
      $$MeasurementDefsTableOrderingComposer,
      $$MeasurementDefsTableAnnotationComposer,
      $$MeasurementDefsTableCreateCompanionBuilder,
      $$MeasurementDefsTableUpdateCompanionBuilder,
      (MeasurementDef, $$MeasurementDefsTableReferences),
      MeasurementDef,
      PrefetchHooks Function({bool projectId, bool measurementValuesRefs})
    >;
typedef $$MeasurementValuesTableCreateCompanionBuilder =
    MeasurementValuesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String defId,
      Value<String?> observationId,
      Value<String?> seasonId,
      Value<String?> varietyId,
      Value<double?> valueNum,
      Value<String?> valueText,
      Value<int> rowid,
    });
typedef $$MeasurementValuesTableUpdateCompanionBuilder =
    MeasurementValuesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> defId,
      Value<String?> observationId,
      Value<String?> seasonId,
      Value<String?> varietyId,
      Value<double?> valueNum,
      Value<String?> valueText,
      Value<int> rowid,
    });

final class $$MeasurementValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementValuesTable,
          MeasurementValue
        > {
  $$MeasurementValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementDefsTable _defIdTable(_$AppDatabase db) => db
      .measurementDefs
      .createAlias('measurement_values__def_id__measurement_defs__id');

  $$MeasurementDefsTableProcessedTableManager get defId {
    final $_column = $_itemColumn<String>('def_id')!;

    final manager = $$MeasurementDefsTableTableManager(
      $_db,
      $_db.measurementDefs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObservationsTable _observationIdTable(_$AppDatabase db) => db
      .observations
      .createAlias('measurement_values__observation_id__observations__id');

  $$ObservationsTableProcessedTableManager? get observationId {
    final $_column = $_itemColumn<String>('observation_id');
    if ($_column == null) return null;
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SeasonsTable _seasonIdTable(_$AppDatabase db) =>
      db.seasons.createAlias('measurement_values__season_id__seasons__id');

  $$SeasonsTableProcessedTableManager? get seasonId {
    final $_column = $_itemColumn<String>('season_id');
    if ($_column == null) return null;
    final manager = $$SeasonsTableTableManager(
      $_db,
      $_db.seasons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seasonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VarietiesTable _varietyIdTable(_$AppDatabase db) =>
      db.varieties.createAlias('measurement_values__variety_id__varieties__id');

  $$VarietiesTableProcessedTableManager? get varietyId {
    final $_column = $_itemColumn<String>('variety_id');
    if ($_column == null) return null;
    final manager = $$VarietiesTableTableManager(
      $_db,
      $_db.varieties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_varietyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementValuesTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueNum => $composableBuilder(
    column: $table.valueNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementDefsTableFilterComposer get defId {
    final $$MeasurementDefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defId,
      referencedTable: $db.measurementDefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementDefsTableFilterComposer(
            $db: $db,
            $table: $db.measurementDefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeasonsTableFilterComposer get seasonId {
    final $$SeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableFilterComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableFilterComposer get varietyId {
    final $$VarietiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableFilterComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueNum => $composableBuilder(
    column: $table.valueNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementDefsTableOrderingComposer get defId {
    final $$MeasurementDefsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defId,
      referencedTable: $db.measurementDefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementDefsTableOrderingComposer(
            $db: $db,
            $table: $db.measurementDefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeasonsTableOrderingComposer get seasonId {
    final $$SeasonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableOrderingComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableOrderingComposer get varietyId {
    final $$VarietiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableOrderingComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<double> get valueNum =>
      $composableBuilder(column: $table.valueNum, builder: (column) => column);

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  $$MeasurementDefsTableAnnotationComposer get defId {
    final $$MeasurementDefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defId,
      referencedTable: $db.measurementDefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementDefsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementDefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeasonsTableAnnotationComposer get seasonId {
    final $$SeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seasonId,
      referencedTable: $db.seasons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.seasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VarietiesTableAnnotationComposer get varietyId {
    final $$VarietiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.varietyId,
      referencedTable: $db.varieties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VarietiesTableAnnotationComposer(
            $db: $db,
            $table: $db.varieties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementValuesTable,
          MeasurementValue,
          $$MeasurementValuesTableFilterComposer,
          $$MeasurementValuesTableOrderingComposer,
          $$MeasurementValuesTableAnnotationComposer,
          $$MeasurementValuesTableCreateCompanionBuilder,
          $$MeasurementValuesTableUpdateCompanionBuilder,
          (MeasurementValue, $$MeasurementValuesTableReferences),
          MeasurementValue,
          PrefetchHooks Function({
            bool defId,
            bool observationId,
            bool seasonId,
            bool varietyId,
          })
        > {
  $$MeasurementValuesTableTableManager(
    _$AppDatabase db,
    $MeasurementValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> defId = const Value.absent(),
                Value<String?> observationId = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<String?> varietyId = const Value.absent(),
                Value<double?> valueNum = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementValuesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                defId: defId,
                observationId: observationId,
                seasonId: seasonId,
                varietyId: varietyId,
                valueNum: valueNum,
                valueText: valueText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String defId,
                Value<String?> observationId = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<String?> varietyId = const Value.absent(),
                Value<double?> valueNum = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementValuesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                defId: defId,
                observationId: observationId,
                seasonId: seasonId,
                varietyId: varietyId,
                valueNum: valueNum,
                valueText: valueText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementValuesTable, MeasurementValue>(table),
                  $$MeasurementValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                defId = false,
                observationId = false,
                seasonId = false,
                varietyId = false,
              }) {
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
                        if (defId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.defId,
                            referencedTable: $$MeasurementValuesTableReferences
                                ._defIdTable(db),
                            referencedColumn: $$MeasurementValuesTableReferences
                                ._defIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (observationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.observationId,
                            referencedTable: $$MeasurementValuesTableReferences
                                ._observationIdTable(db),
                            referencedColumn: $$MeasurementValuesTableReferences
                                ._observationIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (seasonId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seasonId,
                            referencedTable: $$MeasurementValuesTableReferences
                                ._seasonIdTable(db),
                            referencedColumn: $$MeasurementValuesTableReferences
                                ._seasonIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (varietyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.varietyId,
                            referencedTable: $$MeasurementValuesTableReferences
                                ._varietyIdTable(db),
                            referencedColumn: $$MeasurementValuesTableReferences
                                ._varietyIdTable(db)
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

typedef $$MeasurementValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementValuesTable,
      MeasurementValue,
      $$MeasurementValuesTableFilterComposer,
      $$MeasurementValuesTableOrderingComposer,
      $$MeasurementValuesTableAnnotationComposer,
      $$MeasurementValuesTableCreateCompanionBuilder,
      $$MeasurementValuesTableUpdateCompanionBuilder,
      (MeasurementValue, $$MeasurementValuesTableReferences),
      MeasurementValue,
      PrefetchHooks Function({
        bool defId,
        bool observationId,
        bool seasonId,
        bool varietyId,
      })
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> seq,
  required String tbl,
  required String rowId,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> seq,
  Value<String> tbl,
  Value<String> rowId,
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
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get tbl =>
      $composableBuilder(column: $table.tbl, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          OutboxEntry,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> seq = const Value.absent(),
            Value<String> tbl = const Value.absent(),
            Value<String> rowId = const Value.absent(),
          }) => SyncOutboxCompanion(seq: seq, tbl: tbl, rowId: rowId),
          createCompanionCallback: ({
            Value<int> seq = const Value.absent(),
            required String tbl,
            required String rowId,
          }) => SyncOutboxCompanion.insert(seq: seq, tbl: tbl, rowId: rowId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, OutboxEntry>(table),
                  BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxEntry>(
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

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      OutboxEntry,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
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

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
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

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
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

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaEntry,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaEntry,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaEntry>,
          ),
          SyncMetaEntry,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SyncMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetaTable, SyncMetaEntry>(table),
                  BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaEntry>(
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

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaEntry,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaEntry,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaEntry>,
      ),
      SyncMetaEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db, _db.crops);
  $$PhenoScalesTableTableManager get phenoScales =>
      $$PhenoScalesTableTableManager(_db, _db.phenoScales);
  $$PhenoMacrosTableTableManager get phenoMacros =>
      $$PhenoMacrosTableTableManager(_db, _db.phenoMacros);
  $$PhenoStagesTableTableManager get phenoStages =>
      $$PhenoStagesTableTableManager(_db, _db.phenoStages);
  $$VarietiesTableTableManager get varieties =>
      $$VarietiesTableTableManager(_db, _db.varieties);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$SeasonsTableTableManager get seasons =>
      $$SeasonsTableTableManager(_db, _db.seasons);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$WeekStatusesTableTableManager get weekStatuses =>
      $$WeekStatusesTableTableManager(_db, _db.weekStatuses);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$MeasurementDefsTableTableManager get measurementDefs =>
      $$MeasurementDefsTableTableManager(_db, _db.measurementDefs);
  $$MeasurementValuesTableTableManager get measurementValues =>
      $$MeasurementValuesTableTableManager(_db, _db.measurementValues);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
