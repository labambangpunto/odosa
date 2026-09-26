// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryAccountMeta = const VerificationMeta(
    'primaryAccount',
  );
  @override
  late final GeneratedColumn<String> primaryAccount = GeneratedColumn<String>(
    'primary_account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _settlementAccountMeta = const VerificationMeta(
    'settlementAccount',
  );
  @override
  late final GeneratedColumn<String> settlementAccount =
      GeneratedColumn<String>(
        'settlement_account',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _settlementDateMeta = const VerificationMeta(
    'settlementDate',
  );
  @override
  late final GeneratedColumn<DateTime> settlementDate =
      GeneratedColumn<DateTime>(
        'settlement_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    contact,
    primaryAccount,
    labels,
    transactionDate,
    dueDate,
    note,
    isSettled,
    settlementAccount,
    settlementDate,
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    } else if (isInserting) {
      context.missing(_contactMeta);
    }
    if (data.containsKey('primary_account')) {
      context.handle(
        _primaryAccountMeta,
        primaryAccount.isAcceptableOrUnknown(
          data['primary_account']!,
          _primaryAccountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryAccountMeta);
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('settlement_account')) {
      context.handle(
        _settlementAccountMeta,
        settlementAccount.isAcceptableOrUnknown(
          data['settlement_account']!,
          _settlementAccountMeta,
        ),
      );
    }
    if (data.containsKey('settlement_date')) {
      context.handle(
        _settlementDateMeta,
        settlementDate.isAcceptableOrUnknown(
          data['settlement_date']!,
          _settlementDateMeta,
        ),
      );
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
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      )!,
      primaryAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_account'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      settlementAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_account'],
      ),
      settlementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settlement_date'],
      ),
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final String type;
  final double amount;
  final String contact;
  final String primaryAccount;
  final String? labels;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final String note;
  final bool isSettled;
  final String? settlementAccount;
  final DateTime? settlementDate;
  const Debt({
    required this.id,
    required this.type,
    required this.amount,
    required this.contact,
    required this.primaryAccount,
    this.labels,
    required this.transactionDate,
    this.dueDate,
    required this.note,
    required this.isSettled,
    this.settlementAccount,
    this.settlementDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['contact'] = Variable<String>(contact);
    map['primary_account'] = Variable<String>(primaryAccount);
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['note'] = Variable<String>(note);
    map['is_settled'] = Variable<bool>(isSettled);
    if (!nullToAbsent || settlementAccount != null) {
      map['settlement_account'] = Variable<String>(settlementAccount);
    }
    if (!nullToAbsent || settlementDate != null) {
      map['settlement_date'] = Variable<DateTime>(settlementDate);
    }
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      contact: Value(contact),
      primaryAccount: Value(primaryAccount),
      labels: labels == null && nullToAbsent
          ? const Value.absent()
          : Value(labels),
      transactionDate: Value(transactionDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      note: Value(note),
      isSettled: Value(isSettled),
      settlementAccount: settlementAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementAccount),
      settlementDate: settlementDate == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementDate),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      contact: serializer.fromJson<String>(json['contact']),
      primaryAccount: serializer.fromJson<String>(json['primaryAccount']),
      labels: serializer.fromJson<String?>(json['labels']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      note: serializer.fromJson<String>(json['note']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      settlementAccount: serializer.fromJson<String?>(
        json['settlementAccount'],
      ),
      settlementDate: serializer.fromJson<DateTime?>(json['settlementDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'contact': serializer.toJson<String>(contact),
      'primaryAccount': serializer.toJson<String>(primaryAccount),
      'labels': serializer.toJson<String?>(labels),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'note': serializer.toJson<String>(note),
      'isSettled': serializer.toJson<bool>(isSettled),
      'settlementAccount': serializer.toJson<String?>(settlementAccount),
      'settlementDate': serializer.toJson<DateTime?>(settlementDate),
    };
  }

  Debt copyWith({
    int? id,
    String? type,
    double? amount,
    String? contact,
    String? primaryAccount,
    Value<String?> labels = const Value.absent(),
    DateTime? transactionDate,
    Value<DateTime?> dueDate = const Value.absent(),
    String? note,
    bool? isSettled,
    Value<String?> settlementAccount = const Value.absent(),
    Value<DateTime?> settlementDate = const Value.absent(),
  }) => Debt(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    contact: contact ?? this.contact,
    primaryAccount: primaryAccount ?? this.primaryAccount,
    labels: labels.present ? labels.value : this.labels,
    transactionDate: transactionDate ?? this.transactionDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    note: note ?? this.note,
    isSettled: isSettled ?? this.isSettled,
    settlementAccount: settlementAccount.present
        ? settlementAccount.value
        : this.settlementAccount,
    settlementDate: settlementDate.present
        ? settlementDate.value
        : this.settlementDate,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      contact: data.contact.present ? data.contact.value : this.contact,
      primaryAccount: data.primaryAccount.present
          ? data.primaryAccount.value
          : this.primaryAccount,
      labels: data.labels.present ? data.labels.value : this.labels,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      settlementAccount: data.settlementAccount.present
          ? data.settlementAccount.value
          : this.settlementAccount,
      settlementDate: data.settlementDate.present
          ? data.settlementDate.value
          : this.settlementDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('contact: $contact, ')
          ..write('primaryAccount: $primaryAccount, ')
          ..write('labels: $labels, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('isSettled: $isSettled, ')
          ..write('settlementAccount: $settlementAccount, ')
          ..write('settlementDate: $settlementDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    contact,
    primaryAccount,
    labels,
    transactionDate,
    dueDate,
    note,
    isSettled,
    settlementAccount,
    settlementDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.contact == this.contact &&
          other.primaryAccount == this.primaryAccount &&
          other.labels == this.labels &&
          other.transactionDate == this.transactionDate &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.isSettled == this.isSettled &&
          other.settlementAccount == this.settlementAccount &&
          other.settlementDate == this.settlementDate);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> contact;
  final Value<String> primaryAccount;
  final Value<String?> labels;
  final Value<DateTime> transactionDate;
  final Value<DateTime?> dueDate;
  final Value<String> note;
  final Value<bool> isSettled;
  final Value<String?> settlementAccount;
  final Value<DateTime?> settlementDate;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.contact = const Value.absent(),
    this.primaryAccount = const Value.absent(),
    this.labels = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settlementAccount = const Value.absent(),
    this.settlementDate = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required double amount,
    required String contact,
    required String primaryAccount,
    this.labels = const Value.absent(),
    required DateTime transactionDate,
    this.dueDate = const Value.absent(),
    required String note,
    this.isSettled = const Value.absent(),
    this.settlementAccount = const Value.absent(),
    this.settlementDate = const Value.absent(),
  }) : type = Value(type),
       amount = Value(amount),
       contact = Value(contact),
       primaryAccount = Value(primaryAccount),
       transactionDate = Value(transactionDate),
       note = Value(note);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? contact,
    Expression<String>? primaryAccount,
    Expression<String>? labels,
    Expression<DateTime>? transactionDate,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<bool>? isSettled,
    Expression<String>? settlementAccount,
    Expression<DateTime>? settlementDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (contact != null) 'contact': contact,
      if (primaryAccount != null) 'primary_account': primaryAccount,
      if (labels != null) 'labels': labels,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (isSettled != null) 'is_settled': isSettled,
      if (settlementAccount != null) 'settlement_account': settlementAccount,
      if (settlementDate != null) 'settlement_date': settlementDate,
    });
  }

  DebtsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? contact,
    Value<String>? primaryAccount,
    Value<String?>? labels,
    Value<DateTime>? transactionDate,
    Value<DateTime?>? dueDate,
    Value<String>? note,
    Value<bool>? isSettled,
    Value<String?>? settlementAccount,
    Value<DateTime?>? settlementDate,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      contact: contact ?? this.contact,
      primaryAccount: primaryAccount ?? this.primaryAccount,
      labels: labels ?? this.labels,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      settlementAccount: settlementAccount ?? this.settlementAccount,
      settlementDate: settlementDate ?? this.settlementDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (primaryAccount.present) {
      map['primary_account'] = Variable<String>(primaryAccount.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (settlementAccount.present) {
      map['settlement_account'] = Variable<String>(settlementAccount.value);
    }
    if (settlementDate.present) {
      map['settlement_date'] = Variable<DateTime>(settlementDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('contact: $contact, ')
          ..write('primaryAccount: $primaryAccount, ')
          ..write('labels: $labels, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('isSettled: $isSettled, ')
          ..write('settlementAccount: $settlementAccount, ')
          ..write('settlementDate: $settlementDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$DebtDatabase extends GeneratedDatabase {
  _$DebtDatabase(QueryExecutor e) : super(e);
  $DebtDatabaseManager get managers => $DebtDatabaseManager(this);
  late final $DebtsTable debts = $DebtsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [debts];
}

typedef $$DebtsTableCreateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  required String type,
  required double amount,
  required String contact,
  required String primaryAccount,
  Value<String?> labels,
  required DateTime transactionDate,
  Value<DateTime?> dueDate,
  required String note,
  Value<bool> isSettled,
  Value<String?> settlementAccount,
  Value<DateTime?> settlementDate,
});
typedef $$DebtsTableUpdateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<double> amount,
  Value<String> contact,
  Value<String> primaryAccount,
  Value<String?> labels,
  Value<DateTime> transactionDate,
  Value<DateTime?> dueDate,
  Value<String> note,
  Value<bool> isSettled,
  Value<String?> settlementAccount,
  Value<DateTime?> settlementDate,
});

class $$DebtsTableFilterComposer extends Composer<_$DebtDatabase, $DebtsTable> {
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryAccount => $composableBuilder(
    column: $table.primaryAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementAccount => $composableBuilder(
    column: $table.settlementAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$DebtDatabase, $DebtsTable> {
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryAccount => $composableBuilder(
    column: $table.primaryAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementAccount => $composableBuilder(
    column: $table.settlementAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$DebtDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get primaryAccount => $composableBuilder(
    column: $table.primaryAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<String> get settlementAccount => $composableBuilder(
    column: $table.settlementAccount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => column,
  );
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$DebtDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$DebtDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$DebtDatabase db, $DebtsTable table)
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
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> contact = const Value.absent(),
                Value<String> primaryAccount = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<String?> settlementAccount = const Value.absent(),
                Value<DateTime?> settlementDate = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                type: type,
                amount: amount,
                contact: contact,
                primaryAccount: primaryAccount,
                labels: labels,
                transactionDate: transactionDate,
                dueDate: dueDate,
                note: note,
                isSettled: isSettled,
                settlementAccount: settlementAccount,
                settlementDate: settlementDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required double amount,
                required String contact,
                required String primaryAccount,
                Value<String?> labels = const Value.absent(),
                required DateTime transactionDate,
                Value<DateTime?> dueDate = const Value.absent(),
                required String note,
                Value<bool> isSettled = const Value.absent(),
                Value<String?> settlementAccount = const Value.absent(),
                Value<DateTime?> settlementDate = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                contact: contact,
                primaryAccount: primaryAccount,
                labels: labels,
                transactionDate: transactionDate,
                dueDate: dueDate,
                note: note,
                isSettled: isSettled,
                settlementAccount: settlementAccount,
                settlementDate: settlementDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebtsTable, Debt>(table),
                  BaseReferences<_$DebtDatabase, $DebtsTable, Debt>(
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
      _$DebtDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$DebtDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;

class $DebtDatabaseManager {
  final _$DebtDatabase _db;
  $DebtDatabaseManager(this._db);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
}
