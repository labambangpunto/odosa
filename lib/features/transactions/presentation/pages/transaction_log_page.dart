import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../models/transaction_model.dart';

class TransactionLogPage extends StatefulWidget {
  const TransactionLogPage({super.key});

  @override
  State<TransactionLogPage> createState() => _TransactionLogPageState();
}

class _TransactionLogPageState extends State<TransactionLogPage> {
  final Logger _logger = Logger();
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    _logger.i('Mengambil log transaksi dari database Drift...');
    try {
      final query = _db.select(_db.transactions)
        ..orderBy([
          (t) => drift.OrderingTerm(
            expression: t.transactionDate,
            mode: drift.OrderingMode.desc,
          ),
        ]);

      final data = await query.get();
      _logger.d('Berhasil mengambil ${data.length} transaksi');
      return data;
    } catch (e) {
      _logger.e('Gagal melakukan query transaksi', error: e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat transaksi'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isIncome = tx.type == 'income';
              final isExpense = tx.type == 'expense';

              IconData icon;
              Color iconColor;
              String prefix = '';

              if (isIncome) {
                icon = Icons.arrow_downward;
                iconColor = Colors.green;
                prefix = '+';
              } else if (isExpense) {
                icon = Icons.arrow_upward;
                iconColor = Colors.red;
                prefix = '-';
              } else {
                icon = Icons.swap_horiz;
                iconColor = Colors.blue;
              }

              final title = tx.labels.isNotEmpty
                  ? tx.labels
                  : 'Transaksi ${isIncome
                        ? "Pemasukan"
                        : isExpense
                        ? "Pengeluaran"
                        : "Transfer"}';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor),
                ),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(tx.transactionDate),
                    ),
                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tx.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Text(
                  '$prefix Rp ${NumberFormat('#,###').format(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome
                        ? Colors.green
                        : (isExpense ? Colors.red : Colors.black),
                  ),
                ),
                isThreeLine: tx.note != null && tx.note!.isNotEmpty,
              );
            },
          );
        },
      ),
    );
  }
}
