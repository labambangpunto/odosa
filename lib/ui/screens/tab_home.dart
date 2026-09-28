import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/home_summary_provider.dart';
import '../../models/akun.dart';
import '../../controllers/profil_provider.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/backup_restore_service.dart';
import '../../core/services/google_drive_service.dart';
import '../../controllers/master_data_provider.dart';
import '../../controllers/utang_piutang_provider.dart';

class TabHome extends ConsumerWidget {
  const TabHome({super.key});
  void _prosesSinkronisasi(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.read(authProvider);
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Silakan login Google Drive di menu Atur terlebih dahulu.')));
      return;
    }

    final passphraseController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sinkronisasi Google Drive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan Passphrase untuk enkripsi/dekripsi:'),
            const SizedBox(height: 8),
            TextField(
              controller: passphraseController,
              obscureText: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final passphrase = passphraseController.text.trim();
              if (passphrase.isEmpty) return;
              Navigator.pop(ctx);

              // Alur Download
              final encryptedData = await GoogleDriveService.downloadBackup();
              if (encryptedData == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Tidak ada data backup di Google Drive.')));
                }
                return;
              }

              final sukses =
                  await BackupRestoreService.restoreFromEncryptedSync(
                      encryptedData, passphrase);
              if (context.mounted) {
                if (sukses) {
                  ref.read(akunListProvider.notifier).loadAkun();
                  ref.read(labelListProvider.notifier).loadLabels();
                  ref.read(transaksiListProvider.notifier).loadTransaksi();
                  ref.read(utangPiutangListProvider.notifier).loadData();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Sinkronisasi (Download) berhasil.')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Gagal: Passphrase salah atau data korup.')));
                }
              }
            },
            child: const Text('Download'),
          ),
          ElevatedButton(
            onPressed: () async {
              final passphrase = passphraseController.text.trim();
              if (passphrase.isEmpty) return;
              Navigator.pop(ctx);

              // Alur Upload
              final encryptedData =
                  await BackupRestoreService.getEncryptedBackupForSync(
                      passphrase);
              final sukses =
                  await GoogleDriveService.uploadBackup(encryptedData);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(sukses
                          ? 'Sinkronisasi (Upload) berhasil.'
                          : 'Gagal mengunggah data.')),
                );
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namaPengguna = ref.watch(profilProvider);
    final ringkasanBulanan = ref.watch(ringkasanBulananProvider);
    final dataSaldoAkun = ref.watch(saldoAkunProvider);

    double totalSaldo = 0;
    List<Map<String, dynamic>> daftarSaldo = [];

    if (dataSaldoAkun.isNotEmpty) {
      totalSaldo = dataSaldoAkun[0]['totalKeseluruhan'] as double;
      daftarSaldo = dataSaldoAkun.sublist(1);
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $namaPengguna!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Google Drive',
            onPressed: () => _prosesSinkronisasi(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Total Saldo Keseluruhan
          const Text('Total Saldo', style: TextStyle(fontSize: 16)),
          Text(
            currencyFormatter.format(totalSaldo),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Ringkasan Bulan Ini
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemasukan Bulan Ini',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          currencyFormatter.format(
                            ringkasanBulanan['pemasukan'],
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran Bulan Ini',
                          style: TextStyle(color: Colors.red),
                        ),
                        Text(
                          currencyFormatter.format(
                            ringkasanBulanan['pengeluaran'],
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Saldo Masing-Masing Akun
          const Text(
            'Saldo Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...daftarSaldo.map((item) {
            final Akun akun = item['akun'];
            final double saldo = item['saldo'];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(akun.nama),
                trailing: Text(
                  currencyFormatter.format(saldo),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Grafik & Analisis (Placeholder)
          const Text(
            'Grafik Bulan Ini',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: (ringkasanBulanan['pemasukan'] == 0 &&
                    ringkasanBulanan['pengeluaran'] == 0)
                ? const Center(
                    child: Text('Belum ada data transaksi bulan ini.'),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: ringkasanBulanan['pemasukan'],
                          title: 'In',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: ringkasanBulanan['pengeluaran'],
                          title: 'Out',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text('Area Grafik (fl_chart)'),
          ),
        ],
      ),
    );
  }
}
