import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../database/database.dart';
import '../../main.dart'; // Menyesuaikan lokasi databaseProvider Anda

// Provider untuk mengakses repository akun
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountRepository(db);
});

class AccountRepository {
  final AppDatabase _db;

  AccountRepository(this._db);

  // Membaca data secara reaktif (Stream) agar UI otomatis terupdate
  Stream<List<Account>> watchAllAccounts() {
    return _db.select(_db.accounts).watch();
  }

  // Menambah akun baru (Dompet/Bank)
  Future<int> addAccount(String name, double initialBalance) {
    return _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name,
            balance: drift.Value(initialBalance),
          ),
        );
  }
}
