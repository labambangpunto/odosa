import 'package:flutter/material.dart';

import 'manage_accounts_page.dart';
import 'manage_labels_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text('Kelola Akun'),
            subtitle: const Text('Tambah, edit, atau hapus daftar akun'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageAccountsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.label_rounded),
            title: const Text('Kelola Label'),
            subtitle: const Text(
              'Tambah, edit, atau hapus daftar label/kategori',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageLabelsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
