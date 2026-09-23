import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../providers/sync_provider.dart';
import '../../providers/export_provider.dart';
import 'transaction_form_screen.dart';
import 'debt_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsyncValue = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dompet/Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt),
            tooltip: 'Utang & Piutang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Ekspor ke CSV',
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Mengekspor data...')),
              );

              try {
                final exportService = ref.read(exportServiceProvider);
                final filePath = await exportService.exportTransactionsToCSV();

                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Berhasil diekspor ke: $filePath')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Ekspor gagal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Sinkronisasi Google Drive',
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Memulai sinkronisasi...')),
              );

              try {
                final syncService = ref.read(syncServiceProvider);
                await syncService.syncDatabaseToGoogleDrive();

                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Sinkronisasi berhasil.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Sinkronisasi gagal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: accountsAsyncValue.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('Belum ada data. Silakan tambah dompet/bank.'),
            );
          }
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.account_balance_wallet),
                ),
                title: Text(account.name),
                trailing: Text(
                  'Rp ${account.balance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionHistoryScreen(account: account),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Terjadi kesalahan: $error')),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_account',
            onPressed: () => _showAddAccountDialog(context, ref),
            child: const Icon(Icons.account_balance_wallet),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_transaction',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionFormScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Dompet/Bank Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama (mis. BCA, Dompet Utama)',
              ),
              autofocus: true,
            ),
            TextField(
              controller: balanceController,
              decoration: const InputDecoration(labelText: 'Saldo Awal'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0.0;

              if (name.isNotEmpty) {
                ref.read(accountRepositoryProvider).addAccount(name, balance);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
