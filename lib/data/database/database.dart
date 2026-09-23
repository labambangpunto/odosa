import 'package:drift/drift.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Tabel Akun (Dompet/Bank)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
}

// Tabel Kategori/Tag
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type => text()(); // IN, OUT, TRANSFER
}

// Tabel Transaksi
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // INCOME, EXPENSE, TRANSFER
  RealColumn get amount => real()();
  IntColumn get fromAccountId =>
      integer().nullable().references(Accounts, #id)();
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
}

// Tabel Utang
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get personName => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // PAYABLE (Hutang), RECEIVABLE (Piutang)
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, Debts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
