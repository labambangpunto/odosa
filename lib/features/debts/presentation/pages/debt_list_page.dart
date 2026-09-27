import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../../transactions/models/transaction_model.dart';
import '../widgets/settlement_sheet.dart';

class DebtListPage extends StatefulWidget {
  const DebtListPage({super.key});

  @override
  State<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends State<DebtListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AppDatabase _db;

  final Set<int> _selectedDebts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _db = AppDatabase();

    // Hapus seleksi jika tab berganti
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _selectedDebts.isNotEmpty) {
        setState(() => _selectedDebts.clear());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Debt>> _watchDebts(String type) {
    return (_db.select(_db.debts)
          ..where((d) => d.type.equals(type))
          ..orderBy([
            (d) => drift.OrderingTerm(
              expression: d.transactionDate,
              mode: drift.OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedDebts.contains(id)) {
        _selectedDebts.remove(id);
      } else {
        if (_selectedDebts.length >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Maksimal 4 data utang/piutang untuk dihapus sekaligus',
              ),
            ),
          );
          return;
        }
        _selectedDebts.add(id);
      }
    });
  }

  Future<void> _deleteSelectedDebts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Catatan"),
        content: Text(
          "Yakin ingin menghapus ${_selectedDebts.length} catatan ini?",
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
        _db.debts,
      )..where((d) => d.id.isIn(_selectedDebts))).go();
      setState(() {
        _selectedDebts.clear();
      });
    }
  }

  Widget _buildDebtList(String type) {
    final isPayable = type == 'payable';
    final descriptionText = isPayable
        ? 'Anda meminta pinjaman dari orang lain → Anda harus memberi pembayaran'
        : 'Anda memberi pinjaman kepada orang lain → Anda harus menerima pembayaran';
    final isSelectionMode = _selectedDebts.isNotEmpty;

    return Column(
      children: [
        if (!isSelectionMode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: Colors.blue.withValues(alpha: 0.05),
            child: Text(
              descriptionText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: StreamBuilder<List<Debt>>(
            stream: _watchDebts(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat catatan utang/piutang.'),
                );
              }

              final debts = snapshot.data ?? [];

              if (debts.isEmpty) {
                return const Center(child: Text('Tidak ada catatan.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 120, top: 8),
                itemCount: debts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  final isReceivable = type == 'receivable';
                  final isSelected = _selectedDebts.contains(debt.id);

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    onLongPress: () => _toggleSelection(debt.id),
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(debt.id);
                      } else if (!debt.isSettled) {
                        SettlementSheet.show(
                          context,
                          debtType: type,
                          amount: debt.amount,
                          onSuccess: (accountName, settlementDate) async {
                            if (type == 'payable') {
                              final currentBalance = await _db
                                  .getCalculatedBalance(accountName);
                              if (currentBalance < debt.amount) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Saldo akun tidak mencukupi untuk pelunasan!',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }
                            }

                            await (_db.update(
                              _db.debts,
                            )..where((d) => d.id.equals(debt.id))).write(
                              DebtsCompanion(
                                isSettled: const drift.Value(true),
                                settlementAccount: drift.Value(accountName),
                                settlementDate: drift.Value(settlementDate),
                              ),
                            );
                          },
                        );
                      }
                    },
                    leading: isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (val) => _toggleSelection(debt.id),
                          )
                        : CircleAvatar(
                            backgroundColor: isReceivable
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            child: Icon(
                              isReceivable
                                  ? Icons.arrow_circle_right_outlined
                                  : Icons.arrow_circle_left_outlined,
                              color: isReceivable ? Colors.green : Colors.red,
                            ),
                          ),
                    title: Text(
                      debt.contact,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          debt.dueDate != null
                              ? 'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(debt.dueDate!)}'
                              : 'Tanpa tenggat waktu',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: debt.isSettled
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            debt.isSettled ? 'Lunas' : 'Belum Lunas',
                            style: TextStyle(
                              fontSize: 11,
                              color: debt.isSettled
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'Rp ${NumberFormat('#,###').format(debt.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isReceivable ? Colors.green : Colors.red,
                      ),
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = _selectedDebts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedDebts.clear()),
              )
            : null,
        title: Text(
          isSelectionMode
              ? '${_selectedDebts.length} dipilih'
              : 'Utang & Piutang',
        ),
        backgroundColor: isSelectionMode
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: isSelectionMode
            ? [
                if (_selectedDebts.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final id = _selectedDebts.first;
                      final debt = await (_db.select(
                        _db.debts,
                      )..where((d) => d.id.equals(id))).getSingle();

                      if (!context.mounted) return;
                      setState(() => _selectedDebts.clear());

                      Widget formWidget;
                      String title;
                      if (debt.type == 'payable') {
                        formWidget = PayableForm(
                          debt: debt,
                        ); // Perlu penambahan parameter di form
                        title = 'Edit Utang';
                      } else {
                        formWidget = ReceivableForm(debt: debt);
                        title = 'Edit Piutang';
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
                  tooltip: 'Hapus',
                  onPressed: _deleteSelectedDebts,
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Utang'),
            Tab(text: 'Piutang'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDebtList('payable'), _buildDebtList('receivable')],
      ),
    );
  }
}
