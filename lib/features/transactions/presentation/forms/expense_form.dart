import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';
import '../../models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpenseForm extends StatefulWidget {
  // 1. Tambahkan parameter opsional untuk menampung data dari log
  final Transaction? transaction;

  const ExpenseForm({super.key, this.transaction});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  String? _sourceAccount;
  List<String> _labels = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 2. Jika ada data (Mode Edit), isi semua controller dan variabel
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      final formatter = NumberFormat('#,###', 'en_US');

      _amountController.text = formatter.format(tx.amount).replaceAll(',', '.');
      if (tx.fee != null && tx.fee! > 0) {
        _feeController.text = formatter.format(tx.fee).replaceAll(',', '.');
      }
      _qtyController.text = tx.qty.toString();
      _sourceAccount = tx.sourceAccount;
      _labels = tx.labels.isNotEmpty ? tx.labels.split(',') : [];
      _selectedDate = tx.transactionDate;
      _noteController.text = tx.note ?? '';
    }
  }

  // ... (Pertahankan _selectDateTime seperti biasa)

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();

      final amount = double.parse(_amountController.text.replaceAll('.', ''));
      final fee =
          double.tryParse(_feeController.text.replaceAll('.', '')) ?? 0.0;
      final qty = int.tryParse(_qtyController.text) ?? 1;

      final totalDeduction = (amount * qty) + fee;

      // 3. Logika Kalkulasi Saldo (Termasuk Refund Virtual saat Mode Edit)
      final currentBalance = await db.getCalculatedBalance(_sourceAccount!);
      final oldDeduction = widget.transaction != null
          ? (widget.transaction!.amount * widget.transaction!.qty) +
                (widget.transaction!.fee ?? 0)
          : 0.0;

      final availableBalance = currentBalance + oldDeduction;

      if (availableBalance < totalDeduction) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo akun tidak mencukupi!')),
          );
        }
        return;
      }

      // 4. Pisahkan aksi Insert (Baru) dan Update (Edit)
      if (widget.transaction == null) {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'expense',
                amount: amount,
                fee: drift.Value(fee > 0 ? fee : null),
                qty: drift.Value(qty),
                sourceAccount: drift.Value(_sourceAccount),
                labels: _labels.join(','),
                transactionDate: _selectedDate,
                note: drift.Value(_noteController.text),
              ),
            );
      } else {
        await (db.update(
          db.transactions,
        )..where((t) => t.id.equals(widget.transaction!.id))).write(
          TransactionsCompanion(
            amount: drift.Value(amount),
            fee: drift.Value(fee > 0 ? fee : null),
            qty: drift.Value(qty),
            sourceAccount: drift.Value(_sourceAccount),
            labels: drift.Value(_labels.join(',')),
            transactionDate: drift.Value(_selectedDate),
            note: drift.Value(_noteController.text),
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (Widget fields sama seperti sebelumnya)

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            // 5. Ubah teks tombol secara dinamis
            child: Text(
              widget.transaction == null
                  ? 'Simpan Pengeluaran'
                  : 'Simpan Update',
            ),
          ),
        ],
      ),
    );
  }
}
