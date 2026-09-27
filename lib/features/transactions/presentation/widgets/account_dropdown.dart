import 'package:flutter/material.dart';

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
    _accountsFuture = _getAccountsFromDb(); // Panggil hanya sekali di awal
  }

  Future<List<String>> _getAccountsFromDb() async {
    final db = AppDatabase();
    final accounts = await db.select(db.accounts).get();
    return accounts.map((a) => a.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _accountsFuture, // Gunakan variabel yang sudah di-cache
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          );
        }

        final List<String> accounts = snapshot.data ?? [];

        return DropdownButtonFormField<String>(
          initialValue: widget.value,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: accounts.map((account) {
            return DropdownMenuItem(value: account, child: Text(account));
          }).toList(),
          onChanged: widget.onChanged,
          validator:
              widget.validator ??
              (val) =>
                  val == null || val.isEmpty ? 'Pilih ${widget.label}' : null,
        );
      },
    );
  }
}
