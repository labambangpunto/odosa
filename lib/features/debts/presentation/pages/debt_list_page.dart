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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _db = AppDatabase(); // Mengambil instance Singleton
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

  Widget _buildDebtList(String type) {
    return StreamBuilder<List<Debt>>(
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

            return ListTile(
              leading: CircleAvatar(
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
                        color: debt.isSettled ? Colors.green : Colors.orange,
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
              onTap: () {
                if (!debt.isSettled) {
                  SettlementSheet.show(
                    context,
                    debtType: type,
                    amount: debt.amount,
                    onSuccess: (accountName, settlementDate) async {
                      // Jika melunasi utang, cek apakah saldo cukup
                      if (type == 'payable') {
                        final currentBalance = await _db.getCalculatedBalance(
                          accountName,
                        );
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

                      // Eksekusi Update ke Database
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utang & Piutang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Piutang (Uang Masuk)'),
            Tab(text: 'Utang (Uang Keluar)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDebtList('receivable'), _buildDebtList('payable')],
      ),
    );
  }
}
