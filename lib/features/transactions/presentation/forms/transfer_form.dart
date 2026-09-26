import 'package:flutter/material.dart';

import '../widgets/account_dropdown.dart';
import '../widgets/label_chip_input.dart';

import 'package:intl/intl.dart';

class TransferForm extends StatefulWidget {
  const TransferForm({super.key});

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Simpan Transfer: ${_amountController.text}');
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Asal',
            value: _sourceAccount,
            onChanged: (val) => setState(() => _sourceAccount = val),
          ),
          const SizedBox(height: 16),
          AccountDropdown(
            label: 'Akun Tujuan',
            value: _destinationAccount,
            onChanged: (val) => setState(() => _destinationAccount = val),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Pilih Akun Tujuan';
              }
              if (val == _sourceAccount) {
                return 'Akun asal dan tujuan tidak boleh sama';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Biaya Admin (Opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          LabelChipInput(
            selectedLabels: _labels,
            onChanged: (val) => setState(() => _labels = val),
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
            child: const Text('Simpan Transfer'),
          ),
        ],
      ),
    );
  }
}
