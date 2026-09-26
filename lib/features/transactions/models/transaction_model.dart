import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'transaction_model.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  RealColumn get fee => real().nullable()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  TextColumn get sourceAccount => text().nullable()();
  TextColumn get destinationAccount => text().nullable()();
  TextColumn get labels => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get note => text().nullable()();
}

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Labels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DriftDatabase(tables: [Transactions, Accounts, Labels])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'transactions_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
