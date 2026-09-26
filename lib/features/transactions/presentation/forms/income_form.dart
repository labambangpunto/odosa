import 'package:flutter/material.dart';

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';

import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../models/transaction_model.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

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
                type: 'income',
                amount: double.parse(_amountController.text),
                destinationAccount: drift.Value(_destinationAccount),
                labels: _labels.join(','),
                transactionDate: _selectedDate,
                note: drift.Value(_noteController.text),
              ),
            );
        if (mounted) Navigator.pop(context);
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
              labelText: 'Nominal',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Tujuan',
            value: _destinationAccount,
            onChanged: (val) => setState(() => _destinationAccount = val),
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
              labelText: 'Catatan/Deskripsi (Opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Simpan Pemasukan'),
          ),
        ],
      ),
    );
  }
}
