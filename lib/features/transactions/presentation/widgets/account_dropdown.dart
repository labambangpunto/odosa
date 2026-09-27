import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../models/transaction_model.dart';

class AccountDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const AccountDropdown({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  State<AccountDropdown> createState() => _AccountDropdownState();
}

class _AccountDropdownState extends State<AccountDropdown> {
  late Future<List<String>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _getAccountsFromDb();
  }

  Future<List<String>> _getAccountsFromDb() async {
    final db = AppDatabase();
    final accounts = await db.select(db.accounts).get();
    return accounts.map((a) => a.name).toList();
  }

  Future<String?> _showAddAccountDialog() async {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Akun Baru'),
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
                final db = AppDatabase();
                final existing = await (db.select(
                  db.accounts,
                )..where((a) => a.name.equals(name))).getSingleOrNull();

                if (existing != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama akun sudah digunakan!'),
                      ),
                    );
                  }
                  return;
                }

                await db
                    .into(db.accounts)
                    .insert(
                      AccountsCompanion.insert(
                        name: name,
                        initialBalance: drift.Value(balance),
                      ),
                    );

                if (context.mounted) Navigator.pop(context, name);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _accountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          );
        }

        final List<String> accounts = snapshot.data ?? [];

        // Pastikan nilai awal ada di dalam daftar akun, jika tidak set menjadi null
        String? currentValue = widget.value;
        if (currentValue != null && !accounts.contains(currentValue)) {
          currentValue = null;
        }

        final items = accounts.map((account) {
          return DropdownMenuItem(value: account, child: Text(account));
        }).toList();

        items.add(
          const DropdownMenuItem(
            value: '__CREATE_NEW__',
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Buat akun...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

        return DropdownButtonFormField<String>(
          initialValue: currentValue,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items,
          onChanged: (val) async {
            if (val == '__CREATE_NEW__') {
              final newAccount = await _showAddAccountDialog();
              if (newAccount != null) {
                setState(() {
                  _accountsFuture = _getAccountsFromDb();
                });
                widget.onChanged(newAccount);
              } else {
                // Trigger rebuild agar tampilan dropdown kembali ke widget.value yang valid jika dialog dibatalkan
                setState(() {});
              }
            } else {
              widget.onChanged(val);
            }
          },
          validator:
              widget.validator ??
              (val) => val == null || val.isEmpty || val == '__CREATE_NEW__'
                  ? 'Pilih ${widget.label}'
                  : null,
        );
      },
    );
  }
}
