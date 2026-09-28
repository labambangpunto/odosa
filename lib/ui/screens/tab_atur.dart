import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/theme_provider.dart';
import 'form_tambah_akun.dart';
import 'form_tambah_label.dart';

class TabAtur extends ConsumerWidget {
  const TabAtur({super.key});

  void _prosesResetDatabase(BuildContext context) {
    // Metode Verifikasi 1: Dialog Konfirmasi Biasa
    showDialog(
      context: context,
      builder: (ctx1) => AlertDialog(
        title: const Text('Peringatan Reset'),
        content: const Text(
          'Anda yakin ingin menghapus SELURUH data? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx1),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx1);
              // Metode Verifikasi 2: Mengetik kata sandi/konfirmasi teks
              _verifikasiTahapDua(context);
            },
            child: const Text(
              'Lanjutkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _verifikasiTahapDua(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx2) => AlertDialog(
        title: const Text('Verifikasi Final'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ketik "RESET" untuk mengonfirmasi penghapusan seluruh database.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (textController.text == 'RESET') {
                Navigator.pop(ctx2);
                // Logika eksekusi drop table & hapus file SQLite di sini
              }
            },
            child: const Text(
              'RESET DATABASE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profil'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Google Drive Login / Logout'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Mode Gelap / Terang'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).state = val
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Kelola Akun'),
            subtitle: const Text('Buat akun baru dan saldo awal'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormTambahAkun()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Kelola Label'),
            subtitle: const Text('Buat label transaksi baru'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormTambahLabel()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup / Restore JSON'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Ekspor CSV'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text(
              'Danger Zone',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Reset seluruh database'),
            onTap: () => _prosesResetDatabase(context),
          ),
        ],
      ),
    );
  }
}
