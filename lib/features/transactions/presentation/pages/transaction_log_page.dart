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
  late Stream<List<Transaction>> _transactionStream;

  DateTime _selectedDate = DateTime.now();
  String? _selectedAccount;
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _updateStream();
  }

  void _updateStream() {
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      23,
      59,
      59,
      999,
    );

    final query = _db.select(_db.transactions)
      ..orderBy([
        (t) => drift.OrderingTerm(
          expression: t.transactionDate,
          mode: drift.OrderingMode.desc,
        ),
      ]);

    query.where((t) {
      var expr = t.transactionDate.isBetweenValues(startOfDay, endOfDay);

      if (_selectedAccount != null && _selectedAccount!.isNotEmpty) {
        expr =
            expr &
            (t.sourceAccount.equals(_selectedAccount!) |
                t.destinationAccount.equals(_selectedAccount!));
      }

      if (_selectedLabel != null && _selectedLabel!.isNotEmpty) {
        expr = expr & t.labels.like('%$_selectedLabel%');
      }

      return expr;
    });

    setState(() {
      _transactionStream = query.watch();
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _updateStream();
    }
  }

  Future<void> _showFilterModal() async {
    final accounts = await _db.select(_db.accounts).get();
    final labels = await _db.select(_db.labels).get();

    if (!mounted) return;

    String? tempAccount = _selectedAccount;
    String? tempLabel = _selectedLabel;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: tempAccount,
                  decoration: const InputDecoration(
                    labelText: 'Berdasarkan Akun',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Akun'),
                    ),
                    ...accounts.map(
                      (a) =>
                          DropdownMenuItem(value: a.name, child: Text(a.name)),
                    ),
                  ],
                  onChanged: (val) => setModalState(() => tempAccount = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: tempLabel,
                  decoration: const InputDecoration(
                    labelText: 'Berdasarkan Label',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Label'),
                    ),
                    ...labels.map(
                      (l) =>
                          DropdownMenuItem(value: l.name, child: Text(l.name)),
                    ),
                  ],
                  onChanged: (val) => setModalState(() => tempLabel = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedAccount = tempAccount;
                        _selectedLabel = tempLabel;
                      });
                      _updateStream();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive =
        _selectedAccount != null || _selectedLabel != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _showFilterModal,
                  icon: Icon(
                    isFilterActive ? Icons.filter_list_alt : Icons.filter_list,
                    color: isFilterActive ? Colors.blue : Colors.black87,
                  ),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: _transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  _logger.e('Error stream transaksi', error: snapshot.error);
                  return const Center(child: Text('Gagal memuat transaksi'));
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada transaksi pada tanggal ini.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isIncome = tx.type == 'income';
                    final isExpense = tx.type == 'expense';
                    final isTransfer = tx.type == 'transfer';

                    Color amountColor;
                    String prefix = '';
                    String accountInfo = '';

                    if (isIncome) {
                      amountColor = Colors.green;
                      prefix = '+';
                      accountInfo = 'Ke: ${tx.destinationAccount ?? "-"}';
                    } else if (isExpense) {
                      amountColor = Colors.red;
                      prefix = '-';
                      accountInfo = 'Dari: ${tx.sourceAccount ?? "-"}';
                    } else {
                      amountColor = Colors.blue;
                      accountInfo =
                          '${tx.sourceAccount ?? "-"} ➔ ${tx.destinationAccount ?? "-"}';
                    }

                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Hapus Transaksi"),
                              content: const Text(
                                "Apakah Anda yakin ingin menghapus transaksi ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _deleteTransaction(tx.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nominal & Deskripsi (Kiri)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6.0,
                                        children: [
                                          Text(
                                            '$prefix Rp ${NumberFormat('#,###').format(tx.amount)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: amountColor,
                                            ),
                                          ),
                                          // Tampilkan kuantitas hanya untuk pengeluaran (jika qty > 1)
                                          if (isExpense && tx.qty > 1)
                                            Text(
                                              'x${tx.qty}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          // Tampilkan biaya tambahan/admin untuk pengeluaran dan transfer
                                          if ((isExpense || isTransfer) &&
                                              tx.fee != null &&
                                              tx.fee! > 0)
                                            Text(
                                              '(+ Rp ${NumberFormat('#,###').format(tx.fee)})',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (tx.note != null &&
                                          tx.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          tx.note!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Akun & Jam (Kanan)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          accountInfo,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('HH:mm')
                                              .format(tx.transactionDate),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Label Capsule (Bawah)
                            if (tx.labels.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: tx.labels.split(',').map((label) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      label.trim(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
