import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

import '../../../transactions/models/transaction_model.dart';

class ManageAccountsPage extends StatefulWidget {
  const ManageAccountsPage({super.key});

  @override
  State<ManageAccountsPage> createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
  }

  void _showFormDialog({Account? account}) {
    final nameController = TextEditingController(text: account?.name);
    final balanceController = TextEditingController(
      text: account?.initialBalance.toStringAsFixed(0) ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Tambah Akun' : 'Edit Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Akun'),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              decoration: const InputDecoration(
                labelText: 'Saldo Awal (Rp)',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final balance =
                  double.tryParse(balanceController.text.trim()) ?? 0.0;

              if (name.isNotEmpty) {
                // Cek duplikasi nama
                final existing = await (_db.select(
                  _db.accounts,
                )..where((a) => a.name.equals(name))).getSingleOrNull();
                if (existing != null &&
                    (account == null || existing.id != account.id)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama akun sudah digunakan!'),
                      ),
                    );
                  }
                  return; // Hentikan proses simpan
                }

                if (account == null) {
                  await _db
                      .into(_db.accounts)
                      .insert(
                        AccountsCompanion.insert(
                          name: name,
                          initialBalance: drift.Value(balance),
                        ),
                      );
                } else {
                  await (_db.update(
                    _db.accounts,
                  )..where((a) => a.id.equals(account.id))).write(
                    AccountsCompanion(
                      name: drift.Value(name),
                      initialBalance: drift.Value(balance),
                    ),
                  );
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(int id) async {
    await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<List<Account>>(
        stream: _db.select(_db.accounts).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snapshot.data ?? [];

          if (accounts.isEmpty) {
            return const Center(child: Text('Belum ada akun terdaftar.'));
          }

          return ListView.separated(
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final account = accounts[index];

              // Widget StreamBuilder bersarang untuk memantau kalkulasi saldo per akun
              return StreamBuilder<double>(
                stream: _db.watchAccountBalance(
                  account.name,
                  account.initialBalance,
                ),
                builder: (context, balanceSnapshot) {
                  final currentBalance =
                      balanceSnapshot.data ?? account.initialBalance;
                  final isNegative = currentBalance < 0;

                  return ListTile(
                    title: Text(
                      account.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Saldo: Rp ${NumberFormat('#,###').format(currentBalance)}',
                      style: TextStyle(
                        color: isNegative ? Colors.red : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showFormDialog(account: account),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteAccount(account.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
