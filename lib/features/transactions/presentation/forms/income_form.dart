import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';
import '../../models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class IncomeForm extends StatefulWidget {
  final Transaction? transaction;
  const IncomeForm({super.key, this.transaction});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _destinationAccount;
  List<String> _labels = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      final formatter = NumberFormat('#,###', 'en_US');

      _amountController.text = formatter.format(tx.amount).replaceAll(',', '.');
      _destinationAccount = tx.destinationAccount;
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

      if (widget.transaction == null) {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'income',
                amount: amount,
                destinationAccount: drift.Value(_destinationAccount),
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
            destinationAccount: drift.Value(_destinationAccount),
            labels: drift.Value(_labels.join(',')),
            transactionDate: drift.Value(_selectedDate),
            note: drift.Value(_noteController.text),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
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
