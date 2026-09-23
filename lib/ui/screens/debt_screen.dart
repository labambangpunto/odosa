import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/debt_provider.dart';
import '../../data/repositories/debt_repository.dart';

class DebtScreen extends ConsumerWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Utang & Piutang')),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (debts) {
          if (debts.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan utang/piutang.'),
            );
          }
          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              final isPayable = debt.type == 'PAYABLE';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: debt.isSettled
                      ? Colors.grey
                      : (isPayable
                            ? Colors.red.shade100
                            : Colors.green.shade100),
                  child: Icon(
                    isPayable ? Icons.arrow_outward : Icons.arrow_downward,
                    color: debt.isSettled
                        ? Colors.white
                        : (isPayable ? Colors.red : Colors.green),
                  ),
                ),
                title: Text(
                  debt.personName,
                  style: TextStyle(
                    decoration: debt.isSettled
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  isPayable ? 'Saya berutang' : 'Pihak lain berutang',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rp ${debt.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (!debt.isSettled)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.blue,
                        ),
                        tooltip: 'Tandai Lunas',
                        onPressed: () {
                          ref
                              .read(debtRepositoryProvider)
                              .markAsSettled(debt.id);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'PAYABLE'; // Default: Hutang

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Catat Utang/Piutang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'PAYABLE',
                        label: Text('Saya Ngutang'),
                      ),
                      ButtonSegment(
                        value: 'RECEIVABLE',
                        label: Text('Saya Ngutangin'),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Orang/Pihak',
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
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
                    final amount =
                        double.tryParse(amountController.text) ?? 0.0;

                    if (name.isNotEmpty && amount > 0) {
                      ref
                          .read(debtRepositoryProvider)
                          .addDebt(
                            personName: name,
                            amount: amount,
                            type: selectedType,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
