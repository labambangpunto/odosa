import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_provider.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'EXPENSE';
  int? _fromAccountId;
  int? _toAccountId;
  final DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final note = _noteController.text.trim();
    final repo = ref.read(transactionRepositoryProvider);

    try {
      if (_transactionType == 'INCOME') {
        if (_toAccountId == null) {
          throw Exception('Pilih akun tujuan');
        }
        await repo.addIncome(
          amount: amount,
          accountId: _toAccountId!,
          categoryId: 1,
          date: _selectedDate,
          note: note,
        );
      } else if (_transactionType == 'EXPENSE') {
        if (_fromAccountId == null) {
          throw Exception('Pilih akun sumber');
        }
        await repo.addExpense(
          amount: amount,
          accountId: _fromAccountId!,
          categoryId: 2,
          date: _selectedDate,
          note: note,
        );
      } else if (_transactionType == 'TRANSFER') {
        if (_fromAccountId == null || _toAccountId == null) {
          throw Exception('Pilih akun sumber dan tujuan');
        }
        if (_fromAccountId == _toAccountId) {
          throw Exception('Akun sumber dan tujuan tidak boleh sama');
        }
        await repo.addTransfer(
          amount: amount,
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          date: _selectedDate,
          note: note,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catat Transaksi')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                'Harap tambahkan dompet/bank terlebih dahulu di halaman utama.',
              ),
            );
          }

          final accountItems = accounts
              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
              .toList();

          _fromAccountId ??= accounts.first.id;
          _toAccountId ??= accounts.first.id;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'INCOME', label: Text('Pemasukan')),
                    ButtonSegment(value: 'EXPENSE', label: Text('Pengeluaran')),
                    ButtonSegment(value: 'TRANSFER', label: Text('Mutasi')),
                  ],
                  selected: {_transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _transactionType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nominal wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                if (_transactionType == 'EXPENSE' ||
                    _transactionType == 'TRANSFER')
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Dari Dompet/Bank',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _fromAccountId,
                    items: accountItems,
                    onChanged: (val) => setState(() => _fromAccountId = val),
                  ),

                if (_transactionType == 'TRANSFER') const SizedBox(height: 16),

                if (_transactionType == 'INCOME' ||
                    _transactionType == 'TRANSFER')
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Ke Dompet/Bank',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _toAccountId,
                    items: accountItems,
                    onChanged: (val) => setState(() => _toAccountId = val),
                  ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saveTransaction,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Transaksi'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
