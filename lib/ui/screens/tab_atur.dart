import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/theme_provider.dart';
import '../../core/database/database_helper.dart';
import '../../controllers/master_data_provider.dart';
import '../../controllers/utang_piutang_provider.dart';
import '../../core/utils/backup_restore_service.dart';
import '../../controllers/auth_provider.dart';
import 'form_edit_profil.dart';
import 'form_tambah_akun.dart';
import 'form_tambah_label.dart';

class TabAtur extends ConsumerWidget {
  const TabAtur({super.key});

  void _prosesResetDatabase(BuildContext context, WidgetRef ref) {
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
              _verifikasiTahapDua(context, ref);
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

  void _verifikasiTahapDua(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              if (textController.text == 'RESET') {
                await DatabaseHelper.instance.resetDatabase();

                // Refresh seluruh state management agar UI langsung kosong
                ref.read(akunListProvider.notifier).loadAkun();
                ref.read(labelListProvider.notifier).loadLabels();
                ref.read(transaksiListProvider.notifier).loadTransaksi();
                ref.read(utangPiutangListProvider.notifier).loadData();

                if (context.mounted) Navigator.pop(ctx2);
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

  void _tampilkanDialogBackupRestore(BuildContext context, WidgetRef ref) {
    final passphraseController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup / Restore JSON Terenkripsi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan Passphrase (Kunci Enkripsi):'),
            const SizedBox(height: 8),
            TextField(
              controller: passphraseController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Minimal 8 karakter disarankan',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final passphrase = passphraseController.text.trim();
              if (passphrase.isEmpty) return;
              Navigator.pop(ctx);

              final path = await BackupRestoreService.backupJSON(passphrase);
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Backup terenkripsi tersimpan di: $path'),
                  ),
                );
              }
            },
            child: const Text('Backup Lokal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final passphrase = passphraseController.text.trim();
              if (passphrase.isEmpty) return;
              Navigator.pop(ctx);

              final sukses = await BackupRestoreService.restoreJSON(passphrase);
              if (context.mounted) {
                if (sukses) {
                  ref.read(akunListProvider.notifier).loadAkun();
                  ref.read(labelListProvider.notifier).loadLabels();
                  ref.read(transaksiListProvider.notifier).loadTransaksi();
                  ref.read(utangPiutangListProvider.notifier).loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil di-restore')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal: Passphrase salah atau file rusak'),
                    ),
                  );
                }
              }
            },
            child: const Text('Restore Lokal'),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormEditProfil()),
            ),
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
                ref.read(themeProvider.notifier).state =
                    val ? ThemeMode.dark : ThemeMode.light;
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
            onTap: () => _tampilkanDialogBackupRestore(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Ekspor CSV'),
            onTap: () async {
              final path = await BackupRestoreService.exportCSV();
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV berhasil diekspor ke: $path')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text(
              'Danger Zone',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Reset seluruh database'),
            onTap: () => _prosesResetDatabase(context, ref),
          ),
          Consumer(
            builder: (context, ref, child) {
              final isLoggedIn = ref.watch(authProvider);
              return ListTile(
                leading: Icon(isLoggedIn ? Icons.cloud_done : Icons.cloud_off),
                title: Text(
                    isLoggedIn ? 'Logout Google Drive' : 'Login Google Drive'),
                subtitle: Text(isLoggedIn ? 'Terhubung' : 'Belum terhubung'),
                onTap: () async {
                  if (isLoggedIn) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil logout')));
                    }
                  } else {
                    await ref.read(authProvider.notifier).login();
                    final success = ref.read(authProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                success ? 'Berhasil login' : 'Gagal login')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
