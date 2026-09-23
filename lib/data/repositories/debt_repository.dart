import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../database/database.dart';
import '../../main.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DebtRepository(db);
});

class DebtRepository {
  final AppDatabase _db;

  DebtRepository(this._db);

  Stream<List<Debt>> watchAllDebts() {
    return _db.select(_db.debts).watch();
  }

  Stream<List<Debt>> watchUnsettledDebts() {
    return (_db.select(
      _db.debts,
    )..where((t) => t.isSettled.equals(false))).watch();
  }

  Future<int> addDebt({
    required String personName,
    required double amount,
    required String type, // 'PAYABLE' (Hutang), 'RECEIVABLE' (Piutang)
    DateTime? dueDate,
  }) {
    return _db
        .into(_db.debts)
        .insert(
          DebtsCompanion.insert(
            personName: personName,
            amount: amount,
            type: type,
            dueDate: drift.Value(dueDate),
          ),
        );
  }

  Future<void> markAsSettled(int debtId) async {
    final debt = await (_db.select(
      _db.debts,
    )..where((d) => d.id.equals(debtId))).getSingle();
    await _db.update(_db.debts).replace(debt.copyWith(isSettled: true));
  }
}
