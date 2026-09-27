import 'package:flutter/material.dart';

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';

import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

import 'package:flutter/services.dart';

class TransferForm extends StatefulWidget {
  final Transaction? transaction;
  const TransferForm({super.key, this.transaction});

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  String? _sourceAccount;
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

      final amount = double.parse(_amountController.text.replaceAll('.', ''));
      final fee =
          double.tryParse(_feeController.text.replaceAll('.', '')) ?? 0.0;
      final totalDeduction = amount + fee;

      final currentBalance = await db.getCalculatedBalance(_sourceAccount!);
      final oldDeduction = widget.transaction != null
          ? widget.transaction!.amount + (widget.transaction!.fee ?? 0)
          : 0.0;
      final availableBalance = currentBalance + oldDeduction;

      if (availableBalance < totalDeduction) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo akun sumber tidak mencukupi!')),
          );
        }
        return;
      }

      if (widget.transaction == null) {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'transfer',
                amount: amount,
                fee: drift.Value(fee > 0 ? fee : null),
                sourceAccount: drift.Value(_sourceAccount),
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
            fee: drift.Value(fee > 0 ? fee : null),
            sourceAccount: drift.Value(_sourceAccount),
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
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Nominal Transfer',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Biaya Admin (Opsional)',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Sumber',
            value: _sourceAccount,
            onChanged: (val) => setState(() => _sourceAccount = val),
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
            onTap: () async {
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
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            maxLength: 150,
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
            child: Text(
              widget.transaction == null ? 'Simpan Transfer' : 'Simpan Update',
            ),
          ),
        ],
      ),
    );
  }
}
