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
  RealColumn get initialBalance =>
      real().withDefault(const Constant(0.0))(); // Tambahan Saldo Awal
}

class Labels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

// Tabel Debts dipindahkan ke sini
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get contact => text()();
  TextColumn get primaryAccount => text()();
  TextColumn get labels => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text()();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  TextColumn get settlementAccount => text().nullable()();
  DateTimeColumn get settlementDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Transactions, Accounts, Labels, Debts])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Naikkan versi skema

  // Fungsi kalkulasi saldo real-time (Membaca dari Transactions & Debts)
  Stream<double> watchAccountBalance(
    String accountName,
    double initialBalance,
  ) {
    return customSelect(
      '''
      SELECT 
        ? +
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'income' AND destination_account = ?) -
        (SELECT COALESCE(SUM((amount * qty) + IFNULL(fee, 0)), 0) FROM transactions WHERE type = 'expense' AND source_account = ?) -
        (SELECT COALESCE(SUM(amount + IFNULL(fee, 0)), 0) FROM transactions WHERE type = 'transfer' AND source_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'transfer' AND destination_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'payable' AND primary_account = ?) -
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'receivable' AND primary_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'receivable' AND is_settled = 1 AND settlement_account = ?) -
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'payable' AND is_settled = 1 AND settlement_account = ?)
      AS current_balance
      ''',
      variables: [
        Variable.withReal(initialBalance),
        Variable.withString(accountName), // Income
        Variable.withString(accountName), // Expense (dikurangi qty & fee)
        Variable.withString(accountName), // Transfer Keluar (dikurangi fee)
        Variable.withString(accountName), // Transfer Masuk
        Variable.withString(accountName), // Utang Masuk
        Variable.withString(accountName), // Piutang Keluar
        Variable.withString(accountName), // Pelunasan Piutang Masuk
        Variable.withString(accountName), // Pelunasan Utang Keluar
      ],
      readsFrom: {
        transactions,
        debts,
      }, // Bereaksi otomatis jika ada perubahan di dua tabel ini
    ).watchSingle().map((row) => row.read<double>('current_balance'));
  }

  // Tambahkan fungsi ini di dalam class AppDatabase
  Future<double> getCalculatedBalance(String accountName) async {
    final account = await (select(
      accounts,
    )..where((a) => a.name.equals(accountName))).getSingleOrNull();
    if (account == null) return 0.0;

    final row = await customSelect(
      '''
      SELECT 
        ? +
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'income' AND destination_account = ?) -
        (SELECT COALESCE(SUM((amount * qty) + IFNULL(fee, 0)), 0) FROM transactions WHERE type = 'expense' AND source_account = ?) -
        (SELECT COALESCE(SUM(amount + IFNULL(fee, 0)), 0) FROM transactions WHERE type = 'transfer' AND source_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'transfer' AND destination_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'payable' AND primary_account = ?) -
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'receivable' AND primary_account = ?) +
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'receivable' AND is_settled = 1 AND settlement_account = ?) -
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE type = 'payable' AND is_settled = 1 AND settlement_account = ?)
      AS current_balance
      ''',
      variables: [
        Variable.withReal(account.initialBalance),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
        Variable.withString(accountName),
      ],
    ).getSingle();
    return row.read<double>('current_balance');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'transactions_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
