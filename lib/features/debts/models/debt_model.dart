import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'debt_model.g.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type =>
      text()(); // 'receivable' (Piutang) atau 'payable' (Utang)
  RealColumn get amount => real()();
  TextColumn get contact => text()();
  TextColumn get primaryAccount =>
      text()(); // Akun sumber (Piutang) atau Akun tujuan (Utang)
  TextColumn get labels =>
      text().nullable()(); // Disimpan dalam format comma-separated
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text()();

  // Status dan Pelunasan
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  TextColumn get settlementAccount => text().nullable()(); // Akun penerima (Piutang) atau Akun sumber (Utang) pelunasan
  DateTimeColumn get settlementDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Debts])
class DebtDatabase extends _$DebtDatabase {
  DebtDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'debts_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
