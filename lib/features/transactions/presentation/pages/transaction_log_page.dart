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

  final Set<int> _selectedTransactions = {};

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

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedTransactions.contains(id)) {
        _selectedTransactions.remove(id);
      } else {
        if (_selectedTransactions.length >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal 4 transaksi untuk dihapus sekaligus'),
            ),
          );
          return;
        }
        _selectedTransactions.add(id);
      }
    });
  }

  Future<void> _deleteSelectedTransactions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Transaksi"),
        content: Text(
          "Yakin ingin menghapus ${_selectedTransactions.length} transaksi ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await (_db.delete(
        _db.transactions,
      )..where((t) => t.id.isIn(_selectedTransactions))).go();
      setState(() {
        _selectedTransactions.clear();
      });
    }
  }

  // ... (Pertahankan _pickDate dan _showFilterModal persis seperti sebelumnya)
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

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive =
        _selectedAccount != null || _selectedLabel != null;
    final bool isSelectionMode = _selectedTransactions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedTransactions.clear()),
              )
            : null,
        title: Text(
          isSelectionMode
              ? '${_selectedTransactions.length} dipilih'
              : 'Log Transaksi',
        ),
        backgroundColor: isSelectionMode
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: isSelectionMode
            ? [
                if (_selectedTransactions.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Transaksi',
                    onPressed: () async {
                      final id = _selectedTransactions.first;
                      final tx = await (_db.select(
                        _db.transactions,
                      )..where((t) => t.id.equals(id))).getSingle();

                      if (!context.mounted) return;
                      setState(
                        () => _selectedTransactions.clear(),
                      ); // Bersihkan seleksi

                      // Arahkan ke form yang sesuai
                      Widget formWidget;
                      String title;
                      if (tx.type == 'expense') {
                        formWidget = ExpenseForm(
                          transaction: tx,
                        ); // Perlu penambahan parameter di form
                        title = 'Edit Pengeluaran';
                      } else if (tx.type == 'income') {
                        formWidget = IncomeForm(transaction: tx);
                        title = 'Edit Pemasukan';
                      } else {
                        formWidget = TransferForm(transaction: tx);
                        title = 'Edit Transfer';
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: Text(title)),
                            body: formWidget,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus Transaksi',
                  onPressed: _deleteSelectedTransactions,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (!isSelectionMode)
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
                      isFilterActive
                          ? Icons.filter_list_alt
                          : Icons.filter_list,
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
                    final isSelected = _selectedTransactions.contains(tx.id);

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

                    return InkWell(
                      onLongPress: () => _toggleSelection(tx.id),
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(tx.id);
                        }
                      },
                      child: Container(
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.1)
                            : null,
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSelectionMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (val) => _toggleSelection(tx.id),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                                if (isExpense && tx.qty > 1)
                                                  Text(
                                                    'x${tx.qty}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                if ((isExpense || isTransfer) &&
                                                    tx.fee != null &&
                                                    tx.fee! > 0)
                                                  Text(
                                                    '(+ Rp ${NumberFormat('#,###').format(tx.fee)})',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.redAccent,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                  if (tx.labels.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: tx.labels.split(',').map((
                                        label,
                                      ) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
