import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

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
    final controller = TextEditingController(text: account?.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Tambah Akun' : 'Edit Akun'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Akun'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                if (account == null) {
                  await _db
                      .into(_db.accounts)
                      .insert(AccountsCompanion.insert(name: text));
                } else {
                  await (_db.update(_db.accounts)
                        ..where((a) => a.id.equals(account.id)))
                      .write(AccountsCompanion(name: drift.Value(text)));
                }
                // Koreksi context.mounted
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
              return ListTile(
                title: Text(account.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(account: account),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteAccount(account.id),
                    ),
                  ],
                ),
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
