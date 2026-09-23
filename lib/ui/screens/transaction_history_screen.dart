import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';
import '../../data/database/database.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  final Account account;

  const TransactionHistoryScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      accountTransactionsProvider(account.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Riwayat: ${account.name}')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('Belum ada transaksi di dompet/bank ini.'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];

              final isIncome =
                  t.type == 'INCOME' ||
                  (t.type == 'TRANSFER' && t.toAccountId == account.id);

              final iconColor = isIncome ? Colors.green : Colors.red;
              final icon = t.type == 'TRANSFER'
                  ? Icons.swap_horiz
                  : (isIncome ? Icons.arrow_downward : Icons.arrow_upward);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor),
                ),
                title: Text(t.type),
                subtitle: Text(
                  '${t.date.day}/${t.date.month}/${t.date.year} ${t.note != null && t.note!.isNotEmpty ? "- ${t.note}" : ""}',
                ),
                trailing: Text(
                  '${isIncome ? "+" : "-"} Rp ${t.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
