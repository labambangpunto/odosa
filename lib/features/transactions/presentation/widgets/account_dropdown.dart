import 'package:flutter/material.dart';

class AccountDropdown extends StatelessWidget {
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

  Future<List<String>> _getAccountsFromDb() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simulasi delay DB
    return ['BCA', 'Mandiri', 'Gopay', 'OVO', 'Kas Tunai'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getAccountsFromDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          );
        }

        final List<String> accounts = snapshot.data ?? [];

        return DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: accounts.map((account) {
            return DropdownMenuItem(value: account, child: Text(account));
          }).toList(),
          onChanged: onChanged,
          validator:
              validator ??
              (val) => val == null || val.isEmpty ? 'Pilih $label' : null,
        );
      },
    );
  }
}
