import 'package:flutter/material.dart';

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';

import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../models/transaction_model.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();
      try {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'expense',
                amount: double.parse(_amountController.text),
                fee: drift.Value(double.tryParse(_feeController.text)),
                qty: drift.Value(int.tryParse(_qtyController.text) ?? 1),
                sourceAccount: drift.Value(_sourceAccount),
                labels: _labels.join(','),
                transactionDate: _selectedDate,
                note: drift.Value(_noteController.text),
              ),
            );
        if (mounted) Navigator.pop(context); // Menutup form setelah berhasil
      } finally {
        await db.close();
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
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal Utama',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Biaya Tambahan (Opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kuantitas (Qty)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Sumber',
            value: _sourceAccount,
            onChanged: (val) => setState(() => _sourceAccount = val),
          ),
          const SizedBox(height: 16),
          LabelChipInput(
            selectedLabels: _labels,
            onChanged: (val) => setState(() => _labels = val),
            validator: (val) =>
                val == null || val.isEmpty ? 'Minimal 1 label' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            title: const Text('Tanggal & Waktu'),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(_selectedDate),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDateTime(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan/Deskripsi',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Simpan Pengeluaran'),
          ),
        ],
      ),
    );
  }
}
