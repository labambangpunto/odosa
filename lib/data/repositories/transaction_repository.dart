import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../database/database.dart';
import '../../main.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepository(db);
});

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  // Membaca riwayat transaksi secara reaktif
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(
      _db.transactions,
    )..orderBy([(t) => drift.OrderingTerm.desc(t.date)])).watch();
  }

  // Mencatat Pemasukan dan menambah saldo dompet/bank terkait
  Future<void> addIncome({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String? note,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: 'INCOME',
              amount: amount,
              toAccountId: drift.Value(accountId),
              categoryId: drift.Value(categoryId),
              date: date,
              note: drift.Value(note),
            ),
          );

      final account = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).getSingle();
      await _db
          .update(_db.accounts)
          .replace(account.copyWith(balance: account.balance + amount));
    });
  }

  // Mencatat Pengeluaran dan memotong saldo dompet/bank terkait
  Future<void> addExpense({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String? note,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: 'EXPENSE',
              amount: amount,
              fromAccountId: drift.Value(accountId),
              categoryId: drift.Value(categoryId),
              date: date,
              note: drift.Value(note),
            ),
          );

      final account = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).getSingle();
      await _db
          .update(_db.accounts)
          .replace(account.copyWith(balance: account.balance - amount));
    });
  }

  // Mencatat Mutasi antar rekening pribadi (potong saldo asal, tambah saldo tujuan)
  Future<void> addTransfer({
    required double amount,
    required int fromAccountId,
    required int toAccountId,
    required DateTime date,
    String? note,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: 'TRANSFER',
              amount: amount,
              fromAccountId: drift.Value(fromAccountId),
              toAccountId: drift.Value(toAccountId),
              date: date,
              note: drift.Value(note),
            ),
          );

      final fromAccount = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(fromAccountId))).getSingle();
      await _db
          .update(_db.accounts)
          .replace(fromAccount.copyWith(balance: fromAccount.balance - amount));

      final toAccount = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(toAccountId))).getSingle();
      await _db
          .update(_db.accounts)
          .replace(toAccount.copyWith(balance: toAccount.balance + amount));
    });
  }
}
